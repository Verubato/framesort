---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration

---@class RoleOrderingEnum
local M = {
    TankHealerDps = 1,
    HealerTankDps = 2,
    HealerDpsTank = 3,
}

fsConfig.RoleOrdering = M
