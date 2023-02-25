local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

domiC = Tunnel.getInterface(GetCurrentResourceName(),GetCurrentResourceName())

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", GetCurrentResourceName())

local isRepairing = {}

local function CallBackRepair(user_id, vehNet)
    local player = vRP.getUserSource({user_id})
    -- player id가 없거나, 권한이 없으면 리턴합니다.
    if player == nil or not vRP.hasPermission({user_id, cfg.permission}) then return end

    -- 이미 수리중이면 리턴합니다.
    if isRepairing[user_id] ~= nil then
        return
    end

    -- 수리도구 1개가 부족하다면 리턴합니다.
    if not vRP.tryGetInventoryItem({user_id, cfg.tool_item, 1, true}) then
        return
    end

    isRepairing[user_id] = true
    -- 수리 모션
    vRPclient.playAnim(player, {false, {task = "WORLD_HUMAN_WELDING"}, false})

    Wait(1000 * cfg.delay)
    isRepairing[user_id] = nil

    -- 모션 해제
    vRPclient.stopAnim(player, {false, true})

    -- 플레이어에게 차량수리를 요청합니다. (server -> client)
    domiC.fixVehicle(player, {vehNet})
end

Citizen.CreateThread(function()
    local smartHotKey
    while smartHotKey == nil do
        TriggerEvent("domi_smarthotkey:getSharedObject", function(domiObject)
            smartHotKey = domiObject
        end)
        Wait(10)
    end

    -- 메뉴 등록
    cfg.menu.perm = cfg.permission
    smartHotKey.RegisterMenu("vehRepair", 2, cfg.menu)

    -- 콜백함수 등록
    smartHotKey.RegisterMenuCallback("vehRepair", 2, CallBackRepair)
end)