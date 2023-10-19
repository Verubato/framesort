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
---@class Api: IInitialise
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
---@field HidePlayer HidePlayerModule
---@field Targeting TargetingModule
---@field Macro IInitialise

---@class Scheduling
---@field Scheduler Scheduler

---@class WoW
---@field Api WowApi
---@field Frame FrameUtil
---@field Macro MacroUtil
---@field Unit UnitUtil

---@class SortingModules : ISort, IInitialise
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

---@class ISort
---@field TrySort fun(self: table, provider: FrameProvider?): boolean
