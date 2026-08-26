--!strict
--!native

export type Promise = any

export type EmoteInstance = {
	Id: number,
	Character: Model,
	ContextPromise: Promise,
	Storage: { [string]: any },
}

export type EmoteData = {
	Id: number,
	Name: string,
	OnStart: (emoteInstance: EmoteInstance) -> Promise,
	OnStop: (emoteInstance: EmoteInstance) -> (),
}

export type EmoteFactory = {
	Create: (self: EmoteFactory, character: Model, emoteData: EmoteData) -> Promise?,
	DestroyActive: (self: EmoteFactory, character: Model) -> (),
	GetActive: (self: EmoteFactory, character: Model) -> EmoteInstance?,
}

export type EmoteInventoryImpl = {
	__index: EmoteInventoryImpl,
	new: (factory: EmoteFactory, registry: { [number]: EmoteData }, startRemote: RemoteEvent, stopRemote: RemoteEvent) -> EmoteInventory,
	InitReplication: (self: EmoteInventory) -> (),
	Add: (self: EmoteInventory, emoteData: EmoteData) -> (),
	Remove: (self: EmoteInventory, emoteId: number) -> (),
	Get: (self: EmoteInventory, emoteId: number) -> EmoteData?,
	GetAll: (self: EmoteInventory) -> { [number]: EmoteData },
	Use: (self: EmoteInventory, character: Model, emoteId: number) -> Promise?,
	ClearActive: (self: EmoteInventory, character: Model) -> (),
}

export type EmoteInventory = typeof(setmetatable({} :: {
	_factory: EmoteFactory,
	_registry: { [number]: EmoteData },
	_slots: { [number]: EmoteData },
	_startRemote: RemoteEvent,
	_stopRemote: RemoteEvent,
}, {} :: EmoteInventoryImpl))

return nil
