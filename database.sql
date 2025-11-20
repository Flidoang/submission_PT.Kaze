-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 20 Nov 2025 pada 07.34
-- Versi server: 10.4.27-MariaDB
-- Versi PHP: 8.2.0

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `meeting_reservation`
--
CREATE DATABASE IF NOT EXISTS `meeting_reservation` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `meeting_reservation`;

-- --------------------------------------------------------

--
-- Struktur dari tabel `reservations`
--
-- Pembuatan: 20 Nov 2025 pada 04.47
-- Pembaruan terakhir: 20 Nov 2025 pada 06.26
--

CREATE TABLE `reservations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('confirmed','cancelled') DEFAULT 'confirmed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `reservations`:
--   `user_id`
--       `users` -> `id`
--   `room_id`
--       `rooms` -> `id`
--

--
-- Dumping data untuk tabel `reservations`
--

INSERT INTO `reservations` (`id`, `user_id`, `room_id`, `title`, `start_time`, `end_time`, `status`, `created_at`) VALUES
(2, 1, 3, 'Meeting di Ruang', '2025-12-20 08:24:00', '2025-12-20 12:24:00', 'confirmed', '2025-11-20 06:24:12'),
(3, 5, 1, 'Meeting di Ruang ', '2025-12-20 08:24:00', '2025-12-20 12:24:00', 'cancelled', '2025-11-20 06:24:39'),
(4, 6, 3, 'Meeting di Ruang pengen ikutan', '2025-12-21 08:25:00', '2025-12-21 12:25:00', 'confirmed', '2025-11-20 06:26:10');

-- --------------------------------------------------------

--
-- Struktur dari tabel `rooms`
--
-- Pembuatan: 20 Nov 2025 pada 04.47
-- Pembaruan terakhir: 20 Nov 2025 pada 04.47
--

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `capacity` int(11) DEFAULT NULL,
  `facilities` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `rooms`:
--

--
-- Dumping data untuk tabel `rooms`
--

INSERT INTO `rooms` (`id`, `name`, `capacity`, `facilities`, `created_at`) VALUES
(1, 'Ruang A - Merapi', 10, 'Projector, Whiteboard, AC', '2025-11-20 04:47:51'),
(2, 'Ruang B - Bromo', 6, 'TV, Speaker, AC', '2025-11-20 04:47:51'),
(3, 'Ruang C - Rinjani', 20, 'Projector, Video Conference, Catering', '2025-11-20 04:47:51');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--
-- Pembuatan: 20 Nov 2025 pada 04.47
-- Pembaruan terakhir: 20 Nov 2025 pada 06.00
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- RELATIONSHIPS FOR TABLE `users`:
--

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `created_at`) VALUES
(1, 'John Doe', 'john@company.com', '123456', '2025-11-20 04:47:51'),
(5, 'Jane Smith', 'jane@company.com', '123456', '2025-11-20 05:45:39'),
(6, 'Bob Wilson', 'bob@company.com', '123456', '2025-11-20 05:45:39');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indeks untuk tabel `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `reservations`
--
ALTER TABLE `reservations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);


--
-- Metadata
--
USE `phpmyadmin`;

--
-- Metadata untuk tabel reservations
--

--
-- Metadata untuk tabel rooms
--

--
-- Metadata untuk tabel users
--

--
-- Metadata untuk database meeting_reservation
--
SET FOREIGN_KEY_CHECKS=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
