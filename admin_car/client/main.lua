-- ============================================================
-- ADMIN CAR - CLIENT CONTROLLER & HOTKEY HANDLER
-- ============================================================

local isMenuOpen = false
local cachedCars = {}
local spawnedCars = {} -- Lưu trữ entity xe theo carId

-- Bảng chuyển đổi ký tự tiếng Việt có dấu sang không dấu để tránh lỗi font ô vuông [] trong GTA V
local vietnameseAccents = {
    ["à"]="a", ["á"]="a", ["ả"]="a", ["ã"]="a", ["ạ"]="a",
    ["ă"]="a", ["ằ"]="a", ["ắ"]="a", ["ẳ"]="a", ["ẵ"]="a", ["ặ"]="a",
    ["â"]="a", ["ầ"]="a", ["ấ"]="a", ["ẩ"]="a", ["ẫ"]="a", ["ậ"]="a",
    ["đ"]="d",
    ["è"]="e", ["é"]="e", ["ẻ"]="e", ["ẽ"]="e", ["ẹ"]="e",
    ["ê"]="e", ["ề"]="e", ["ế"]="e", ["ể"]="e", ["ễ"]="e", ["ệ"]="e",
    ["ì"]="i", ["í"]="i", ["ỉ"]="i", ["ĩ"]="i", ["ị"]="i",
    ["ò"]="o", ["ó"]="o", ["ỏ"]="o", ["õ"]="o", ["ọ"]="o",
    ["ô"]="o", ["ồ"]="o", ["ố"]="o", ["ổ"]="o", ["ỗ"]="o", ["ộ"]="o",
    ["ơ"]="o", ["ờ"]="o", ["ớ"]="o", ["ở"]="o", ["ỡ"]="o", ["ợ"]="o",
    ["ù"]="u", ["ú"]="u", ["ủ"]="u", ["ũ"]="u", ["ụ"]="u",
    ["ư"]="u", ["ừ"]="u", ["ứ"]="u", ["ử"]="u", ["ữ"]="u", ["ự"]="u",
    ["ỳ"]="y", ["ý"]="y", ["ỷ"]="y", ["ỹ"]="y", ["ỵ"]="y",
    ["À"]="A", ["Á"]="A", ["Ả"]="A", ["Ã"]="A", ["Ạ"]="A",
    ["Ă"]="A", ["Ằ"]="A", ["Ắ"]="A", ["Ẳ"]="A", ["Ẵ"]="A", ["Ặ"]="A",
    ["Â"]="A", ["Ầ"]="A", ["Ấ"]="A", ["Ẩ"]="A", ["Ẫ"]="A", ["Ậ"]="A",
    ["Đ"]="D",
    ["È"]="E", ["É"]="E", ["Ẻ"]="E", ["Ẽ"]="E", ["Ẹ"]="E",
    ["Ê"]="E", ["Ề"]="E", ["Ế"]="E", ["Ể"]="E", ["Ễ"]="E", ["Ệ"]="E",
    ["Ì"]="I", ["Í"]="I", ["Ỉ"]="I", ["Ĩ"]="I", ["Ị"]="I",
    ["Ò"]="O", ["Ó"]="O", ["Ỏ"]="O", ["Õ"]="O", ["Ọ"]="O",
    ["Ô"]="O", ["Ồ"]="O", ["Ố"]="O", ["Ổ"]="O", ["Ỗ"]="O", ["Ộ"]="O",
    ["Ơ"]="O", ["Ờ"]="O", ["Ớ"]="O", ["Ở"]="O", ["Ỡ"]="O", ["Ợ"]="O",
    ["Ù"]="U", ["Ú"]="U", ["Ủ"]="U", ["Ũ"]="U", ["Ụ"]="U",
    ["Ư"]="U", ["Ừ"]="U", ["Ứ"]="U", ["Ử"]="U", ["Ữ"]="U", ["Ự"]="U",
    ["Ỳ"]="Y", ["Ý"]="Y", ["Ỷ"]="Y", ["Ỹ"]="Y", ["Ỵ"]="Y"
}

local function CleanGtaText(str)
    if not str then return "" end
    for accent, replacement in pairs(vietnameseAccents) do
        str = string.gsub(str, accent, replacement)
    end
    return str
end

