local frameMock = require("Mock\\Frame")

---@type FrameProvider
return {
    State = {
        PartyFrames = {},
        RaidFrames = {},
        EnemyArenaFrames = {},
        Callbacks = {},
    },
    Reset = function(self)
        self.State.Callbacks = {}
        self.State.PartyFrames = {}
        self.State.RaidFrames = {}
        self.State.EnemyArenaFrames = {}
    end,
    Name = function()
        return "Test"
    end,
    Init = function() end,
    Enabled = function()
        return true
    end,
    GetUnit = function(_, frame)
        return frame.unit
    end,
    PartyContainer = function(_)
        return frameMock:New("Frame", "PartyContainer")
    end,
    RaidContainer = function(_)
        return frameMock:New("Frame", "RaidContainer")
    end,
    EnemyArenaContainer = function(_)
        return frameMock:New("Frame", "EnemyArenaContainer")
    end,
    RaidFrames = function(self)
        return self.State.RaidFrames
    end,
    RaidGroups = function()
        return {}
    end,
    PartyFrames = function(self)
        return self.State.PartyFrames
    end,
    IsRaidGrouped = function()
        return false
    end,
    IsPartyHorizontalLayout = function()
        return false
    end,
    IsRaidHorizontalLayout = function()
        return false
    end,
    IsEnemyArenaHorizontalLayout = function()
        return false
    end,
    EnemyArenaFrames = function(self)
        return self.State.EnemyArenaFrames
    end,
    PlayerRaidFrames = function(self)
        local frames = {}

        for _, frame in ipairs(self.State.PartyFrames) do
            if frame.unit == "player" then
                frames[#frames + 1] = frame
            end
        end

        for _, frame in ipairs(self.State.RaidFrames) do
            if frame.unit == "player" then
                frames[#frames + 1] = frame
            end
        end

        return frames
    end,
    IsUsingRaidStyleFrames = function() return true end,
    RaidGroupMembers = function()
        return {}
    end,
    RegisterCallback = function(self, callback)
        self.State.Callbacks[#self.State.Callbacks + 1] = callback
    end,
    FireCallbacks = function(self)
        for _, callback in ipairs(self.State.Callbacks) do
            callback(self)
        end
    end,
}
