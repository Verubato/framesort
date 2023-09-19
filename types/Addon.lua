---@meta
---@class Addon
---@field Api Api
---@field Configuration Configuration
---@field Collections Collections
---@field DB DB
---@field Health Health
---@field Logging Logging
---@field Modules Modules
---@field Numerics Numerics
---@field Providers Providers
---@field Scheduling Scheduling
---@field WoW WoW
---@field Loaded boolean
---@field Init fun(self: table)
---@field InitDB fun(self: table)

---@meta
---@class Api: Initialise
---@field v1 ApiV1

---@class Collections
---@field Enumerable Enumerable
---@field Comparer Comparer

---@meta
---@class DB
---@field Options Options

---@class Logging
---@field Log Log

---@class Health
---@field HealthCheck HealthChecker

---@class Numerics
---@field Math Math

---@meta
---@class Modules
---@field Sorting SortingModules
---@field Spacing SpacingModule
---@field HidePlayer HidePlayerModule
---@field Targeting TargetingModule
---@field Macro Initialise

---@class Scheduling
---@field Scheduler Scheduler

---@class WoW
---@field Api WowApi
---@field Frame FrameUtil
---@field Macro MacroUtil
---@field Unit UnitUtil

---@class SortingModules : Initialise
---@field Core CoreSortingModule
---@field Traditional TraditionalSortingModule
---@field Taintless SortingModule
---@field Secure SortingModule
---@field TrySort fun(self: table, provider: FrameProvider?):  boolean
---@field RegisterPostSortCallback fun(self: table, callback: function)

---@class TraditionalSortingModule : Initialise
---@field TrySort fun(self: table): boolean

---@class SortingModule : Initialise
---@field TrySort fun(self: table, provider: FrameProvider): boolean

---@class CoreSortingModule
---@field TrySort fun(self: table, provider: FrameProvider): boolean
