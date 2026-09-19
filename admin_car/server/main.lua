-- ============================================================
-- ADMIN CAR - SERVER SIDE CONTROLLER & DATA PERSISTENCE
-- ============================================================

local DATA_FILE = 'data/cars.json'
local SavedCars = {}

-- Lấy mã định danh duy nhất của người chơi (ưu tiên license, sau đó discord, fivem, steam)
local function GetPlayerIdentifierKey(source)
    local identifiers = GetPlayerIdentifiers(source)
    local fallback = nil

    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 8) == "license:" then
            return id
        elseif string.sub(id, 1, 8) == "discord:" then
            fallback = fallback or id
        elseif string.sub(id, 1, 6) == "fivem:" then
            fallback = fallback or id
        elseif string.sub(id, 1, 6) == "steam:" then
            fallback = fallback or id
        end
    end

    return fallback or identifiers[1] or ("player_" .. tostring(source))
end

-- Kiểm tra quyền Admin (nếu Config.RequireAdmin được bật)
local function HasAdminPermission(source)
    if not Config.RequireAdmin then return true end
    if IsPlayerAceAllowed(source, Config.AdminAce) or IsPlayerAceAllowed(source, "command") then
        return true
    end
    return false
end

-- Tải dữ liệu xe từ file JSON
local function LoadData()
    local raw = LoadResourceFile(GetCurrentResourceName(), DATA_FILE)
    if raw and raw ~= "" then
        local status, decoded = pcall(json.decode, raw)
        if status and type(decoded) == "table" then
            SavedCars = decoded
            print(string.format("^2[admin_car]^7 Da tai du lieu xe thanh cong."))
            return
        else
            print(string.format("^3[admin_car]^7 Du lieu data/cars.json rong hoac bi loi dinh dang, khoi tao moi.^7"))
        end
    end
    SavedCars = {}
    SaveResourceFile(GetCurrentResourceName(), DATA_FILE, json.encode(SavedCars, { indent = true }), -1)
end

-- Lưu dữ liệu xe vào file JSON
local function SaveData()
    local encoded = json.encode(SavedCars, { indent = true })
    SaveResourceFile(GetCurrentResourceName(), DATA_FILE, encoded, -1)
end

-- Khởi động resource và nạp dữ liệu
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    LoadData()
end)

-- ============================================================
-- SERVER EVENTS
-- ============================================================

-- 1. Lưu xe mới vào danh sách cá nhân (/admincar)
RegisterNetEvent('admincar:server:saveCar', function(carData)
    local src = source
    if not HasAdminPermission(src) then
        TriggerClientEvent('admincar:client:notify', src, Config.Locale.noPermission, 'error')
        return
    end

    if not carData or not carData.props then
        TriggerClientEvent('admincar:client:notify', src, Config.Locale.noVehicle, 'error')
        return
    end

    local identifier = GetPlayerIdentifierKey(src)
    if not SavedCars[identifier] then
        SavedCars[identifier] = {}
    end

    -- Sinh mã ID xe duy nhất
    local carId = "car_" .. os.time() .. "_" .. math.random(100, 999)
    local carRecord = {
        id = carId,
        name = carData.name or "Xe Admin",
        model = carData.model,
        modelName = carData.modelName or "unknown",
        plate = carData.props.plate or "ADMIN",
        customImage = carData.customImage or nil,
        props = carData.props,
        createdAt = os.date('%Y-%m-%d %H:%M:%S')
    }

    table.insert(SavedCars[identifier], carRecord)
    SaveData()

    TriggerClientEvent('admincar:client:notify', src, string.format(Config.Locale.carSaved, carRecord.name), 'success')
    TriggerClientEvent('admincar:client:syncCars', src, SavedCars[identifier])
end)

-- 2. Yêu cầu lấy danh sách xe của bản thân để mở Menu
RegisterNetEvent('admincar:server:getCars', function()
    local src = source
    if not HasAdminPermission(src) then
        TriggerClientEvent('admincar:client:notify', src, Config.Locale.noPermission, 'error')
        return
    end

    local identifier = GetPlayerIdentifierKey(src)
    local playerCars = SavedCars[identifier] or {}
    TriggerClientEvent('admincar:client:openMenu', src, playerCars)
end)

-- 3. Cập nhật bản độ mới cho xe (Khi độ thêm xe ngoài đời rồi Cất Xe)
RegisterNetEvent('admincar:server:updateCarProps', function(carId, newProps)
    local src = source
    if not HasAdminPermission(src) then return end

    local identifier = GetPlayerIdentifierKey(src)
    local playerCars = SavedCars[identifier] or {}

    for _, car in ipairs(playerCars) do
        if car.id == carId then
            car.props = newProps
            if newProps.plate then
                car.plate = newProps.plate
            end
            car.updatedAt = os.date('%Y-%m-%d %H:%M:%S')
            SaveData()
            TriggerClientEvent('admincar:client:notify', src, string.format(Config.Locale.carStored, car.name), 'success')
            TriggerClientEvent('admincar:client:syncCars', src, playerCars)
            return
        end
    end

    -- Nếu không tìm thấy carId (có thể xe được spawn thủ công)
    TriggerClientEvent('admincar:client:notify', src, string.format(Config.Locale.carStoredNotFound, "Xe"), 'warning')
end)

-- 4. Xóa xe khỏi danh sách cá nhân
RegisterNetEvent('admincar:server:deleteCar', function(carId)
    local src = source
    if not HasAdminPermission(src) then return end

    local identifier = GetPlayerIdentifierKey(src)
    local playerCars = SavedCars[identifier] or {}

    for i, car in ipairs(playerCars) do
        if car.id == carId then
            local carName = car.name
            table.remove(playerCars, i)
            SaveData()
            TriggerClientEvent('admincar:client:notify', src, string.format(Config.Locale.carDeleted, carName), 'info')
            TriggerClientEvent('admincar:client:syncCars', src, playerCars)
            return
        end
    end
end)

-- 5. Cập nhật link ảnh hoặc tên tùy chỉnh cho xe
RegisterNetEvent('admincar:server:updateCarMetadata', function(carId, newName, newImage)
    local src = source
    if not HasAdminPermission(src) then return end

    local identifier = GetPlayerIdentifierKey(src)
    local playerCars = SavedCars[identifier] or {}

    for _, car in ipairs(playerCars) do
        if car.id == carId then
            if newName and newName ~= "" then
                car.name = newName
            end
            if newImage ~= nil then
                car.customImage = newImage
            end
            SaveData()
            TriggerClientEvent('admincar:client:notify', src, "Da cap nhat thong tin xe!", 'success')
            TriggerClientEvent('admincar:client:syncCars', src, playerCars)
            return
        end
    end
end)
