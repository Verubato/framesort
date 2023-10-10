---@type string, Addon
local addonName, addon = ...
local wow = addon.WoW.Api
local fsEnumerable = addon.Collections.Enumerable
local fsProviders = addon.Providers
local fsConfig = addon.Configuration
local fsFrame = addon.WoW.Frame
---@class HealthChecker
local M = {}
addon.Health.HealthCheck = M

local function AddonFriendlyName(name)
    if not name then
        return "(unknown)"
    elseif name == "" then
        return "(user macro)"
    elseif name == "*** ForceTaint_Strong ***" then
        return "(user macro)"
    else
        return name
    end
end

local function SortingFunctionsTampered()
    local functions = {
        "CRFSort_Group",
        "CRFSort_Role",
        "CRFSort_Alphabetical",
    }

    for _, f in ipairs(functions) do
        local issecure, taintedAddon = wow.issecurevariable(f)
        if not issecure then
            return AddonFriendlyName(taintedAddon)
        end
    end

    return nil
end

local function ConflictingAddons()
    if not fsProviders.Blizzard:Enabled() then
        return nil
    end

    if wow.CompactRaidFrameContainer then
        local issecure, taintedAddon = wow.issecurevariable("CompactRaidFrameContainer")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end

        issecure, taintedAddon = wow.issecurevariable(wow.CompactRaidFrameContainer, "flowSortFunc")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end
    end

    if wow.CompactPartyFrame then
        local issecure, taintedAddon = wow.issecurevariable("CompactPartyFrame")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end

        issecure, taintedAddon = wow.issecurevariable(wow.CompactPartyFrame, "flowSortFunc")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end
    end

    -- running both at the same time would cause issues
    if wow.GetAddOnEnableState(nil, "SortGroup") ~= 0 then
        return "SortGroup"
    end

    return nil
end

local function CanSeeFrames()
    if not wow.IsInGroup() then
        return true
    end

    for _, provider in pairs(fsProviders:Enabled()) do
        local containers = provider:Containers()

        for _, container in ipairs(containers) do
            local frames = fsFrame:ExtractUnitFrames(container.Frame)
            local anyVisible = fsEnumerable:From(frames):Any(function(frame) return frame:IsVisible() end)

            if anyVisible then
                return true
            end

            if container.SupportsGrouping and container:SupportsGrouping() then
                local groups = fsFrame:ExtractGroups(container.Frame)
                local anyVisibleInGroup = fsEnumerable
                    :From(groups)
                    :Map(function(group) return fsFrame:ExtractUnitFrames(group) end)
                    :Flatten()
                    :Any(function(frame) return frame:IsVisible() end)

                if anyVisibleInGroup then
                    return true
                end
            end
        end
    end

    return false
end

local function OnlyUsingBlizzard()
    -- TODO: make this more generic, probs need a supporting method added to providers
    if addon.DB.Options.EnemyArena.Enabled and (fsProviders.GladiusEx:Enabled() or fsProviders.sArena:Enabled()) then
        return false
    end

    return not fsProviders.ElvUI:Enabled()
end

local function UsingSpacing()
    local spacings = {}

    if addon.DB.Options.World.Enabled then
        spacings[#spacings + 1] = addon.DB.Options.Appearance.Party.Spacing
    end

    if addon.DB.Options.Raid.Enabled then
        spacings[#spacings + 1] = addon.DB.Options.Appearance.Raid.Spacing
    end

    if addon.DB.Options.EnemyArena.Enabled then
        spacings[#spacings + 1] = addon.DB.Options.Appearance.EnemyArena.Spacing
    end

    return fsEnumerable
        :From(spacings)
        :Any(function(spacing) return spacing.Vertical ~= 0 or spacing.Horizontal ~= 0 end)
end

local function IsUsingRaidStyleFrames()
    if wow.IsRetail() then
        return wow.EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        return wow.GetCVarBool("useCompactPartyFrames")
    end
end

local function IsRaidGrouped()
    if wow.IsRetail() then
        local raidGroupDisplayType = wow.EditModeManagerFrame:GetSettingValue(
            wow.Enum.EditModeSystem.UnitFrame,
            wow.Enum.EditModeUnitFrameSystemIndices.Raid,
            wow.Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    end

    return wow.CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

---Returns true if the environment/settings is in a good state, otherwise false.
---@return boolean healthy,HealthCheckResult[] results
function M:IsHealthy()
    local results = {}

    assert(#fsProviders.All > 0)

    local addonsString = fsProviders.All[1]:Name()

    for i = 2, #fsProviders.All do
        local provider = fsProviders.All[i]
        addonsString = addonsString .. ", " .. provider:Name()
    end

    local enabledNonBlizzard = fsEnumerable
        :From(fsProviders:Enabled())
        :Where(function(p)
            return p ~= fsProviders.Blizzard
        end)
        :ToTable()

    local enabledNonBlizzardString = ""
    if #enabledNonBlizzard > 0 then
        enabledNonBlizzardString = enabledNonBlizzard[1]:Name()

        for i = 2, #enabledNonBlizzard do
            local provider = enabledNonBlizzard[i]
            enabledNonBlizzardString = enabledNonBlizzardString .. ", " .. provider:Name()
        end
    end

    results[#results + 1] = {
        Applicable = true,
        Passed = CanSeeFrames(),
        Description = "Can detect frames",
        Help = "FrameSort currently supports frames from these addons: " .. addonsString,
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional,
        Passed = IsUsingRaidStyleFrames(),
        Description = "Using Raid-Style Party Frames",
        Help = "Please enable 'Use Raid-Style Party Frames' in the Blizzard settings",
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional,
        Passed = not IsRaidGrouped(),
        Description = "Keep Groups Together setting disabled",
        Help = wow.IsRetail() and "Change the raid display mode to one of the 'Combined Groups' options via Edit Mode" or "Disable the 'Keep Groups Together' raid profile setting",
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional,
        Passed = OnlyUsingBlizzard(),
        Description = "Only using Blizzard frames with Traditional mode",
        Help = string.format("Traditional mode can't sort your other frame addons: '%s'", enabledNonBlizzardString),
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional,
        Passed = not UsingSpacing(),
        Description = "Using Secure sorting mode when spacing is being used.",
        Help = "Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method.",
    }

    local conflictingSorter = SortingFunctionsTampered()
    results[#results + 1] = {
        Applicable = addon.DB.Options.SortingMethod == fsConfig.SortingMethod.Traditional,
        Passed = conflictingSorter == nil,
        Description = "Blizzard sorting functions not tampered with",
        Help = string.format('"%s" may cause conflicts, consider disabling it', conflictingSorter or "(unknown)"),
    }

    local conflictingAddon = ConflictingAddons()
    results[#results + 1] = {
        Applicable = true,
        Passed = conflictingAddon == nil,
        Description = "No conflicting addons",
        Help = string.format('"%s" may cause conflicts, consider disabling it', conflictingAddon or "(unknown)"),
    }

    return fsEnumerable:From(results):All(function(x)
        return not x.Applicable or x.Passed
    end), results
end
