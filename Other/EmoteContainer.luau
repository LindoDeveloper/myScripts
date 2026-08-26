local RS = game:GetService("ReplicatedStorage")

-- folders
local Shared = RS:WaitForChild("Shared")
local assets = RS:WaitForChild("Assets")
local animations = RS:WaitForChild("Animations")

-- utils
local Promise = require(Shared.Promise)

-- modules
local AnimationModule = require(Shared.AnimationModule)
local CameraTrack = require(Shared.CameraTrack)
local InputCancel = require(Shared.InputCancel)
local SpeedStun = require(Shared.SpeedStun)

local VFXModule = require(Shared.VFX)
local SFXModule = require(Shared.SFXModule)

-- varib
local isPlaying = false

-- caches
local emoteCache = {}

-- lf
local function LoopingRoomStart(player, animObject)
	return Promise.new(function(resolve, reject, onCancel)
		isPlaying = true
		local character = player.Character
		if not character then return end
		local head = character:FindFirstChild("Head")
		if not head then return end

		character:SetAttribute("InEmote", true)
		
		local shakeConnection = task.spawn(function()
			while task.wait(0.4) do
				CameraTrack.Shake(0.2, 0.1)
			end
		end)
		 
		onCancel(function()
			if shakeConnection then
				task.cancel(shakeConnection)
			end
			AnimationModule.StopAnim(player, animObject, true, false)
			VFXModule.LoopingRoomsAM(player, "Stop", false, 0, 0, 0)
			SFXModule.StopSFX(player, "LoopingTheRooms")
			
			InputCancel.EnableInput()
			SpeedStun.DisableStun(player)
			
			task.spawn(function()
				task.wait(1)
				character:SetAttribute("InEmote", false)
				isPlaying = false
				reject("Cancelled")
			end)
		end)
		
		InputCancel.DisableInput()
		SpeedStun.StunV2(player, false, 5, 0)
		AnimationModule.PlayAnim(player, animObject, false, false)
		SFXModule.PlaySFX(player, "LoopingTheRooms")
		task.wait(0.1)
		VFXModule.LoopingRoomsAM(player, "Play", true, 0, 0.4, 2)
	end)
end

local emoteContainer = {}

emoteContainer.LoopingRooms = function(player)
	if not emoteCache[player] then
		emoteCache[player] = {}
	end
	if isPlaying then return end
	local character = player.Character
	if not character then return end

	if character:GetAttribute("InCutscene") == true then
		return
	end
	
	local animationFolder = animations:FindFirstChild("LoopingRooms")
	local animObject = animationFolder:FindFirstChild("Anim1")
	
	local current_thread
	current_thread = LoopingRoomStart(player, animObject)
	if not emoteCache[player]["EmoteThreads"] then
		emoteCache[player]["EmoteThreads"] = {}
	end 
	table.insert(emoteCache[player]["EmoteThreads"], current_thread)
	
	current_thread:andThen(function()
		print("Looping Rooms started")
	end)
end

emoteContainer.EmoteCancel = function(player)
	if not emoteCache[player] then
		emoteCache[player] = {}
	end
	if not emoteCache[player]["EmoteThreads"] then
		emoteCache[player]["EmoteThreads"] = {}
	end
	
	if #emoteCache[player]["EmoteThreads"] > 0 then
		for _, thread in pairs(emoteCache[player]["EmoteThreads"]) do
			thread:cancel()
		end
		table.clear(emoteCache[player]["EmoteThreads"])
	end
end

return emoteContainer
