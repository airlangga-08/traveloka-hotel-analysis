CREATE DATABASE milestone_2;

CREATE TABLE traveloka_raw(time_collacted timestamp,
	 city VARCHAR (50),
	 checkin TEXT,
	 checkout TEXT,
	 num_staying_nights INT,
	 id BIGINT,
	 name VARCHAR (300),
	 displayName VARCHAR(300),
	 region VARCHAR (300),
	 starRating FLOAT,
	 userRating FLOAT,
	 numReviews FLOAT,
	 userRatingInfo VARCHAR (300),
	 latitude FLOAT,
	 longitude FLOAT,
	 lowRate INT,
	 highRate FLOAT,
	 hotelFeatures TEXT,
	 hotelSeoUrl TEXT,
	 cheapestRate_allNights_baseFare INT,
	 cheapestRate_allNights_fees INT,
	 cheapestRate_allNights_taxes FLOAT,
	 cheapestRate_allNights_totalFare INT,
	 cheapestRate_perNight_baseFare INT,
	 cheapestRate_perNight_fees FLOAT,
	 cheapestRate_perNight_taxes FLOAT,
	 cheapestRate_perNight_totalFare INT,
	 originalRate_allNights_baseFare INT,
	 originalRate_allNights_fees INT,
	 originalRate_allNights_taxes INT,
	 originalRate_allNights_totalFare INT,
	 originalRate_perNight_baseFare INT,
	 originalRate_perNight_fees FLOAT,
	 originalRate_perNight_taxes FLOAT,
	 originalRate_perNight_totalFare INT	 
);

-- LOADING DATA MENGGUNAKAN COPY AS PATH --
COPY traveloka_raw
FROM 'C:\Users\Airlangga\Downloads\traveloka_newyearhotels.csv'
DELIMITER '|' CSV HEADER;
-- Muncul pesan error saat load data
-- Sehingga menggunakan alternatif import data di bagian table

-- BERIKUT ADALAH KOLOM YANG DIBUTUHKAN --
SELECT 
	name,
	city,
	region,
	starrating,
	latitude,
	longitude,
	num_staying_nights,
	cheapestRate_allNights_totalFare,
	cheapestRate_perNight_totalFare,
	originalRate_allNights_totalFare,
	originalRate_perNight_totalFare
FROM traveloka_raw;

-- CEK MISSING VALUE --
SELECT 
COUNT (*) FILTER (WHERE name IS NULL) AS nama_kosong,
COUNT (*) FILTER (WHERE city IS NULL) AS kota_kosong,
COUNT (*) FILTER (WHERE region IS NULL) AS region_kosong,
COUNT (*) FILTER (WHERE starrating IS NULL) AS rating_kosong,
COUNT (*) FILTER (WHERE latitude IS NULL) AS lati_kosong,
COUNT (*) FILTER (WHERE longitude IS NULL) AS long_kosong,
COUNT (*) FILTER (WHERE num_staying_nights IS NULL) AS num_stay_kosong,
COUNT (*) FILTER (WHERE cheapestRate_allNights_totalFare IS NULL) AS chp_all,
COUNT (*) FILTER (WHERE cheapestRate_perNight_totalFare IS NULL) AS chp_per,
COUNT (*) FILTER (WHERE originalRate_allNights_totalFare IS NULL) AS ori_all,
COUNT (*) FILTER (WHERE originalRate_perNight_totalFare IS NULL) AS ori_per
FROM traveloka_raw;
-- Dari output yang ditampilkan tidak ditemukan missing value dari kolom-kolom yang akan digunakan sebagai bahan analisa

-- CEK DUPLIKAT --
SELECT name,
	city,
	--region,
	checkin,
	checkout,
	starrating,
	--latitude,
	--longitude,
	num_staying_nights,
	cheapestRate_perNight_totalFare,
	originalRate_perNight_totalFare, 
	COUNT(*) AS toal_records
FROM traveloka_raw
GROUP BY name,
	city,
	--region,
	checkin,
	checkout,
	starrating,
	--latitude,
	--longitude,
	num_staying_nights,
	cheapestRate_perNight_totalFare,
	originalRate_perNight_totalFare
HAVING COUNT(*)>1
ORDER BY toal_records DESC;

SELECT *
FROM traveloka_raw
WHERE name = 'Amanda Hills Bandungan'
	AND city ='Semarang'
