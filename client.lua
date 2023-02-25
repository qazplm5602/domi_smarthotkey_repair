domi = {}
Tunnel.bindInterface(GetCurrentResourceName(),domi)

function domi.fixVehicle(vehNet)
    -- netID를 entity ID로 변환합니다.
    local vehicle = NetToVeh(vehNet)
    
    -- 차량이 없으면 리턴합니다.
    if not IsEntityAVehicle(vehicle) then
        return
    end

    local timeout = 500
    -- 엔티티 제어권한을 가질때까지 대기합니다.
    while not NetworkHasControlOfEntity(vehicle) do
        Wait(1)
        -- 엔티티 제어를 요청합니다.
        NetworkRequestControlOfEntity(vehicle)
        timeout = timeout - 1
        if timeout <= 0 then -- 제어 권한을 가져오지 못함 (시간초과)
            return
        end
    end

    -- 수리 하기 전 기름을 저장합니다
    local fuel = GetVehicleFuelLevel(vehicle)

    -- 차량 수리
    SetVehicleFixed(vehicle)

    -- 기름 복원
    SetVehicleFuelLevel(vehicle, fuel)
end