---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsCompare = addon.Collections.Comparer
local M = {}
addon.Modules.Sorting.Traditional = M

function M:Init() end

---Attempts to sort Blizzard frames.
---@return boolean sorted true if sorted, otherwise false.
function M:TrySort()
    local sorted = false
    local sortFunction = fsCompare:SortFunction()

    if wow.IsRetail() then
        if wow.CompactRaidFrameContainer and not wow.CompactRaidFrameContainer:IsForbidden() and wow.CompactRaidFrameContainer:IsVisible() then
            wow.CompactRaidFrameContainer:SetFlowSortFunction(sortFunction)
            sorted = true
        end

        if wow.CompactPartyFrame and not wow.CompactPartyFrame:IsForbidden() and wow.CompactPartyFrame:IsVisible() then
            wow.CompactPartyFrame:SetFlowSortFunction(sortFunction)
            sorted = sorted or true
        end
    else
        if wow.CompactRaidFrameContainer and not wow.CompactRaidFrameContainer:IsForbidden() and wow.CompactRaidFrameContainer:IsVisible() then
            wow.CompactRaidFrameContainer_SetFlowSortFunction(wow.CompactRaidFrameContainer, sortFunction)
            sorted = true
        end
    end

    return sorted
end
