--[[
	@details
	Loads the client / server framework based on environment.

	@file Scrypt.lua
    @shared
    @author zblox164
    @version 0.0.41-alpha
    @since 2024-12-17
--]]

local RunService: RunService = game:GetService("RunService")

local function GetServer()
	return require(script.Server)
end

local function GetClient()
	task.defer(function() 
		script:WaitForChild("Server"):Destroy() 
	end)
	
	return require(script.Client)
end

local function Scrypt()
	if RunService:IsServer() then
		return GetServer()
	else
		return GetClient()
	end
end


-- Public Types
export type Result<T> = {
    Success: boolean,
    Value: T?,
    Error: string?
}

export type Packet = number | string | {Packet} | boolean | Instance | buffer | Player | CFrame | Vector3 | Vector2 | Color3 | UDim2 | UDim | Enum | BrickColor
export type ClientPacketData = {
    Data: Packet,
    Reliable: boolean
}

export type ServerPacketData = {
    Data: Packet,
    Reliable: boolean,
	Address: Player
}


export type Service = {
	["Name"]: string,
	["Service"]: any
}

export type Controller = {
	["Name"]: string,
	["Controller"]: any
}

export type SharedModule = {[string]: any}

export type Signal = typeof(setmetatable({}:: {
	Connections: {SignalConnection?},
	YieldedConnections: {thread?}
}, {}:: SignalImpl))

type SignalImpl = {
	__index: SignalImpl,
	New: () -> Signal,
	Connect: (self: Signal, Function: CallbackFunction) -> SignalConnection?,
	Once: (self: Signal, Function: CallbackFunction) -> SignalConnection?,
	Wait: (self: Signal) -> (),
	Disconnect: (self: Signal) -> (),
	DisconnectAll: (self: Signal) -> (),
	Fire: (self: Signal, ...any) -> (),
}

export type CallbackFunction = (...any) -> ...any
export type SignalConnection = typeof(setmetatable({}:: {
	Function: CallbackFunction,
	IsOnce: boolean,
	Self: Signal,
}, {}))

export type Function = typeof(setmetatable({}:: {
	Function: ((...any) -> ...any)?,
	YieldedCalls: {thread?}
}, {}:: FunctionImpl))

type FunctionImpl = {
	__index: FunctionImpl,
	New: () -> Function,
	OnInvoke: (self: Function, ReturnFunction: (...any) -> ...any) -> (),
	Invoke: (self: Function, ...any) -> ...any,
	Destroy: (self: Function) -> ()
}

return Scrypt()