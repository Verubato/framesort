local _, addon = ...

---Hooks functions that we should perform a re-sort on.
function addon:HookExperimental()
    hooksecurefunc("CompactRaidFrameContainer_LayoutFrames", function() addon:LayoutRaid(CompactRaidFrameContainer) end)
end
