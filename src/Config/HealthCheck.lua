local _, addon = ...
local fsBuilder = addon.OptionsBuilder
local verticalSpacing = fsBuilder.VerticalSpacing
local fsHealth = addon.Health
local lines = {}

---Adds the health check options panel.
---@param parent table the parent UI panel.
function fsBuilder:BuildHealthCheck(parent)
    local panel = CreateFrame("Frame", "FrameSortHealthCheck", parent)
    panel.name = "Health Check"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Health Check")

    local healthDescription = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    healthDescription:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    healthDescription:SetText("Any known issues with configuration or conflicting addons will be shown below.")

    local remediationTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    remediationTitle:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    remediationTitle:SetText("Remediation Steps")

    panel:HookScript("OnShow", function()
        local healthy, results = fsHealth:IsHealthy()

        while #lines < #results do
            local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
            local result = panel:CreateFontString(nil, "ARTWORK", "GameFontRed")
            local remediation = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")

            result:SetPoint("TOPLEFT", description, "TOPRIGHT", 4, 0)

            lines[#lines + 1] = {
                Description = description,
                Result = result,
                Remediation = remediation
            }
        end

        local anchor = healthDescription
        for i, result in ipairs(results) do
            local line = lines[i]

            line.Description:SetText(result.Description)
            line.Description:SetPoint("TOPLEFT", anchor, 0, -verticalSpacing * 2)
            line.Result:SetText(result.Passed and "Passed!" or "Failed")
            line.Result:SetFontObject(result.Passed and "GameFontGreen" or "GameFontRed")

            anchor = line.Description
        end

        remediationTitle:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        remediationTitle:SetShown(not healthy)
        anchor = remediationTitle

        for i, result in ipairs(results) do
            local line = lines[i]
            line.Remediation:SetText(result.Remediation and (" - " .. result.Remediation) or "")
            line.Remediation:SetShown(not result.Passed)

            if not result.Passed then
                line.Remediation:SetPoint("TOPLEFT", anchor, 0, -verticalSpacing * 2)
                anchor = line.Remediation
            end
        end
    end)

    InterfaceOptions_AddCategory(panel)

    return panel
end
