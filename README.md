# Domain Model: Rental Kendaraan

## 1. Domain & Alasan Pemodelan

Sistem ini memodelkan reservasi sewa kendaraan harian.

- **Relasi 3 Kelas**: Memisahkan entitas `Customer`, `Vehicle`, dan `RentalOrder`. `RentalOrder` menggunakan komposisi karena transaksi sewa _memiliki_ relasi terhadap penyewa dan kendaraan, bukan mewarisinya.
- **Inheritance**: `Car` diturunkan dari kelas abstrak `Vehicle` untuk mewarisi identitas dan tarif sewa dasar serta menambahkan properti spesifik (`seatingCapacity`).
- **Mixin (`Loggable`)**: Memberikan kemampuan audit pencatatan aktivitas transaksi tanpa mengikat hierarki pohon inheritance.
- **Enum (`RentalStatus`)**: Membatasi status rental (`active`, `completed`, `cancelled`) agar bebas dari resiko salah ketik (_type-safe_).
- **Null Safety**: Properti `phoneNumber` dan `returnNotes` diperbolehkan null (`?`) karena bersifat opsional saat transaksi pertama kali dibuat. Sebaliknya, `orderId` dan `durationDays` wajib non-nullable.
- **Custom Exception (`RentalException`)**: Menolak instansiasi order berdurasi $\le 0$ hari dan melarang penyelesaian ganda pada transaksi yang sudah berstatus selesai.

## 2. Keputusan yang Sempat Diragukan

Sempat ragu apakah status ketersediaan (_availability_) harus ditempelkan langsung sebagai field `isAvailable` di dalam kelas `Vehicle`. Keputusan akhirnya adalah memisahkannya dari `Vehicle` dan menyerahkannya ke siklus hidup `RentalOrder`. Alasan: sebuah mobil secara fisik tetap ada dan tidak berubah identitasnya; yang menentukan ketersediaannya adalah ada/tidaknya transaksi `RentalOrder` yang berstatus `active` pada rentang tanggal tersebut.
