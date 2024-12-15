---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsEnumerable = addon.Collections.Enumerable
local fsCompare = addon.Collections.Comparer
local M = {}

fsProviders.GladiusEx = M
table.insert(fsProviders.All, M)

function M:Name()
    return "GladiusEx"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "GladiusEx") ~= 0
end

function M:Init() end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    ---@type FrameContainer[]
    local containers = {}

    if GladiusExPartyFrame and GladiusExButtonAnchorparty then
        containers[#containers + 1] = {
            Frame = GladiusExPartyFrame,
            Anchor = GladiusExButtonAnchorparty,
            AnchorPoint = "LEFT",
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.Hard,
            Spacing = function()
                local margin = GladiusExDB.namespaces.party.profiles.Default.margin or 20
                local iconsHeight = GladiusExDB.namespaces.Cooldowns.profiles.Default.groups.group_1.cooldownsSize or 5
                local vertical = margin + iconsHeight

                return {
                    Horizontal = 0,
                    Vertical = vertical,
                }
            end,
            FramesOffset = function()
                local castBarWidth = GladiusExDB.namespaces.CastBar.profiles.Default.castBarWidth or 175

                return {
                    X = castBarWidth,
                    -- TODO: where does this come from?
                    Y = 12,
                }
            end,
        }
    end

    local function GetProfileKey()
        local name = wow.UnitName("player")
        -- important to use GetRealmName() because this is what AceDB uses and it returns the realm name with spaces and hyphens
        -- whereas UnitFullName returns the realm name without hyphens and spaces
        local realm = wow.GetRealmName()
        local fullName = name .. " - " .. realm
        return GladiusExDB.profileKeys[fullName] or "Default"
    end

    if GladiusExArenaFrame and GladiusExButtonAnchorarena then
        containers[#containers + 1] = {
            Frame = GladiusExArenaFrame,
            Anchor = GladiusExButtonAnchorarena,
            AnchorPoint = "LEFT",
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Hard,
            Spacing = function()
                local profileKey = GetProfileKey()
                local margin = 5
                local iconsHeight = 20

                if GladiusExDB.namespaces.arena.profiles[profileKey] then
                    margin = GladiusExDB.namespaces.arena.profiles[profileKey].margin
                end

                -- profiles may be null when they disable the Cooldowns module
                if GladiusExDB.namespaces.Cooldowns.profiles and GladiusExDB.namespaces.Cooldowns.profiles[profileKey] then
                    iconsHeight = GladiusExDB.namespaces.Cooldowns.profiles[profileKey].groups.group_1.cooldownsSize
                else
                    iconsHeight = 0
                end

                local vertical = margin + iconsHeight
                return {
                    Horizontal = 0,
                    Vertical = vertical,
                }
            end,
            FramesOffset = function()
                local profileKey = GetProfileKey()
                local castBarWidth = 175

                -- profiles may be null when they disable the CastBar module
                if GladiusExDB.namespaces.CastBar.profiles and GladiusExDB.namespaces.CastBar.profiles[profileKey] then
                    castBarWidth = GladiusExDB.namespaces.CastBar.profiles[profileKey].castBarWidth
                else
                    castBarWidth = 0
                end

                return {
                    X = castBarWidth,
                    -- TODO: where does this come from?
                    Y = 102,
                }
            end,
        }
    end

    return containers
end
