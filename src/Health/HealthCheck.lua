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

local function IsSafeAddon(name)
    return name == addonName
        -- wotlk uses a backport addon for raid frames

        or name == "CompactRaidFrame"
end

local function SortingFunctionsTampered()
    local functions = {
        "CRFSort_Group",
        "CRFSort_Role",
        "CRFSort_Alphabetical",
    }

    for _, f in ipairs(functions) do
        local issecure, taintedAddon = wow.issecurevariable(f)
        if not issecure and not IsSafeAddon(taintedAddon) then
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
        if not issecure and not IsSafeAddon(taintedAddon) then
            return AddonFriendlyName(taintedAddon)
        end

        issecure, taintedAddon = wow.issecurevariable(wow.CompactRaidFrameContainer, "flowSortFunc")
        if not issecure and not IsSafeAddon(taintedAddon) then
            return AddonFriendlyName(taintedAddon)
        end
    end

    if wow.CompactPartyFrame then
        local issecure, taintedAddon = wow.issecurevariable("CompactPartyFrame")
        if not issecure and not IsSafeAddon(taintedAddon) then
            return AddonFriendlyName(taintedAddon)
        end

        issecure, taintedAddon = wow.issecurevariable(wow.CompactPartyFrame, "flowSortFunc")
        if not issecure and not IsSafeAddon(taintedAddon) then
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
            local anyVisible = fsEnumerable:From(frames):Any(function(frame)
                return frame:IsVisible()
            end)

            if anyVisible then
                return true
            end

            if container.IsGrouped and container:IsGrouped() then
                local groups = fsFrame:ExtractGroups(container.Frame)
                local anyVisibleInGroup = fsEnumerable
                    :From(groups)
                    :Map(function(group)
                        return fsFrame:ExtractUnitFrames(group)
                    end)
                    :Flatten()
                    :Any(function(frame)
                        return frame:IsVisible()
                    end)

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
    if addon.DB.Options.Sorting.EnemyArena.Enabled and (fsProviders.GladiusEx:Enabled() or fsProviders.sArena:Enabled()) then
        return false
    end

    return not fsProviders.ElvUI:Enabled()
end

local function UsingSpacing()
    local options = addon.DB.Options
    local spacings = {}

    if options.Sorting.World.Enabled then
        spacings[#spacings + 1] = options.Spacing.Party
    end

    if options.Sorting.Raid.Enabled then
        spacings[#spacings + 1] = options.Spacing.Raid
    end

    if options.Sorting.EnemyArena.Enabled then
        spacings[#spacings + 1] = options.Spacing.EnemyArena
    end

    return fsEnumerable:From(spacings):Any(function(spacing)
        return spacing.Vertical ~= 0 or spacing.Horizontal ~= 0
    end)
end

local function IsUsingRaidStyleFrames()
    if wow.IsRetail() then
        return wow.EditModeManagerFrame:UseRaidStylePartyFrames()
    end

    -- for wotlk private
    if CUF_CVar and CUF_CVar.GetCVarBool then
        return CUF_CVar:GetCVarBool("useCompactPartyFrames")
    end

    return wow.GetCVarBool("useCompactPartyFrames")
end

local function IsRaidGrouped()
    if wow.IsRetail() then
        local raidGroupDisplayType =
            wow.EditModeManagerFrame:GetSettingValue(wow.Enum.EditModeSystem.UnitFrame, wow.Enum.EditModeUnitFrameSystemIndices.Raid, wow.Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
        return raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsVertical or raidGroupDisplayType == wow.Enum.RaidGroupDisplayType.SeparateGroupsHorizontal
    end

    return wow.CompactRaidFrameManager_GetSetting("KeepGroupsTogether")
end

local function IsMainTankAssistEnabled()
    return wow.GetCVarBool("raidOptionDisplayMainTankAndAssist")
end

local function CheckCell()
    local passed = false
    local applicable = false

    if Cell and CellDB and CellDB.layouts then
        local selectedLayout = Cell.vars.currentLayout or "default"

        applicable = true
        -- when using combined layout, the group filter will show all groups
        passed = CellDB.layouts[selectedLayout].main.combineGroups
    end

    return {
        Applicable = applicable,
        Passed = passed,
        Description = "Using grouped layout for Cell raid frames",
        Help = "Please check the 'Combined Groups (Raid)' option in Cell -> Layouts",
    }
end

---Returns true if the environment/settings is in a good state, otherwise false.
---@return boolean healthy,HealthCheckResult[] results
function M:IsHealthy()
    local results = {}
    local allProviderNames = fsEnumerable
        :From(fsProviders.All)
        :Map(function(provider)
            return provider:Name()
        end)
        :ToTable()
    local enabledNonBlizzardNames = fsEnumerable
        :From(fsProviders:Enabled())
        :Where(function(p)
            return p ~= fsProviders.Blizzard
        end)
        :Map(function(provider)
            return provider:Name()
        end)
        :ToTable()

    local allProvidersString = wow.strjoin(", ", allProviderNames)
    local enabledNonBlizzardString = wow.strjoin(", ", enabledNonBlizzardNames)

    results[#results + 1] = {
        Applicable = true,
        Passed = CanSeeFrames(),
        Description = "Can detect frames",
        Help = "FrameSort currently supports frames from these addons: " .. allProvidersString,
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.Sorting.Method == fsConfig.SortingMethod.Traditional,
        Passed = IsUsingRaidStyleFrames(),
        Description = "Using Raid-Style Party Frames",
        Help = "Please enable 'Use Raid-Style Party Frames' in the Blizzard settings",
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.Sorting.Method == fsConfig.SortingMethod.Traditional,
        Passed = not IsRaidGrouped(),
        Description = "Keep Groups Together setting disabled",
        Help = wow.IsRetail() and "Change the raid display mode to one of the 'Combined Groups' options via Edit Mode" or "Disable the 'Keep Groups Together' raid profile setting",
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.Sorting.Method == fsConfig.SortingMethod.Traditional,
        Passed = OnlyUsingBlizzard(),
        Description = "Only using Blizzard frames with Traditional mode",
        Help = string.format("Traditional mode can't sort your other frame addons: '%s'", enabledNonBlizzardString),
    }

    results[#results + 1] = {
        Applicable = addon.DB.Options.Sorting.Method == fsConfig.SortingMethod.Traditional,
        Passed = not UsingSpacing(),
        Description = "Using Secure sorting mode when spacing is being used.",
        Help = "Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method.",
    }

    local conflictingSorter = SortingFunctionsTampered()
    results[#results + 1] = {
        Applicable = addon.DB.Options.Sorting.Method == fsConfig.SortingMethod.Traditional,
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

    local mainTankAndAssist = IsMainTankAssistEnabled()
    results[#results + 1] = {
        Applicable = wow.IsInRaid(),
        Passed = not mainTankAndAssist,
        Description = "Main tank and assist setting disabled",
        Help = "Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames",
    }

    results[#results + 1] = CheckCell()

    return fsEnumerable:From(results):All(function(x)
        return not x.Applicable or x.Passed
    end), results
end
