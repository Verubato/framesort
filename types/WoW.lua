---@meta
---@class WowApi
-- fields
---@field C_PvP C_PvP
-- constants
---@field MAX_RAID_MEMBERS number
---@field MEMBERS_PER_RAID_GROUP number
-- frames
---@field CreateFrame fun(frameType: string, name: string?, parent: table?, template: string?, id: number?): frame: table
---@field UIParent table
---@field CompactPartyFrame table
---@field PartyFrame table
---@field CompactRaidFrameContainer table
---@field CompactArenaFrame table
---@field CompactArenaFrameTitle table
---@field CompactArenaFrameMember1 table
---@field CompactRaidFrameContainer_SetFlowSortFunction fun(container: table, sortFunction: fun(unit1: string, unit2: string): boolean)
---@field CompactRaidFrameManager_GetSetting fun(name: string): boolean
---@field EditModeManagerFrame table
-- settings
---@field SlashCmdList table
---@field SettingsPanel table
---@field InterfaceOptions_AddCategory fun(panel: table)
---@field InterfaceOptionsFrame_OpenToCategory fun(panel: table)
---@field InterfaceOptionsFramePanelContainer table
---@field Enum table
---@field EventRegistry table
---@field Settings table
-- cvars
---@field GetCVarBool fun(name: string): boolean?
---@field GetCVar fun(name: string): any?
-- macro
---@field GetMacroInfo fun(id: string|number): name: string, icon: number, body: string
---@field EditMacro fun(macroInfo: number|string, name: string?, icon: number|string?, body: string?): macroId: number
-- unit functions
---@field UnitGUID fun(unit: string): string
---@field UnitName fun(unit: string): string
---@field GetUnitName fun(unit: string, showServername: boolean): string
---@field UnitExists fun(unit: string): boolean
---@field UnitIsUnit fun(unit1: string, unit2: string): boolean
---@field UnitInRaid fun(unit: string): index: number?
---@field UnitIsPlayer fun(unit: string): boolean
---@field GetRaidRosterInfo fun(id: number): ...
---@field GetArenaOpponentSpec fun(id: number): specId: number, gender: number
---@field GetSpecializationInfoByID fun(specIndex: number): id: number, name: string, description: string, icon: number, role: string, classFile: string, className: string
---@field UnitGroupRolesAssigned fun(unit: string): role: string
---@field GetInspectSpecialization fun(unit: string): specId: number
---@field GetSpecialization fun(isInspect: boolean?, isPet: boolean?, specGroup: number?): specId: number
---@field UnitIsGroupLeader fun(unit: string, partyCategory: number?): boolean
---@field PromoteToLeader fun(unitOrPlayerName: string)
-- group size functions
---@field GetNumGroupMembers fun(): number
---@field GetNumArenaOpponentSpecs fun(): number
-- state functions
---@field IsInInstance fun(): boolean
---@field IsInGroup fun(): boolean
---@field IsInRaid fun(): boolean
---@field InCombatLockdown fun(): boolean
-- utility
---@field wipe fun(table: table): table
---@field CopyTable fun(table: table): table
---@field strjoin fun(delimiter: string, ...): string
-- secure functions
---@field issecurevariable fun(tableOrName: table|string, name: string?): isSecure: boolean, taint: string?
---@field hooksecurefunc fun(...)
---@field RegisterAttributeDriver fun(frame: table, attribute: string, conditional: string)
---@field UnregisterAttributeDriver fun(frame: table, attribute: string)
---@field SecureHandlerWrapScript fun(frame: table, script: string, header: table, preBody: string?, postBody: string?)
---@field SecureHandlerSetFrameRef fun(frame: table, label: string, refFrame: table)
---@field SecureHandlerExecute fun(frame: table, body: string)
---@field RegisterUnitWatch fun(frame: table)
---@field UnregisterUnitWatch fun(frame: table)
-- addon related
---@field GetAddOnEnableState fun(character: string?, addon: string): number
---@field GetAddOnMetadata fun(nameOrIndex: string, field: string): string
-- time related
---@field GetTimePreciseSec fun(): number
-- other
---@field ReloadUI fun()
---@field C_Timer table
---@field GetLocale fun(): string
---@field GetRealmName fun(): string
-- non-blizzard
---@field IsRetail fun(): boolean
---@field IsClassic fun(): boolean
---@field IsWotlk fun(): boolean
---@field Events WowEvents

---@class C_PvP
---@field IsSoloShuffle fun(): boolean
---@field GetActiveMatchState fun(): number
