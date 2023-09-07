---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local M = {}
fsConfig.SortingMethod = M

---Adds a dot point list for each string item in lines
---@param panel table the parent panel
---@param anchor table anchor point.
---@param titleText string the dotpoint list title.
---@param lines table
---@return table returns the anchor of the bottom item.
local function BuildDottedList(panel, anchor, titleText, lines)
    local verticalSpacing = fsConfig.VerticalSpacing
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
    title:SetText(titleText)

    anchor = title
    for _, line in ipairs(lines) do
        local lineItem = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        lineItem:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing / 2)
        lineItem:SetText(" - " .. line)
        anchor = lineItem
    end

    return anchor
end

function M:Build(parent)
    local verticalSpacing = fsConfig.VerticalSpacing
    local panel = wow.CreateFrame("Frame", "FrameSortSortingMethod", parent)
    panel.name = "Sorting Method"
    panel.parent = parent.name

    local taintless = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    -- not sure why, but checkbox left seems to be off by about 4 units by default
    taintless:SetPoint("TOPLEFT", panel, verticalSpacing - 4, -verticalSpacing + 4)
    taintless.Text:SetText("Taintless")
    taintless.Text:SetFontObject("GameFontNormalLarge")
    taintless:SetChecked(addon.DB.Options.SortingMethod.TaintlessEnabled)

    local taintlessLines = {
        "A brand new sorting mode that shouldn't bug/lock/taint the UI.",
    }

    local anchor = taintless
    for i, line in ipairs(taintlessLines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", i == 1 and 4 or 0, -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    anchor = BuildDottedList(panel, anchor, "Pros: ", {
        "No taint (technical term for addons interfering with Blizzard's UI code).",
        "No Lua errors.",
        "No UI lockups.",
        "Can sort grouped raid frames.",
        "Can sort pet frames.",
        "Can sort frames from other addons.",
    })

    anchor = BuildDottedList(panel, anchor, "Cons: ", {
        "May break with Blizzard patches.",
        "May not work well with other addons and WeakAuras that expect the traditional method.",
    })

    local traditional = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    traditional:SetPoint("TOPLEFT", anchor, 0, -verticalSpacing * 2)
    traditional.Text:SetText("Traditional")
    traditional.Text:SetFontObject("GameFontNormalLarge")
    traditional:SetChecked(addon.DB.Options.SortingMethod.TraditionalEnabled)

    local traditionalLines = {
        "This is the standard sorting mode that addons and macros have used for 10+ years.",
        "However it seems since DragonFlight the Blizzard UI has become quite fragile.",
    }

    anchor = traditional
    for i, line in ipairs(traditionalLines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", i == 1 and 4 or 0, -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    anchor = BuildDottedList(panel, anchor, "Pros: ", {
        "Probably more stable/reliable as it leverages Blizzard's internal sorting methods.",
    })

    anchor = BuildDottedList(panel, anchor, "Cons: ", {
        "Will cause Lua errors, this is normal and can be ignored in most cases.",
        "BugSack will report the occasional ADDON_ACTION_BLOCKED error from FrameSort.",
        "May sporadically lockup certain parts of the UI.",
        "Can't sort grouped raid frames.",
        "Can't sort pet frames.",
        "Can't sort frames from other addons.",
    })

    local reloadReminder = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
    reloadReminder:SetPoint("TOPLEFT", anchor, 0, -verticalSpacing * 2)
    reloadReminder:SetText("Please reload after changing these settings.")

    local reloadButton = wow.CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reloadButton:SetPoint("TOPLEFT", reloadReminder, 0, -verticalSpacing * 1.5)
    reloadButton:SetWidth(100)
    reloadButton:SetText("Reload")
    reloadButton:HookScript("OnClick", function()
        wow.ReloadUI()
    end)
    reloadButton:SetShown(false)

    taintless:HookScript("OnClick", function()
        addon.DB.Options.SortingMethod.TaintlessEnabled = taintless:GetChecked()
        addon.DB.Options.SortingMethod.TraditionalEnabled = not taintless:GetChecked()
        traditional:SetChecked(not taintless:GetChecked())
        reloadButton:SetShown(true)
    end)

    traditional:HookScript("OnClick", function()
        addon.DB.Options.SortingMethod.TraditionalEnabled = traditional:GetChecked()
        addon.DB.Options.SortingMethod.TaintlessEnabled = not traditional:GetChecked()
        taintless:SetChecked(not traditional:GetChecked())
        reloadButton:SetShown(true)
    end)

    return panel
end
