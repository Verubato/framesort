---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsCompare = addon.Collections.Comparer
local fsLuaEx = addon.Collections.LuaEx
local fsEnumerable = addon.Collections.Enumerable
local M = {}

fsProviders.Gladius = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Gladius"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Gladius") ~= 0
end

function M:Init() end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    ---@type FrameContainer[]
    local containers = {}
    local function getFrames()
        -- in test mode, get the number of frames shown
        local isTest = fsLuaEx:SafeGet(Gladius, { "test" })
        local testCount = fsLuaEx:SafeGet(Gladius, { "testCount" })
        local count = isTest and testCount or wow.GetNumArenaOpponentSpecs()

        return fsEnumerable
            :From({
                ---@diagnostic disable: undefined-global
                GladiusButtonFramearena1,
                GladiusButtonFramearena2,
                GladiusButtonFramearena3,
                GladiusButtonFramearena4,
                GladiusButtonFramearena5,
            })
            :Take(count)
            :ToTable()
    end

    local realmKey = wow.GetRealmName()
    local charKey = wow.UnitName("player") .. " - " .. realmKey
    local profileKey = fsLuaEx:SafeGet(Gladius2DB, { "profileKeys", charKey })
    local profile = fsLuaEx:SafeGet(Gladius2DB, { "profiles", profileKey })

    containers[#containers + 1] = {
        Frame = wow.UIParent,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Hard,
        AnchorPoint = "BOTTOMLEFT",
        VisibleOnly = false,
        Frames = getFrames,
        FramesOffset = function()
            local arena1 = fsLuaEx:SafeGet(Gladius, { "buttons", "arena1" })

            -- refer to Gladius.lua:581
            local scale = arena1 and arena1:GetEffectiveScale() or 1
            local x = (fsLuaEx:SafeGet(Gladius, { "db", "x", "arena1" }) or 0) / scale
            local y = (fsLuaEx:SafeGet(Gladius, { "db", "y", "arena1" }) or 0) / scale

            y = y - (arena1 and arena1:GetHeight())

            return { X = x, Y = y }
        end,
        Spacing = function()
            return {
                Horizontal = 0,
                Vertical = fsLuaEx:SafeGet(profile, { "bottomMargin" }) or 20,
            }
        end,
        PostSort = function()
            local frames = getFrames()

            if #frames == 0 then
                return
            end

            table.sort(frames, function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)

            local topFrame = frames[1]
            GladiusButtonBackground:SetPoint("TOPLEFT", topFrame, -46, 5)
        end,
    }

    return containers
end
