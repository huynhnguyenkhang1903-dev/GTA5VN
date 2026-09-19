Config = {}

-- ============================================================
-- PHÍM TẮT & LỆNH ĐIỀU KHIỂN
-- ============================================================
-- Phím tắt mặc định để mở menu (Y). Kết hợp với giữ phím CTRL sẽ thành CTRL + Y.
-- Người chơi có thể tự đổi phím này trong Cài đặt GTA V -> Key Bindings -> FiveM
Config.KeyMapping = 'Y'

-- Yêu cầu giữ phím CTRL khi bấm phím Config.KeyMapping
-- Nếu đặt là true: phải bấm CTRL + Y mới mở menu
-- Nếu đặt là false: chỉ cần bấm Y là mở menu
Config.RequireCtrl = true

-- Tên các lệnh gõ trong khung chat (T) hoặc F8 console
Config.Commands = {
    save = 'admincar',          -- Lưu xe hiện tại vào danh sách cá nhân (/admincar [tên])
    menu = 'admincarmenu',      -- Mở menu gara xe cá nhân (/admincarmenu hoặc /admincars)
    quickStore = 'admincatxe'   -- Cất nhanh xe đang ngồi và cập nhật bản độ
}

-- ============================================================
-- CẤU HÌNH QUYỀN HẠN (PERMISSIONS)
-- ============================================================
-- Đặt là false để cho phép mọi người chơi đều dùng được (phù hợp server làm phim Studio)
-- Đặt là true nếu chỉ muốn Admin có quyền dùng
Config.RequireAdmin = false
Config.AdminAce = 'command.admincar' -- Quyền ACE nếu Config.RequireAdmin = true

-- ============================================================
-- HÀNH VI SPAWN VÀ CẤT XE
-- ============================================================
-- Tự động đưa người chơi vào ghế lái sau khi lấy xe ra
Config.WarpIntoVehicle = true

-- Khoảng cách tối đa (mét) để tìm và cất xe khi người chơi không ngồi trực tiếp trong xe
Config.MaxStoreDistance = 50.0

-- Tự động sửa chữa toàn bộ xe (máu động cơ, thân xe, bình xăng) khi lấy xe ra
Config.RepairOnSpawn = true

-- ============================================================
-- CẤU HÌNH HÌNH ẢNH XE
-- ============================================================
-- Các nguồn CDN lấy ảnh xe GTA V tự động theo tên model
Config.ImageCdns = {
    "https://raw.githubusercontent.com/root-cause/v-vehicle-hashes/master/images/%s.webp",
    "https://docs.fivem.net/vehicles/%s.webp"
}

-- ============================================================
-- THÔNG BÁO TIẾNG VIỆT
-- ============================================================
Config.Locale = {
    noVehicle = "Ban phai ngoi trong xe hoac dung gan xe de luu!",
    carSaved = "Da luu xe ~g~%s~w~ vao gara ca nhan! Bam ~y~CTRL + Y~w~ de mo menu.",
    carUpdated = "Da cap nhat ban do moi cho xe ~g~%s~w~!",
    carSpawned = "Da lay xe ~g~%s~w~ ra thanh cong!",
    carStored = "Da luu ban do moi va cat xe ~y~%s~w~ vao gara!",
    carStoredNotFound = "Xe ~y~%s~w~ da duoc cat vao gara.",
    carDeleted = "Da xoa xe ~r~%s~w~ khoi danh sach!",
    noPermission = "Ban khong co quyen thuc hien hanh dong nay!",
    alreadySpawned = "Xe dang o ngoai pho. Da cat xe cu va lay xe moi ra!",
    storeFailed = "Khong tim thay chiec xe nay o gan ban de cat!",
    invalidModel = "Model xe khong hop le!"
}
