---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local fsLuaEx = addon.Language.LuaEx
local fsLog = addon.Logging.Log
local M = {}

fsProviders.Grid2 = M
table.insert(fsProviders.All, M)

function M:Name()
    return "Grid2"
end

function M:Enabled()
    return wow.GetAddOnEnableState(nil, "Grid2") ~= 0
end

function M:Init() end
function M:RegisterRequestSortCallback() end
function M:RegisterContainersChangedCallback() end

function M:Containers()
    local containers = {}

    if not M:Enabled() then
        return containers
    end

    if Grid2LayoutHeader1 then
        ---@type FrameContainer
        local party = {
            Frame = Grid2LayoutHeader1,
            Type = fsFrame.ContainerType.Party,
            LayoutType = fsFrame.LayoutType.NameList,
            ShowUnit = function(_, unitId)
                if not wow.IsInInstance() then
                    return true
                end

                local selectedLayout = fsLuaEx:SafeGet(Grid2, { "db", "profile", "raidSizeType" })
                local onlyShowUnitsInRaid = 3

                if selectedLayout ~= onlyShowUnitsInRaid then
                    return true
                end

                if not wow.C_Map or not wow.C_Map.GetBestMapForUnit then
                    return true
                end

                local instanceId = wow.C_Map.GetBestMapForUnit("player")
                local unitInstanceId = wow.C_Map.GetBestMapForUnit(unitId)

                return instanceId == unitInstanceId
            end,
        }

        containers[#containers + 1] = party
    end

    return containers
end
