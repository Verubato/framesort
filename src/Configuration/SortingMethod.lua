---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration

local M = {
    Secure = 1,
    Taintless = 2,
    Traditional = 3
}
fsConfig.SortingMethod = M
