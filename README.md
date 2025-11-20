# Sistem Reservasi Ruang Rapat

## Deskripsi
Sistem untuk melakukan reservasi ruang rapat dengan validasi jadwal dan authentication.

## Fitur
- ✅ Authentication System
- ✅ Booking ruangan meeting  
- ✅ Prevent jadwal conflict
- ✅ Validasi jam kerja (08:00-17:00)
- ✅ Riwayat reservasi pribadi
- ✅ Batalkan reservasi (hanya milik sendiri)

## Tech Stack
- Frontend: Vue.js 3 + Pinia + Composition API
- Backend: PHP Native
- Database: MySQL
- Styling: Tailwind CSS

## Installation BE
1. Import database `database.sql`
2. Setup XAMPP/WAMP
3. Letakkan folder di `htdocs/`

## Installation FE
1. buka file frontend/meeting-system/ : `cd frontend/meeting-system`
2. lakukan installasi terlebih dahulu untuk library yang digunakan : `npm install`
1. Jalankan Vue dev server: `npm run dev`
2. Akses: `http://localhost:5173`

## Demo Accounts
- Email: john@company.com / jane@company.com / bob@company.com  
- Password: 123456