local luaunit = require("luaunit")

-- unit tests
TestPartyMembers = require("Unit\\ComparePartyTest")
TestRaidMembers = require("Unit\\CompareRaidTest")
TestUnitGetUnits = require("Unit\\GetUnitsTest")
TestUnitMacro = require("Unit\\MacroTest")
TestUnitOptionsUpgrader = require("Unit\\UpgradeOptionsTest")
TestUnitEnumerable = require("Unit\\EnumerableTest")

-- component tests
TestComponentTestAddon = require("Component\\All")
TestComponentTestApi = require("Component\\Api")
TestComponentTestMacro = require("Component\\Macro")
TestComponentTestHidePlayer = require("Component\\HidePlayer")
TestComponentTestTargeting = require("Component\\Targeting")
TestComponentTestSorting = require("Component\\Sorting")
TestComponentTestSpacing = require("Component\\Spacing")

os.exit(luaunit:run())
