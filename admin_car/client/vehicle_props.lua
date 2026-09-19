-- ============================================================
-- MODULE XỬ LÝ & LƯU TRỮ THÔNG SỐ ĐỘ XE (VEHICLE PROPERTIES)
-- ============================================================

-- Trích xuất 100% thông số bản độ hiện tại của xe
function GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return nil end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    local hasCustomPrimary = GetIsVehiclePrimaryColourCustom(vehicle)
    local customPrimaryColor = nil
    if hasCustomPrimary then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        customPrimaryColor = { r, g, b }
    end

    local hasCustomSecondary = GetIsVehicleSecondaryColourCustom(vehicle)
    local customSecondaryColor = nil
    if hasCustomSecondary then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        customSecondaryColor = { r, g, b }
    end

    local interiorColor = nil
    if GetVehicleInteriorColour then
        interiorColor = GetVehicleInteriorColour(vehicle)
    end

    local dashboardColor = nil
    if GetVehicleDashboardColour then
        dashboardColor = GetVehicleDashboardColour(vehicle)
    end

    local xenonColor = -1
    if GetVehicleXenonLightsColour then
        xenonColor = GetVehicleXenonLightsColour(vehicle)
    end

    local neonEnabled = {
        IsVehicleNeonLightEnabled(vehicle, 0) == 1 or IsVehicleNeonLightEnabled(vehicle, 0) == true,
        IsVehicleNeonLightEnabled(vehicle, 1) == 1 or IsVehicleNeonLightEnabled(vehicle, 1) == true,
        IsVehicleNeonLightEnabled(vehicle, 2) == 1 or IsVehicleNeonLightEnabled(vehicle, 2) == true,
        IsVehicleNeonLightEnabled(vehicle, 3) == 1 or IsVehicleNeonLightEnabled(vehicle, 3) == true
    }

    local r, g, b = GetVehicleNeonLightsColour(vehicle)
    local neonColor = { r, g, b }

    local sr, sg, sb = GetVehicleTyreSmokeColor(vehicle)
    local tyreSmokeColor = { sr, sg, sb }

    -- Lấy toàn bộ 50 loại phụ tùng độ xe (Mods 0 đến 49)
    local mods = {}
    for i = 0, 49 do
        mods[tostring(i)] = GetVehicleMod(vehicle, i)
    end

    -- Lấy Extras (1 đến 14)
    local extras = {}
    for i = 1, 14 do
        if DoesExtraExist(vehicle, i) then
            extras[tostring(i)] = IsVehicleExtraTurnedOn(vehicle, i) == 1 or IsVehicleExtraTurnedOn(vehicle, i) == true
        end
    end

    local livery = GetVehicleLivery(vehicle)
    if livery == -1 then
        livery = GetVehicleMod(vehicle, 48)
    end

    local props = {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = math.floor(GetVehicleBodyHealth(vehicle) + 0.5),
        engineHealth = math.floor(GetVehicleEngineHealth(vehicle) + 0.5),
        tankHealth = math.floor(GetVehiclePetrolTankHealth(vehicle) + 0.5),
        fuelLevel = math.floor(GetVehicleFuelLevel(vehicle) + 0.5),
        dirtLevel = math.floor(GetVehicleDirtLevel(vehicle) + 0.5),

        color1 = colorPrimary,
        color2 = colorSecondary,
        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        interiorColor = interiorColor,
        dashboardColor = dashboardColor,

        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenonColor = xenonColor,

        neonEnabled = neonEnabled,
        neonColor = neonColor,
        tyreSmokeColor = tyreSmokeColor,

        mods = mods,
        modCustomTiresF = GetVehicleModVariation(vehicle, 23),
        modCustomTiresR = GetVehicleModVariation(vehicle, 24),
        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),

        modLivery = livery,
        extras = extras,
        bulletProofTyres = not GetVehicleTyresCanBurst(vehicle)
    }

    return props
end

-- Áp dụng 100% thông số bản độ vào chiếc xe vừa spawn
function SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) or not props then return end

    SetVehicleModKit(vehicle, 0)

    -- Biển số
    if props.plate then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end
    if props.plateIndex then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end

    -- Màu sơn gốc GTA
    if props.color1 and props.color2 then
        SetVehicleColours(vehicle, props.color1, props.color2)
    end

    -- Màu ngọc trai & Màu mâm
    if props.pearlescentColor and props.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor)
    end

    -- Màu sơn tùy chỉnh RGB (Custom RGB Paint)
    if props.customPrimaryColor then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3])
    else
        ClearVehicleCustomPrimaryColour(vehicle)
    end

    if props.customSecondaryColor then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3])
    else
        ClearVehicleCustomSecondaryColour(vehicle)
    end

    -- Màu nội thất & taplo
    if props.interiorColor and SetVehicleInteriorColour then
        SetVehicleInteriorColour(vehicle, props.interiorColor)
    end
    if props.dashboardColor and SetVehicleDashboardColour then
        SetVehicleDashboardColour(vehicle, props.dashboardColor)
    end

    -- Kiểu mâm xe (phải set trước khi set mod bánh xe)
    if props.wheels then
        SetVehicleWheelType(vehicle, props.wheels)
    end

    -- Độ tối kính (Window Tint)
    if props.windowTint then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    -- Đèn Xenon & Màu Xenon
    if props.modXenon ~= nil then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end
    if props.xenonColor and SetVehicleXenonLightsColour and props.xenonColor ~= -1 then
        SetVehicleXenonLightsColour(vehicle, props.xenonColor)
    end

    -- Đèn Neon gầm xe
    if props.neonEnabled then
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i + 1] or false)
        end
    end
    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    -- Khói bánh xe
    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
    end
    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    -- Turbo
    if props.modTurbo ~= nil then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end

    -- Toàn bộ 50 phụ tùng độ xe (Spoilers, động cơ, phanh, hộp số, pô, bodykit, ...)
    if props.mods then
        for i = 0, 49 do
            local modVal = props.mods[tostring(i)]
            if modVal ~= nil then
                if i == 23 then
                    SetVehicleMod(vehicle, 23, modVal, props.modCustomTiresF or false)
                elseif i == 24 then
                    SetVehicleMod(vehicle, 24, modVal, props.modCustomTiresR or false)
                else
                    SetVehicleMod(vehicle, i, modVal, false)
                end
            end
        end
    end

    -- Lốp chống đạn
    if props.bulletProofTyres ~= nil then
        SetVehicleTyresCanBurst(vehicle, not props.bulletProofTyres)
    end

    -- Tem xe (Livery)
    if props.modLivery ~= nil and props.modLivery ~= -1 then
        SetVehicleLivery(vehicle, props.modLivery)
        SetVehicleMod(vehicle, 48, props.modLivery, false)
    end

    -- Extras (1 đến 14)
    if props.extras then
        for i = 1, 14 do
            if DoesExtraExist(vehicle, i) then
                local isOn = props.extras[tostring(i)]
                SetVehicleExtra(vehicle, i, isOn and 0 or 1)
            end
        end
    end

    -- Độ bền xe & mức nhiên liệu
    if Config.RepairOnSpawn then
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
    else
        if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
        if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
        if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
        if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
    end

    if props.fuelLevel and SetVehicleFuelLevel then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end
end
