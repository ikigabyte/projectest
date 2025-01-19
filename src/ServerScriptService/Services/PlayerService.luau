--!strict
-- File: ServerScriptService/Modules/PlayerService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local PlayerService = {}
--[=[
    @class PlayerService
    @server
]=]

local DataService = Scrypt.GetService("DataService")
local CurrencyService = Scrypt.GetService("CurrencyService")
local TeamService = Scrypt.GetService("TeamService")
local GameConfig = Scrypt.GetModule("GameConfig")

--[=[
    @param Player Player
    @param UpgradeName string
    @within PlayerService
    Gives the player an upgrade.
]=]
function PlayerService.GiveUpgrade(Player: Player, UpgradeName: string)
    local Level = Player:GetAttribute(UpgradeName)
    if not Level then Level = 1 end

    Level += 1
    Player:SetAttribute(UpgradeName, Level)
end

--[=[
    @param Player Player
    @param UpgradeName string
    @within PlayerService
    @return boolean
    Attempts to buy an upgrade. Returns whether the upgrade purchase was successful or not.
]=]
function PlayerService.BuyUpgrade(Player: Player, UpgradeName: string): boolean
    
end

function PlayerService.BuyTeamUpgrade(Player: Player, UpgradeName: string): boolean
    if Player.Team == nil then return false end

    local Upgrade = TeamService.GetBaseChild(tostring(Player.Team), "Upgrades"):FindFirstChild(UpgradeName)
    if not Upgrade then return false end

    local Cost = GameConfig[UpgradeName .. "BaseCost"]
    print(Cost)
    CurrencyService.HandleRAMPurchase(Player, "Coins", Cost)
    Upgrade.Value += 1
end

--[=[
    @param Player Player
    @param UpgradeName string
    @within PlayerService
    @return any?
    Returns an upgrade for the player.
]=]
function PlayerService.GetUpgrade(Player: Player, UpgradeName: string): any?
    local Upgrade = Player:GetAttribute(UpgradeName)
    if not Upgrade then return nil end

    return Upgrade
end

--[=[
    @param Player Player
    @within PlayerService
    @return number
    @unreleased
    Returns the maximum amount of blocks a player can hold.
]=]
function PlayerService.GetMaxBlocksHold(Player: Player): number
    local Amount = Player:GetAttribute("MaxBlocksHold")

    if not Amount then
        Amount = 10
    end

    return Amount
end

--[=[
    @param Player Player
    @within PlayerService
    @return Team?
    Returns the team the player is assigned to.
]=]
function PlayerService.GetTeam(Player: Player): Team?
    if Player.Team == nil then
        return nil
    end
    
    return Player.Team
end

--[=[
    @param Player Player
    @within PlayerService
    @return string
    Returns the block skin of the player.
]=]
function PlayerService.GetBlockSkin(Player : Player)
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data.BlockSkin, "Block skin not found")

    return Data.BlockSkin
end

return PlayerService