import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'app_firebase.dart';
import 'navigation.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'info' | 'warning' | 'danger' | 'success'
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory AppNotification.fromMap(String id, Map<dynamic, dynamic> map) {
    return AppNotification(
      id: id,
      title: map['title']?.toString() ?? 'Notifikasi',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'info',
      isRead: map['isRead'] == true,
      createdAt: map['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class NotificationService {
  static const _path = 'devices/main/notifications';

  static DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref(_path);

  /// Stream semua notifikasi, diurutkan terbaru dulu
  static Stream<List<AppNotification>> stream() {
    return Stream.fromFuture(AppFirebase.ensureInitialized())
        .asyncExpand((_) => _ref.onValue)
        .map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <AppNotification>[];

      final list = <AppNotification>[];
      for (final entry in value.entries) {
        final v = entry.value;
        if (v is Map) {
          list.add(AppNotification.fromMap(entry.key.toString(), v));
        }
      }

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Tandai satu notifikasi sebagai dibaca
  static Future<void> markAsRead(String id) async {
    await AppFirebase.ensureInitialized();
    await _ref.child(id).update({'isRead': true});
  }

  /// Tandai semua sebagai dibaca
  static Future<void> markAllAsRead(List<AppNotification> notifs) async {
    await AppFirebase.ensureInitialized();
    final updates = <String, dynamic>{};
    for (final n in notifs) {
      if (!n.isRead) updates['$_path/${n.id}/isRead'] = true;
    }
    if (updates.isNotEmpty) {
      await FirebaseDatabase.instance.ref().update(updates);
    }
  }

  /// Hapus satu notifikasi
  static Future<void> delete(String id) async {
    await AppFirebase.ensureInitialized();
    await _ref.child(id).remove();
  }

  /// Hapus semua notifikasi
  static Future<void> deleteAll() async {
    await AppFirebase.ensureInitialized();
    await _ref.remove();
  }

  /// Tambah notifikasi baru (dipakai ESP32 atau seed)
  static Future<void> add({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    await AppFirebase.ensureInitialized();
    final newRef = _ref.push();
    await newRef.set({
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': ServerValue.timestamp,
    });
  }

  /// Seed data notifikasi contoh jika kosong
  static Future<void> seedIfEmpty() async {
    await AppFirebase.ensureInitialized();
    final snap = await _ref.get();
    if (snap.exists) return;

    final now = DateTime.now();
    final samples = [
      {
        'title': 'Baterai Rendah',
        'message': 'Level baterai tersisa 18%. Segera periksa sumber daya panel surya.',
        'type': 'danger',
        'isRead': false,
        'createdAt': now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
      },
      {
        'title': 'Suhu Perangkat Tinggi',
        'message': 'Suhu mencapai 38°C. Pastikan ventilasi perangkat tidak terhalang.',
        'type': 'warning',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      },
      {
        'title': 'Relay 2 Diaktifkan',
        'message': 'Stop Kontak 2 berhasil diaktifkan oleh pengguna.',
        'type': 'success',
        'isRead': true,
        'createdAt': now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch,
      },
      {
        'title': 'Koneksi Pulih',
        'message': 'Perangkat kembali online setelah terputus selama 2 menit.',
        'type': 'info',
        'isRead': true,
        'createdAt': now.subtract(const Duration(hours: 6)).millisecondsSinceEpoch,
      },
    ];

    final updates = <String, dynamic>{};
    for (final s in samples) {
      final key = _ref.push().key!;
      updates['$_path/$key'] = s;
    }
    await FirebaseDatabase.instance.ref().update(updates);
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'semua'; // 'semua' | 'belum' | 'sudah'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      final filters = ['semua', 'belum', 'sudah'];
      setState(() => _filter = filters[_tabController.index]);
    });
    NotificationService.seedIfEmpty();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> _applyFilter(List<AppNotification> all) {
    if (_filter == 'belum') return all.where((n) => !n.isRead).toList();
    if (_filter == 'sudah') return all.where((n) => n.isRead).toList();
    return all;
  }

  Future<void> _confirmDeleteAll(List<AppNotification> all) async {
    if (all.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Semua?',
          style: TextStyle(fontWeight: FontWeight.w800, color: _NC.text),
        ),
        content: const Text(
          'Semua notifikasi akan dihapus permanen.',
          style: TextStyle(color: _NC.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: _NC.mutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) await NotificationService.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: NotificationService.stream(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final filtered = _applyFilter(all);
        final unreadCount = all.where((n) => !n.isRead).length;

        return Scaffold(
          backgroundColor: _NC.background,
          body: Stack(
            children: [
              // ─ Header gradient background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.28,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0B5E1F), Color(0xFF1B8A3B)],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, all, unreadCount),
                    _buildTabBar(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildList(filtered, all),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
        );
      },
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, List<AppNotification> all, int unread) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Tandai semua dibaca
              if (all.any((n) => !n.isRead))
                TextButton.icon(
                  onPressed: () => NotificationService.markAllAsRead(all),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Baca Semua',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              // Hapus semua
              IconButton(
                tooltip: 'Hapus semua',
                onPressed: () => _confirmDeleteAll(all),
                icon: const Icon(Icons.delete_sweep_outlined,
                    color: Colors.white70, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Summary card
          _buildSummaryCard(all, unread),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<AppNotification> all, int unread) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              _summaryChip(
                icon: Icons.notifications_active_outlined,
                label: 'Belum Dibaca',
                value: unread.toString(),
                color: const Color(0xFFFFB800),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 36, color: Colors.white24),
              const SizedBox(width: 12),
              _summaryChip(
                icon: Icons.mark_email_read_outlined,
                label: 'Total',
                value: all.length.toString(),
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: unread > 0
                      ? const Color(0xFFFFB800).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: unread > 0
                        ? const Color(0xFFFFB800).withValues(alpha: 0.4)
                        : Colors.white24,
                  ),
                ),
                child: Text(
                  unread > 0 ? '$unread baru' : 'Semua terbaca',
                  style: TextStyle(
                    color: unread > 0 ? const Color(0xFFFFB800) : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // ─── Tab Bar ────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: _NC.primaryDark,
        unselectedLabelColor: _NC.mutedText,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Belum Dibaca'),
          Tab(text: 'Sudah Dibaca'),
        ],
      ),
    );
  }

  // ─── List ───────────────────────────────────────────────────────────────

  Widget _buildList(
      List<AppNotification> filtered, List<AppNotification> all) {
    if (filtered.isEmpty) {
      return _buildEmpty();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _NotificationTile(
          key: ValueKey(filtered[index].id),
          notification: filtered[index],
          onRead: () => NotificationService.markAsRead(filtered[index].id),
          onDelete: () => NotificationService.delete(filtered[index].id),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined,
                color: Color(0xFF4CAF50), size: 44),
          ),
          const SizedBox(height: 20),
          const Text('Tidak ada notifikasi',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _NC.text)),
          const SizedBox(height: 8),
          const Text('Semua aktivitas perangkat\nakan muncul di sini.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: _NC.mutedText, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Notification Tile ───────────────────────────────────────────────────────

class _NotificationTile extends StatefulWidget {
  const _NotificationTile({
    super.key,
    required this.notification,
    required this.onRead,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onRead;
  final VoidCallback onDelete;

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (widget.notification.type) {
      case 'danger':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'success':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF0284C7);
    }
  }

  IconData get _typeIcon {
    switch (widget.notification.type) {
      case 'danger':
        return Icons.error_outline_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notif = widget.notification;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dismissible(
          key: ValueKey(notif.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 26),
                SizedBox(height: 4),
                Text('Hapus',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          onDismissed: (_) => widget.onDelete(),
          child: GestureDetector(
            onTap: notif.isRead ? null : widget.onRead,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: notif.isRead ? Colors.white : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: notif.isRead
                      ? const Color(0xFFE5E7EB)
                      : _typeColor.withValues(alpha: 0.25),
                  width: notif.isRead ? 1 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: notif.isRead ? 0.03 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(_typeIcon, color: _typeColor, size: 22),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: notif.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: _NC.text,
                                  ),
                                ),
                              ),
                              // Unread dot
                              if (!notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _typeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: notif.isRead
                                  ? _NC.mutedText
                                  : const Color(0xFF374151),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 11, color: _NC.mutedText),
                              const SizedBox(width: 4),
                              Text(
                                _timeAgo(notif.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: _NC.mutedText),
                              ),
                              const Spacer(),
                              // Action buttons
                              if (!notif.isRead)
                                _ActionChip(
                                  label: 'Tandai Dibaca',
                                  icon: Icons.done,
                                  color: _NC.primary,
                                  onTap: widget.onRead,
                                ),
                              const SizedBox(width: 6),
                              _ActionChip(
                                label: 'Hapus',
                                icon: Icons.delete_outline,
                                color: Colors.redAccent,
                                onTap: widget.onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Colors ──────────────────────────────────────────────────────────────────

class _NC {
  static const Color primary = Color(0xFF12A73B);
  static const Color primaryDark = Color(0xFF087A2B);
  static const Color background = Color(0xFFF4F7F5);
  static const Color text = Color(0xFF17201A);
  static const Color mutedText = Color(0xFF697586);
}
