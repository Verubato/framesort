local _, addon = ...

---Attempts to sort the party/raid frames.
---@return boolean sorted true if sorted, otherwise false.
function addon:TrySort()
    if not addon:CanSort() then return false end

    local sortFunc = addon:GetSortFunction()
    if sortFunc == nil then return false end

    if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
        if addon.Options.ExperimentalEnabled then
            return CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer)
        else
            addon:Debug("Sorting raid frames.")
            CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, sortFunc)
        end
    else
        return false
    end

    return true
end
