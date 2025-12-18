local function chainToNames(root)
    local out = {}
    local cur = root
    while cur do
        out[#out + 1] = cur.Value:GetName()
        cur = cur.Next
    end
    return out
end

local frameMock
---@type Addon
local addon
---@type FrameUtil
local fsFrame

M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local providerFactory = require("TestHarness\\ProviderFactory")
    frameMock = require("TestHarness\\Frame")

    addon = addonFactory:Create()
    fsFrame = addon.WoW.Frame
end

function M:test_valid_chain()
    local a = frameMock:New("Frame", "A")
    local b = frameMock:New("Frame", "B")
    local c = frameMock:New("Frame", "C")

    a:SetPoint("TOPLEFT", nil, nil, 0, 0)
    b:SetPoint("TOPLEFT", a, "TOPLEFT", 0, 0)
    c:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    -- Pass in any order
    local root = fsFrame:ToFrameChain({ c, a, b })

    assertEquals(root.Valid, true)
    assertEquals(chainToNames(root), { "A", "B", "C" })
    assertEquals(root.Previous, nil)
    assertEquals(root.Next.Value:GetName(), "B")
end

function M:test_external_root_allowed()
    local external = frameMock:New("Frame", "ExternalParent")
    local a = frameMock:New("Frame", "A")
    local b = frameMock:New("Frame", "B")

    -- A anchored to external frame (not in set)
    a:SetPoint("TOPLEFT", external, "TOPLEFT", 0, 0)
    b:SetPoint("TOPLEFT", a, "TOPLEFT", 0, 0)

    local root = fsFrame:ToFrameChain({ b, a })

    assertEquals(root.Valid, true)
    assertEquals(chainToNames(root), { "A", "B" })
end

function M:test_invalid_two_roots()
    local a = frameMock:New("Frame", "A")
    local b = frameMock:New("Frame", "B")

    a:SetPoint("TOPLEFT", nil, nil, 0, 0)
    b:SetPoint("TOPLEFT", nil, nil, 0, 0)

    local root = fsFrame:ToFrameChain({ a, b })
    assertEquals(root.Valid, false)
end

function M:test_invalid_branching()
    local a = frameMock:New("Frame", "A")
    local b = frameMock:New("Frame", "B")
    local c = frameMock:New("Frame", "C")

    a:SetPoint("TOPLEFT", nil, nil, 0, 0)
    b:SetPoint("TOPLEFT", a, "TOPLEFT", 0, 0)
    c:SetPoint("TOPLEFT", a, "TOPLEFT", 0, 0) -- branching

    local root = fsFrame:ToFrameChain({ a, b, c })
    assertEquals(root.Valid, false)
end

function M:test_invalid_cycle()
    local a = frameMock:New("Frame", "A")
    local b = frameMock:New("Frame", "B")
    local c = frameMock:New("Frame", "C")

    -- Cycle: A -> B -> C -> A (via relativeTo)
    a:SetPoint("TOPLEFT", c, "TOPLEFT", 0, 0)
    b:SetPoint("TOPLEFT", a, "TOPLEFT", 0, 0)
    c:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    local root = fsFrame:ToFrameChain({ a, b, c })
    assertEquals(root.Valid, false)
end

function M:test_invalid_disconnected()
    local a = frameMock:New("Frame", "A")
    local b = frameMock:New("Frame", "B")
    local c = frameMock:New("Frame", "C")

    a:SetPoint("TOPLEFT", nil, nil, 0, 0)
    b:SetPoint("TOPLEFT", a, "TOPLEFT", 0, 0)

    -- C is disconnected but included
    c:SetPoint("TOPLEFT", nil, nil, 0, 0)

    local root = fsFrame:ToFrameChain({ a, b, c })
    assertEquals(root.Valid, false)
end

return M
