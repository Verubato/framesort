local _, addon = ...
local builder = addon.OptionsBuilder
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing
local maxMacros = 138
local macro = addon.Macro

local function CountMacros()
    local count = 0

    for i = 1, maxMacros do
        local _, _, body = GetMacroInfo(i)

        if body and macro:IsFrameSortMacro(body) then
            count = count + 1
        end
    end

    return count
end

---Adds the macro options panel.
---@param parent table the parent UI panel.
function builder:BuildMacroOptions(parent)
    local panel = CreateFrame("Frame", "FrameSortMacros", parent)
    panel.name = "Macros"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Macros")

    local countLine = panel:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    countLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    countLine:SetText("FrameSort has found 0 macros to manage.")

    local lines = {
        "FrameSort will dynamically update macros with the \"#FrameSort\" header.",
        "Below are some examples on how to use this.",
        "",
        "Example 1",
        "",
        "#showtooltip",
        "#FrameSort Frame1",
        "/cast [@placeholder] Spell;",
        "",
        "Example 2",
        "",
        "#framesort frame2",
        "/cast [@placeholder,help] Dispel; [@placeholder,harm] Purge;",
        "",
        "Example 3",
        "",
        "#FrameSort: frame1 frame2",
        "/cast [@a] Spell; [mod:shift, @b] Spell;",
        "",
        "Example 4",
        "",
        "#framesort: frame1, frame2, frame3",
        "/cast [@a] Spell; [mod:shift, @b] Spell; [mod:ctrl, @c] Spell;",
        "",
        "Notes:",
        " - The \"@\" placeholder values can be anything, e.g. @a, or @placeholder, or @frame1.",
        " - Order matters, e.g. \"#framesort frame2, frame1\" would replace the first '@' with frame2."
    }

    local anchor = countLine
    for i, line in ipairs(lines) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    panel:HookScript("OnShow", function()
        local count = CountMacros()
        countLine:SetText("FrameSort has found " .. count .. " |4macro:macros; to manage.")
    end)

    InterfaceOptions_AddCategory(panel)
end
