---@diagnostic disable: cast-local-type
---@type Addon
local addon
---@type WowApi
local wow
---@type ClientCapabilities
local capabilities
---@type NameplatesModule
local fsNameplates
---@type SortedUnits
local fsSortedUnits
---@type UnitUtil
local fsUnit
---@type InspectorModule
local fsInspector

local M = {}

local providerFactory = nil
local frameMock = nil
local provider = nil

local nameplate1 = nil
local nameplate2 = nil

local function makeNameTextRegion(frame)
    frame.name = {
        Text = nil,
        SetText = function(self, t)
            self.Text = t
        end,
    }
end

local function captureHook()
    local captured = {}
    local orig = wow.hooksecurefunc

    wow.hooksecurefunc = function(funcName, callback)
        captured.funcName = funcName
        captured.callback = callback
        -- don't call original - we just capture
    end

    return captured, function()
        wow.hooksecurefunc = orig
    end
end

local function setNameplatesConfig(opts)
    local np = addon.DB.Options.Nameplates
    for k, v in pairs(opts) do
        np[k] = v
    end
end

local function setSortedUnits(friendlyUnits, enemyUnits)
    fsSortedUnits.FriendlyUnits = function()
        return friendlyUnits
    end
    fsSortedUnits.ArenaUnits = function()
        return enemyUnits
    end
end

local function setUnitFriendliness(fn)
    fsUnit.IsFriendlyUnit = fn
end

local function makeNameplateFrame(unit)
    assert(frameMock)

    local f = frameMock:New("Frame", nil, nil)
    f.unit = unit
    f:SetName(unit)
    makeNameTextRegion(f)
    return f
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    providerFactory = require("TestHarness\\ProviderFactory")
    frameMock = require("TestHarness\\FrameMock")

    addon = addonFactory:Create()

    wow = addon.WoW.Api
    capabilities = addon.WoW.Capabilities

    fsNameplates = addon.Modules.Nameplates
    fsSortedUnits = addon.Modules.Sorting.SortedUnits
    fsUnit = addon.WoW.Unit
    fsInspector = addon.Modules.Inspector

    provider = providerFactory:Create()
    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    _G.CompactUnitFrame_UpdateName = function() end

    wow.UnitIsPlayer = function(_)
        return true
    end
    wow.issecretvalue = function(_)
        return false
    end
    wow.UnitIsUnit = function(a, b)
        return a == b
    end
    wow.UnitName = function(unit)
        return unit .. "_Name"
    end
    wow.GetSpecializationInfoByID = function(id)
        ---@diagnostic disable-next-line: missing-return-value, return-type-mismatch
        return nil, ("Spec" .. tostring(id))
    end

    capabilities.HasSpecializations = function()
        return true
    end

    fsInspector.FriendlyUnitSpec = function(_)
        return nil
    end
    fsInspector.EnemyUnitSpec = function(_)
        return nil
    end

    setUnitFriendliness(function(unit)
        return not tostring(unit):find("enemy", 1, true)
    end)

    setNameplatesConfig({
        FriendlyEnabled = true,
        EnemyEnabled = true,
        FriendlyFormat = "Frame - $framenumber",
        EnemyFormat = "Enemy $FRAMENUMBER - $NAME ($unit) - $spec",
    })

    setSortedUnits({ "party1", "party2" }, { "arena1", "arena2" })

    nameplate1 = makeNameplateFrame("nameplate1")
    nameplate2 = makeNameplateFrame("nameplate2")
end

function M:teardown()
    if addon and provider and addon.Providers and addon.Providers.All then
        for i = #addon.Providers.All, 1, -1 do
            if addon.Providers.All[i] == provider then
                table.remove(addon.Providers.All, i)
            end
        end
        if addon.Providers.Test == provider then
            addon.Providers.Test = nil
        end
    end

    addon = nil
    wow = nil
    capabilities = nil
    fsNameplates = nil
    fsSortedUnits = nil
    fsUnit = nil
    fsInspector = nil
    provider = nil
    providerFactory = nil
    frameMock = nil
    nameplate1 = nil
    nameplate2 = nil
    _G.CompactUnitFrame_UpdateName = nil
end

function M:test_init_hooks_compactunitframe_updatename()
    local cap, restore = captureHook()
    fsNameplates:Init()
    restore()

    assertEquals(cap.funcName, "CompactUnitFrame_UpdateName")
    assertEquals(type(cap.callback), "function")
end

function M:test_init_bails_when_compactunitframe_updatename_missing()
    _G.CompactUnitFrame_UpdateName = nil
    local cap, restore = captureHook()
    fsNameplates:Init()
    restore()

    assertEquals(cap.funcName, nil)
    assertEquals(cap.callback, nil)
end

local function initAndGetCallback()
    local cap, restore = captureHook()
    fsNameplates:Init()
    restore()
    assert(cap.callback)
    return cap.callback
end

function M:test_onupdatename_ignores_non_player()
    local callback = initAndGetCallback()
    wow.UnitIsPlayer = function(_)
        return false
    end

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, nil)
end

function M:test_onupdatename_ignores_non_nameplate_unit()
    local callback = initAndGetCallback()
    local raidFrame = makeNameplateFrame("raid1")

    callback(raidFrame)
    assertEquals(raidFrame.name.Text, nil)
