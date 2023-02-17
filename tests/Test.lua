local luaunit = require('luaunit')

Test3Members = require('Compare3Test')
Test5Members = require('Compare5Test')
Test8Members = require('Compare8Test')
TestGetUnits = require('GetUnitsTest')

os.exit(luaunit:run())
