---@diagnostic disable: undefined-global
---@type string, Addon
local _, addon = ...
---@type WowApi
addon.WoW.Api = {
    -- fields
    C_PvP = C_PvP,
    C_Map = C_Map,
    C_Timer = C_Timer,

    -- constants
    MAX_RAID_MEMBERS = MAX_RAID_MEMBERS or 40,
    MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS or 4,
    MEMBERS_PER_RAID_GROUP = MEMBERS_PER_RAID_GROUP or 5,
    RAID_CLASS_COLORS = RAID_CLASS_COLORS,

    -- frames
    CreateFrame = CreateFrame,
    UIParent = UIParent,
    PartyFrame = PartyFrame,
    CompactPartyFrame = CompactPartyFrame,
    CompactRaidFrameContainer = CompactRaidFrameContainer,
    CompactArenaFrame = CompactArenaFrame,
    CompactRaidFrameContainer_SetFlowSortFunction = CompactRaidFrameContainer_SetFlowSortFunction,
    CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting or function(_)
        return false
    end,
    EditModeManagerFrame = EditModeManagerFrame,

    -- mouse
    GetCursorPosition = GetCursorPosition,

    -- settings
    SlashCmdList = SlashCmdList,
    SettingsPanel = SettingsPanel,
    InterfaceOptions_AddCategory = InterfaceOptions_AddCategory,
    InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory,
    InterfaceOptionsFramePanelContainer = InterfaceOptionsFramePanelContainer,
    Enum = Enum,
    EventRegistry = EventRegistry,
    Settings = Settings,

    -- cvars
    GetCVarBool = GetCVarBool,
    GetCVar = GetCVar,

    -- macro
    GetMacroInfo = GetMacroInfo,
    EditMacro = EditMacro,

    -- unit functions
    GetUnitName = GetUnitName,
    UnitName = UnitName,
    UnitGUID = UnitGUID,
    UnitExists = UnitExists,
    UnitClass = UnitClass,
    UnitIsUnit = UnitIsUnit,
    UnitIsEnemy = UnitIsEnemy,
    UnitIsFriend = UnitIsFriend,
    UnitInRaid = UnitInRaid,
    UnitIsPlayer = UnitIsPlayer,
    UnitIsConnected = UnitIsConnected,
    UnitIsGroupLeader = UnitIsGroupLeader,
    UnitGroupRolesAssigned = UnitGroupRolesAssigned,
    GetRaidRosterInfo = GetRaidRosterInfo,
    GetArenaOpponentSpec = GetArenaOpponentSpec,
    GetSpecializationInfoByID = GetSpecializationInfoByID,
    GetSpecialization = GetSpecialization,
    GetInspectSpecialization = GetInspectSpecialization,
    GetSpecializationInfo = GetSpecializationInfo,
    PromoteToLeader = PromoteToLeader,

    -- inspect functions
    CanInspect = CanInspect,
    NotifyInspect = NotifyInspect,
    ClearInspectPlayer = ClearInspectPlayer,

    -- state functions
    IsInInstance = IsInInstance,
    IsInGroup = IsInGroup or function()
        if GetNumGroupMembers then
            return GetNumGroupMembers() > 0
        end

        if GetNumRaidMembers and GetNumRaidMembers() > 0 then
            return true
        end

        if GetNumPartyMembers and GetNumPartyMembers() > 0 then
            return true
        end

        return false
    end,

    IsInRaid = IsInRaid,
    InCombatLockdown = InCombatLockdown,

    -- group size functions
    GetNumGroupMembers = GetNumGroupMembers,
    GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs,
    GetNumArenaOpponents = GetNumArenaOpponents,
    GetNumBattlefieldScores = GetNumBattlefieldScores,

    -- utility
    wipe = wipe,
    CopyTable = CopyTable,

    -- secure functions
    issecurevariable = issecurevariable,
    hooksecurefunc = hooksecurefunc,
    RegisterAttributeDriver = RegisterAttributeDriver,
    UnregisterAttributeDriver = UnregisterAttributeDriver,
    -- used for older clients that don't have the new attribute driver functions
    RegisterStateDriver = RegisterStateDriver,
    UnregisterStateDriver = UnregisterStateDriver,
    RegisterUnitWatch = RegisterUnitWatch,
    UnregisterUnitWatch = UnregisterUnitWatch,
    SecureHandlerWrapScript = SecureHandlerWrapScript,
    SecureHandlerSetFrameRef = SecureHandlerSetFrameRef,
    SecureHandlerExecute = SecureHandlerExecute,

    -- class related
    GetClassInfo = GetClassInfo,
    GetNumSpecializationsForClassID = C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializationsForClassID or GetNumSpecializationsForClassID,
    GetSpecializationInfoForClassID = C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfoForClassID or GetSpecializationInfoForClassID,

    -- bg related
    GetBattlefieldScore = GetBattlefieldScore,

    -- other
    ReloadUI = ReloadUI,
    GetLocale = GetLocale,
    GetRealmName = GetRealmName,
    GetRealZoneText = GetRealZoneText,

    -- addon related
    GetAddOnEnableState = function(character, name)
        -- in wotlk private 3.4.3 C_AddOns exists but C_AddOns.GetAddOnEnableState doesn't
        if C_AddOns and C_AddOns.GetAddOnEnableState then
            -- argument order is reversed
            return C_AddOns.GetAddOnEnableState(name, character)
        end

        if GetAddOnEnableState then
            return GetAddOnEnableState(character, name)
        end

        local getAddonInfo = C_AddOns and C_AddOns.GetAddOnInfo or GetAddOnInfo

        if not getAddonInfo then
            return 0
        end

        local _, _, _, loadable, reason, _, _ = getAddonInfo(name)

        if loadable and not reason then
            return 1
        else
            return 0
        end
    end,
    GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata,

    -- time related
    GetTimePreciseSec = GetTimePreciseSec or function()
        return debugprofilestop() / 1000
    end,

    -- secrets
    issecretvalue = issecretvalue or function()
        return false
    end,
}
