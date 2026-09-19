-- ============================================================
-- GTA5VN SPEEDOMETER & CAR HUD - CLIENT SCRIPT
-- ============================================================

local isInVehicle = false
local currentVehicle = 0
local isSeatbeltOn = false
local lastVehicleVelocity = vector3(0.0, 0.0, 0.0)
local isLeftIndicator = false
local isRightIndicator = false
local isHazardActive = false
local lastChimeTime = 0

-- Chuyển đổi chuỗi thông báo sang không dấu chuẩn GTA V
local function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, false)
end

-- ============================================================
-- PHÍM TẮT DÂY AN TOÀN (SEATBELT)
-- ============================================================
local function ToggleSeatbelt()
    if not isInVehicle then return end
    local ped = PlayerPedId()
    local class = GetVehicleClass(currentVehicle)

    -- Không áp dụng dây an toàn cho xe đạp (13), xe máy (8), cano/thuyền (14)
    if class == 8 or class == 13 or class == 14 then
        return
    end

    isSeatbeltOn = not isSeatbeltOn

    -- Gửi âm thanh click về NUI
    SendNUIMessage({
        action = "playSeatbeltSound",
        state = isSeatbeltOn
    })

    if isSeatbeltOn then
        ShowNotification("~g~" .. Config.Locale.seatbeltOn)
    else
        ShowNotification("~y~" .. Config.Locale.seatbeltOff)
    end
end

RegisterCommand('toggle_seatbelt', function()
    ToggleSeatbelt()
end, false)

RegisterKeyMapping('toggle_seatbelt', 'That/Thao Day An Toan (GTA5VN)', 'keyboard', Config.SeatbeltKey)

-- ============================================================
-- HỆ THỐNG ĐÈN XI-NHAN & KHẨN CẤP
-- ============================================================
local function ToggleLeftIndicator()
    if not isInVehicle then return end
    isLeftIndicator = not isLeftIndicator
    isRightIndicator = false
    isHazardActive = false
    SetVehicleIndicatorLights(currentVehicle, 1, isLeftIndicator)
    SetVehicleIndicatorLights(currentVehicle, 0, false)
end

local function ToggleRightIndicator()
    if not isInVehicle then return end
    isRightIndicator = not isRightIndicator
    isLeftIndicator = false
    isHazardActive = false
    SetVehicleIndicatorLights(currentVehicle, 0, isRightIndicator)
    SetVehicleIndicatorLights(currentVehicle, 1, false)
end

local function ToggleHazardLights()
    if not isInVehicle then return end
    isHazardActive = not isHazardActive
    isLeftIndicator = isHazardActive
    isRightIndicator = isHazardActive
    SetVehicleIndicatorLights(currentVehicle, 0, isHazardActive)
    SetVehicleIndicatorLights(currentVehicle, 1, isHazardActive)
end

RegisterCommand('indicator_left', function() ToggleLeftIndicator() end, false)
RegisterCommand('indicator_right', function() ToggleRightIndicator() end, false)
RegisterCommand('indicator_hazard', function() ToggleHazardLights() end, false)

RegisterKeyMapping('indicator_left', 'Xi-nhan Trai (GTA5VN)', 'keyboard', '[')
RegisterKeyMapping('indicator_right', 'Xi-nhan Phai (GTA5VN)', 'keyboard', ']')
RegisterKeyMapping('indicator_hazard', 'Den Khan Cap Hazard (GTA5VN)', 'keyboard', 'BACK')

