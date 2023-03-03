local _, addon = ...

---Applies spacing to party/raid frames (depending on which are shown).
function addon:ApplySpacing()
    if not CompactRaidFrameContainer:IsForbidden() and CompactRaidFrameContainer:IsVisible() then
        addon:ApplyRaidFrameSpacing()
    end
end

---Applies spacing to the raid frames.
function addon:ApplyRaidFrameSpacing()
    -- TODO
end
