--!strict
local Players = game:GetService("Players")

local EmotesF = script.Parent
local Libs = EmotesF.Parent:WaitForChild("Libs")
local Promise = require(Libs.Promise)

local CancelModule = require(Libs:WaitForChild("CancelModule"))
local StanModule = require(Libs:WaitForChild("StanModule"))
local TpModule = require(Libs:WaitForChild("TpModule"))

type PromiseInstance = {
	new: (callback: (resolve: (any) -> (), reject: (any) -> (), onCancel: ((() -> ()) -> ()) -> ()) -> ()) -> PromiseInstance,
	[any]: any
}

type EmoteConfigType = {
	Id: number,
	Name: string,
	Context: string,
	MaxPlayers: number,
	Animation: Animation?,
	Callback: (character: Model, myInventory: any) -> any
}

local TARGET_MAX_PLAYERS: number = 2
local EMOTE_NAME: string = "Test"
local CONTEXT_TYPE: string = "Duo"
local EMOTE_ID: number = 3

local EmoteConfig: EmoteConfigType = {
	Id = EMOTE_ID,
	Name = EMOTE_NAME,
	Context = CONTEXT_TYPE,
	MaxPlayers = TARGET_MAX_PLAYERS,
	Animation = script:FindFirstChild("MikuAnim") :: Animation?,

	Callback = function(character: Model, myInventory: any)
		local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if humanoid.FloorMaterial == Enum.Material.Air then return nil end
			local state = humanoid:GetState()
			if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Dead then
				return nil
			end
		end

		return Promise.new(function(resolve: (any) -> (), reject: (any) -> (), onCancel: ((() -> ()) -> ()) -> ())
			local rootPart: BasePart? = character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if not humanoid or not rootPart then return reject("Missing components") end

			local creatorAnimOBJ: Animation? = script:FindFirstChild("MikuAnim") :: Animation?
			local guestAnimOBJ: Animation? = script:FindFirstChild("TetoAnim") :: Animation?
			if not creatorAnimOBJ or not guestAnimOBJ then return reject("Missing animations") end

			local animator: Animator? = humanoid:FindFirstChildOfClass("Animator")
			if not animator then return reject("No animator") end

			local localPlayer = Players.LocalPlayer
			local isCreator: boolean = localPlayer and localPlayer.Character == character

			local isLocalGuest: boolean = false
			local activeEmote = myInventory and myInventory._factory:GetActive(character)
			if castedData and (myInventory :: any).IsGuestSession == true then
				isLocalGuest = true
			end

			local activeTrack: AnimationTrack? = nil
			local targetAnim = (isLocalGuest and guestAnimOBJ) or creatorAnimOBJ

			activeTrack = animator:LoadAnimation(targetAnim :: Animation)
			if activeTrack then
				activeTrack.Looped = true
				activeTrack:Play(0.05)
			end

			local attachment: Attachment? = nil
			local prompt: ProximityPrompt? = nil
			local connections: {RBXScriptConnection} = {}

			if isCreator then
				attachment = Instance.new("Attachment")
				if attachment then
					attachment.Name = "SharedEmoteAttachment"
					attachment.Parent = rootPart

					prompt = Instance.new("ProximityPrompt")
					if prompt then
						prompt.ObjectText = "Emote: Test"
						prompt.ActionText = "Join"
						prompt.HoldDuration = 0
						prompt.MaxActivationDistance = 8
						prompt.Parent = attachment

						table.insert(connections, prompt.Triggered:Connect(function(playerWhoTriggered: Player)
							if not prompt or not prompt.Parent then return end
							local guestChar: Model? = playerWhoTriggered.Character
							if not guestChar or guestChar == character then return end

							if localPlayer and localPlayer == playerWhoTriggered then
								prompt.Enabled = false
								prompt:Destroy()

								if myInventory and typeof(myInventory.Use) == "function" then
									local creatorPlayer = Players:GetPlayerFromCharacter(character)
									myInventory:Use(guestChar, EMOTE_ID, creatorPlayer)
								end
							end
						end))
					end
				end
			end

			StanModule.Lock(character)
			CancelModule.Listen(character, myInventory, onCancel)

			if isLocalGuest and (myInventory :: any).CreatorChar then
				local creatorChar = (myInventory :: any).CreatorChar
				TpModule.Attach(creatorChar, character)
			end

			onCancel(function()
				for _, conn: RBXScriptConnection in ipairs(connections) do
					if conn then conn:Disconnect() end
				end

				if attachment then attachment:Destroy() end

				if activeTrack then
					if activeTrack.IsPlaying then activeTrack:Stop() end
					activeTrack:Destroy()
				end

				StanModule.Unlock(character)

				if isLocalGuest and (myInventory :: any).CreatorChar then
					local creatorChar = (myInventory :: any).CreatorChar
					TpModule.Detach(creatorChar, character)
				end
			end)
		end)
	end
}

return EmoteConfig
