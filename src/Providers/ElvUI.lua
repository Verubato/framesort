---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsLog = addon.Logging.Log
local fsProviders = addon.Providers
local M = {}
local callbacks = {}
local fsPlugin = nil
local pluginName = "FrameSort"

fsProviders.ElvUI = M
table.insert(fsProviders.All, M)

local function GetUnit(frame)
    return frame.unit
end

local function IntegrationEnabled()
    ---@diagnostic disable-next-line: undefined-global
    local E = ElvUI[1]

    if not E or not E.db or not E.db.FrameSort then
        return true
    end

    return E.db.FrameSort.Enabled
end

local function PluginEnabled()
    return wow.GetAddOnEnableState(nil, "ElvUI") ~= 0
end

local function Update()
    if not IntegrationEnabled() then
        return
    end

    for _, callback in pairs(callbacks) do
        callback(M)
    end
end

local function OnSecureGroupHeaderUpdate(header)
    ---@diagnostic disable-next-line: undefined-global
    if header ~= ElvUF_PartyGroup1 then
        return
    end

    Update()
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

    if #callbacks > 0 then
        callbacks = {}
    end

    ---@diagnostic disable-next-line: undefined-global
    local E, _, _, P, _ = unpack(ElvUI)
    ---@diagnostic disable-next-line: undefined-global
    local EP = LibStub("LibElvUIPlugin-1.0")
    local UF = E:GetModule("UnitFrames")

    fsPlugin = E:NewModule(pluginName, "AceHook-3.0")

    P[pluginName] = {
        ["Enabled"] = true,
    }

    function fsPlugin:Initialize()
        EP:RegisterPlugin(pluginName, fsPlugin.InsertOptions)

        -- party frames are secure unit buttons that change visibility based on a secure state driver
        -- so we can't rely on event handling to determine when updates are required
        -- instead we hook OnShow/OnHide for each of the secure unit button frames
        fsPlugin:SecureHook(UF, "LoadUnits", function()
            ---@diagnostic disable-next-line: undefined-global
            if not ElvUF_PartyGroup1 then
                fsLog:Error("ElvUF_PartyGroup1 container is nil")
                return
            end

            local expectedChildren = 6
            ---@diagnostic disable-next-line: undefined-global
            local children = ElvUF_PartyGroup1 and { ElvUF_PartyGroup1:GetChildren() } or {}

            if #children == 0 then
                fsLog:Error("ElvUF_PartyGroup1 unexpectedly has 0 children where it should have " .. expectedChildren)
                return
            end

            if #children ~= expectedChildren then
                fsLog:Error(string.format("ElvUF_PartyGroup1 unexpectedly has %d children where it should have %d", #children, expectedChildren))
                -- don't return, might as well try with however many child frames there are
            end

            for _, child in ipairs(children) do
                child:HookScript("OnShow", Update)
                child:HookScript("OnHide", Update)
            end

            fsPlugin:SecureHook("SecureGroupHeader_Update", OnSecureGroupHeaderUpdate)
        end)
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
    end

    E:RegisterModule(pluginName)
end

function M:RegisterCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyFrames()
    ---@diagnostic disable-next-line: undefined-global
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
