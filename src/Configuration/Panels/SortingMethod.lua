---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local M = {}
fsConfig.Panels.SortingMethod = M

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

    local secure = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    -- not sure why, but checkbox left seems to be off by about 4 units by default
    secure:SetPoint("TOPLEFT", panel, verticalSpacing - 4, -verticalSpacing + 4)
    secure.Text:SetText("Secure")
    secure.Text:SetFontObject("GameFontNormalLarge")
    secure:SetChecked(addon.DB.Options.SortingMethod == M.Secure)

    local secureLines = {
        "Adjusts the position of each individual frame and doesn't bug/lock/taint the UI.",
    }

    local anchor = secure
    for i, line in ipairs(secureLines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", i == 1 and 4 or 0, -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    anchor = BuildDottedList(panel, anchor, "Pros: ", {
        "Can sort frames from other addons.",
        "Can apply frame spacing.",
        "No taint (technical term for addons interfering with Blizzard's UI code).",
        "Works with 10.1.7.",
    })

    anchor = BuildDottedList(panel, anchor, "Cons: ", {
        "House of cards situation to workaround Blizzard spaghetti.",
        "Ironically is not secure in the foundational sense (name is referring to 'secure' code).",
        "May break with WoW patches.",
        "If it breaks in 10.2 the developer may go insane.",
    })

    local traditional = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    traditional:SetPoint("TOPLEFT", anchor, -4, -verticalSpacing * 2)
    traditional.Text:SetText("Traditional")
    traditional.Text:SetFontObject("GameFontNormalLarge")
    traditional:SetChecked(addon.DB.Options.SortingMethod == M.Traditional)

    local traditionalLines = {
        "This is the standard sorting mode that addons and macros have used for 10+ years.",
        "It replaces the internal Blizzard sorting method with our own.",
        "This is the same as the \"SetFlowSortFunction\" script but with FrameSort configuration."
    }

    anchor = traditional
    for i, line in ipairs(traditionalLines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", i == 1 and 4 or 0, -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    anchor = BuildDottedList(panel, anchor, "Pros: ", {
        "More stable/reliable as it leverages Blizzard's internal sorting methods.",
    })

    anchor = BuildDottedList(panel, anchor, "Cons: ", {
        "Only sorts Blizzard party frames, nothing else.",
        "Will cause Lua errors which is normal and can be ignored.",
        "Cannot apply frame spacing.",
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

    local function setSortingMethod(method)
        if method == M.Secure then
            traditional:SetChecked(false)
        elseif method == M.Traditional then
            secure:SetChecked(false)
        end

        ---@diagnostic disable-next-line: inject-field
        addon.DB.Options.SortingMethod = method
        reloadButton:SetShown(true)
    end

    secure:HookScript("OnClick", function()
        if not secure:GetChecked() then
            secure:SetChecked(true)
            return
        end

        setSortingMethod(M.Secure)
    end)

    traditional:HookScript("OnClick", function()
        if not traditional:GetChecked() then
            traditional:SetChecked(true)
            return
        end

        setSortingMethod(M.Traditional)
    end)

    return panel
end
