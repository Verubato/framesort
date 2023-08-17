---@type string, Addon
local _, addon = ...

---@diagnostic disable-next-line: missing-fields
addon.Api = {}

function addon:InitApi()
    FrameSortApi = addon.Api
end
