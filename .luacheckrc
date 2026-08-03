---@diagnostic disable: lowercase-global
local config = {
	std = "lua51",

	globals = {
		"FrameSort",
		"FrameSortDB",
		"FrameSortApi",
		"SLASH_FRAMESORT1",
		"SLASH_FRAMESORT2",
		"BINDING_HEADER_FRAMESORT_TARGET",
		-- published by tests/Test.lua for the harness and any test that loads addon source directly
		"FS_ADDON_ROOT",
		-- read by Capabilities to detect the modern dropdown API, written by the test harness
		"MenuUtil",
	},

	read_globals = {
		"assertEquals",
		"GladiusExPartyFrame",
		"GladiusExArenaFrame",
		"sArena",
		"ElvUI",
		"LibStub",
		"ElvUF_PartyGroup1",
		"ElvUF_Arena1",
		"CompactRaidGroup_OnLoad",
		"CUF_CVar",
		"DefaultCompactUnitFrameSetupOptions",
		"CompactRaidFrame1",
		"CompactPartyFrameBorderFrame",
		"CompactRaidFrameContainer_OnSizeChanged",
		"Cell",
		"CellPartyFrameHeader",
		"CellRaidFrameHeader0",
		"CellDB",
		"SUFHeaderparty",
		"SUFHeaderarena",
		"Grid2LayoutHeader1",
		"CompactArenaFrame_RefreshMembers",
		"GladiusExButtonAnchorarena",
		"GladiusExButtonAnchorparty",
		"GladiusExDB",
		"Grid2",
		"Gladius",
		"BattleGroundEnemies",
		"BattleGroundEnemiesDB",
		"GladdyFrame",
		"CompactUnitFrame_SetUnit",
		"CompactArenaFrameTitle",
		"CompactArenaFrameMember1",
		"GladiusEx",
		"Gladdy",
		"ShadowUF",
		"Grid2Frame",
		"Grid2Layout",
		"CompactRaidFrameContainer_LayoutFrames",
		"LE_EXPANSION_LEVEL_CURRENT",
		"GladdyButtonFrame1",
		"GladdyButtonFrame2",
		"GladdyButtonFrame3",
		"GladdyButtonFrame4",
		"GladdyButtonFrame5",
		"GladdyXZ",
		"GladiusButtonFramearena1",
		"GladiusButtonFramearena2",
		"GladiusButtonFramearena3",
		"GladiusButtonFramearena4",
		"GladiusButtonFramearena5",
		"Gladius2DB",
		"GladiusButtonBackground",
		"CompactUnitFrame_UpdateName",
		"CompactUnitFrame_UpdateVisible",
		"GameTooltip",
        "Platynator",
	},

	ignore = {
		-- line is too long
		"631",
		-- unused self argument
		"212",
	},

	files = {},
}

-- This has no effect: build/Linter.lua hands this table to luacheck.check_strings as an options
-- table, and per-file patterns are only expanded when luacheck loads the config itself. Use an
-- inline `-- luacheck: ignore <code>` comment in the file instead, as src/WoW/Capabilities.lua does.
config.files["**/WoW.lua"] = {
	ignore = { "113" },
}

return config
