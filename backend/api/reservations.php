<?php
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

session_start();

require_once '../config/database.php';

// Check authentication
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Unauthorized - Please login first']);
    exit();
}

$userId = $_SESSION['user_id'];
$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        getReservations($pdo, $userId);
        break;
    case 'POST':
        createReservation($pdo, $userId);
        break;
    case 'DELETE':
        cancelReservation($pdo, $userId);
        break;
    default:
        http_response_code(405);
        echo json_encode(['success' => false, 'error' => 'Method not allowed']);
}

function getReservations($pdo, $userId) {
    try {
        $stmt = $pdo->prepare("
            SELECT r.*, rm.name as room_name 
            FROM reservations r 
            JOIN rooms rm ON r.room_id = rm.id 
            WHERE r.user_id = ? AND r.status = 'confirmed'
            ORDER BY r.start_time DESC
        ");
        $stmt->execute([$userId]);
        $reservations = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'data' => $reservations]);
    } catch(PDOException $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}

function createReservation($pdo, $userId) {
    // Get JSON data
    $input = json_decode(file_get_contents('php://input'), true);
    
    $roomId = $input['room_id'] ?? null;
    $title = $input['title'] ?? '';
    $startTime = $input['start_time'] ?? '';
    $endTime = $input['end_time'] ?? '';
    
    // Validasi input
    if (!$roomId || !$title || !$startTime || !$endTime) {
        echo json_encode(['success' => false, 'error' => 'Semua field harus diisi']);
        return;
    }
    
    try {
        // 1. CEK KONFLIK JADWAL (CORE BUSINESS LOGIC)
        $conflictCheck = $pdo->prepare("
            SELECT COUNT(*) as conflict_count 
            FROM reservations 
            WHERE room_id = ? 
            AND status = 'confirmed'
            AND (
                (start_time BETWEEN ? AND ?) 
                OR (end_time BETWEEN ? AND ?)
                OR (? BETWEEN start_time AND end_time)
                OR (? BETWEEN start_time AND end_time)
            )
        ");
        $conflictCheck->execute([$roomId, $startTime, $endTime, $startTime, $endTime, $startTime, $endTime]);
        $result = $conflictCheck->fetch(PDO::FETCH_ASSOC);
        
        if ($result['conflict_count'] > 0) {
            echo json_encode(['success' => false, 'error' => '❌ Ruangan sudah dipesan di jam tersebut']);
            return;
        }
        
        // 2. CEK JAM KERJA (08:00-17:00)
        $startHour = date('H:i', strtotime($startTime));
        $endHour = date('H:i', strtotime($endTime));
        
        if ($startHour < '08:00' || $endHour > '17:00') {
            echo json_encode(['success' => false, 'error' => '❌ Hanya bisa booking antara jam 08:00 - 17:00']);
            return;
        }
        
        // 3. BUAT RESERVASI
        $stmt = $pdo->prepare("
            INSERT INTO reservations (user_id, room_id, title, start_time, end_time) 
            VALUES (?, ?, ?, ?, ?)
        ");
        $stmt->execute([$userId, $roomId, $title, $startTime, $endTime]);
        
        echo json_encode([
            'success' => true, 
            'message' => '✅ Reservasi berhasil dibuat!',
            'reservation_id' => $pdo->lastInsertId()
        ]);
        
    } catch(PDOException $e) {
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
    }
}

function cancelReservation($pdo, $userId) {
    $input = json_decode(file_get_contents('php://input'), true);
    $reservationId = $input['reservation_id'] ?? null;
    
    if (!$reservationId) {
        echo json_encode(['success' => false, 'error' => 'Reservation ID required']);
        return;
    }
    
    try {
        // CEK APAKAH RESERVASI MILIK USER YANG SAMA
        $checkStmt = $pdo->prepare("SELECT user_id FROM reservations WHERE id = ?");
        $checkStmt->execute([$reservationId]);
        $reservation = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$reservation || $reservation['user_id'] != $userId) {
            echo json_encode(['success' => false, 'error' => '❌ Hanya bisa membatalkan reservasi sendiri']);
            return;
        }
        
        // UPDATE STATUS JADI CANCELLED
        $stmt = $pdo->prepare("UPDATE reservations SET status = 'cancelled' WHERE id = ?");
        $stmt->execute([$reservationId]);
        
        echo json_encode(['success' => true, 'message' => '✅ Reservasi berhasil dibatalkan']);
        
    } catch(PDOException $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
}
?>