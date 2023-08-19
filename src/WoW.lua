---@diagnostic disable: undefined-global
---@type string, Addon
local _, addon = ...
---@type WoW
addon.WoW = {
    -- constants
    WOW_PROJECT_ID = WOW_PROJECT_ID,
    WOW_PROJECT_CLASSIC = WOW_PROJECT_CLASSIC,
    WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE,
    MAX_RAID_MEMBERS = MAX_RAID_MEMBERS or 40,
    MEMBERS_PER_RAID_GROUP = MEMBERS_PER_RAID_GROUP or 5,

    -- frames
    CreateFrame = CreateFrame,
    UIParent = UIParent,
    CompactPartyFrame = CompactPartyFrame,
    PartyFrame = PartyFrame,
    CompactRaidFrameContainer = CompactRaidFrameContainer,
    CompactArenaFrame = CompactArenaFrame,
    CompactRaidFrameContainer_SetFlowSortFunction = CompactRaidFrameContainer_SetFlowSortFunction,
    CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting,
    EditModeManagerFrame = EditModeManagerFrame,

    -- settings
    SlashCmdList = SlashCmdList,
    SettingsPanel = SettingsPanel,
    InterfaceOptions_AddCategory = InterfaceOptions_AddCategory,
    InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory,
    InterfaceOptionsFramePanelContainer = InterfaceOptionsFramePanelContainer,
    GetCVarBool = GetCVarBool,
    Enum = Enum,
    EventRegistry = EventRegistry,
    Settings = Settings,

    -- macro
    GetMacroInfo = GetMacroInfo,
    EditMacro = EditMacro,

    -- unit functions
    UnitName = UnitName,
    UnitExists = UnitExists,
    UnitIsUnit = UnitIsUnit,
    UnitInRaid = UnitInRaid,
    UnitIsPlayer = UnitIsPlayer,
    GetRaidRosterInfo = GetRaidRosterInfo,
    GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs,
    GetArenaOpponentSpec = GetArenaOpponentSpec,
    GetSpecializationInfoByID = GetSpecializationInfoByID,
    UnitGroupRolesAssigned = UnitGroupRolesAssigned,

    -- state functions
    IsInInstance = IsInInstance,
    IsInGroup = IsInGroup,
    IsInRaid = IsInRaid,
    InCombatLockdown = InCombatLockdown,

    -- utility
    ReloadUI = ReloadUI,
    C_Timer = C_Timer,
    wipe = wipe,
    CopyTable = CopyTable,

    -- secure functions
    issecurevariable = issecurevariable,
    hooksecurefunc = hooksecurefunc,
    RegisterAttributeDriver = RegisterAttributeDriver,

    -- addon related
    GetAddOnEnableState = GetAddOnEnableState,

    -- non-blizzard methods
    IsRetail = function()
        return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    end,
    IsWotlk = function()
        return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
    end,
    IsClassic = function()
        return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
    end,
}
