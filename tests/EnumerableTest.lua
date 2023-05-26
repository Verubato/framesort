local deps = {
    "Util\\Enumerable.lua",
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local enumerable = addon.Enumerable

local M = {}

function M:test_empty()
    local one = enumerable:Empty()
    local two = enumerable:Empty()

    -- should be the same instance
    assertEquals(one, two)
    assert(one:ToTable() == two:ToTable())
end

function M:test_totable()
    local array = enumerable:From({ "a", "b", "c" })
    local test = array:ToTable()

    assertEquals(test, { "a", "b", "c" })
end

function M:test_map()
    local array = enumerable:From({ "a", "b", "c" })
    local mapped = array
        :Map(function(x) return x .. x end)
        :ToTable()

    assertEquals(mapped, { "aa", "bb", "cc" })
end

function M:test_where()
    local array = enumerable:From({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
    local even = array
        :Where(function(x) return x % 2 == 0 end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
end

function M:test_where_multiple()
    local array = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    local even = enumerable:From(array)
        :Where(function(x) return x % 2 == 0 end)
        :ToTable()
    local odd = enumerable:From(array)
        :Where(function(x) return x % 2 == 1 end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
    assertEquals(odd, { 1, 3, 5, 7, 9 })
end

function M:test_orderby()
    local array = enumerable:From({ "z", "x", "a", "d" })
    local sorted = array
        :OrderBy(function(x, y) return x < y end)
        :ToTable()

    assertEquals(sorted, { "a", "d", "x", "z" })
end

function M:test_first()
    local array = enumerable:From({ 1, 3, 5, 6, 8, 9 })
    local first = array
        :First(function(x) return x % 2 == 0 end)

    assertEquals(first, 6)
end

function M:test_tolookup()
    local array = enumerable:From({
        { letter = "a", word = "apple" },
        { letter = "b", word = "banana" },
        { letter = "c", word = "carrot" }
    })

    local dict = array
        :ToLookup(function(x) return x.letter end, function(x) return x.word end)

    assertEquals(dict, {
        ["a"] = "apple",
        ["b"] = "banana",
        ["c"] = "carrot"
    })
end

function M:test_reverse()
    assertEquals(
        enumerable
        :From({ 1, 2, 3 })
        :Reverse()
        :ToTable(),
        -- expected
        { 3, 2, 1 })

    assertEquals(
        enumerable
        :From({ 1, 2, 3, 4 })
        :Reverse()
        :ToTable(),
        -- expected
        { 4, 3, 2, 1 })

    assertEquals(
        enumerable
        :From({ 1 })
        :Reverse()
        :ToTable(),
        -- expected
        { 1 })

    assertEquals(
        enumerable
        :From({ "a", "b", "c", "d", "e" })
        :Reverse()
        :ToTable(),
        -- expected
        { "e", "d", "c", "b", "a" })
end

function M:test_min()
    assertEquals(enumerable:From({ 7, 5, 2 }):Min(), 2)

    assertEquals(enumerable:From({
            { name = "a", value = 5 },
            { name = "b", value = 3 },
            { name = "c", value = 8 }
        })
        :Min(function(x) return x.value end),
        { name = "b", value = 3 })
end

function M:test_max()
    assertEquals(enumerable:From({ 7, 5, 2 }):Max(), 7)

    assertEquals(enumerable:From({
            { name = "a", value = 5 },
            { name = "b", value = 3 },
            { name = "c", value = 8 }
        })
        :Max(function(x) return x.value end),
        { name = "c", value = 8 })
end

return M
