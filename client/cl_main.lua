local firstspawn = true
local new_character = 0
local respawned = false
local dsbl = true
RegisterCommand("kys", function(source, args, rawCommand) -- KILL YOURSELF COMMAND
local _source = source
if Config.kysCommand then
	local pl = Citizen.InvokeNative(0x217E9DC48139933D)
    local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
        Citizen.InvokeNative(0x697157CED63F18D4, ped, 500000, false, true, true)
		else end
end, false)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0) -- DO NOT REMOVE
		local pl = Citizen.InvokeNative(0x217E9DC48139933D)
		while Citizen.InvokeNative(0x2E9C3FCB6798F397, pl) do
			Citizen.Wait(0) -- DO NOT REMOVE
			local timer = GetGameTimer()+Config.RespawnTime
			while timer >= GetGameTimer() do
				if respawned == false then
					Citizen.Wait(0) -- DO NOT REMOVE
					Citizen.InvokeNative(0xFA08722A5EA82DA7, Config.Timecycle)
					Citizen.InvokeNative(0xFDB74C9CC54C3F37, Config.TimecycleStrenght)
					Citizen.InvokeNative(0x405224591DF02025, 0.50, 0.475, 1.0, 0.22, 1, 1, 1, 100, true, true)
					DrawTxt(Config.LocaleDead, 0.50, 0.40, 1.0, 1.0, true, 161, 3, 0, 255, true)
					DrawTxt(Config.LocaleTimer .. " " .. tonumber(string.format("%.0f", (((GetGameTimer() - timer) * -1)/1000))), 0.50, 0.50, 0.7, 0.7, true, 255, 255, 255, 255, true) 
					--print ("PLAYER IS DEAD")
					DisplayHud(false)
					DisplayRadar(false)
					exports.spawnmanager:setAutoSpawn(false) -- disable respawn
				else
					respawned = false
					break
				end
			end

			if Config.UseSingleSpawn then
				SimpleRespawn(true)
			else
				respawn()
			end
		end
	end
end)


function respawn()
	SendNUIMessage({
		type = 1,
		showMap = true
	})
	SetNuiFocus(true, true)
	
	local pl = Citizen.InvokeNative(0x217E9DC48139933D)
	local ped = Citizen.InvokeNative(0x275F255ED201B937, pl)
	local coords = GetEntityCoords(ped, false)
	SetEntityCoords(ped, coords.x, coords.y, coords.z - 128.0)
	FreezeEntityPosition(ped, true)
    Citizen.InvokeNative(0x71BC8E838B9C6035, ped)
	Citizen.InvokeNative(0x0E3F4AF2D63491FB)
end

function LoadClothes()
	Citizen.CreateThread(function()
		Citizen.Wait(5000)
		TriggerServerEvent("redemrp_clothing:loadClothes", 1, function(cb)
		end)
	end)
end

RegisterNetEvent("redemrp_respawn:respawn")
AddEventHandler("redemrp_respawn:respawn", function(new1)
	local new = new1
	new_character = tonumber(new)
	if Config.UseSingleSpawn then
		DoScreenFadeOut(1000)
		Wait(5000)
		if firstspawn then 
			TriggerServerEvent("redemrp_respawn:FirstSpawn")
			DoScreenFadeIn(1000)
		else
			SimpleRespawn()
		end
		CoordsSave()
	else
		respawn()
	end
end)

function SimpleRespawn(lightning)
	local ply = PlayerPedId()
	local coords = Config.SingleRespawnSpawn
	
	DoScreenFadeOut(7000)
	Wait(8000)
	ShutdownLoadingScreen()
	NetworkResurrectLocalPlayer(Config.SingleRespawnSpawn.x, Config.SingleRespawnSpawn.y, Config.SingleRespawnSpawn.z, Config.SingleSpawnHeading, true, true, false)
	SetEntityCoords(ply, Config.SingleRespawnSpawn.x, Config.SingleRespawnSpawn.y, Config.SingleRespawnSpawn.z)
	ClearTimecycleModifier()
	ClearPedTasksImmediately(ply)
	SetEntityVisible(ply, true)
	NetworkSetFriendlyFireOption(true)
	
	TriggerEvent("redemrp_respawn:camera", coords, lightning)
	
	if Config.UsingInventory then
		TriggerServerEvent("player:getItems", source)
	end
	
	if Config.UsingClothes then
		LoadClothes()
	end
	
	if new_character == 1 then
		TriggerEvent("redemrp_skin:openCreator")
		new_character = 0
	else
		TriggerServerEvent("redemrp_skin:loadSkin", function(cb)
		end)
	end