-- Hàm hiển thị thông báo GTA V góc trái màn hình (đã xử lý sạch lỗi font)
local function ShowNotification(text)
    local cleanText = CleanGtaText(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(cleanText)
    DrawNotification(false, false)
end

RegisterNetEvent('admincar:client:notify', function(msg, msgType)
    ShowNotification(msg)
    if isMenuOpen then
        SendNUIMessage({
            action = 'notify',
            message = msg,
            type = msgType or 'info'
        })
    end
end)

-- Kiểm tra tổ hợp phím CTRL
local function IsCtrlPressed()
    return IsControlPressed(0, 36) or IsDisabledControlPressed(0, 36)
        or IsControlPressed(1, 36) or IsDisabledControlPressed(1, 36)
        or IsControlPressed(2, 36) or IsDisabledControlPressed(2, 36)
        or IsControlPressed(0, 224) or IsDisabledControlPressed(0, 224)
        or IsControlPressed(0, 210) or IsDisabledControlPressed(0, 210)
        or IsControlPressed(0, 326) or IsDisabledControlPressed(0, 326)
end

-- Tìm xe gần nhất xung quanh người chơi
local function GetNearbyVehicle(radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local handle, veh = FindFirstVehicle()
    if not handle or handle == -1 then return 0 end

    local success
    local closestVehicle = 0
    local minDistance = radius or 5.0

    repeat
        if DoesEntityExist(veh) then
            local vehCoords = GetEntityCoords(veh)
            local dist = #(coords - vehCoords)
            if dist < minDistance and not IsPedInVehicle(ped, veh, false) then
                minDistance = dist
                closestVehicle = veh
            end
        end
        success, veh = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)

    return closestVehicle
end

-- ============================================================
-- MENU CONTROLLER
-- ============================================================
local function OpenMenu()
    if isMenuOpen then return end
    TriggerServerEvent('admincar:server:getCars')
end

local function CloseMenu()
    if not isMenuOpen then return end
    isMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeMenu' })
end

RegisterNetEvent('admincar:client:openMenu', function(cars)
    cachedCars = cars or {}
    isMenuOpen = true
    SetNuiFocus(true, true)

    -- Đánh dấu trạng thái xe nào đang được spawn ra ngoài đời
    local carsData = {}
    for _, car in ipairs(cachedCars) do
        local isSpawned = false
        local vehEntity = spawnedCars[car.id]
        if vehEntity and DoesEntityExist(vehEntity) then
            isSpawned = true
        end

        local carCopy = {}
        for k, v in pairs(car) do carCopy[k] = v end
        carCopy.isSpawned = isSpawned
        table.insert(carsData, carCopy)
    end

    SendNUIMessage({
        action = 'openMenu',
        cars = carsData
    })
end)

RegisterNetEvent('admincar:client:syncCars', function(cars)
    cachedCars = cars or {}
    if isMenuOpen then
        local carsData = {}
        for _, car in ipairs(cachedCars) do
            local isSpawned = false
            local vehEntity = spawnedCars[car.id]
            if vehEntity and DoesEntityExist(vehEntity) then
                isSpawned = true
            end

            local carCopy = {}
            for k, v in pairs(car) do carCopy[k] = v end
            carCopy.isSpawned = isSpawned
            table.insert(carsData, carCopy)
        end

        SendNUIMessage({
            action = 'updateCars',
            cars = carsData
        })
    end
end)

-- ============================================================
-- ĐĂNG KÝ PHÍM TẮT CTRL + Y
-- ============================================================
RegisterCommand('+admincarmenu', function()
    if not isMenuOpen then
        if not Config.RequireCtrl or IsCtrlPressed() then
            OpenMenu()
        end
    else
        CloseMenu()
    end
end, false)
RegisterCommand('-admincarmenu', function() end, false)

RegisterKeyMapping('+admincarmenu', 'Menu Xe Ca Nhan Admin (CTRL + Y)', 'keyboard', Config.KeyMapping)

-- Lệnh mở menu bằng khung chat: /admincarmenu hoặc /admincars
RegisterCommand(Config.Commands.menu, function()
    OpenMenu()
end, false)

RegisterCommand('admincars', function()
    OpenMenu()
end, false)

-- ============================================================
-- LỆNH /admincar: LƯU XE HIỆN TẠI VÀO DANH SÁCH BẢN THÂN
-- ============================================================
RegisterCommand(Config.Commands.save, function(source, args)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- Nếu không ngồi trong xe, tìm xe đứng gần nhất (bán kính 5m)
    if vehicle == 0 then
        vehicle = GetNearbyVehicle(5.0)
    end

    -- Nếu người chơi cung cấp tên model (vd: /admincar t20) mà chưa có xe nào
    if vehicle == 0 and args[1] then
        local modelHash = GetHashKey(args[1])
        if IsModelInCdimage(modelHash) and IsModelAVehicle(modelHash) then
            RequestModel(modelHash)
            local timeout = 0
            while not HasModelLoaded(modelHash) and timeout < 100 do
                Wait(50)
                timeout = timeout + 1
            end

            if HasModelLoaded(modelHash) then
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
                SetEntityAsMissionEntity(vehicle, true, true)
                TaskWarpPedIntoVehicle(ped, vehicle, -1)
                SetModelAsNoLongerNeeded(modelHash)
                Wait(200)
            end
        end
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        ShowNotification(Config.Locale.noVehicle)
        return
    end

    -- Trích xuất toàn bộ 100% bản độ hiện tại của xe
    local props = GetVehicleProperties(vehicle)
    if not props then
        ShowNotification("Lỗi khi lấy thông số xe!")
        return
    end

    -- Xác định tên xe hiển thị
    local modelHash = props.model
    local modelName = GetDisplayNameFromVehicleModel(modelHash)
    local label = GetLabelText(modelName)
    if label == "NULL" or label == "" or not label then
        label = modelName
    end

    local customName = label
    if args and #args > 0 then
        customName = table.concat(args, " ")
    end

    TriggerServerEvent('admincar:server:saveCar', {
        name = customName,
        model = modelHash,
        modelName = string.lower(modelName),
        props = props
    })
end, false)

-- ============================================================
-- CÁC HÀM XỬ LÝ LẤY XE VÀ CẤT XE (SPAWN & STORE)
-- ============================================================

-- Tìm thông tin xe trong cache theo carId
local function FindCarById(carId)
    for _, car in ipairs(cachedCars) do
        if car.id == carId then
            return car
        end
    end
    return nil
end

-- 1. LẤY XE (SPAWN CAR)
local function SpawnCar(carId)
    local car = FindCarById(carId)
    if not car or not car.props then
        ShowNotification("Không tìm thấy dữ liệu xe để lấy ra!")
        return
    end

    local ped = PlayerPedId()
    local modelHash = car.props.model or tonumber(car.model)

    if not modelHash then
        ShowNotification(Config.Locale.invalidModel)
        return
    end

    -- Nếu xe này đã được lấy ra trước đó, xóa xe cũ hoặc cất xe cũ trước
    local existingVeh = spawnedCars[carId]
    if existingVeh and DoesEntityExist(existingVeh) then
        -- Cập nhật lại bản độ mới nhất của xe cũ trước khi xóa
        local currentProps = GetVehicleProperties(existingVeh)
        if currentProps then
            car.props = currentProps
            TriggerServerEvent('admincar:server:updateCarProps', carId, currentProps)
        end
        SetEntityAsMissionEntity(existingVeh, true, true)
        DeleteVehicle(existingVeh)
        DeleteEntity(existingVeh)
        spawnedCars[carId] = nil
    end

    -- Tải model xe
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(modelHash) then
        ShowNotification(Config.Locale.invalidModel)
        return
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Tạo xe mới
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z + 0.2, heading, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)

    -- Phục hồi 100% bản độ đã lưu
    SetVehicleProperties(vehicle, car.props)
    SetModelAsNoLongerNeeded(modelHash)

    -- Đưa người chơi vào ghế lái
    if Config.WarpIntoVehicle then
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
    end

    spawnedCars[carId] = vehicle
    ShowNotification(string.format(Config.Locale.carSpawned, car.name))

    -- Cập nhật lại UI nếu menu đang mở
    if isMenuOpen then
        TriggerServerEvent('admincar:server:getCars')
    end