ORDER BY checkin, time_collacted;
	
-- Ditemukan beberapa nama hotel yang muncul lebih dari satu kali.
-- Setelah dilakukan pengecekan terhadap check in, out, jumlah malam menginap dan tarif hotel
-- sebagian besar record merupakan observasi penawaran hotel yang berbeda
-- bukan data duplikat
-- record yang hanya berbeda pada waktu pengambilan data akan dicek ulang di python.


-- CEK TIPE DATA --
SELECT 
	MAX (CASE WHEN column_name = 'city' THEN data_type END) AS city,
	MAX (CASE WHEN column_name = 'region'THEN data_type END) AS region,
	MAX (CASE WHEN column_name = 'checkin' THEN data_type END) AS checkin,
	MAX (CASE WHEN column_name = 'checkout' THEN data_type END) AS checkout,
	MAX (CASE WHEN column_name = 'starrating' THEN data_type END) AS starrating,
	MAX (CASE WHEN column_name = 'latitude' THEN data_type END) AS latitude,
	MAX (CASE WHEN column_name = 'longitude' THEN data_type END) AS longitude,
	MAX (CASE WHEN column_name = 'num_staying_nights' THEN data_type END) AS num_staying_nights,
	MAX (CASE WHEN column_name = 'cheapestrate_pernight_totalfare' THEN data_type END) AS cheapestRate_perNight_totalFare,
	MAX (CASE WHEN column_name = 'originalrate_pernight_totalfare' THEN data_type END) AS originalRate_perNight_totalFare
FROM information_schema.columns
WHERE table_name = 'traveloka_raw';
-- Kolom ditulis lowercase karena saat create table nama kolom tidak menggunakan ""

-- MEMERIKSA KOLOM HARGA MENCEGAH ADANYA ANOMALI DATA --
SELECT *
FROM traveloka_raw
WHERE cheapestRate_perNight_totalFare <= 0
	OR originalRate_perNight_totalFare <= 0;
-- Tidak ada tarif yang 0 ataupun minus sehingga datanya bisa dianggap normal

SELECT DISTINCT starrating
FROM traveloka_raw
ORDER BY starrating;
-- Nilai starrating berada pada range 0-5. 
-- Nilai 0 perlu diperlakukan sebagai hotel tanpa klasifikasi bintang

SELECT name,
	checkin,
	checkout,
	num_staying_nights,
	TO_DATE(checkout, 'DD-MM-YYYY') - TO_DATE(checkin, 'DD-MM-YYYY') AS calculated_night
FROM traveloka_raw
WHERE TO_DATE(checkout, 'DD-MM-YYYY') - TO_DATE(checkin, 'DD-MM-YYYY') <> num_staying_nights;
-- Tidak ditemukan ketidaksesuaian antara tanggal cek in, cek out dan jumlah malam menginap
-- data durasi menginap bisa dibilang valid

SELECT *
FROM traveloka_raw
WHERE cheapestrate_pernight_totalfare > originalrate_pernight_totalfare
-- Tarif termurah tidak lebih besar dari tarif awal
-- Sehingga bisa dibilang struktur tarif pada dataset masih konsisten

CREATE TABLE traveloka_clean AS 
SELECT
	 city,
	 TO_DATE (checkin, 'DD-MM-YYYY') AS checkin, -- Mengubah tipe data text ke Date
	 TO_DATE (checkout, 'DD-MM-YYYY') AS checkout, -- Mengubah tipe data text ke Date
	 num_staying_nights,
	 name,
	 region,
	 starrating AS star_rating,
	 latitude,
	 longitude,
	 cheapestrate_allnights_totalfare AS cheapest_rate_all,
	 cheapestrate_pernight_totalfare AS cheapest_rate_pern,
	 originalrate_allnights_totalfare AS original_all,
	 originalrate_pernight_totalfare AS original_pern
FROM traveloka_raw;
SELECT 
	column_name,
	data_type
FROM information_schema.columns
WHERE table_name = 'traveloka_clean';

SELECT COUNT (*) FROM traveloka_clean;
-- Jumlah baris adalah 904 (sama dengan jumlah baris di raw)

SELECT * FROM traveloka_clean
LIMIT 10;
-- Memeriksa apakah datanya sesuai