-- ============================================================
-- VÒNG LẶP CHÍNH CẬP NHẬT ĐỒNG HỒ TỐC ĐỘ (60FPS NUI / LOW CPU)
-- ============================================================
Citizen.CreateThread(function()
    local isHudVisible = false

    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and DoesEntityExist(vehicle) and not IsPlayerDead(PlayerId()) then
            -- Khi vừa lên xe
            if not isInVehicle or vehicle ~= currentVehicle then
                isInVehicle = true
                currentVehicle = vehicle
                isSeatbeltOn = false
                isLeftIndicator = false
                isRightIndicator = false
                isHazardActive = false
                lastVehicleVelocity = GetEntityVelocity(vehicle)

                SendNUIMessage({ action = "show" })
                isHudVisible = true
            end

            -- Ẩn khi tạm dừng game (Pause Menu)
            if IsPauseMenuActive() then
                if isHudVisible then
                    SendNUIMessage({ action = "hide" })
                    isHudVisible = false
                end
                Citizen.Wait(200)
            else
                if not isHudVisible then
                    SendNUIMessage({ action = "show" })
                    isHudVisible = true
                end

                -- LẤY DỮ LIỆU XE
                local rawSpeed = GetEntitySpeed(vehicle)
                local speed = math.floor(rawSpeed * Config.SpeedMultiplier + 0.5)
                local rpm = GetVehicleCurrentRpm(vehicle)
                local gear = GetVehicleCurrentGear(vehicle)
                local fuel = math.floor(GetVehicleFuelLevel(vehicle) + 0.5)
                local engineHealth = GetVehicleEngineHealth(vehicle)
                local handbrake = GetVehicleHandbrake(vehicle)

                -- Trạng thái số xe (P, R, N, 1-7)
                local gearDisplay = "1"
                if rawSpeed < 0.2 and handbrake then
                    gearDisplay = "P"
                elseif gear == 0 then
                    local velocity = GetEntitySpeedVector(vehicle, true)
                    if velocity.y < -0.1 or IsControlPressed(0, 72) then
                        gearDisplay = "R"
                    else
                        gearDisplay = "N"
                    end
                else
                    gearDisplay = tostring(gear)
                end

                -- Trạng thái đèn xe
                local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
                local lightStatus = 0 -- 0: tắt, 1: đèn cốt, 2: đèn pha
                if highbeamsOn == 1 or highbeamsOn == true then
                    lightStatus = 2
                elseif lightsOn == 1 or lightsOn == true then
                    lightStatus = 1
                end

                -- Cảnh báo chuông dây an toàn khi chạy trên 25 km/h
                local class = GetVehicleClass(vehicle)
                if not isSeatbeltOn and speed > Config.ChimeSpeed and (class ~= 8 and class ~= 13 and class ~= 14) then
                    local now = GetGameTimer()
                    if now - lastChimeTime > 2500 then
                        lastChimeTime = now
                        SendNUIMessage({ action = "playChime" })
                    end
                end

                -- GỬI CẬP NHẬT VỀ NUI
                SendNUIMessage({
                    action = "update",
                    speed = speed,
                    rpm = rpm,
                    gear = gearDisplay,
                    fuel = fuel,
                    engineHealth = engineHealth,
                    handbrake = handbrake,
                    lights = lightStatus,
                    leftIndicator = isLeftIndicator,
                    rightIndicator = isRightIndicator,
                    seatbelt = isSeatbeltOn,
                    unit = Config.SpeedUnit,
                    maxSpeed = Config.MaxGaugeSpeed
                })

                -- ============================================================
                -- CƠ CHẾ VA CHẠM & VĂNG KÍNH KHI KHÔNG CÀI DÂY AN TOÀN
                -- ============================================================
                if Config.EjectionOnCrash and not isSeatbeltOn and (class ~= 8 and class ~= 13 and class ~= 14) then
                    local curVelocity = GetEntityVelocity(vehicle)
                    local prevSpeedKmh = #(lastVehicleVelocity) * 3.6
                    local speedDrop = #(lastVehicleVelocity - curVelocity) * 3.6

                    -- Nếu tốc độ trước va chạm > 65 km/h và tốc độ giảm đột ngột > 50 km/h (đâm trực diện vật cản)
                    if prevSpeedKmh > Config.MinSpeedForEjection and speedDrop > 50.0 then
                        local forwardVector = GetEntityForwardVector(vehicle)
                        local pedCoords = GetEntityCoords(ped)

                        -- Đưa nhân vật ra khỏi xe xuyên qua kính lái
                        SetEntityCoords(ped, pedCoords.x + forwardVector.x * 1.5, pedCoords.y + forwardVector.y * 1.5, pedCoords.z + 0.6, true, true, true, false)
                        SetEntityVelocity(ped, lastVehicleVelocity.x * 1.1, lastVehicleVelocity.y * 1.1, lastVehicleVelocity.z * 1.1 + 1.5)
                        SetPedToRagdoll(ped, 3500, 3500, 0, 0, 0, 0)
                        ApplyDamageToPed(ped, Config.EjectionDamage, false)
                        ShowNotification("~r~Ban da bi vang khoi xe do khong that day an toan!")
                    end

                    lastVehicleVelocity = curVelocity
                else
                    lastVehicleVelocity = GetEntityVelocity(vehicle)
                end

                Citizen.Wait(Config.UpdateInterval)
            end
        else
            -- Khi rời xe hoặc không ngồi trong xe
            if isInVehicle then
                isInVehicle = false
                currentVehicle = 0
                isSeatbeltOn = false
                isLeftIndicator = false
                isRightIndicator = false
                isHazardActive = false
                isHudVisible = false
                SendNUIMessage({ action = "hide" })
            end
            Citizen.Wait(500) -- Nghỉ khi không ngồi trong xe, tối ưu 0.00ms
        end
    end
end)
