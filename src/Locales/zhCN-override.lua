local _, addon = ...
local L = addon.Locale
local wow = addon.WoW.Api

if wow.GetLocale() ~= "zhCN" then
    return
end

L["Alpha"] = "字母顺序"
