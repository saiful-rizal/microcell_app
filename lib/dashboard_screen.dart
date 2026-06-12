import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // HEADER
              Stack(
                clipBehavior: Clip.none,
                children: [

                  Container(
                    height: 230,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/bg.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Container(
                    height: 230,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.only(
                        bottomLeft:
                            Radius.circular(40),
                        bottomRight:
                            Radius.circular(40),
                      ),
                      color: Colors.black.withOpacity(
                        0.45,
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [

                        Row(
                          children: [

                            const CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  AssetImage(
                                "assets/images/profile.jpg",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: const [

                                Text(
                                  "Haii 👋",
                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                  ),
                                ),

                                Text(
                                  "Budiono",
                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Stack(
                          children: [

                            Container(
                              width: 45,
                              height: 45,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    Color(0xFF2E7D32),
                                shape:
                                    BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons
                                    .notifications_none,
                                color:
                                    Colors.white,
                              ),
                            ),

                            Positioned(
                              top: 8,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration:
                                    const BoxDecoration(
                                  color: Colors.red,
                                  shape:
                                      BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // CARD CUACA
                  Positioned(
                    bottom: -50,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding:
                          const EdgeInsets.all(18),
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF7E8A08),
                            Color(0xFF9E9E9E),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: const [

                          Text(
                            "Kamis, Bangsalsari, Kabupaten Jember",
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 13,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "35°C",
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 42,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            "Cuaca Berawan",
                            style: TextStyle(
                              color:
                                  Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),

              // BATTERY
              Container(
                width: 260,
                height: 260,
                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF95D600),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration:
                        const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF95D600),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: const [

                        Text(
                          "Daya Baterai",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 18,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "85%",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 58,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Arus      Tegangan",
                          style: TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),

                        Text(
                          "1,2 A     12,5 V",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration:
                      const BoxDecoration(
                    color: Color(0xFF006B1B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.yellow,
                    size: 32,
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [

                    sensorCard(
                      Icons.thermostat,
                      "Suhu",
                      "15 °C",
                    ),

                    sensorCard(
                      Icons.water_drop,
                      "Kelembapan",
                      "75 %",
                    ),

                    sensorCard(
                      Icons.bolt,
                      "Tegangan AC",
                      "220 V",
                    ),

                    sensorCard(
                      Icons.wb_sunny,
                      "Intensitas Cahaya",
                      "570 Lux",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // NAVBAR
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [

            IconButton(
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                });
              },
              icon: Icon(
                Icons.home,
                color: currentIndex == 0
                    ? const Color(0xFF00B320)
                    : Colors.grey,
                size: 30,
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: 60,
                height: 60,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFF006B1B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },
              icon: Icon(
                Icons.person,
                color: currentIndex == 2
                    ? const Color(0xFF00B320)
                    : Colors.grey,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sensorCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFD7F0CE),
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [

          Icon(
            icon,
            size: 32,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}