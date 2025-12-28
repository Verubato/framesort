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
	},

	read_globals = {
		"assertEquals",
		"GladiusExPartyFrame",
		"GladiusExArenaFrame",
		"sArena",
		"ElvUI",
		"LibStub",
		"ElvUF_PartyGroup1",
		"CompactRaidGroup_OnLoad",
		"CUF_CVar",
		"DefaultCompactUnitFrameSetupOptions",
		"CompactRaidFrame1",
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
	},

	ignore = {
		-- line is too long
		"631",
		-- unused self argument
		"212",
	},

	files = {},
}

-- for some annoying reason this doesn't work
-- I've tried every path pattern combination you can think of
config.files["**/WoW.lua"] = {
	ignore = { "113" },
}

return config
