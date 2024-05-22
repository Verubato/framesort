---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local M = {}
fsConfig.Panels.RoleOrdering = M

function M:Build(parent)
    local verticalSpacing = fsConfig.VerticalSpacing
    local panel = wow.CreateFrame("Frame", nil, parent)
    panel.name = "Role Ordering"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Role Ordering")

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    description:SetText("Specify the ordering you wish to use when sorting by role.")

    local tankHealerDps = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    tankHealerDps:SetPoint("TOPLEFT", description, "BOTTOMLEFT", -4, -verticalSpacing)
    tankHealerDps.Text:SetText("Tank > Healer > DPS")
    tankHealerDps.Text:SetFontObject("GameFontNormalLarge")
    tankHealerDps.RoleOrdering = fsConfig.RoleOrdering.TankHealerDps
    tankHealerDps:SetChecked(addon.DB.Options.Sorting.RoleOrdering == tankHealerDps.RoleOrdering)

    local healerTankDps = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    healerTankDps:SetPoint("TOPLEFT", tankHealerDps, "BOTTOMLEFT", 0, -verticalSpacing)
    healerTankDps.Text:SetText("Healer > Tank > DPS")
    healerTankDps.Text:SetFontObject("GameFontNormalLarge")
    healerTankDps.RoleOrdering = fsConfig.RoleOrdering.HealerTankDps
    healerTankDps:SetChecked(addon.DB.Options.Sorting.RoleOrdering == healerTankDps.RoleOrdering)

    local healerDpsTank = wow.CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    healerDpsTank:SetPoint("TOPLEFT", healerTankDps, "BOTTOMLEFT", 0, -verticalSpacing)
    healerDpsTank.Text:SetText("Healer > DPS > Tank")
    healerDpsTank.Text:SetFontObject("GameFontNormalLarge")
    healerDpsTank.RoleOrdering = fsConfig.RoleOrdering.HealerDpsTank
    healerDpsTank:SetChecked(addon.DB.Options.Sorting.RoleOrdering == healerDpsTank.RoleOrdering)

    local all = {
        tankHealerDps,
        healerTankDps,
        healerDpsTank,
    }

    local function OnClick(box)
        if not box:GetChecked() then
            box:SetChecked(true)
        end

        for _, other in ipairs(all) do
            if other ~= box then
                other:SetChecked(false)
            end
        end

        addon.DB.Options.Sorting.RoleOrdering = box.RoleOrdering

        -- run modules to re-sort and update macros
        addon.Modules:Run()
    end

    for _, box in ipairs(all) do
        box:HookScript("OnClick", OnClick)
    end

    return panel
end