end

function CoordsSave()
	Citizen.CreateThread(function()
		while true do 
			if Config.SaveCoords then
				Wait(Config.SaveDelay)
				local coordss = GetEntityCoords(PlayerPedId())
				TriggerServerEvent("redemrp_respawn:SaveCoordsFromClient", coordss)
			end
		end
	end)
end

RegisterNetEvent("redemrp_respawn:SaveFromAndToServer")
AddEventHandler("redemrp_respawn:SaveFromAndToServer", function()
	local coordss = GetEntityCoords(PlayerPedId())
	TriggerServerEvent("redemrp_respawn:SaveCoordsFromClient", coordss)
end)

RegisterNetEvent("redemrp_respawn:FirstSpawnClient")
AddEventHandler("redemrp_respawn:FirstSpawnClient",function(coords)

	local ply = PlayerId()
	DoScreenFadeIn(500)
	ShutdownLoadingScreen()
	SetEntityVisible(ply, true)
	NetworkSetFriendlyFireOption(true)
	
	Cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.SingleSpawnCam.x,Config.SingleSpawnCam.y,Config.SingleSpawnCam.z, 300.00,0.00,0.00, 100.00, false, 0) -- CAMERA COORDS
	SetCamActive(Cam1, true)
	RenderScriptCams(true, true, 1000, true, true)
	Wait(1000)

	if coords ~= nil then 
		local _coords = {coords.x,coords.y,coords.z}
		Cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x,coords.y,coords.z+6, 300.00,0.00,0.00, 100.00, false, 0)
		PointCamAtCoord(Cam2, coords.x,coords.y,coords.z+3)
	else 
		Cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.SingleFirstSpawn.x,Config.SingleFirstSpawn.y,Config.SingleFirstSpawn.z+6, 300.00,0.00,0.00, 100.00, false, 0)
		PointCamAtCoord(Cam2, Config.SingleFirstSpawn.x,Config.SingleFirstSpawn.y,Config.SingleFirstSpawn.z+3)
	end

	SetCamActiveWithInterp(Cam2, Cam1, 5000, false, false)
	Wait(5000)
	
	RenderScriptCams(false, true, 7000, true, true)
	DestroyCam(Cam1, true)
	DestroyCam(Cam2, true)
	DisplayHud(true)
	DisplayRadar(true)
	
	firstspawn = false
	if Config.UsingInventory then
		TriggerServerEvent("player:getItems", source)
	end
	
	if Config.UsingClothes then
		LoadClothes()
	end
	if new_character == 1 then
		TriggerEvent("redemrp_skin:openCreator")
		new_character = 0
	else
		TriggerServerEvent("redemrp_skin:loadSkin", function(cb)
		end)
	end
	if coords == nil then 
		NetworkResurrectLocalPlayer(Config.SingleFirstSpawn.x,Config.SingleFirstSpawn.y,Config.SingleFirstSpawn.z)
	else
		NetworkResurrectLocalPlayer(coords.x,coords.y,coords.z, Config.SingleSpawnHeading, true, true, false)
	end

	TriggerEvent('playerSpawned',_coords)

end)

