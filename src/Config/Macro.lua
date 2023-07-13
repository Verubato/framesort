local _, addon = ...
local fsBuilder = addon.OptionsBuilder
local fsMacro = addon.Macro
local maxMacros = 138
local verticalSpacing = fsBuilder.VerticalSpacing

local function CountMacros()
    local count = 0

    for i = 1, maxMacros do
        local _, _, body = GetMacroInfo(i)

        if body and fsMacro:IsFrameSortMacro(body) then
            count = count + 1
        end
    end

    return count
end

---Adds the macro options panel.
---@param parent table the parent UI panel.
function fsBuilder:BuildMacroOptions(parent)
    local panel = CreateFrame("Frame", "FrameSortMacros", parent)
    panel.name = "Macros"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Macros")

    local countLine = panel:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    countLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    countLine:SetText("FrameSort has found 0 macros to manage.")

    panel:HookScript("OnShow", function()
        local count = CountMacros()
        countLine:SetText("FrameSort has found " .. count .. " |4macro:macros; to manage.")
    end)

    local intro = {
        'FrameSort will dynamically update macros with the "#FrameSort" header.',
        "Below are some examples on how to use this.",
    }

    local anchor = countLine
    for i, line in ipairs(intro) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    local examples = {
        [[#showtooltip
#FrameSort Frame1
/cast [@none] Spell;]],
        [[#framesort frame2
/cast [@placeholder,help] Dispel; [@placeholder,harm] Purge;]],
        [[#FrameSort: frame1 frame2
/cast [mod:shift,@a] Spell; [@b] Spell;]],
        [[#framesort: frame3, frame2, frame1
/cast [mod:shift,@a] Spell; [mod:ctrl,@b] Spell; [@c] Spell;]],
    }

    local padding = 10
    for i, example in ipairs(examples) do
        local header = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        header:SetText(string.format("Example %d", i))

        local box = CreateFrame("EditBox", nil, panel)
        box:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -verticalSpacing)
        box:SetSize(400, 1)
        box:SetFontObject("GameFontWhite")
        box:SetAutoFocus(false)
        box:SetMultiLine(true)
        box:SetText(example)
        box:SetCursorPosition(0)

        -- undo any user changes
        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            box:SetText(example)
        end)

        box:SetScript("OnEscapePressed", function()
            box:ClearFocus()
        end)
        box:SetTextInsets(padding, padding, padding, padding)

        local bg = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        bg:SetBackdrop({
            edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
            edgeSize = 16,
        })
        bg:SetAllPoints(box)

        anchor = box
    end

    local notes = {
        "Notes:",
        ' - The "@" placeholder values can be anything, e.g. @none, or @placeholder, or @a.',
        " - Order matters, e.g. \"#framesort frame2, frame1\" would replace the first '@' with frame2.",
    }

    for i, line in ipairs(notes) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    InterfaceOptions_AddCategory(panel)
end
