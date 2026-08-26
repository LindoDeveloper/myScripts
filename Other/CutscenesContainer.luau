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
local TextModule = require(Shared.TextModule)

-- varib
local isPlaying = false

-- lf
local function NagiDevourStart(player, anim)
	return Promise.new(function(resolve, reject, onCancel)
		isPlaying = true
		local character = player.Character
		if not character then return end
		
		character:SetAttribute("InCutscene", true)
		
		local currentSkull = nil
		local NagiDevourAssets = assets:FindFirstChild("NagiDevour")
		local skull = NagiDevourAssets:FindFirstChild("SkullRig")
		if skull then
			local character = player.Character
			if not character then return end
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			currentSkull = skull:Clone()
			currentSkull.Parent = character
			
			local tMotor6d = Instance.new("Motor6D", currentSkull)
			tMotor6d.Name = "t"
			tMotor6d.Part0 = hrp
			tMotor6d.Part1 = currentSkull
			
			tMotor6d.C0 = CFrame.new(-1.053, -0.068, -0.094) * CFrame.fromOrientation(math.rad(-14.623), math.rad(89.998), math.rad(0))
			tMotor6d.C1 = CFrame.new(0, -1.506, 0.227)
			
		end
		
		if game:GetService("Lighting") then
			local lighting = game:GetService("Lighting")
			lighting.Brightness = 0
			
			local cutsceneCorr = lighting:FindFirstChild("CutsceneCorr")
			if cutsceneCorr then
				cutsceneCorr.Brightness = -0.1
			end
		end
		
		onCancel(function()
			if currentSkull then
				currentSkull:Destroy()
				currentSkull = nil
			end
			
			CameraTrack.Stop()
			AnimationModule.StopAnim(player, anim, true, true)
			CameraTrack.StopTrack(player)
			VFXModule.NagiAura(player, "Stop")
			VFXModule.NagiCC(player, "Stop", 0)
			VFXModule.NagiSkullBeam(player, "Stop")
			VFXModule.NagiDustAura(player, "Stop")
			VFXModule.Speedlines(player, "Stop", 0)
			TextModule.StopAll(player, true)
			SFXModule.StopSFX(player, "NagiTrap", false)
			SFXModule.StopSFX(player, "StepWind", false)
			SFXModule.StopSFX(player, "NagiVoiceline1", false)
			SFXModule.StopSFX(player, "Riser", false)
			SFXModule.StopSFX(player, "SkullSFX", false)
			SpeedStun.DisableStun(player)
			InputCancel.EnableInput()
			
			task.spawn(function()
				task.wait(1)
				character:SetAttribute("InCutscene", false)
				isPlaying = false
			end)
			reject("Cancelled")
		end)
		
		InputCancel.DisableInput()
		SpeedStun.Stun(player, true)
		local preTrack: AnimationTrack = AnimationModule.PlayAnim(player, anim, true, false)
		CameraTrack.StartTrack(player)
		VFXModule.NagiAura(player, "Play")
		VFXModule.NagiSkullBeam(player, "Play", 0.5)
		VFXModule.NagiDustAura(player, "Play")
		SFXModule.PlaySFX(player, "NagiTrap")
		SFXModule.PlaySFX(player, "NagiVoiceline1")
		TextModule.PlayText(player, "Reo, I'll give it a try", "12359659240", 0.05, 2.7, "FadeOut", 0.2, 0.8)
		
		CameraTrack.Shake(0.5, 0.3)
		CameraTrack.Shake(0.1, 1)
		
		local stepVFXConnection
		stepVFXConnection = preTrack:GetMarkerReachedSignal("Step"):Connect(function()
			VFXModule.StepVFX(player, "Left Leg", "Play", true)
			SFXModule.PlaySFX(player, "StepWind")
			stepVFXConnection:Disconnect()
		end)
		
		local riserSoundConnection
		riserSoundConnection = preTrack:GetMarkerReachedSignal("Zoom"):Connect(function()
			SFXModule.PlaySFX(player, "Riser")
			VFXModule.NagiSkullBeam(player, "Stop", 0)
			task.spawn(function()
				VFXModule.Speedlines(player, "Play", 0)
				task.wait(1.3)
				VFXModule.Speedlines(player, "Stop", 0)
			end)
			riserSoundConnection:Disconnect()
		end)
		
		local skullConnection
		skullConnection = preTrack:GetMarkerReachedSignal("Skull"):Connect(function()
			SFXModule.PlaySFX(player, "SkullSFX")
			VFXModule.NagiCC(player, "Play", 0.5)
			CameraTrack.Shake(0.2, 0.3)
			task.spawn(function()
				task.wait(0.3)
				CameraTrack.Shake(0.5, 0.5)
			end)
			skullConnection:Disconnect()
		end)

		preTrack.Stopped:Wait()
		
		if stepVFXConnection then stepVFXConnection:Disconnect() end
		if riserSoundConnection then riserSoundConnection:Disconnect() end
		if skullConnection then skullConnection:Disconnect() end
		
		AnimationModule.StopAnim(player, anim, true, true)
		CameraTrack.StopTrack(player)
		VFXModule.NagiAura(player, "Stop")
		VFXModule.NagiDustAura(player, "Stop")
		VFXModule.NagiCC(player, "Stop", 0)
		if currentSkull then
			currentSkull:Destroy()
			currentSkull = nil
		end
		SFXModule.StopSFX(player, "NagiTrap", false)
		SFXModule.StopSFX(player, "StepWind", false)
		SFXModule.StopSFX(player, "NagiVoiceline1", false)
		CameraTrack.Stop()
		SpeedStun.DisableStun(player)
		InputCancel.EnableInput()
		
		if game:GetService("Lighting") then
			local lighting = game:GetService("Lighting")
			lighting.Brightness = 3
			
			local cutsceneCorr = lighting:FindFirstChild("CutsceneCorr")
			if cutsceneCorr then
				cutsceneCorr.Brightness = 0
			end
		end
		
		task.wait(1)
		character:SetAttribute("InCutscene", false)
		isPlaying = false
		resolve()
	end)
end

local CutsceneContainer = {}

CutsceneContainer.NagiDevour = function(player)
	if isPlaying == true then return end
	local character = player.Character
	if not character then return end

	if character:GetAttribute("InEmote") == true then
		return
	end
	
	local nagiDevourAnims = animations:FindFirstChild("NagiDevour")
	local anim = nagiDevourAnims:FindFirstChild("NagiAnim")
	
	local current_thread
	current_thread = NagiDevourStart(player, anim)
	current_thread:andThen(function()
		print("CutsceneFinished")
	end)
	
	
end

return CutsceneContainer
