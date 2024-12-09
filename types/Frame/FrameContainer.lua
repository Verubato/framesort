---@meta
---@class FrameContainer
---@field Frame table the container frame.
---@field Type number the type of frames this container holds.
---@field LayoutType number the layout type to use when arranging frames.
---@field FramesOffset? fun(self: table): Offset? any offset to apply for frames within the container.
---@field GroupFramesOffset? fun(self: table): Offset? any offset to apply for frames within a group.
---@field SupportsSpacing boolean? whether frames should have spacing applied.
---@field Spacing? fun(self: table): Spacing custom spacing to apply as an override.
---@field VisibleOnly boolean? whether or not to only sort visible frames.
---@field IsHorizontalLayout? fun(self: table): boolean? whether frames are placed horizontally, only applicable to when the layout type is "Hard".
---@field IsGrouped? fun(self: table): boolean? whether the container may or may not have groups within.
---@field FramesPerLine? fun(self: table): number?: For the hard layout type, specify the number of frames per horizontal/vertical line.
---@field Anchor table?: the frame anchor to use (defaults to parent).
---@field AnchorPoint string?: anchor point of frames relative to their anchor (TOPLEFT/TOPRIGHT/CENTER/etc).
---@field InCombatSortingRequired boolean?: Whether in-combat sorting is required.
---@field Frames? fun(self: table): table[] Returns the set of frames to be used instead of being automatically determined.
---@field ShowUnit? fun(self: table, unitId: string): boolean Determines whether a unit should be shown; only applicable to NameList containers.
---@field PostSort? fun(self: table) Optional callback function that's called after each sort.
---@field SubscribeToVisibility? boolean Whether to run sorting when a frame's visibility status changes.
