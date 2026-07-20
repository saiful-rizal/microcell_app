#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

//====================================================
// WIFI
//====================================================
#define WIFI_SSID      "Kos Nias 5G"
#define WIFI_PASSWORD  "KosniasA08"

//====================================================
// FIREBASE
//====================================================
#define API_KEY        "AIzaSyB9iqiqEOnWhp5tHJcWvvo1l0iS_SXHRVI"
#define DATABASE_URL   "microcellapp-default-rtdb.firebaseio.com"

#define USER_EMAIL     "esp32@microcell.com"
#define USER_PASSWORD  "passwordesp32"

//====================================================
// RELAY
//====================================================
#define RELAY1_PIN 5
#define RELAY2_PIN 18

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long lastMillis = 0;

//====================================================
// System Data — matches Flutter app DeviceStatus fields
//====================================================
float batteryLevel = 85.0;
float voltage = 12.50;
float current = 1.20;
float power = 15.00;
float temperature = 28.0;
float humidity = 70.0;
float acVoltage = 220.0;
float lightIntensity = 570.0;
float weatherTemp = 32.0;
String weatherDescription = "Cerah Berawan";
String location = "Bangsalsari, Jember";

//====================================================
void connectWiFi()
{
    if (WiFi.status() == WL_CONNECTED)
        return;

    Serial.println();
    Serial.print("Connecting WiFi");

    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    unsigned long start = millis();

    while (WiFi.status() != WL_CONNECTED && millis() - start < 20000)
    {
        Serial.print(".");
        delay(500);
    }

    if (WiFi.status() == WL_CONNECTED)
    {
        Serial.println();
        Serial.println("WiFi Connected");
        Serial.print("IP Address : ");
        Serial.println(WiFi.localIP());
    }
    else
    {
        Serial.println();
        Serial.println("WiFi Connection Failed");
    }
}

//====================================================
void setup()
{
    Serial.begin(115200);

    randomSeed(micros());

    pinMode(RELAY1_PIN, OUTPUT);
    pinMode(RELAY2_PIN, OUTPUT);

    // Relay OFF (active LOW)
    digitalWrite(RELAY1_PIN, HIGH);
    digitalWrite(RELAY2_PIN, HIGH);

    connectWiFi();

    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;

    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;

    config.token_status_callback = tokenStatusCallback;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    Serial.println("Waiting Firebase Login...");

    unsigned long start = millis();

    while (!Firebase.ready() && millis() - start < 15000)
    {
        Serial.print(".");
        delay(500);
    }

    if (Firebase.ready())
    {
        Serial.println();
        Serial.println("Firebase Connected");
    }
    else
    {
        Serial.println();
        Serial.println("Firebase Login Failed");
    }
}

//====================================================
void loop()
{
    if (WiFi.status() != WL_CONNECTED)
    {
        connectWiFi();
        return;
    }

    if (!Firebase.ready())
        return;

    if (millis() - lastMillis < 5000)
        return;

    lastMillis = millis();

    //==============================
    // Dummy Sensor Data
    //==============================
    batteryLevel = constrain(85 + random(-5, 6), 0, 100);
    voltage = 12.4 + random(-20, 21) / 100.0;
    current = 1.20 + random(-10, 11) / 100.0;
    power = voltage * current;
    temperature = 28.0 + random(-5, 6) + random(0, 100) / 100.0;
    humidity = constrain(70 + random(-10, 11), 0, 100);
    acVoltage = 220.0 + random(-5, 6);
    lightIntensity = constrain(570 + random(-50, 51), 0, 1000);
    weatherTemp = 32.0 + random(-3, 4);

    //==============================
    // Upload Status
    //==============================

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/batteryLevel", batteryLevel))
    {
        Serial.print("Upload Error batteryLevel : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/voltage", voltage))
    {
        Serial.print("Upload Error voltage : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/current", current))
    {
        Serial.print("Upload Error current : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/power", power))
    {
        Serial.print("Upload Error power : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/temperature", temperature))
    {
        Serial.print("Upload Error temperature : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/humidity", humidity))
    {
        Serial.print("Upload Error humidity : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/acVoltage", acVoltage))
    {
        Serial.print("Upload Error acVoltage : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/lightIntensity", lightIntensity))
    {
        Serial.print("Upload Error lightIntensity : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setFloat(&fbdo, "/devices/main/status/weatherTemp", weatherTemp))
    {
        Serial.print("Upload Error weatherTemp : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setString(&fbdo, "/devices/main/status/weatherDescription", weatherDescription))
    {
        Serial.print("Upload Error weatherDescription : ");
        Serial.println(fbdo.errorReason());
    }

    if (!Firebase.RTDB.setString(&fbdo, "/devices/main/status/location", location))
    {
        Serial.print("Upload Error location : ");
        Serial.println(fbdo.errorReason());
    }

    Firebase.RTDB.setTimestamp(&fbdo, "/devices/main/status/updatedAt");

    //==============================
    // Relay 1
    //==============================

    if (Firebase.RTDB.getBool(&fbdo, "/devices/main/relays/relay1"))
    {
        bool relay1 = fbdo.boolData();

        digitalWrite(RELAY1_PIN, relay1 ? LOW : HIGH);

        Firebase.RTDB.setBool(&fbdo, "/devices/main/status/relay1", relay1);
    }
    else
    {
        Serial.print("Relay1 Error : ");
        Serial.println(fbdo.errorReason());
    }

    //==============================
    // Relay 2
    //==============================

    if (Firebase.RTDB.getBool(&fbdo, "/devices/main/relays/relay2"))
    {
        bool relay2 = fbdo.boolData();

        digitalWrite(RELAY2_PIN, relay2 ? LOW : HIGH);

        Firebase.RTDB.setBool(&fbdo, "/devices/main/status/relay2", relay2);
    }
    else
    {
        Serial.print("Relay2 Error : ");
        Serial.println(fbdo.errorReason());
    }



    //==============================
    // Serial Monitor
    //==============================

    Serial.println();
    Serial.println("===== SYSTEM STATUS =====");

    Serial.print("WiFi : ");
    Serial.println(WiFi.status() == WL_CONNECTED ? "Connected" : "Disconnected");

    Serial.print("Firebase : ");
    Serial.println(Firebase.ready() ? "Ready" : "Not Ready");

    Serial.println("------------------------");

    Serial.print("Battery : ");
    Serial.print(batteryLevel);
    Serial.println("%");

    Serial.print("Voltage : ");
    Serial.print(voltage);
    Serial.println(" V");

    Serial.print("Current : ");
    Serial.print(current);
    Serial.println(" A");

    Serial.print("Power : ");
    Serial.print(power);
    Serial.println(" W");

    Serial.print("Temp : ");
    Serial.print(temperature);
    Serial.println(" C");

    Serial.print("Humidity : ");
    Serial.print(humidity);
    Serial.println(" %");

    Serial.print("AC Volt : ");
    Serial.print(acVoltage);
    Serial.println(" V");

    Serial.print("Light : ");
    Serial.print(lightIntensity);
    Serial.println(" Lux");

    Serial.print("Weather : ");
    Serial.print(weatherTemp);
    Serial.println(" C");

    Serial.print("Desc : ");
    Serial.println(weatherDescription);

    Serial.print("Location : ");
    Serial.println(location);

    Serial.print("Relay1 : ");
    Serial.println(digitalRead(RELAY1_PIN) == LOW ? "ON" : "OFF");

    Serial.print("Relay2 : ");
    Serial.println(digitalRead(RELAY2_PIN) == LOW ? "ON" : "OFF");

    Serial.println("======================");
}
