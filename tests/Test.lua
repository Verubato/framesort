local luaunit = require("luaunit")

-- unit tests
TestPartyMembers = require("Unit\\ComparePartyTest")
TestRaidMembers = require("Unit\\CompareRaidTest")
TestUnitGetUnits = require("Unit\\GetUnitsTest")
TestUnitMacro = require("Unit\\MacroTest")
TestUnitOptionsUpgrader = require("Unit\\UpgradeOptionsTest")
TestUnitEnumerable = require("Unit\\EnumerableTest")

-- component tests
TestComponentTestApiV1 = require("Component\\ApiV1")
TestComponentTestApiV2 = require("Component\\ApiV2")
TestComponentTestMacro = require("Component\\Macro")
TestComponentTestHidePlayer = require("Component\\HidePlayer")
TestComponentTestTargeting = require("Component\\Targeting")
TestComponentTestSorting = require("Component\\Sorting")
TestComponentTestSpacing = require("Component\\Spacing")

-- TODO: if we re-order some of these tests, they will start failing
-- e.g. move the All test to the top
-- sounds like some shared state not being cleared between test runs
-- figure out what the problem is and fix it
TestComponentTestAddon = require("Component\\All")

os.exit(luaunit:run())
