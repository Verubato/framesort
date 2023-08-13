local _, addon = ...
local fsFrame = addon.Frame
local M = {}
local callbacks = {}
local fsPlugin = nil
local pluginName = "FrameSort"

fsFrame.Providers.ElvUI = M
table.insert(fsFrame.Providers.All, M)

local function GetUnit(frame)
    return frame.unit
end

local function IntegrationEnabled()
    local E = ElvUI[1]

    if not E or not E.db or not E.db.FrameSort then
        return true
    end

    return E.db.FrameSort.Enabled
end

local function PluginEnabled()
    return GetAddOnEnableState(nil, "ElvUI") ~= 0
end

local function Update()
    if not IntegrationEnabled() then
        return
    end

    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

function M:Name()
    return "ElvUI"
end

function M:Enabled()
    return PluginEnabled() and IntegrationEnabled()
end

function M:Init()
    if not PluginEnabled() then
        return
    end

    local E, _, _, P, _ = unpack(ElvUI)
    local UF = E:GetModule("UnitFrames")
    local EP = LibStub("LibElvUIPlugin-1.0")

    fsPlugin = E:NewModule(pluginName, "AceHook-3.0")

    P[pluginName] = {
        ["Enabled"] = true,
    }

    function fsPlugin:Initialize()
        EP:RegisterPlugin(pluginName, fsPlugin.InsertOptions)
    end

    function fsPlugin:InsertOptions()
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

        E.Options.args.unitframe.args.groupUnits.args.party.args.generalGroup.args.sortingGroup.args.groupBy.values.FRAMESORT = "FrameSort"
        E.Options.args.unitframe.args.groupUnits.args.party.args.generalGroup.args.sortingGroup.args.sortDir.values.FRAMESORT = "FrameSort"
        E.Options.args.unitframe.args.groupUnits.args.party.args.generalGroup.args.sortingGroup.args.sortMethod.values.FRAMESORT = "FrameSort"

        UF.headerGroupBy.FRAMESORT = function(header)
            header:SetAttribute("sortMethod", nil)
            header:SetAttribute("groupBy", nil)
            header:SetAttribute("sortDir", nil)
        end
    end

    E:RegisterModule(pluginName)

    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Update)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ROLES_ASSIGNED)
    eventFrame:RegisterEvent(addon.Events.UNIT_PET)

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        EventRegistry:RegisterCallback(addon.Events.EditModeExit, Update)
        eventFrame:RegisterEvent(addon.Events.ARENA_PREP_OPPONENT_SPECIALIZATIONS)
        eventFrame:RegisterEvent(addon.Events.ARENA_OPPONENT_UPDATE)
    end
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyFrames()
    return fsFrame:ChildUnitFrames(ElvUF_PartyGroup1, GetUnit)
end

function M:RaidFrames()
    -- not implemented
    return {}
end

function M:RaidGroupMembers(_)
    -- not implemented
    return {}
end

function M:RaidGroups()
    -- not implemented
    return {}
end

function M:EnemyArenaFrames()
    -- not implemented
    return {}
end

function M:ShowPartyPets()
    -- not implemented
    return false
end

function M:ShowRaidPets()
    -- not implemented
    return false
end

function M:IsRaidGrouped()
    -- not implemented
    return false
end
