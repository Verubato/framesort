local frameMock
---@type Addon
local addon
---@type FrameUtil
local fsFrame

local M = {}

local function chainToNames(root)
    local out = {}
    local cur = root
    while cur do
        out[#out + 1] = cur.Value:GetName()
        cur = cur.Next
    end
    return out
end

function M:setup()
    local addonFactory = require("TestHarness.AddonFactory")
    frameMock = require("TestHarness.FrameMock")

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

function M:test_frame_unit_cached_for_a_pass()
    local frame = frameMock:New("Frame", "A")
    frame.unit = "raid1"

    fsFrame:BeginPass()

    assertEquals(fsFrame:GetFrameUnit(frame), "raid1")

    -- the sort, targeting and macro steps all ask the same frame within one pass
    frame.unit = "raid2"

    assertEquals(fsFrame:GetFrameUnit(frame), "raid1")

    fsFrame:EndPass()

    assertEquals(fsFrame:GetFrameUnit(frame), "raid2")
end

function M:test_frame_unit_not_cached_outside_a_pass()
    local frame = frameMock:New("Frame", "A")
    frame.unit = "raid1"

    -- combat defers a run, so anything asking mid fight must reach the client
    assertEquals(fsFrame:GetFrameUnit(frame), "raid1")

    frame.unit = "raid2"

    assertEquals(fsFrame:GetFrameUnit(frame), "raid2")
end

return M