RegisterNetEvent('redemrp_respawn:camera')
AddEventHandler('redemrp_respawn:camera', function(cord,light)
	local coords = cord
	
	if Config.UseSingleSpawn then
		DoScreenFadeIn(6000)
		Cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.SingleSpawnCam.x,Config.SingleSpawnCam.y,Config.SingleSpawnCam.z, 300.00,0.00,0.00, 100.00, false, 0) -- CAMERA COORDS
    	SetCamActive(Cam1, true)
    	RenderScriptCams(true, true, 10000, true, true)
		Wait(1000)
		
		Cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x,coords.y,coords.z+6, 300.00,0.00,0.00, 100.00, false, 0)
		PointCamAtCoord(Cam2, coords.x,coords.y,coords.z+3)
		SetCamActiveWithInterp(Cam2, Cam1, 10000, false, false)
		Wait(2000)
		if Config.SingleSpawnUseLightning and light then
			Citizen.InvokeNative(0x67943537D179597C, Config.LightningCoords.x,Config.LightningCoords.y,Config.LightningCoords.z)
		end
		Wait(8000)
		
		RenderScriptCams(false, true, 2500, true, true)
    	DestroyCam(Cam1, true)
		DestroyCam(Cam2, true)
		DisplayHud(true)
		DisplayRadar(true)
		Wait(5000)
	else
		DoScreenFadeIn(500)
		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 621.67,374.08,873.24, 300.00,0.00,0.00, 100.00, false, 0) -- CAMERA COORDS
		PointCamAtCoord(cam, coords.x,coords.y,coords.z+200)
    	SetCamActive(cam, true)
    	RenderScriptCams(true, false, 1, true, true)
		DoScreenFadeIn(500)
		Citizen.Wait(500)
		
		cam3 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x,coords.y,coords.z+200, 300.00,0.00,0.00, 100.00, false, 0)
    	PointCamAtCoord(cam3, coords.x,coords.y,coords.z+200)
    	SetCamActiveWithInterp(cam3, cam, 3700, true, true)
    	Citizen.Wait(3700)
		
		cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x,coords.y,coords.z+200, 300.00,0.00,0.00, 100.00, false, 0)
		PointCamAtCoord(cam2, coords.x,coords.y,coords.z+2)
		SetCamActiveWithInterp(cam2, cam3, 3700, true, true)
		RenderScriptCams(false, true, 500, true, true)
		Citizen.Wait(500)
    	SetCamActive(cam, false)
    	DestroyCam(cam, true)
		DestroyCam(cam2, true)
		DestroyCam(cam3, true)
		DisplayHud(true)
    	DisplayRadar(true)
		Citizen.Wait(3000)
	end
	
end)
--=============================================================-- DRAW TEXT SECTION --=============================================================--
function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str)
	
	
    --Citizen.InvokeNative(0x66E0276CC5F6B9DA, 2)
    SetTextScale(w, h)
    SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
	SetTextCentre(centre)
    if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	Citizen.InvokeNative(0xADA9255D, 1);
    DisplayText(str, x, y)
end

function CreateVarString(p0, p1, variadic)
    return Citizen.InvokeNative(0xFA925AC00EB830B9, p0, p1, variadic, Citizen.ResultAsLong())
end
-----------------------------------------------------------------------------------------NUI-------------------------------------------------------------
RegisterNUICallback('select', function(spawn, cb)
	print(spawn)
	print('What tha hek is this ?')
	local coords = Config[spawn][math.random(#Config[spawn])]
	local ped = PlayerPedId()
	SetEntityCoords(ped, coords.x, coords.y, coords.z)
	SetNuiFocus(false, false)
	SendNUIMessage({
		type = 1,
		showMap = false
	})
	FreezeEntityPosition(ped, false)
	
	ShutdownLoadingScreen()
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 59.95, true, true, false)
	local ped = PlayerPedId()
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	ClearPedTasksImmediately(ped)
	ClearPlayerWantedLevel(PlayerId())
	FreezeEntityPosition(ped, false)
	SetPlayerInvincible(PlayerId(), false)
	SetEntityVisible(ped, true)
	SetEntityCollision(ped, true)
	TriggerEvent('playerSpawned', spawn)
	Citizen.InvokeNative(0xF808475FA571D823, true)
	NetworkSetFriendlyFireOption(true)
	TriggerEvent("redemrp_respawn:camera", coords)
	if Config.UsingInventory then
		TriggerServerEvent("player:getItems", source)
	else end
	if new_character == 1 then
		TriggerEvent("redemrp_skin:openCreator")
		print("new character")
		new_character = 0
	else
		TriggerServerEvent("redemrp_skin:loadSkin", function(cb)
		end)
		if Config.UsingClothes then
			LoadClothes()
		else end
	end
end)