end

-- 2. CẤT XE (STORE CAR - TỰ ĐỘNG LƯU TOÀN BỘ BẢN ĐỘ MỚI)
local function StoreCar(carId)
    local car = FindCarById(carId)
    if not car then
        ShowNotification("Không tìm thấy thông tin xe!")
        return
    end

    local ped = PlayerPedId()
    local targetVehicle = 0

    -- Bước 1: Kiểm tra xem người chơi có đang ngồi trực tiếp trong xe này không
    local currentVehicle = GetVehiclePedIsIn(ped, false)
    if currentVehicle ~= 0 then
        local currentPlate = string.gsub(GetVehicleNumberPlateText(currentVehicle), "^%s*(.-)%s*$", "%1")
        local savedPlate = car.props and car.props.plate and string.gsub(car.props.plate, "^%s*(.-)%s*$", "%1") or ""
        local currentModel = GetEntityModel(currentVehicle)
        local savedModel = car.props and car.props.model or tonumber(car.model)

        if currentVehicle == spawnedCars[carId] or (currentPlate == savedPlate and currentModel == savedModel) then
            targetVehicle = currentVehicle
        end
    end

    -- Bước 2: Nếu không ngồi trong xe, kiểm tra handle đã lưu
    if targetVehicle == 0 and spawnedCars[carId] and DoesEntityExist(spawnedCars[carId]) then
        local vehCoords = GetEntityCoords(spawnedCars[carId])
        local dist = #(GetEntityCoords(ped) - vehCoords)
        if dist <= Config.MaxStoreDistance then
            targetVehicle = spawnedCars[carId]
        end
    end

    -- Bước 3: Tìm xe theo biển số trong bán kính gần
    if targetVehicle == 0 and car.props and car.props.plate then
        local savedPlate = string.gsub(car.props.plate, "^%s*(.-)%s*$", "%1")
        local handle, veh = FindFirstVehicle()
        if handle and handle ~= -1 then
            local success
            repeat
                if DoesEntityExist(veh) then
                    local plate = string.gsub(GetVehicleNumberPlateText(veh), "^%s*(.-)%s*$", "%1")
                    if plate == savedPlate then
                        local dist = #(GetEntityCoords(ped) - GetEntityCoords(veh))
                        if dist <= Config.MaxStoreDistance then
                            targetVehicle = veh
                            break
                        end
                    end
                end
                success, veh = FindNextVehicle(handle)
            until not success
            EndFindVehicle(handle)
        end
    end

    -- NẾU TÌM THẤY CHIẾC XE NGOÀI ĐỜI:
    if targetVehicle ~= 0 and DoesEntityExist(targetVehicle) then
        -- QUAN TRỌNG: Trích xuất 100% bản độ hiện tại (màu mới, turbo, động cơ nâng cấp,...)
        local latestProps = GetVehicleProperties(targetVehicle)

        -- Gửi lên server để cập nhật đè vào bản độ đã lưu
        TriggerServerEvent('admincar:server:updateCarProps', carId, latestProps)

        -- Xóa xe khỏi bản đồ
        SetEntityAsMissionEntity(targetVehicle, true, true)
        DeleteVehicle(targetVehicle)
        DeleteEntity(targetVehicle)
        spawnedCars[carId] = nil

        ShowNotification(string.format(Config.Locale.carStored, car.name))
    else
        -- Không tìm thấy xe ngoài phố, chỉ đánh dấu trạng thái cất vào gara
        spawnedCars[carId] = nil
        ShowNotification(string.format(Config.Locale.carStoredNotFound, car.name))
    end

    -- Cập nhật lại UI
    if isMenuOpen then
        TriggerServerEvent('admincar:server:getCars')
    end
