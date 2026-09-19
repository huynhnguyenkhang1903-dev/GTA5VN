Config = {}

-- ============================================================
-- CẤU HÌNH ĐỒNG HỒ TỐC ĐỘ (SPEEDOMETER)
-- ============================================================
-- Đơn vị tốc độ: 'KMH' (chuẩn Việt Nam) hoặc 'MPH'
Config.SpeedUnit = 'KMH'
Config.SpeedMultiplier = 3.6 -- 3.6 cho KM/H, 2.236936 cho MPH

-- Giới hạn tốc độ trên thang đo vòng cung (tự động co dãn nếu xe chạy nhanh hơn)
Config.MaxGaugeSpeed = 360

-- Tần số cập nhật HUD (mili-giây) - 50ms tạo độ mượt 60fps nhưng siêu nhẹ (<0.02ms CPU)
Config.UpdateInterval = 50

-- Mức máu động cơ cảnh báo đèn Check Engine (mặc định dưới 400 là động cơ hỏng)
Config.EngineWarningHealth = 400.0

-- Mức phần trăm xăng cảnh báo sắp hết (đổi màu cam/đỏ)
Config.LowFuelWarning = 20.0

-- ============================================================
-- HỆ THỐNG DÂY AN TOÀN (SEATBELT)
-- ============================================================
-- Phím tắt thắt / mở dây an toàn (Mặc định phím B)
Config.SeatbeltKey = 'B'

-- Kích hoạt cơ chế văng ra khỏi xe khi đâm va chạm mạnh mà KHÔNG thắt dây an toàn
Config.EjectionOnCrash = true

-- Tốc độ tối thiểu (KM/H) để có nguy cơ bị văng kính khi va chạm đột ngột
Config.MinSpeedForEjection = 65.0

-- Sát thương nhận khi bị văng qua kính chắn gió (từ 0 đến 100)
Config.EjectionDamage = 35

-- Tốc độ (KM/H) bắt đầu kích hoạt chuông nhắc nhở thắt dây an toàn
Config.ChimeSpeed = 25.0

-- ============================================================
-- HỆ THỐNG XI-NHAN & ĐÈN KHẨN CẤP
-- ============================================================
Config.TurnSignals = {
    enabled = true,
    leftKey = 'LEFT',     -- Phím mũi tên Trái hoặc '['
    rightKey = 'RIGHT',   -- Phím mũi tên Phải hoặc ']'
    hazardKey = 'DOWN'    -- Phím mũi tên Xuống
}

-- Thông báo trong game (đã lọc sạch font dấu theo chuẩn GTA V)
Config.Locale = {
    seatbeltOn = "Da that day an toan.",
    seatbeltOff = "Da thao day an toan."
}
