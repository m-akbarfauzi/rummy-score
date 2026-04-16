Product Requirements Document (PRD): RummyScore (Aplikasi Penghitung Remi)
1. Ringkasan Produk (Product Summary)
RummyScore adalah aplikasi mobile berbasis Flutter yang berfungsi sebagai pencatat skor digital untuk permainan kartu remi. Aplikasi ini menggantikan kertas dan pulpen, memberikan perhitungan otomatis, serta menyimpan riwayat permainan.

2. Tujuan & Objektif (Goals & Objectives)
Akurasi: Menghilangkan kesalahan manusia dalam perhitungan skor manual.

Kemudahan: Mempercepat proses input skor di setiap akhir putaran.

Transparansi: Memberikan visualisasi klasemen pemain secara real-time.

3. Target Pengguna (User Personas)
Pemain kartu kasual yang sering berkumpul dengan teman atau keluarga.

Pemain yang menginginkan catatan permanen dari sesi permainan mereka.

4. Kebutuhan Fungsional (Functional Requirements)
A. Manajemen Permainan
Setup Pemain: Pengguna dapat menambah 2 hingga 6 pemain dalam satu sesi.

Target Skor: Menentukan batas skor maksimal (misal: 500 poin) di mana pemain yang melebihinya dinyatakan kalah/selesai.

Jenis Perhitungan: Opsi untuk menghitung skor secara akumulatif (poin positif atau poin negatif/penalti).

B. Input Skor (In-Game)
Input Per Putaran: Form sederhana untuk memasukkan skor setiap pemain setelah satu ronde berakhir.

Edit Skor: Kemampuan untuk mengubah skor putaran sebelumnya jika terjadi kesalahan input.

Validasi: Sistem memastikan skor yang dimasukkan adalah angka yang valid.

C. Klasemen & Visualisasi
Papan Peringkat: Daftar pemain yang diurutkan berdasarkan skor terkini.

Status Pemain: Menandai pemain yang sudah "Out" jika melewati batas skor.

Grafik Tren: (Opsional) Grafik garis untuk melihat kenaikan skor pemain dari putaran ke putaran.

5. Alur Pengguna (User Flow)
Home: Pilih "Mulai Permainan Baru" atau "Lihat Riwayat".

Configuration: Masukkan nama pemain dan tentukan batas skor.

Gameplay: Halaman utama yang menampilkan skor total. Tekan tombol "+" untuk menambah skor ronde baru.

Game Over: Menampilkan pemenang dan ringkasan statistik setelah batas skor tercapai.

6. Spesifikasi Teknis (Flutter Stack)
Framework: Flutter (Android & iOS).

State Management: Provider atau Bloc (untuk mengelola perubahan skor di seluruh layar).

Penyimpanan Lokal: shared_preferences atau sqflite untuk menyimpan data permainan yang sedang berlangsung agar tidak hilang saat aplikasi tertutup.

UI Components: * DataTable untuk riwayat skor per ronde.

Card dan ListView untuk daftar pemain.

FloatingActionButton untuk input skor baru.

7. Kriteria Penerimaan (Acceptance Criteria)
Aplikasi dapat menghitung total skor dengan benar dari semua ronde yang ada.

Aplikasi tetap menyimpan data permainan meskipun ponsel dimatikan (persistence).

Antarmuka harus responsif di berbagai ukuran layar ponsel.

Tips Flutter untuk Proyek Ini:
Karena ini adalah aplikasi penghitung skor, pastikan Anda merancang Model Data yang baik. Misalnya, buatlah class GameSession yang berisi daftar Player, di mana setiap Player memiliki daftar RoundScore.