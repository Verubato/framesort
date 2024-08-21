---@meta
---@class Configuration
---@field Init fun(self: table)
---@field Panels Panels
---@field HorizontalSpacing number
---@field VerticalSpacing number
---@field Defaults Options
---@field PlayerSortMode PlayerSortModeEnum
---@field GroupSortMode GroupSortModeEnum
---@field RoleOrdering RoleOrderingEnum
---@field SortingMethod SortingMethodEnum
---@field Upgrader OptionsUpgrader
---@field RegisterConfigurationChangedCallback fun(self: table, callback: fun())
---@field NotifyChanged fun(self: table)
---@field TextLine fun(self: table, line: string, parent: table, anchor: table?, font: string?, verticalSpacing: number?): table anchor
---@field TextBlock fun(self: table, lines: string[], parent: table, anchor: table): table anchor
---@field MultilineTextBlock fun(self: table, lines: string, parent: table, anchor: table): table anchor

---@class Panels
---@field Sorting OptionsPanel
---@field Spacing OptionsPanel
---@field Health OptionsPanel
---@field Keybinding OptionsPanel
---@field Macro OptionsPanel
---@field Addons OptionsPanel
---@field RoleOrdering OptionsPanel
---@field AutoLeader OptionsPanel
---@field SortingMethod OptionsPanel
---@field Api OptionsPanel
---@field Help OptionsPanel
