local luaunit = require("luaunit")

-- unit tests
Test3Members = require("Unit\\Compare3Test")
Test5Members = require("Unit\\Compare5Test")
Test8Members = require("Unit\\Compare8Test")
TestGetUnits = require("Unit\\GetUnitsTest")
TestMacro = require("Unit\\MacroTest")
TestOptionsUpgrader = require("Unit\\UpgradeOptionsTest")
TestEnumerable = require("Unit\\EnumerableTest")

-- component tests
TestAddon = require("Component\\All")
TestMacro = require("Component\\Macro")
TestHidePlayer = require("Component\\HidePlayer")
TestTargeting = require("Component\\Target")

os.exit(luaunit:run())
