---@type UnitUtil
local fsUnit
local addon
local M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()
    fsUnit = addon.WoW.Unit
end

function M:test_normalise()
    assertEquals(fsUnit:NormaliseUnit("player"), "player")
    assertEquals(fsUnit:NormaliseUnit("pet"), "pet")
    assertEquals(fsUnit:NormaliseUnit("target"), "target")
    assertEquals(fsUnit:NormaliseUnit("party1pet"), "partypet1")
    assertEquals(fsUnit:NormaliseUnit("raid29pet"), "raidpet29")
    assertEquals(fsUnit:NormaliseUnit("arena3pet"), "arenapet3")
end

return M
