--!strict
local EmotesF = script.Parent
local Libs = EmotesF.Parent:WaitForChild("Libs")

local Promise = require(Libs.Promise)
local CancelModule = require(Libs:WaitForChild("CancelModule"))

type PromiseInstance = {
	new: (callback: (resolve: (any) -> (), reject: (any) -> (), onCancel: ((() -> ()) -> ()) -> ()) -> ()) -> PromiseInstance,
	[any]: any
}

type EmoteConfigType = {
	Id: number,
	Name: string,
	Context: string,
	Animation: Animation?,
	Callback: (character: Model, myInventory: any) -> any
}

local EmoteConfig: EmoteConfigType = {
	Id = 1,
	Name = "AeroStep",
	Context = "None",
	Animation = script:FindFirstChild("AeroStepAnim") :: Animation?,

	Callback = function(character: Model, myInventory: any)
		return Promise.new(function(resolve: (any) -> (), reject: (any) -> (), onCancel: ((() -> ()) -> ()) -> ())
			if not character then return reject("No character") end
			local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
			if not humanoid then return reject("No humanoid") end

			local animOBJ: Animation? = script:FindFirstChild("AeroStepAnim") :: Animation?
			if not animOBJ then return reject("No animation object") end

			local animator: Animator? = humanoid:FindFirstChildOfClass("Animator")
			if not animator then return reject("No animator") end

			local animTrack: AnimationTrack? = animator:LoadAnimation(animOBJ)
			if animTrack then
				animTrack:Play(0.05)
			end

			CancelModule.Listen(character, myInventory, onCancel)

			onCancel(function()
				if animTrack then
					if animTrack.IsPlaying then
						animTrack:Stop()
					end
					animTrack:Destroy()
				end
			end)
		end)
	end
}

return EmoteConfig