end

function M:test_onupdatename_respects_friendly_enabled_flag()
    local callback = initAndGetCallback()
    setNameplatesConfig({ FriendlyEnabled = false })

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, nil)
end

function M:test_onupdatename_respects_enemy_enabled_flag()
    local callback = initAndGetCallback()
    setNameplatesConfig({ EnemyEnabled = false })

    local enemyNP = makeNameplateFrame("nameplate1enemy")
    setUnitFriendliness(function(_)
        return false
    end)

    callback(enemyNP)
    assertEquals(enemyNP.name.Text, nil)
end

function M:test_onupdatename_ignores_when_sorted_units_empty()
    local callback = initAndGetCallback()
    setSortedUnits({}, {})

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, nil)
end

function M:test_onupdatename_sets_text_when_matches_friendly_units()
    local callback = initAndGetCallback()

    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1" and b == "party2")
    end

    setNameplatesConfig({ FriendlyFormat = "Frame $FrameNumber: $Name ($UNIT)" })

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, "Frame 2: party2_Name (party2)")
end

function M:test_onupdatename_does_not_set_text_when_is_secret_value()
    local callback = initAndGetCallback()

    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1" and b == "party1")
    end
    wow.issecretvalue = function(_)
        return true
    end

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, nil)
end

function M:test_onupdatename_replaces_framenumber_unit_name_spec_friendly()
    local callback = initAndGetCallback()

    -- nameplate2 should match party1 (frameNumber=1)
    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate2" and b == "party1")
    end

    setNameplatesConfig({
        FriendlyFormat = "FN=$FrameNumber UNIT=$UNIT NAME=$Name SPEC=$sPeC",
    })

    -- Ensure a spec exists for friendly unit (NOTE: colon-method signature!)
    fsInspector.FriendlyUnitSpec = function(_, unit)
        assertEquals(unit, "party1")
        return 123
    end

    wow.GetSpecializationInfoByID = function(id)
        assertEquals(id, 123)
        ---@diagnostic disable-next-line: missing-return-value, return-type-mismatch
        return nil, "Holy"
    end

    wow.UnitName = function(unit)
        assertEquals(unit, "party1")
        return "Alice"
    end

    assert(nameplate2)
    callback(nameplate2)

    assertEquals(nameplate2.name.Text, "FN=1 UNIT=party1 NAME=Alice SPEC=Holy")
end

function M:test_onupdatename_replaces_framenumber_unit_name_spec_enemy()
    local callback = initAndGetCallback()

    -- force enemy path
    setUnitFriendliness(function(_)
        return false
    end)

    -- nameplate1enemy should match arena2 (frameNumber=2)
    local enemyNP = makeNameplateFrame("nameplate1enemy")
    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1enemy" and b == "arena2")
    end

    setNameplatesConfig({
        EnemyFormat = "[$FRAMENUMBER][$unit][$NAME][$SPEC]",
    })

    -- NOTE: colon-method signature!
    fsInspector.EnemyUnitSpec = function(_, unit)
        assertEquals(unit, "arena2")
        return 71
    end

    wow.GetSpecializationInfoByID = function(id)
        assertEquals(id, 71)
        ---@diagnostic disable-next-line: missing-return-value, return-type-mismatch
        return nil, "Arms"
    end

    wow.UnitName = function(unit)
        assertEquals(unit, "arena2")
        return "Bob"
    end

    callback(enemyNP)
    assertEquals(enemyNP.name.Text, "[2][arena2][Bob][Arms]")
end

function M:test_onupdatename_spec_falls_back_to_unknown_when_specid_nil()
    local callback = initAndGetCallback()

    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1" and b == "party2")
    end

    setNameplatesConfig({
        FriendlyFormat = "SPEC=$spec",
    })

    fsInspector.FriendlyUnitSpec = function(_)
        return nil
    end

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, "SPEC=unknown")
end

function M:test_onupdatename_spec_falls_back_to_unknown_when_capabilities_off()
    local callback = initAndGetCallback()

    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1" and b == "party1")
    end

    setNameplatesConfig({
        FriendlyFormat = "SPEC=$spec",
    })

    capabilities.HasSpecializations = function()
        return false
    end

    fsInspector.FriendlyUnitSpec = function(_)
        return 999 -- should be ignored when HasSpecializations=false
    end

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, "SPEC=unknown")
end

function M:test_onupdatename_name_falls_back_to_unknown_when_unitname_missing()
    local callback = initAndGetCallback()

    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1" and b == "party1")
    end

    setNameplatesConfig({
        FriendlyFormat = "NAME=$name",
    })

    -- Simulate API absence: module checks (wow.UnitName and wow.UnitName(unit))
    wow.UnitName = nil

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, "NAME=unknown")
end

function M:test_onupdatename_unknown_variable_is_preserved()
    local callback = initAndGetCallback()

    wow.UnitIsUnit = function(a, b)
        return (a == "nameplate1" and b == "party1")
    end

    setNameplatesConfig({
        FriendlyFormat = "X=$unknown FN=$framenumber",
    })

    assert(nameplate1)
    callback(nameplate1)
    assertEquals(nameplate1.name.Text, "X=$unknown FN=1")
end

return M
