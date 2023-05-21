local deps = {
    "Util\\Enumerable.lua",
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local M = {}

function M:test_empty()
    local one = addon.Enumerable:Empty()
    local two = addon.Enumerable:Empty()

    -- should be the same instance
    assertEquals(one, two)
    assert(one:ToTable() == two:ToTable())
end

function M:test_totable()
    local array = addon.Enumerable:From({ "a", "b", "c" })
    local test = array:ToTable()

    assertEquals(test, { "a", "b", "c" })
end

function M:test_map()
    local array = addon.Enumerable:From({ "a", "b", "c" })
    local mapped = array
        :Map(function(x) return x .. x end)
        :ToTable()

    assertEquals(mapped, { "aa", "bb", "cc" })
end

function M:test_where()
    local array = addon.Enumerable:From({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
    local even = array
        :Where(function(x) return x % 2 == 0 end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
end

function M:test_where_multiple()
    local array = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    local even = addon.Enumerable:From(array)
        :Where(function(x) return x % 2 == 0 end)
        :ToTable()
    local odd = addon.Enumerable:From(array)
        :Where(function(x) return x % 2 == 1 end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
    assertEquals(odd, { 1, 3, 5, 7, 9 })
end

function M:test_orderby()
    local array = addon.Enumerable:From({ "z", "x", "a", "d" })
    local sorted = array
        :OrderBy(function(x, y) return x < y end)
        :ToTable()

    assertEquals(sorted, { "a", "d", "x", "z" })
end

function M:test_first()
    local array = addon.Enumerable:From({ 1, 3, 5, 6, 8, 9 })
    local first = array
        :First(function(x) return x % 2 == 0 end)

    assertEquals(first, 6)
end

function M:test_tolookup()
    local array = addon.Enumerable:From({
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

return M
