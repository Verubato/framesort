local addonName, addon = ...
---@type WoW
local wow = addon.WoW
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
        local issecure, taintedAddon = wow.issecurevariable(f)
        if not issecure then
            return AddonFriendlyName(taintedAddon)
        end
    end

    return nil
end

local function ConflictingAddons()
    if not addon.Frame.Providers.Blizzard:Enabled() then
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

local function SupportsGroups()
    return addon.Options.SortingMethod.TaintlessEnabled or not addon.Frame.Providers.Blizzard:IsRaidGrouped()
end

local function CanSeeFrames()
    if not wow.IsInGroup() then
        return true
    end

    for _, provider in pairs(addon.Frame.Providers:Enabled()) do
        local anyParty = fsEnumerable:From(provider:PartyFrames()):Any(function(x)
            return x:IsVisible()
        end)

        if anyParty then
            return true
        end

        local anyRaid = false

        if not provider:IsRaidGrouped() then
            anyRaid = fsEnumerable:From(provider:RaidFrames()):Any(function(x)
                return x:IsVisible()
            end)
        else
            anyRaid = fsEnumerable
                :From(provider:RaidGroups())
                :Map(function(group)
                    return provider:RaidGroupMembers(group)
                end)
                :Flatten()
                :Any(function(x)
                    return x:IsVisible()
                end)
        end

        if anyRaid then
            return true
        end
    end

    return false
end

---Returns true if the environment/settings is in a good state, otherwise false.
---@return boolean healthy,HealthCheckResult[] results
function M:IsHealthy()
    local results = {}

    assert(#addon.Frame.Providers.All > 0)

    local addonsString = addon.Frame.Providers.All[1]:Name()

    for i = 2, #addon.Frame.Providers.All do
        local provider = addon.Frame.Providers.All[i]
        addonsString = addonsString .. ", " .. provider:Name()
    end

    results[#results + 1] = {
        Passed = CanSeeFrames(),
        Description = "Can detect frames",
        Help = "FrameSort currently supports frames from these addons: " .. addonsString,
    }

    if addon.Frame.Providers.Blizzard:Enabled() then
        results[#results + 1] = {
            Passed = addon.Frame.Providers.Blizzard:IsUsingRaidStyleFrames(),
            Description = "Using Raid-Style Party Frames",
            Help = "Please enable 'Use Raid-Style Party Frames' in the Blizzard settings",
        }

        results[#results + 1] = {
            Passed = SupportsGroups(),
            Description = "'Keep Groups Together' setting disabled, or using Taintless sorting",
            Help = wow.WOW_PROJECT_ID == wow.WOW_PROJECT_MAINLINE and "Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"
                or "Disable the 'Keep Groups Together' raid profile setting",
        }
    end

    local conflictingSorter = SortingFunctionsTampered()
    results[#results + 1] = {
        Passed = conflictingSorter == nil,
        Description = "Blizzard sorting functions not tampered with",
        Help = string.format('"%s" may cause conflicts, consider disabling it', conflictingSorter or "(unknown)"),
    }

    local conflictingAddon = ConflictingAddons()
    results[#results + 1] = {
        Passed = conflictingAddon == nil,
        Description = "No conflicting addons",
        Help = string.format('"%s" may cause conflicts, consider disabling it', conflictingAddon or "(unknown)"),
    }

    return fsEnumerable:From(results):All(function(x)
        return x.Passed
    end), results
end
