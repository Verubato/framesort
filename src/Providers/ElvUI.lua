---@type string, Addon
local _, addon = ...
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLog = addon.Logging.Log
local fsLuaEx = addon.Language.LuaEx
local wowEx = addon.WoW.WowEx
local events = addon.WoW.Events
local M = {}
local useEvents = false
local containersChangedCallbacks = {}
local sortCallbacks = {}
local fsPlugin = nil
local pluginName = "FrameSort"
local maxArenaFrames = 5

fsProviders.ElvUI = M
table.insert(fsProviders.All, M)

local function RequestSort(reason)
    for _, callback in ipairs(sortCallbacks) do
        callback(M, reason)
    end
end

local function RequestUpdateContainers()
    for _, callback in ipairs(containersChangedCallbacks) do
        callback(M)
    end
end

local function IntegrationEnabled()
    if not ElvUI then
        return false
    end

    local E = ElvUI[1]

    if not E or not E.db or not E.db.FrameSort then
        return true
    end

    return E.db.FrameSort.Enabled
end

local function ElvUiEnabled()
    return wowEx.IsAddOnEnabled("ElvUI")
end

local function OnHook(_, event)
    if not IntegrationEnabled() then
        return
    end

    RequestSort(event)
end

function M:Name()
    return "ElvUI"
end

function M:Enabled()
    return ElvUiEnabled() and IntegrationEnabled()
end

function M:RegisterRequestSortCallback(callback)
    if not callback then
        fsLog:Bug("ElvUI:RegisterRequestSortCallback() - callback must not be nil.")
        return
    end

    sortCallbacks[#sortCallbacks + 1] = callback
end

function M:RegisterContainersChangedCallback(callback)
    if not callback then
        fsLog:Bug("ElvUI:RegisterContainersChangedCallback() - callback must not be nil.")
        return
    end

    containersChangedCallbacks[#containersChangedCallbacks + 1] = callback
end

function M:ProcessEvent(event)
    if not useEvents then
        return
    end

    if event == events.GROUP_ROSTER_UPDATE then
        RequestSort(event)
    elseif event == events.PLAYER_ROLES_ASSIGNED then
        RequestSort(event)
    elseif event == events.PLAYER_SPECIALIZATION_CHANGED then
        RequestSort(event)
    elseif event == events.UNIT_PET then
        RequestSort(event)
    elseif event == events.ARENA_OPPONENT_UPDATE then
        RequestSort(event)
    elseif event == events.ARENA_PREP_OPPONENT_SPECIALIZATIONS then
        RequestSort(event)
    end
end

function M:Containers()
    local containers = {}

    if not ElvUiEnabled() then
        return containers
    end

    if ElvUF_PartyGroup1 then
        ---@type FrameContainer
        local party = {
            Frame = ElvUF_PartyGroup1,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.NameList,
        }

        containers[#containers + 1] = party
    end

    -- ElvUI arena frames are individually spawned (ElvUF_Arena1..5) and chain-anchored,
    -- so this container uses the Hard layout (anchor-based) like sArena, not NameList.
    local arenaHeader = _G.ArenaHeader
    if arenaHeader and ElvUF_Arena1 then
        local growthDirection = function()
            return fsLuaEx:SafeGet(ElvUI[1], { "db", "unitframe", "units", "arena", "growthDirection" }) or "DOWN"
        end

        local anchorPointForDirection = {
            DOWN = "TOPRIGHT",
            UP = "BOTTOMRIGHT",
            RIGHT = "LEFT",
            LEFT = "RIGHT",
        }

        ---@type FrameContainer
        local arena = {
            Frame = arenaHeader,
            Anchor = (arenaHeader.mover or arenaHeader),
            AnchorPoint = anchorPointForDirection[growthDirection()] or "TOPRIGHT",
            Type = fsFrame.ContainerType.EnemyArena,
            LayoutType = fsFrame.LayoutType.Hard,
            -- in the prep room, frames are hidden behind prep overlays
            -- so we still want to sort them regardless of visibility
            VisibleOnly = false,
            SupportsSpacing = true,
            InCombatSortingRequired = true,
            SubscribeToVisibility = true,
            Frames = function()
                local count = wowEx.ArenaOpponentsCount()
                if count <= 0 then
                    count = maxArenaFrames
                end

                local frames = {}
                for i = 1, count do
                    local frame = _G["ElvUF_Arena" .. i]
                    if frame then
                        frames[#frames + 1] = frame
                    end
                end

                return frames
            end,
            IsHorizontalLayout = function()
                local dir = growthDirection()
                return dir == "LEFT" or dir == "RIGHT"
            end,
            Spacing = function()
                local spacing = fsLuaEx:SafeGet(ElvUI[1], { "db", "unitframe", "units", "arena", "spacing" }) or 3
                return {
                    Horizontal = spacing,
                    Vertical = spacing,
                }
            end,
        }

        containers[#containers + 1] = arena
    end

    return containers
end

function M:Init()
    if not ElvUiEnabled() then
        return
    end

    if not ElvUI then
        fsLog:Bug("ElvUI is nil.")
        return
    end

    local E, _, _, P, _ = unpack(ElvUI)

    if not E then
        fsLog:Bug("ElvUI module handler is nil.")
        return
    end

    if not P then
        fsLog:Bug("ElvUI plugin handler is nil.")
        return
    end

    local EP = LibStub("LibElvUIPlugin-1.0", true)

    if not EP then
        fsLog:Bug("ElvUI plugin stub is nil.")
        return
    end

    local UF = E:GetModule("UnitFrames")

    if not UF then
        fsLog:Bug("ElvUI unit frames is nil.")
        return
    end

    fsPlugin = E:NewModule(pluginName, "AceHook-3.0")

    if not fsPlugin then
        fsLog:Bug("Failed to create ElvUI plugin module.")
        return
    end

    P[pluginName] = {
        ["Enabled"] = true,
    }

    function fsPlugin.Initialize()
        EP:RegisterPlugin(pluginName, fsPlugin.InsertOptions)

        fsPlugin:SecureHook(UF, "LoadUnits", function()
            local hasParty = ElvUF_PartyGroup1 ~= nil
            local hasArena = ElvUF_Arena1 ~= nil

            if not hasParty and not hasArena then
                fsLog:Bug("Missing ElvUF_PartyGroup1 and ElvUF_Arena1.")

                useEvents = true
                return
            end

            fsLog:Debug("ElvUI loaded units, requesting container update.")
            RequestUpdateContainers()

            if hasParty then
                ElvUF_PartyGroup1:HookScript("OnEvent", OnHook)

                -- parent (ElvUF_Party) owns the state driver; sort when it becomes visible
                local parentFrame = ElvUF_PartyGroup1:GetParent()
                if parentFrame then
                    parentFrame:HookScript("OnShow", function()
                        RequestSort("ElvUF_PartyGroup1 shown")
                    end)
                end
            else
                useEvents = true
            end

            if hasArena then
                ElvUF_Arena1:HookScript("OnEvent", OnHook)
            else
                useEvents = true
            end
        end)
    end

    function fsPlugin.InsertOptions()
        E.Options.args.FrameSort = {
            order = 100,
            type = "group",
            name = pluginName,
            args = {
                Enabled = {
                    order = 1,
                    type = "toggle",
                    name = "Enabled",
                    desc = "Enables/disables FrameSort integration.",
                    get = function(_)
                        return E.db.FrameSort.Enabled
                    end,
                    set = function(_, value)
                        E.db.FrameSort.Enabled = value
                    end,
                },
            },
        }
    end

    E:RegisterModule(pluginName)
end
