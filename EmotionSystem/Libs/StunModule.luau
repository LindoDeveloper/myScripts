--!strict
type SavedState = {
	WalkSpeed: number,
	JumpPower: number,
	JumpHeight: number,
}

local StanModule = {}
local savedStates: {[Humanoid]: SavedState} = {}

function StanModule.Lock(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	savedStates[humanoid] = {
		WalkSpeed = humanoid.WalkSpeed,
		JumpPower = humanoid.JumpPower,
		JumpHeight = humanoid.JumpHeight,
	}

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
end

function StanModule.Unlock(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or not savedStates[humanoid] then return end

	local state = savedStates[humanoid]
	humanoid.WalkSpeed = state.WalkSpeed
	humanoid.JumpPower = state.JumpPower
	humanoid.JumpHeight = state.JumpHeight
	savedStates[humanoid] = nil
end

return StanModule
