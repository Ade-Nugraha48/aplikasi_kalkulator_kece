# Backend REST API - Aplikasi Kalkulator Kece

Ini adalah proyek backend Node.js (Express.js) yang bertindak sebagai jembatan antara aplikasi Flutter (Mobile) dan database PostgreSQL lokal Anda. Backend ini menggunakan arsitektur 3-tier.

## Prasyarat
- [Node.js](https://nodejs.org/) terinstal di komputer Anda.
- [PostgreSQL](https://www.postgresql.org/) berjalan secara lokal.

## 🚀 Cara Menjalankan Backend Secara Lokal

1. Buka terminal (CMD/PowerShell) dan arahkan ke folder ini:
   ```bash
   cd "C:\Semester 5\Moblie Teori\Aplikasi Kalkulator Kece\aplikasi_kalkulator_kece\backend"
   ```
2. Instal semua dependensi:
   ```bash
   npm install
   ```
3. Sesuaikan *environment variables*:
   Buka file `.env` di folder ini dan isikan password PostgreSQL Anda pada `DB_PASSWORD`.
4. Jalankan server:
   ```bash
   npm start
   ```
   Atau jika ingin menggunakan *hot-reload* saat masa pengembangan:
   ```bash
   npm run dev
   ```
   *Jika berhasil, Anda akan melihat pesan "Terkoneksi ke database PostgreSQL" di console.*

## 📱 Cara Mengakses Endpoint dari Aplikasi Mobile

### 1. Emulator Android
Jika Anda menggunakan Android Emulator bawaan Android Studio, Anda tidak bisa menggunakan `localhost` atau `127.0.0.1` di kode Flutter Anda karena itu akan merujuk ke sistem internal emulator itu sendiri. 

Gunakan IP khusus **`10.0.2.2`** yang secara otomatis akan diarahkan ke localhost komputer host (PC Anda).
- URL API: `http://10.0.2.2:3000/api/users`

### 2. Emulator iOS / Web / Desktop
Jika Anda menjalankan Flutter di Simulator iOS, browser (Chrome), atau Windows Desktop, Anda bisa langsung menggunakan `localhost`.
- URL API: `http://localhost:3000/api/users`

### 3. Perangkat HP Fisik (Real Device)
Jika Anda me-run aplikasi di HP asli yang terhubung ke WiFi yang sama dengan PC Anda, Anda harus menggunakan alamat IP Local PC (IPv4 LAN).
Cek IP Anda di CMD dengan mengetik `ipconfig`. (Misalnya IPv4 Anda adalah `192.168.1.5`).
- URL API: `http://192.168.1.5:3000/api/users`

> **Note:** Pada real device, pastikan *Windows Firewall* tidak memblokir port 3000 untuk koneksi masuk (Inbound Rules).

---

## 🛠️ Contoh Kode HTTP Request di Flutter (Dart)

Untuk menggantikan `DatabaseHelper` dengan REST API, Anda perlu menginstal package `http` di Flutter (`flutter pub add http`). 

Berikut adalah contoh memanggil API `GET` dan `POST` dari Flutter:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti sesuai device (10.0.2.2 untuk Android Emulator)
  static const String baseUrl = 'http://10.0.2.2:3000/api/users';

  // 1. GET: Mengambil daftar pengguna
  static Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Daftar Users: \${data['data']}');
      } else {
        print('Gagal mengambil data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // 2. POST: Mendaftarkan pengguna baru
  static Future<bool> register(String user, String pass, String mail, String dob) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'username': user,
          'password': pass,
          'email': mail,
          'birth_date': dob,
        }),
      );

      if (response.statusCode == 201) {
        print('Berhasil register');
        return true;
      }
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
```
