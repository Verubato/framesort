---@meta
---@class Configuration
---@field Init fun(self: table)
---@field HorizontalSpacing number
---@field VerticalSpacing number
---@field Defaults Options
---@field PlayerSortMode PlayerSortModeEnum
---@field GroupSortMode GroupSortModeEnum
---@field Upgrader OptionsUpgrader
---@field Announcement OptionsPanel
---@field Sorting OptionsPanel
---@field Spacing OptionsPanel
---@field Health OptionsPanel
---@field Keybinding OptionsPanel
---@field SortingMethod SortingMethodOptions
---@field Macro OptionsPanel
---@field Integration OptionsPanel
---@field RegisterConfigurationChangedCallback fun(self: table, callback: fun())
---@field NotifyChanged fun(self: table)
