EXPORT_ASSERT_TO_GLOBALS = true

-- The suite requires its own modules by name (Comparer.ComparePartyTest and friends), so this
-- directory has to be on the search path. Derived from arg[0] rather than assumed to be the
-- working directory, so `lua tests/Test.lua` from the repository root works the same as
-- `lua Test.lua` from in here - CI does the former.
local testsDir = (arg and arg[0] or ""):gsub("\\", "/"):match("^(.*)/[^/]+$") or "."
package.path = testsDir .. "/?.lua;" .. package.path

-- Published for the harness and any test that loads addon source directly. Deriving it in each
-- of those files instead is unreliable: require rewrites module names using the platform
-- separator, so the path they see varies with both the OS and the directory lua was started in.
FS_ADDON_ROOT = testsDir .. "/.."

local luaunit = require("luaunit")

-- backwards compatibile support
local lu = luaunit.LuaUnit or luaunit

if lu.setOutputType then
    lu:setOutputType("text")
end

TestPartyMembers = require("Comparer.ComparePartyTest")
TestRaidMembers = require("Comparer.CompareRaidTest")
TestArenaMembers = require("Comparer.CompareArenaTest")
TestCaching = require("Comparer.CachingTest")
TestUnitGetUnits = require("WoW.GetUnitsTest")
TestNormaliseUnits = require("WoW.NormaliseUnitTest")
TestUnitMacro = require("Macro.ParserTest")
TestUnitOptionsUpgrader = require("Configuration.UpgradeOptionsTest")
TestUnitEnumerable = require("Collections.EnumerableTest")
TestLuaEx = require("Language.LuaExTest")

TestApiV1 = require("Api.ApiV1Test")
TestApiV2 = require("Api.ApiV2Test")
TestApiV3 = require("Api.ApiV3Test")
TestMacro = require("Modules.MacroTest")
TestHidePlayer = require("Modules.HidePlayerTest")
TestAutoLeader = require("Modules.AutoLeaderTest")

TestTargeting = require("Modules.TargetingTest")
TestSortedUnits = require("Modules.SortedUnitsTest")
TestSortedFrames = require("Modules.SortedFramesTest")
TestSorting = require("Modules.SortingTest")
TestSpacing = require("Modules.SpacingTest")
TestNameplates = require("Modules.NameplatesTest")
TestAddon = require("Modules.AddonTest")

TestFrameChain = require("Frame.FrameChainTest")

os.exit(lu.run())
