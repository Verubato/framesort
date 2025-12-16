---@diagnostic disable: undefined-global
---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api

-- shims for older clients
local version = GetBuildInfo and GetBuildInfo()
local nextFrameId = 1
local isWotlkPrivate = version == "3.3.5"

local function FrameShims(frame)
    -- classic
    if not frame.Text and frame.text then
        frame.Text = frame.text
    end

    -- wotlk private
    if not frame.Text then
        frame.Text = {
            SetFontObject = function(_, fontName)
                local textFrame = _G[frame:GetName() .. "Text"]
                return textFrame:SetFontObject(fontName)
            end,
            SetText = function(_, text)
                local textFrame = _G[frame:GetName() .. "Text"]
                textFrame:SetText(text)
            end,
        }

        local originalCreateFontString = frame.CreateFontString
        frame.CreateFontString = function(...)
            local fontString = originalCreateFontString(...)
            FrameShims(fontString)
            return fontString
        end
    end

    -- wotlk private
    frame.SetShown = frame.SetShown or function(self, show)
        if show then
            self:Show()
        else
            self:Hide()
        end
    end

    -- wotlk private
    frame.SetAttributeNoHandler = frame.SetAttributeNoHandler or function(self, ...)
        self:SetAttribute(...)
    end

    -- wotlk private
    frame.SetObeyStepOnDrag = frame.SetObeyStepOnDrag or function() end
end

local createFrame = wow.CreateFrame

wow.CreateFrame = function(frameType, name, parent, template, id)
    if not name and isWotlkPrivate then
        -- wotlk private requires name to not be nil
        name = "FSDummyName" .. nextFrameId
        nextFrameId = nextFrameId + 1
    end

    -- wotlk private doesn't have this
    if template == "BackdropTemplate" and not BackdropTemplateMixin then
        template = nil
    end

    local frame = createFrame(frameType, name, parent, template, id)
    FrameShims(frame)
    return frame
end

wow.RegisterAttributeDriver = wow.RegisterAttributeDriver
    or function(frame, attribute, conditional)
        local attributeWithoutState = string.gsub(attribute, "state%-", "")
        wow.RegisterStateDriver(frame, attributeWithoutState, conditional)
    end

wow.UnregisterAttributeDriver = wow.UnregisterAttributeDriver
    or function(frame, attribute)
        local attributeWithoutState = string.gsub(attribute, "state%-", "")
        wow.UnregisterStateDriver(frame, attributeWithoutState)
    end

-- for unit tests
wow.CopyTable = wow.CopyTable
    or function(t)
        if type(t) ~= "table" then
            return t
        end

        local out = {}
        for k, v in pairs(t) do
            out[k] = wow.CopyTable(v)
        end

        return out
    end

wow.wipe = wow.wipe or function(t)
    for k in pairs(t) do
        t[k] = nil
    end
    return t
end
