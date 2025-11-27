---@meta
---@class Addon
---@field Api Api
---@field Configuration Configuration
---@field Language Language
---@field Collections Collections
---@field DB DB
---@field Health Health
---@field Locale table<string, string>
---@field Logging Logging
---@field Modules Modules
---@field Numerics Numerics
---@field Providers Providers
---@field Scheduling Scheduling
---@field WoW WoW
---@field Loaded boolean
---@field Init fun(self: table)
---@field InitDB fun(self: table)

---@class Api: IInitialise
---@field v1 ApiV1
---@field v2 ApiV2
---@field v3 ApiV3

---@class Collections
---@field Enumerable Enumerable

---@class Language
---@field LuaEx LuaEx

---@class DB
---@field Options Options
---@field SpecCache any

---@class Logging
---@field Log Log

---@class Health
---@field HealthCheck HealthChecker

---@class Numerics
---@field Math Math

---@class Modules : IInitialise, IRun
---@field Sorting SortingModule
---@field HidePlayer HidePlayerModule
---@field Targeting TargetingModule
---@field Macro MacroModule
---@field AutoLeader AutoLeaderModule
---@field Inspector InspectorModule
---@field UnitTracker UnitTrackerModule

---@class Scheduling
---@field Scheduler Scheduler

---@class WoW
---@field Api WowApi
---@field Frame FrameUtil
---@field Unit UnitUtil

---@class MacroModule : IRun, IInitialise
---@field Parser MacroParser

---@class SortingModule : IRun, IInitialise
---@field Comparer Comparer
---@field Traditional TraditionalSortingModule
---@field Secure SecureSortingModule
---@field RegisterPostSortCallback fun(self: table, callback: function)
---@field NotifySorted fun(self: table)

---@class TraditionalSortingModule : ISort

---@class SecureSortingModule : ISort, IInitialise
---@field InCombat InCombatSecureSorter
---@field NoCombat NoCombatSecureSorter

---@class NoCombatSecureSorter : ISort, IInitialise
---@class InCombatSecureSorter : IInitialise

---@class MacroModule : IRun, IInitialise

---@class ISort
---@field TrySort fun(self: table, provider: FrameProvider?): boolean

---@class IRun
---@field Run fun(self: table, provider: FrameProvider?)

---@class IInitialise
---@field Init fun(self: table)
