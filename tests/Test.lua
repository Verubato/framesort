local luaunit = require("luaunit")

-- unit tests
TestUnit3Members = require("Unit\\Compare3Test")
TestUnit5Members = require("Unit\\Compare5Test")
TestUnit8Members = require("Unit\\Compare8Test")
TestUnitGetUnits = require("Unit\\GetUnitsTest")
TestUnitMacro = require("Unit\\MacroTest")
TestUnitOptionsUpgrader = require("Unit\\UpgradeOptionsTest")
TestUnitEnumerable = require("Unit\\EnumerableTest")

-- component tests
TestComponentTestAddon = require("Component\\All")
TestComponentTestMacro = require("Component\\Macro")
TestComponentTestHidePlayer = require("Component\\HidePlayer")
TestComponentTestTargeting = require("Component\\Target")

os.exit(luaunit:run())