end

-- 3. CẤT XE NHANH CHIẾC XE ĐANG NGỒI (/admincatxe hoặc nút trên giao diện)
local function QuickStoreCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        ShowNotification("Bạn không ngồi trong chiếc xe nào để cất!")
        return
    end

    local currentPlate = string.gsub(GetVehicleNumberPlateText(vehicle), "^%s*(.-)%s*$", "%1")
    local currentModel = GetEntityModel(vehicle)
    local foundCarId = nil

    -- Tìm xem chiếc xe này có nằm trong danh sách gara đã lưu không
    for _, car in ipairs(cachedCars) do
        local savedPlate = car.props and car.props.plate and string.gsub(car.props.plate, "^%s*(.-)%s*$", "%1") or ""
        local savedModel = car.props and car.props.model or tonumber(car.model)
        if savedPlate == currentPlate and savedModel == currentModel then
            foundCarId = car.id
            break
        end
    end

    if foundCarId then
        StoreCar(foundCarId)
    else
        -- Nếu là xe chưa lưu, lấy thông số lưu mới luôn hoặc chỉ cất
        local latestProps = GetVehicleProperties(vehicle)
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
        DeleteEntity(vehicle)
        ShowNotification("~g~Đã cất chiếc xe hiện tại.")
    end

    if isMenuOpen then
        TriggerServerEvent('admincar:server:getCars')
    end
end

RegisterCommand(Config.Commands.quickStore, function()
    QuickStoreCurrentVehicle()
end, false)

-- ============================================================
-- NUI CALLBACKS (GIAO DIỆN WEB GỬI VỀ CLIENT LUA)
-- ============================================================

RegisterNUICallback('close', function(data, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    if data and data.carId then
        SpawnCar(data.carId)
        CloseMenu()
    end
    cb('ok')
end)

RegisterNUICallback('storeVehicle', function(data, cb)
    if data and data.carId then
        StoreCar(data.carId)
    end
    cb('ok')
end)

RegisterNUICallback('quickStore', function(data, cb)
    QuickStoreCurrentVehicle()
    cb('ok')
end)

RegisterNUICallback('deleteVehicle', function(data, cb)
    if data and data.carId then
        TriggerServerEvent('admincar:server:deleteCar', data.carId)
    end
    cb('ok')
end)

RegisterNUICallback('updateMetadata', function(data, cb)
    if data and data.carId then
        TriggerServerEvent('admincar:server:updateCarMetadata', data.carId, data.name, data.customImage)
    end
    cb('ok')
end)
