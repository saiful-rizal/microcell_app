#include <WiFi.h>
#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Define WiFi credentials
#define WIFI_SSID "NAMA_WIFI_KAMU"
#define WIFI_PASSWORD "PASSWORD_WIFI_KAMU"

// Define Firebase Configuration
#define API_KEY "AIzaSyB9iqiqEOnWhp5tHJcWvvo1l0iS_SXHRVI"
#define DATABASE_URL "https://microcellapp-default-rtdb.firebaseio.com"

// Define User Email and Password (buat satu akun khusus di Firebase Auth untuk ESP32 ini)
#define USER_EMAIL "esp32@microcell.com"
#define USER_PASSWORD "passwordesp32"

// Pin Definisi Relay (sesuaikan dengan wiring ESP32 kamu)
#define RELAY1_PIN 23
#define RELAY2_PIN 22
#define RELAY3_PIN 21

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
const long interval = 5000; // Update data setiap 5 detik

// Dummy variabel sensor
float temperature = 28.5;
float humidity = 65.0;
float batteryLevel = 85.0;
float current = 1.2;
float voltage = 12.5;
float acVoltage = 220.0;
float lightIntensity = 500.0;

void setup() {
  Serial.begin(115200);

  // Setup Pin Mode
  pinMode(RELAY1_PIN, OUTPUT);
  pinMode(RELAY2_PIN, OUTPUT);
  pinMode(RELAY3_PIN, OUTPUT);

  // Matikan semua relay di awal (asumsikan relay active LOW)
  digitalWrite(RELAY1_PIN, HIGH);
  digitalWrite(RELAY2_PIN, HIGH);
  digitalWrite(RELAY3_PIN, HIGH);

  // Koneksi WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

  // Setup Firebase
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // Setup Firebase Autentikasi
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Callback untuk token generation (opsional tapi disarankan)
  config.token_status_callback = tokenStatusCallback;

  // Mulai koneksi Firebase
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Jika Firebase sudah siap dan sudah waktunya update data
  if (Firebase.ready() && (millis() - sendDataPrevMillis > interval || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();

    // 1. UPLOAD DATA STATUS SENSOR (Gunakan sensor asli untuk aplikasi nyata)
    // Di sini kita membuat dummy nilai acak sedikit agar terlihat realtime
    temperature += random(-5, 6) / 10.0; 
    
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/temperature", temperature);
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/humidity", humidity);
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/batteryLevel", batteryLevel);
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/current", current);
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/voltage", voltage);
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/acVoltage", acVoltage);
    Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/lightIntensity", lightIntensity);
    
    // Catat waktu update
    // Firebase.RTDB.setTimestamp(&fbdo, "/devices/main/status/updatedAt"); // Jika butuh timestamp

    Serial.println("Data sensor diupdate ke Firebase!");

    // 2. BACA DATA RELAY DARI FIREBASE
    if (Firebase.RTDB.getBool(&fbdo, "/devices/main/relays/relay1")) {
      bool r1 = fbdo.boolData();
      digitalWrite(RELAY1_PIN, r1 ? LOW : HIGH); // LOW jika ON, HIGH jika OFF (sesuaikan jenis relay)
      Serial.print("Relay 1: "); Serial.println(r1 ? "ON" : "OFF");
    }

    if (Firebase.RTDB.getBool(&fbdo, "/devices/main/relays/relay2")) {
      bool r2 = fbdo.boolData();
      digitalWrite(RELAY2_PIN, r2 ? LOW : HIGH);
      Serial.print("Relay 2: "); Serial.println(r2 ? "ON" : "OFF");
    }

    if (Firebase.RTDB.getBool(&fbdo, "/devices/main/relays/relay3")) {
      bool r3 = fbdo.boolData();
      digitalWrite(RELAY3_PIN, r3 ? LOW : HIGH);
      Serial.print("Relay 3: "); Serial.println(r3 ? "ON" : "OFF");
    }
  }
}
