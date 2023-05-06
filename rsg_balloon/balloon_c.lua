-- Spawn Balloon --------------------------------------------------------------------
local RSGCore = exports['rsg-core']:GetCoreObject()
local balloon = nil
local canoe = nil
local lockZ = false
local balloonPrompts = UipromptGroup:new("Balloon")
local nsPrompt = Uiprompt:new({`INPUT_VEH_MOVE_UP_ONLY`, `INPUT_VEH_MOVE_DOWN_ONLY`}, "North/South", balloonPrompts)
local wePrompt = Uiprompt:new({`INPUT_VEH_MOVE_LEFT_ONLY`, `INPUT_VEH_MOVE_RIGHT_ONLY`}, "West/East", balloonPrompts)
--local boostPrompt = Uiprompt:new(`INPUT_VEH_TRAVERSAL`, "Boost", balloonPrompts) -- Causes issues with other prompts for some reason
local brakePrompt = Uiprompt:new(`INPUT_VEH_BRAKE`, "Brake", balloonPrompts)
local lockZPrompt = Uiprompt:new(`INPUT_VEH_SHUFFLE`, "Lock Altitude", balloonPrompts)
local throttlePrompt = Uiprompt:new(`INPUT_VEH_FLY_THROTTLE_UP`, "Ascend", balloonPrompts)


-- Example






Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local coords = GetEntityCoords(PlayerPedId())
    if (Vdist(coords.x, coords.y, coords.z, -5188.013, -2089.668, 17.074) < 2.0) then
            DrawTxt("Press [~e~G~q~] to Ride Balloon.", 0.50, 0.85, 0.7, 0.7, true, 255, 255, 255, 255, true)
            if IsControlJustReleased(0, 0x760A9C6F) then -- g
                TriggerEvent("SpawnBalloon")
                --print('openedwarmenu')

            end
        end
	   if (Vdist(coords.x, coords.y, coords.z, -1369.349, -2357.067, 43.022) < 2.0) then
            DrawTxt("Press [~e~G~q~] to take out Row Boat.", 0.50, 0.85, 0.7, 0.7, true, 255, 255, 255, 255, true)
            if IsControlJustReleased(0, 0x760A9C6F) then -- g
                TriggerEvent("SpawnRowBoat")
                --print('openedwarmenu')

            end
        end
    end
end)

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str, Citizen.ResultAsLong())
   SetTextScale(w, h)
   SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
   SetTextCentre(centre)
   if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
   Citizen.InvokeNative(0xADA9255D, 10);
   DisplayText(str, x, y)
end

RegisterNetEvent('SpawnBalloon')

AddEventHandler('SpawnBalloon', function()
    Citizen.CreateThread(function()

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local head = GetEntityHeading(playerPed)
        local hash = GetHashKey('hotAirBalloon01')

        
    
            
        while not HasModelLoaded(hash) do
            Wait(10)
            RequestModel(hash)
        end

        if DoesEntityExist(balloon) then
            SetEntityAsMissionEntity(balloon)
            DeleteEntity(balloon)
            balloon = nil
        end

        balloon = CreateVehicle(hash, coords.x, coords.y-2.0, coords.z, head, true, true)

    end)
end)


RegisterNetEvent('SpawnRowBoat')
AddEventHandler('SpawnRowBoat', function()
    Citizen.CreateThread(function()

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local head = GetEntityHeading(playerPed)
        local hash = GetHashKey('rowboat')

        while not HasModelLoaded(hash) do
            Wait(10)
            RequestModel(hash)
        end

        if DoesEntityExist(balloon) then
            SetEntityAsMissionEntity(balloon)
            DeleteEntity(balloon)
            balloon = nil
        end

        balloon = CreateVehicle(hash, -1370.474, -2352.288, 42.28, head, true, true)

    end)
end)

Citizen.CreateThread(function()
    while true do
        local wait = 500
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsUsing(playerPed)
        local driving = GetPedInVehicleSeat(vehicle, -1)
        if IsPedInFlyingVehicle(playerPed) and driving then
            wait = 5
            if IsControlPressed(0, 0x8FD015D8) then  -- W
                ApplyForceToEntity(vehicle, 0, 2.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
            if IsControlPressed(0, 0x7065027D) then -- A
                ApplyForceToEntity(vehicle, 0, 0.0, 2.5, 0.0, 1.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
            if IsControlPressed(0, 0xD27782E3) then -- S
                ApplyForceToEntity(vehicle, 0, -2.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
            if IsControlPressed(0, 0xB4E465B4) then -- D
                ApplyForceToEntity(vehicle, 0, 0.0, -2.5, 0.0, 1.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
        end
        Wait(wait)
    end
end)

--balloon controls
Citizen.CreateThread(function()
	while true do
		local vehicle = GetVehiclePedIsUsing(PlayerPedId())
		local isBalloon = GetEntityModel(vehicle) == `hotairballoon01`

		if not balloon and isBalloon then
			balloon = vehicle
		elseif balloon and not isBalloon then
			balloon = nil
		end

		Citizen.Wait(500)
	end
end)

Citizen.CreateThread(function()
	local bv

	while true do
		if balloon then
			balloonPrompts:handleEvents()

			local speed

			if IsControlPressed(0, `INPUT_VEH_TRAVERSAL`) then
				speed = 0.15
			else
				speed = 0.05
			end

			local v1 = GetEntityVelocity(balloon)
			local v2 = v1

			if IsControlPressed(0, `INPUT_VEH_MOVE_UP_ONLY`) then
				v2 = v2 + vector3(0, speed, 0)
			end

			if IsControlPressed(0, `INPUT_VEH_MOVE_DOWN_ONLY`) then
				v2 = v2 - vector3(0, speed, 0)
			end

			if IsControlPressed(0, `INPUT_VEH_MOVE_LEFT_ONLY`) then
				v2 = v2 - vector3(speed, 0, 0)
			end

			if IsControlPressed(0, `INPUT_VEH_MOVE_RIGHT_ONLY`) then
				v2 = v2 + vector3(speed, 0, 0)
			end

			if IsControlPressed(0, `INPUT_VEH_BRAKE`) then
				if bv then
					local x = bv.x > 0 and bv.x - speed or bv.x + speed
					local y = bv.y > 0 and bv.y - speed or bv.y + speed
					v2 = vector3(x, y, v2.z)
				end
				bv = v2.xy
			else
				if bv then
					bv = nil
				end
			end

			if IsControlJustPressed(0, `INPUT_VEH_SHUFFLE`) then
				lockZ = not lockZ

				if lockZ then
					lockZPrompt:setText("Unlock Altitude")
				else
					lockZPrompt:setText("Lock Altitude")
				end
					
			end

			if lockZ and not IsControlPressed(0, `INPUT_VEH_FLY_THROTTLE_UP`) then
				SetEntityVelocity(balloon, vector3(v2.x, v2.y, 0.0))
			elseif v2 ~= v1 then
				SetEntityVelocity(balloon, v2)
			end

			Citizen.Wait(0)
		else
			Citizen.Wait(500)
		end
	end
end)