local _, addon = ...

---Hooks functions that we should perform a re-sort on.
function addon:HookExperimental()
    hooksecurefunc("CompactRaidGroup_UpdateLayout", function(frame) addon:LayoutParty(frame) end)
    hooksecurefunc(CompactRaidFrameContainer, "LayoutFrames", function() addon:LayoutRaid(CompactRaidFrameContainer) end)
end
