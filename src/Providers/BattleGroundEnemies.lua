---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLuaEx = addon.Collections.LuaEx
local M = {}

fsProviders.BattleGroundEnemies = M
table.insert(fsProviders.All, M)

function M:Name()
    return "BattleGroundEnemies"
end

function M:Enabled()
    return BattleGroundEnemies and type(BattleGroundEnemies) == "table"
end

function M:Init() end
function M:RegisterRequestSortCallback() end
function M:RegisterContainersChangedCallback() end

function M:Containers()
    if not self:Enabled() then
        return {}
    end

    local containers = {}
    local arenaFrame = BattleGroundEnemies.Enemies
    local allyFrame = BattleGroundEnemies.Allies
    local charKey = wow.UnitName("player") .. " - " .. wow.GetRealmName()
    local profileKey = fsLuaEx:SafeGet(BattleGroundEnemiesDB, { "profileKeys", charKey })
    local profile = fsLuaEx:SafeGet(BattleGroundEnemiesDB, { "profiles", profileKey })

    if allyFrame then
        local configs = fsLuaEx:SafeGet(profile, { "Allies", "playerCountConfigs" })
        local arenaConfig = configs and configs[1]
        local verticalSpacing = arenaConfig and arenaConfig.BarVerticalSpacing

        containers[#containers + 1] = {
            Frame = allyFrame,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.Hard,
            AnchorPoint = "TOPLEFT",
            Spacing = function()
                return {
                    Horizontal = 0,
                    Vertical = verticalSpacing or 40,
                }
            end,
            EnableInBattlegrounds = false
        }
    end

    if arenaFrame then
        local configs = fsLuaEx:SafeGet(profile, { "Enemies", "playerCountConfigs" })
        local arenaConfig = configs and configs[1]
        local verticalSpacing = arenaConfig and arenaConfig.BarVerticalSpacing

        containers[#containers + 1] = {
            Frame = arenaFrame,
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Hard,
            AnchorPoint = "TOPLEFT",
            Spacing = function()
                return {
                    Horizontal = 0,
                    Vertical = verticalSpacing or 40,
                }
            end,
            EnableInBattlegrounds = false
        }
    end

    return containers
end
