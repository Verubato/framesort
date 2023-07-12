local addonName, addon = ...
local fsFrame = addon.Frame
local fsEnumerable = addon.Enumerable
local M = {}
addon.Health = M

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
        local issecure, taintedAddon = issecurevariable(f)
        if not issecure then
            return AddonFriendlyName(taintedAddon)
        end
    end

    return nil
end

local function ConflictingAddons()
    local issecure, taintedAddon = issecurevariable(CompactRaidFrameContainer, "flowSortFunc")
    if not issecure and taintedAddon ~= addonName then
        return AddonFriendlyName(taintedAddon)
    end

    -- running both at the same time would cause issues
    if GetAddOnEnableState(nil, "SortGroup") ~= 0 then
        return "SortGroup"
    end

    return nil
end

local function SupportsKeepTogether()
    return addon.Options.SortingMethod.TaintlessEnabled or not fsFrame:KeepGroupsTogether()
end

---Returns true if the environment/settings is in a good state, otherwise false.
---@return boolean healthy,HealthCheckResult[] results
function M:IsHealthy()
    local results = {}

    results[#results + 1] = {
        Passed = fsFrame:IsUsingRaidStyleFrames(),
        Description = "Using Raid-Style Party Frames...",
        Remediation = "Please enable 'Use Raid-Style Party Frames' in the Blizzard settings.",
    }

    local conflictingSorter = SortingFunctionsTampered()
    results[#results + 1] = {
        Passed = conflictingSorter == nil,
        Description = "Blizzard sorting functions not tampered with... ",
        Remediation = string.format("%s may cause conflicts, consider disabling it.", conflictingSorter or ""),
    }

    local conflictingAddon = ConflictingAddons()
    results[#results + 1] = {
        Passed = conflictingAddon == nil,
        Description = "No conflicting addons...",
        Remediation = string.format("%s may cause conflicts, consider disabling it.", conflictingAddon or ""),
    }

    results[#results + 1] = {
        Passed = SupportsKeepTogether(),
        Description = "'Keep Groups Together' setting disabled, or using Taintless sorting...",
        Remediation = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "Change the raid display mode to one of the 'Combined Groups' options via Edit Mode."
            or "Disable the 'Keep Groups Together' raid profile setting.",
    }

    return fsEnumerable:From(results):All(function(x)
        return x.Passed
    end), results
end
