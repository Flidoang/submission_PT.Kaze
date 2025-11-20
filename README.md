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
1. Letakkan folder yang sudah di clone di `htdocs/`
2. Setup XAMPP/WAMP
3. Import database `database.sql` pada mySql/postgreSql (file database nya sudah tersedia dengan nama yang sama dan folder yang sama)

## Installation FE
1. buka file frontend/meeting-system/ : `cd frontend/meeting-system`
2. lakukan installasi terlebih dahulu untuk library yang digunakan : `npm install`
3. Jalankan Vue dev server: `npm run dev`
4. Akses: `http://localhost:5173`

## Demo Accounts
- Email: john@company.com / jane@company.com / bob@company.com  
- Password: 123456