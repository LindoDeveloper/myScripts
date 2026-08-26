--!strict
--!native
local Players = game:GetService("Players")
local EmoteTypes = require(script.EmoteTypes)

type EmoteData = EmoteTypes.EmoteData
type EmoteFactory = EmoteTypes.EmoteFactory
type EmoteInventory = EmoteTypes.EmoteInventory
type EmoteInventoryImpl = EmoteTypes.EmoteInventoryImpl

local LocalPlayer = Players.LocalPlayer

local EmoteInventory: EmoteInventoryImpl = {} :: EmoteInventoryImpl
EmoteInventory.__index = EmoteInventory

function EmoteInventory.new(factory: EmoteFactory, registry: { [number]: EmoteData }, startRemote: RemoteEvent, stopRemote: RemoteEvent): EmoteInventory
	local selfInstance = setmetatable({
		_factory = factory,
		_registry = registry,
		_slots = {},
		_startRemote = startRemote,
		_stopRemote = stopRemote,
	}, EmoteInventory) :: any

	if factory then 
		(factory :: any)._inventory = selfInstance 
	end
	return selfInstance
end

function EmoteInventory:InitReplication()
	self._startRemote.OnClientEvent:Connect(function(sender: Player, emoteId: number, guestPlayer: Player?)
		local character = sender.Character
		local emoteData = self._registry[emoteId]
		if not character or not emoteData then return end

		if guestPlayer and guestPlayer == LocalPlayer then
			local myChar = LocalPlayer.Character
			if myChar then
				local extendedData = setmetatable({ IsGuestSession = true, CreatorChar = character }, { __index = emoteData }) :: any
				self._factory:Create(myChar, extendedData, self)
			end
		else
			self._factory:Create(character, emoteData, self)
		end
	end)

	self._stopRemote.OnClientEvent:Connect(function(sender: Player, partner: Player?)
		local character = sender.Character
		if character then
			self._factory:DestroyActive(character)
		end
		if partner and partner == LocalPlayer then
			local myChar = LocalPlayer.Character
			if myChar then
				self._factory:DestroyActive(myChar)
			end
		end
	end)
end

function EmoteInventory:Add(emoteData: EmoteData) self._slots[emoteData.Id] = emoteData end
function EmoteInventory:Remove(emoteId: number) self._slots[emoteId] = nil end
function EmoteInventory:Get(emoteId: number): EmoteData? return self._slots[emoteId] end
function EmoteInventory:GetAll(): { [number]: EmoteData } return self._slots end

function EmoteInventory:Use(character: Model, emoteId: number, targetPlayer: Player?)
	local config = self._registry[emoteId]
	if not config then return end

	local promise = self._factory:Create(character, config, self)
	if promise then
		self._startRemote:FireServer(emoteId, targetPlayer)
	end
end

function EmoteInventory:ClearActive(character: Model)
	self._factory:DestroyActive(character)
	self._stopRemote:FireServer()
end

return EmoteInventory
