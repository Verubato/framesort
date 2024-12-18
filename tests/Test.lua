local luaunit = require("luaunit")

-- unit tests
TestPartyMembers = require("Unit\\ComparePartyTest")
TestRaidMembers = require("Unit\\CompareRaidTest")
TestArenaMembers = require("Unit\\CompareArenaTest")
TestUnitGetUnits = require("Unit\\GetUnitsTest")
TestUnitMacro = require("Unit\\MacroTest")
TestUnitOptionsUpgrader = require("Unit\\UpgradeOptionsTest")
TestUnitEnumerable = require("Unit\\EnumerableTest")
TestLuaEx = require("Unit\\LuaExTest")

-- component tests
TestComponentTestApiV1 = require("Component\\ApiV1")
TestComponentTestApiV2 = require("Component\\ApiV2")
TestComponentTestMacro = require("Component\\Macro")
TestComponentTestHidePlayer = require("Component\\HidePlayer")
TestComponentTestTargeting = require("Component\\Targeting")
TestComponentTestSorting = require("Component\\Sorting")
TestComponentTestSpacing = require("Component\\Spacing")
TestComponentTestAddon = require("Component\\All")

os.exit(luaunit:run())
