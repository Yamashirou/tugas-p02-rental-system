Catatan singkat mengenai alasan dan keputusan desain di balik pembuatan sistem rental ini.

1. Alasan Pemodelan Kelas

Kenapa Car mewarisi Vehicle (Inheritance)?
Secara logika, mobil adalah kendaraan. Kelas `Vehicle` dibuat sebagai kelas induk untuk menampung data dasar yang pasti dimiliki semua kendaraan (id, brand, tarif per hari, dan fungsi `toJson`). Sedangkan `Car` menambahkan hal yang spesifik untuk mobil, yaitu kapasitas penumpang. Jika nanti ingin menambah jenis kendaraan baru seperti motor atau truk, `RentalOrder` tidak perlu diubah karena sudah mengacu ke `Vehicle`.

Kenapa RentalOrder memakai Komposisi?
`RentalOrder` menghubungkan `Customer` dan `Vehicle`. Hubungannya adalah kepemilikan (order memiliki pelanggan dan memiliki kendaraan), bukan pewarisan. Order bertugas menghitung total biaya sewa dan mencatat status transaksi.

Validasi Nilai (Mencegah Data Tidak Masuk Akal)
Semua input dicek langsung saat objek dibuat: durasi minimal 1 hari, tarif sewa dan kapasitas kursi harus lebih dari 0, serta nama pelanggan tidak boleh kosong. Jika ada yang tidak valid, program langsung melempar `RentalException`.

Alur Status Transaksi
Status transaksi dibatasi lewat enum (`active`, `completed`, `cancelled`). Transisinya dijaga agar masuk akal: order yang sudah dibatalkan tidak boleh diselesaikan, dan order yang sudah selesai tidak bisa dibatalkan lagi.

2.  Keputusan yang Sempat Dipertimbangkan

Kenapa tidak memakai Mixin?  
 Awalnya sempat terpikir memakai mixin untuk logging, tetapi sistem ini masih sederhana dan alurnya lurus. Menambahkan mixin hanya membuat kode lebih ramai tanpa kegunaan nyata.

Kenapa menghapus Car.fromJson?
Di `main.dart`, kita hanya mengembalikan objek `Customer` dari JSON. Karena `Car.fromJson` sama sekali tidak pernah dipanggil, fungsi ini dihapus agar tidak menjadi kode mati yang membingungkan.

Penggunaan Future.delayed
Jeda waktu pada `completeRentalAsync` sengaja dipertahankan untuk mensimulasikan proses asinkron nyata, seperti menunggu respons server atau penyimpanan data pengembalian.

Ketersediaan Kendaraan
Status ketersediaan tidak disimpan sebagai variabel di kelas `Vehicle`. Mobilnya sendiri tidak berubah secara fisik; ketersediaannya otomatis terlihat dari ada atau tidaknya `RentalOrder` yang sedang aktif untuk mobil tersebut.

Catatan tentang copyWith
Pada `RentalOrder`, `copyWith` diberi penanganan khusus agar nilai `returnNotes` bisa benar-benar dikosongkan (diubah jadi null) jika dibutuhkan, tanpa tertahan oleh nilai lama.
