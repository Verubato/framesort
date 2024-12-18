---@type Addon
local addon
local fsLuaEx
local M = {}

function M:setup()
    local addonFactory = require("Mock\\AddonFactory")
    addon = addonFactory:Create()
    fsLuaEx = addon.Collections.LuaEx

    addon.WoW.Api.IsInGroup = function()
        return true
    end
    addon.WoW.Api.UnitIsUnit = function(x, y)
        return x == y
    end
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

    local value = fsLuaEx:SafeGet(root, {
        "first",
        "second",
        "third",
    })

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

    local value = fsLuaEx:SafeGet(root, {
        "first",
        "second",
        "third",
        "fourth",
        "fifth"
    })

    assert(value == nil)
end

return M
