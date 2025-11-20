---@meta
---@class Addon
---@field Api Api
---@field Configuration Configuration
---@field Collections Collections
---@field DB DB
---@field Health Health
---@field Locale table<string, string>
---@field Languages table
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
---@class Api: IInitialise
---@field v1 ApiV1
---@field v2 ApiV2

---@class Collections
---@field Enumerable Enumerable
---@field LuaEx LuaEx

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
---@class Modules : IInitialise, IRun
---@field Sorting SortingModule
---@field HidePlayer HidePlayerModule
---@field Targeting TargetingModule
---@field Macro MacroModule
---@field AutoLeader AutoLeaderModule
---@field Inspector InspectorModule

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
