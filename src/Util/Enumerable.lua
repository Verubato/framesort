local _, addon = ...
local empty = nil

---@class Enumerable
---@field Next function
---@field State table
local M = {}
local metatable = {
    __index = M,
}

addon.Enumerable = M

---Returns an empty singleton instance.
function M:Empty()
    if not empty then
        empty = M:New()
    end

    return empty
end

---Returns an Enumerable instance from the specified items.
---@generic T: table, V
---@param auto T|function
---@return Enumerable
function M:From(auto)
    local t = type(auto)
    local enumerable = {}

    if t == "table" then
        local iterator, elements, index = ipairs(auto)
        enumerable.State = {
            Iterator = iterator,
            Elements = elements,
            Index = index
        }
        enumerable.Next = function()
            local nextIndex, next = iterator(enumerable.State.Elements, enumerable.State.Index)
            enumerable.State.Index = nextIndex
            return next
        end
    elseif t == "function" then
        enumerable.Next = auto
    else
        error(string.format("Invalid type %s", t))
    end

    return setmetatable(enumerable, metatable)
end

---Returns a new Enumerable instance.
---@return Enumerable
function M:New()
    return M:From({})
end

---Maps a sequence from one type into another.
---@param apply fun(item: any)
---@return Enumerable
function M:Map(apply)
    local iterator = function()
        local next = self.Next()
        if not next then return nil end

        return apply(next)
    end

    return M:From(iterator)
end

---Filters a sequence.
---@param predicate fun(item: any): boolean
---@return Enumerable
function M:Where(predicate)
    local iterator = function()
        local next = self.Next()
        while next and not predicate(next) do
            next = self.Next()
        end

        return next
    end

    return M:From(iterator)
end

---Returns the first instance that matches the predicate.
---@param predicate fun(item: any): boolean
---@return any? item, number? index
function M:First(predicate)
    local next = self.Next()
    local index = 1
    while next and not predicate(next) do
        next = self.Next()
        index = index + 1
    end

    return next, next and index or nil
end

---Evaluates the iterator function to return the results as a table.
---@return table items
function M:ToTable()
    if self.State and self.State.Elements then
        return self.State.Elements
    end

    local items = {}
    local next = self.Next()

    while next do
        items[#items + 1] = next
        next = self.Next()
    end

    return items
end

---Evaluates the iterator function to return the results as a lookup table.
---@param valueSelector function(item: any, index: number): any
---@param keySelector function(item: any, index: number): any
---@return table items
function M:ToLookup(keySelector, valueSelector)
    local items = self:ToTable()
    local dict = {}

    for index, item in ipairs(items) do
        local key = keySelector(item, index)
        local value = valueSelector(item, index)

        dict[key] = value
    end

    return dict
end

---Orders the enumable using the specified comparison function.
---@generic T
---@param compare? fun(a: T, b: T):boolean
function M:OrderBy(compare)
    local items = self:ToTable()
    table.sort(items, compare)

    return M:From(items)
end

---Compares the two arrays and returns true if their items are equivalent, otherwise false.
---@param left table<any>
---@param right table<any>
---@return boolean
function M:ArrayEquals(left, right)
    if #left ~= #right then return false end

    for i = 0, #left do
        if left[i] ~= right[i] then return false end
    end

    return true
end
