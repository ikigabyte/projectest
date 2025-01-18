--!strict
-- File: ServerScriptService/Modules/PlayerService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local PlayerService = {}
local DataService = Scrypt.GetService("DataService")
local CurrencyService = Scrypt.GetService("CurrencyService")

function PlayerService.GiveUpgrade(Player: Player, UpgradeName: string)
    local Level = Player:GetAttribute(UpgradeName)
    if not Level then Level = 1 end

    Level += 1
    Player:SetAttribute(UpgradeName, Level)
end

function PlayerService.BuyUpgrade(Player: Player, UpgradeName: string): boolean
    local Upgrade = Player:GetAttribute(UpgradeName)
    if not Upgrade then return false end

    local Cost = 20
    CurrencyService.HandleRAMPurchase(Player, Cost)
    Player:SetAttribute(UpgradeName, Upgrade + 1)
end

function PlayerService.GetUpgrade(Player: Player, UpgradeName: string): any?
    local Upgrade = Player:GetAttribute(UpgradeName)
    if not Upgrade then return nil end

    return Upgrade
end

function PlayerService.GetMaxBlocksHold(Player: Player): number
    local Amount = Player:GetAttribute("MaxBlocksHold")

    if not Amount then
        Amount = 10
    end

    return Amount
end

function PlayerService.GetTeam(Player: Player): Team?
    if Player.Team == nil then
        return nil
    end
    
    return Player.Team
end

function PlayerService.GetBlockSkin(Player : Player)
    local Data = DataService.GetPlayerDataAsync(Player)
    assert(Data, "Player data not found")
    assert(Data.BlockSkin, "Block skin not found")

    return Data.BlockSkin
end

return PlayerService