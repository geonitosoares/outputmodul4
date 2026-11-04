-- Database schema berdasarkan ERD sistem produksi dan pemesanan
-- PostgreSQL
-- Jalankan pada database yang sudah dibuat.

CREATE TABLE admin (
    id_admin VARCHAR(20) PRIMARY KEY
);

CREATE TABLE owner (
    id_owner VARCHAR(20) PRIMARY KEY,
    id_admin VARCHAR(20) NOT NULL REFERENCES admin(id_admin)
);

CREATE TABLE supplier (
    id_supplier VARCHAR(20) PRIMARY KEY,
    nama_supplier VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    alamat VARCHAR(255),
    id_admin VARCHAR(20) REFERENCES admin(id_admin),
    id_owner VARCHAR(20) REFERENCES owner(id_owner)
);

CREATE TABLE karyawan_produksi (
    id_karyawan VARCHAR(20) PRIMARY KEY,
    id_admin VARCHAR(20) REFERENCES admin(id_admin)
);

CREATE TABLE produk (
    id_produk VARCHAR(20) PRIMARY KEY,
    jumlah_target INTEGER NOT NULL DEFAULT 0 CHECK (jumlah_target >= 0),
    jumlah_berhasil INTEGER NOT NULL DEFAULT 0 CHECK (jumlah_berhasil >= 0),
    nama_produk VARCHAR(100) NOT NULL,
    harga_jual NUMERIC(15,2) NOT NULL CHECK (harga_jual >= 0),
    id_admin VARCHAR(20) REFERENCES admin(id_admin),
    id_owner VARCHAR(20) REFERENCES owner(id_owner)
);

CREATE TABLE pesanan_produk (
    id_pesanan VARCHAR(20) PRIMARY KEY,
    tanggal_pesanan DATE NOT NULL,
    jenis_pesanan VARCHAR(30),
    status VARCHAR(30) NOT NULL,
    nama_pelanggan VARCHAR(100) NOT NULL,
    total_biaya_pesanan NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (total_biaya_pesanan >= 0),
    id_admin VARCHAR(20) REFERENCES admin(id_admin),
    id_owner VARCHAR(20) REFERENCES owner(id_owner)
);

-- Detail pesanan: satu pesanan dapat berisi beberapa produk.
CREATE TABLE detail_pesanan_produk (
    id_pesanan VARCHAR(20) NOT NULL REFERENCES pesanan_produk(id_pesanan) ON DELETE CASCADE,
    id_produk VARCHAR(20) NOT NULL REFERENCES produk(id_produk),
    jumlah INTEGER NOT NULL CHECK (jumlah > 0),
    harga_satuan NUMERIC(15,2) NOT NULL CHECK (harga_satuan >= 0),
    PRIMARY KEY (id_pesanan, id_produk)
);

CREATE TABLE bahan_baku (
    id_bahan_baku VARCHAR(20) PRIMARY KEY,
    nama_bahan VARCHAR(100) NOT NULL,
    stok_tersedia NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (stok_tersedia >= 0),
    stok_minimal NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (stok_minimal >= 0),
    harga_satuan NUMERIC(12,2) NOT NULL CHECK (harga_satuan >= 0),
    id_owner VARCHAR(20) REFERENCES owner(id_owner)
);

CREATE TABLE pesanan_bahan_baku (
    id_pengadaan VARCHAR(20) PRIMARY KEY,
    status VARCHAR(30) NOT NULL,
    tanggal_pesanan DATE NOT NULL,
    total_biaya NUMERIC(15,2) NOT NULL DEFAULT 0 CHECK (total_biaya >= 0),
    persetujuan_owner VARCHAR(20),
    jumlah_pesanan INTEGER NOT NULL DEFAULT 0 CHECK (jumlah_pesanan >= 0),
    id_owner VARCHAR(20) REFERENCES owner(id_owner),
    id_admin VARCHAR(20) REFERENCES admin(id_admin),
    id_supplier VARCHAR(20) NOT NULL REFERENCES supplier(id_supplier)
);

-- Detail pengadaan: satu pengadaan dapat memuat beberapa bahan baku.
CREATE TABLE detail_pesanan_bahan_baku (
    id_pengadaan VARCHAR(20) NOT NULL REFERENCES pesanan_bahan_baku(id_pengadaan) ON DELETE CASCADE,
    id_bahan_baku VARCHAR(20) NOT NULL REFERENCES bahan_baku(id_bahan_baku),
    jumlah NUMERIC(12,2) NOT NULL CHECK (jumlah > 0),
    harga_satuan NUMERIC(12,2) NOT NULL CHECK (harga_satuan >= 0),
    PRIMARY KEY (id_pengadaan, id_bahan_baku)
);

CREATE TABLE resep_standar (
    id_resep VARCHAR(20) PRIMARY KEY,
    nama_resep VARCHAR(100) NOT NULL,
    porsi_standar INTEGER NOT NULL CHECK (porsi_standar > 0),
    petunjuk_pembuatan INTEGER
        -- Ubah ke TEXT jika petunjuk berupa uraian, bukan angka.
        ,
    id_admin VARCHAR(20) REFERENCES admin(id_admin),
    id_owner VARCHAR(20) REFERENCES owner(id_owner),
    id_produk VARCHAR(20) NOT NULL REFERENCES produk(id_produk)
);

-- Resep dapat menggunakan banyak bahan baku; bahan baku dapat dipakai
-- pada banyak resep.
CREATE TABLE resep_bahan_baku (
    id_resep VARCHAR(20) NOT NULL REFERENCES resep_standar(id_resep) ON DELETE CASCADE,
    id_bahan_baku VARCHAR(20) NOT NULL REFERENCES bahan_baku(id_bahan_baku),
    jumlah_bahan NUMERIC(12,2) NOT NULL CHECK (jumlah_bahan > 0),
    satuan VARCHAR(30),
    PRIMARY KEY (id_resep, id_bahan_baku)
);

-- Relasi penugasan karyawan ke produk (bila diperlukan).
CREATE TABLE penugasan_karyawan_produk (
    id_karyawan VARCHAR(20) NOT NULL REFERENCES karyawan_produksi(id_karyawan),
    id_produk VARCHAR(20) NOT NULL REFERENCES produk(id_produk),
    PRIMARY KEY (id_karyawan, id_produk)
);

CREATE TABLE laporan (
    id_laporan VARCHAR(20) PRIMARY KEY,
    tanggal_generate DATE NOT NULL,
    periode VARCHAR(50),
    id_admin VARCHAR(20) REFERENCES admin(id_admin),
    id_owner VARCHAR(20) REFERENCES owner(id_owner),
    id_produk VARCHAR(20) REFERENCES produk(id_produk)
);

-- Index untuk kolom FK yang sering dipakai dalam pencarian/join.
CREATE INDEX idx_supplier_admin ON supplier(id_admin);
CREATE INDEX idx_supplier_owner ON supplier(id_owner);
CREATE INDEX idx_produk_owner ON produk(id_owner);
CREATE INDEX idx_pesanan_produk_owner ON pesanan_produk(id_owner);
CREATE INDEX idx_pengadaan_supplier ON pesanan_bahan_baku(id_supplier);
CREATE INDEX idx_bahan_owner ON bahan_baku(id_owner);
CREATE INDEX idx_laporan_produk ON laporan(id_produk);