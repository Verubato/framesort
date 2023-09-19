---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration

local M = {
    Traditional = "Traditional",
    Secure = "Secure",
}
fsConfig.SortingMethod = M
