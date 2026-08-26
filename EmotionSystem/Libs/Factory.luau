--!strict
local EmoteTypes = require(script.Parent.Parent.EmoteTypes)

type BaseEmoteData = EmoteTypes.EmoteData
type EmoteData = BaseEmoteData & { Callback: (character: Model, myInventory: any) -> any }

local EmoteFactory = {}
EmoteFactory.__index = EmoteFactory

export type EmoteFactoryImpl = {
	__index: EmoteFactoryImpl,
	new: () -> EmoteFactory,
	Create: (self: EmoteFactory, character: Model, emoteData: EmoteData, myInventory: any) -> any,
	DestroyActive: (self: EmoteFactory, character: Model) -> (),
	GetActive: (self: EmoteFactory, character: Model) -> any
}

export type EmoteFactory = {
	_activeEmotes: { [Model]: any }
}

local EmoteFactoryTable: EmoteFactoryImpl = EmoteFactory :: any

function EmoteFactoryTable.new(): EmoteFactory
	return setmetatable({
		_activeEmotes = {}
	}, EmoteFactory) :: any
end

function EmoteFactoryTable:Create(character: Model, emoteData: EmoteData, myInventory: any): any
	local castedSelf = (self :: any) :: EmoteFactory
	self:DestroyActive(character)

	if not emoteData or typeof(emoteData.Callback) ~= "function" then
		return nil
	end

	local emotePromise = emoteData.Callback(character, myInventory)
	if emotePromise then
		castedSelf._activeEmotes[character] = emotePromise
	end

	return emotePromise
end

function EmoteFactoryTable:DestroyActive(character: Model)
	local castedSelf = (self :: any) :: EmoteFactory
	local currentPromise = castedSelf._activeEmotes[character]
	if currentPromise and typeof(currentPromise) == "table" and typeof(currentPromise.cancel) == "function" then
		currentPromise:cancel()
		castedSelf._activeEmotes[character] = nil
	end
end

function EmoteFactoryTable:GetActive(character: Model): any
	local castedSelf = (self :: any) :: EmoteFactory
	return castedSelf._activeEmotes[character]
end

return EmoteFactoryTable
