---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsCompare = addon.Modules.Sorting.Comparer
local fsLuaEx = addon.Language.LuaEx
local fsEnumerable = addon.Collections.Enumerable
local M = {}
local sortCallbacks = {}

fsProviders.Gladdy = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Gladdy"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Gladdy") ~= 0
end

function M:Init() end

function M:RegisterRequestSortCallback(callback) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    if not M:Enabled() then
        return {}
    end

    local function getFrames()
        local inInstance, instaceType = wow.IsInInstance()
        local isArena = inInstance and instaceType == "arena"
        local frames = {
            ---@diagnostic disable: undefined-global
            GladdyButtonFrame1,
            GladdyButtonFrame2,
            GladdyButtonFrame3,
            GladdyButtonFrame4,
            GladdyButtonFrame5,
        }

        local count = isArena and wow.GetNumArenaOpponentSpecs() or 5
        return fsEnumerable:From(frames):Take(count):ToTable()
    end

    local charKey = wow.UnitName("player") .. " - " .. wow.GetRealmName()
    local profileKey = fsLuaEx:SafeGet(GladdyXZ, { "profileKeys", charKey })
    local profile = fsLuaEx:SafeGet(GladdyXZ, { "profiles", profileKey })

    ---@type FrameContainer
    local arena = {
        Frame = GladdyFrame,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Hard,
        Frames = getFrames,
        Spacing = function()
            local margin = fsLuaEx:SafeGet(profile, { "bottomMargin" }) or 95
            local highlightBorderSize = fsLuaEx:SafeGet(profile, { "highlightInset" }) and 0 or fsLuaEx:SafeGet(profile, { "highlightBorderSize" }) * 2
            local powerBarHeight = fsLuaEx:SafeGet(profile, { "powerBarEnabled" }) and (fsLuaEx:SafeGet(profile, { "powerBarHeight" }) + 1) or 0

            return {
                Horizontal = 0,
                Vertical = margin + highlightBorderSize + powerBarHeight,
            }
        end,
    }

    return {
        arena,
    }
end
