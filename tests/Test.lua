EXPORT_ASSERT_TO_GLOBALS = true

local luaunit = require("luaunit")

-- backwards compatibile support
local lu = luaunit.LuaUnit or luaunit

if lu.setOutputType then
    lu:setOutputType("text")
end

TestPartyMembers = require("Comparer\\ComparePartyTest")
TestRaidMembers = require("Comparer\\CompareRaidTest")
TestArenaMembers = require("Comparer\\CompareArenaTest")
TestCaching = require("Comparer\\CachingTest")
TestUnitGetUnits = require("WoW\\GetUnitsTest")
TestNormaliseUnits = require("WoW\\NormaliseUnitTest")
TestUnitMacro = require("Macro\\ParserTest")
TestUnitOptionsUpgrader = require("Configuration\\UpgradeOptionsTest")
TestUnitEnumerable = require("Collections\\EnumerableTest")
TestLuaEx = require("Language\\LuaExTest")

TestApiV1 = require("Api\\ApiV1Test")
TestApiV2 = require("Api\\ApiV2Test")
TestApiV3 = require("Api\\ApiV3Test")
TestMacro = require("Modules\\MacroTest")
TestHidePlayer = require("Modules\\HidePlayerTest")
TestAutoLeader = require("Modules\\AutoLeaderTest")
TestUnitTracker = require("Modules\\UnitTrackerTest")
TestTargeting = require("Modules\\TargetingTest")
TestSortedUnits = require("Modules\\SortedUnitsTest")
TestSortedFrames = require("Modules\\SortedFramesTest")
TestSorting = require("Modules\\SortingTest")
TestSpacing = require("Modules\\SpacingTest")
TestNameplates = require("Modules\\NameplatesTest")
TestAddon = require("Modules\\AddonTest")

TestFrameChain = require("Frame\\FrameChainTest")

os.exit(lu.run())
