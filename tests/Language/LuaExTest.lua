---@type Addon
local addon
local fsLuaEx
local M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()
    fsLuaEx = addon.Language.LuaEx
end

function M:test_enumerate_non_null_chain()
    local root = {
        first = {
            second = {
                third = 3,
                fourth = {
                    fifth = 5,
                },
            },
        },
    }

    local value = fsLuaEx:SafeGet(root, { "first", "second", "third" })

    assert(value == 3)
end

function M:test_enumerate_null_chain()
    local root = {
        first = {
            second = {
                third = nil,
            },
        },
    }

    local value = fsLuaEx:SafeGet(root, { "first", "second", "third", "fourth", "fifth" })

    assert(value == nil)
end

return M
