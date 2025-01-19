--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local CurrencyService = {}
--[=[
    @class CurrencyService
    @server
]=]

local DataService = Scrypt.GetService("DataService")

-- Types
--[=[
    @type RAMCurrency {[Player]: number}
    @within CurrencyService
    A RAM currency is a currency that does not save across game sessions.
]=]
type RAMCurrency = {
    [Player]: number
}

--[=[
    @type RAMCurrencies {[string]: RAMCurrency}
    @within CurrencyService
]=]
type RAMCurrencies = {
    [string]: RAMCurrency
}

-- Currencies that do not save across game sessions (named RAM as it's similar to RAM where data is temp)
local InMemoryCurrencies: RAMCurrencies = {
    ["Coins"] = {}:: RAMCurrency,
    -- etc
}

-- Returns a multiplier to multiply currencies
local function Multipliers(Player: Player)
    return 1 -- TODO Add gamepass checks
end

-- Returns a multiplier to multiply RAM currencies
local function RAMMultipliers(Player: Player)
    return 1 -- TODO Add gamepass checks
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Amount number
    @within CurrencyService
    Adds currency to the player's data.
]=]
function CurrencyService.AddCurrency(Player: Player, CurrencyName: string, Amount: number)
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data[CurrencyName], `Currency '{CurrencyName}' not found in PlayerData`)
    Data[CurrencyName] += Amount*Multipliers(Player)
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Amount number
    @within CurrencyService
    Removes currency from the player's data.
]=]
function CurrencyService.RemoveCurrency(Player: Player, CurrencyName: string, Amount: number)
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data[CurrencyName], `Currency '{CurrencyName}' not found in PlayerData`)
    Data[CurrencyName] -= Amount
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Amount number
    @within CurrencyService
    Sets a value on a currency for the player.
]=]
function CurrencyService.SetCurrency(Player: Player, CurrencyName: string, Amount: number)
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data[CurrencyName], `Currency '{CurrencyName}' not found in PlayerData`)
    Data[CurrencyName] = Amount
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Cost number
    @return boolean
    @within CurrencyService
    Handles purchases with saved currencies.
]=]
function CurrencyService.HandlePurchase(Player: Player, CurrencyName: string, Cost: number): boolean
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data[CurrencyName], `Currency '{CurrencyName}' not found in PlayerData`)

    if Data[CurrencyName] < Cost then
        return false
    end

    Data[CurrencyName] -= Cost
    return true
end

--[=[
    @param Player Player
    @param CurrencyName string
    @return number
    @within CurrencyService
    Returns a player's currency.
]=]
function CurrencyService.GetPlayerCurrency(Player: Player, CurrencyName: string): number
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data[CurrencyName], `Currency '{CurrencyName}' not found in PlayerData`)

    return Data[CurrencyName]
end

-- Add player to the currency type table
local function AddPlayerToRAMCurrencyType(Player: Player, CurrencyName: string)
    assert(Player, "Player does not exist")
    assert(CurrencyName, "CurrencyName does not exist")

    local CurrencyType = InMemoryCurrencies[CurrencyName]
    assert(CurrencyType, "Currency does not exist")

    CurrencyType[Player] = 0
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Amount number
    @within CurrencyService
    Adds RAM currency to the player.
]=]
function CurrencyService.AddRAMCurrencyToPlayer(Player: Player, CurrencyName: string, Amount: number)
    local CurrencyType = InMemoryCurrencies[CurrencyName]
    assert(CurrencyType, "Currency does not exist!")

    if not CurrencyType[Player] then
        AddPlayerToRAMCurrencyType(Player, CurrencyName)
    end

    CurrencyType[Player] += Amount*RAMMultipliers(Player)

	Scrypt.ServerNetwork.SendPacketToClient(
		"CurrencyUpdate",
		{ Address = Player, Data = Amount, Reliable = true }
	)
    -- TODO Make sure to check if the player has any type of vip
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Amount number
    @within CurrencyService
    Removes RAM currency from the player.
]=]
function CurrencyService.RemoveRAMCurrencyFromPlayer(Player: Player, CurrencyName: string, Amount: number)
    local CurrencyType = InMemoryCurrencies[CurrencyName]
    assert(CurrencyType, "Currency does not exist!")

    if not CurrencyType[Player] then
        AddPlayerToRAMCurrencyType(Player, CurrencyName)
        return 0
    end

    CurrencyType[Player] -= Amount
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Amount number
    @within CurrencyService
    Sets a value on a RAM currency for the player.
]=]
function CurrencyService.SetRAMCurrencyForPlayer(Player: Player, CurrencyName: string, Amount: number)
    local CurrencyType = InMemoryCurrencies[CurrencyName]
    assert(CurrencyType, "Currency does not exist!")

    if not CurrencyType[Player] then
        AddPlayerToRAMCurrencyType(Player, CurrencyName)
    end

    CurrencyType[Player] = Amount
end

--[=[
    @param Player Player
    @param CurrencyName string
    @param Cost number
    @return boolean
    @within CurrencyService
    Handles purchases with RAM currencies. Returns true or false based on if it was successful.
]=]
function CurrencyService.HandleRAMPurchase(Player: Player, CurrencyName: string, Cost: number): boolean
    local CurrencyType = InMemoryCurrencies[CurrencyName]
    assert(CurrencyType, "Currency does not exist!")

    if not CurrencyType[Player] then
        AddPlayerToRAMCurrencyType(Player, CurrencyName)
        return false
    end

    if CurrencyType[Player] < Cost then
        return false
    end

    CurrencyType[Player] -= Cost
    return true
end

--[=[
    @param Player Player
    @param CurrencyName string
    @return number
    @within CurrencyService
    Returns a player's RAM currency.
]=]
function CurrencyService.GetPlayerRAMCurrency(Player: Player, CurrencyName: string): number
    local CurrencyType = InMemoryCurrencies[CurrencyName]
    assert(CurrencyType, "Currency does not exist!")

    if not CurrencyType[Player] then
        AddPlayerToRAMCurrencyType(Player, CurrencyName)
        return 0
    end

    return CurrencyType[Player]
end

-- Cleanup function
--[=[
    @param Player Player
    @within CurrencyService
    Erases a player from all currencies in a server. This should be used when you do not want to keep track of a player's RAM currencies anymore.
]=]
function CurrencyService.ErasePlayer(Player: Player)
    for name, currency: RAMCurrency in pairs(InMemoryCurrencies) do
        currency[Player] = nil
    end
end

return CurrencyService