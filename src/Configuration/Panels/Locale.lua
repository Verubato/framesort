---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local fsEnumerable = addon.Collections.Enumerable
local L = addon.Locale.Current
-- An empty locale means "follow the client", which is what Locales/Locale.lua already falls back
-- to and what Defaults.lua ships. Auto carries no Name: this table is built when the file loads,
-- before addon.Locale:Init() installs the lookup metatable, so an L[] read here would come back
-- nil. It is resolved when the dropdown draws instead. Every other entry names its language in
-- that language, so none of those need translating.
local items = {
    { Locale = "" },
    { Locale = "enUS", Name = "English" },
    { Locale = "deDE", Name = "Deutsch" },
    { Locale = "esES", Name = "Español" },
    { Locale = "esMX", Name = "Español (México)" },
    { Locale = "frFR", Name = "Français" },
    { Locale = "itIT", Name = "Italiano" },
    { Locale = "koKR", Name = "한국어" },
    { Locale = "ptBR", Name = "Português (Brasil)" },
    { Locale = "ruRU", Name = "Русский" },
    { Locale = "zhCN", Name = "简体中文" },
    { Locale = "zhTW", Name = "繁體中文" },
}
local M = {}
fsConfig.Panels.Locale = M

function M:Build(parent)
    local verticalSpacing = fsConfig.VerticalSpacing

    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = L["Language"]
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText(L["Language"])

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    description:SetText(L["Specify the language we use."])

    local dd = fsConfig:Dropdown(panel, items, function()
        return fsEnumerable:From(items):First(function(item)
            return item.Locale == (addon.DB.Options.Locale or "")
        end)
    end, function(item)
        addon.DB.Options.Locale = item.Locale
    end, function(item)
        return item.Name or L["Auto"]
    end)

    dd:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -verticalSpacing)
    dd:SetWidth(200)

    local reloadButton = wow.CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reloadButton:SetPoint("TOPLEFT", dd, "BOTTOMLEFT", 0, -verticalSpacing)
    reloadButton:SetWidth(100)
    reloadButton:SetText(L["Reload"])
    reloadButton:SetScript("OnClick", function()
        wow.ReloadUI()
    end)

    return panel
end
