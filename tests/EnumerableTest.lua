local deps = {
    "Util\\Enumerable.lua",
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local fsEnumerable = addon.Enumerable

local M = {}

function M:test_empty()
    local one = fsEnumerable:Empty()
    local two = fsEnumerable:Empty()

    -- should be the same instance
    assertEquals(one, two)
    assert(one:ToTable() == two:ToTable())
end

function M:test_totable()
    local array = fsEnumerable:From({ "a", "b", "c" })
    local test = array:ToTable()

    assertEquals(test, { "a", "b", "c" })
end

function M:test_map()
    local array = fsEnumerable:From({ "a", "b", "c" })
    local mapped = array
        :Map(function(x) return x .. x end)
        :ToTable()

    assertEquals(mapped, { "aa", "bb", "cc" })
end

function M:test_where()
    local array = fsEnumerable:From({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
    local even = array
        :Where(function(x) return x % 2 == 0 end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
end

function M:test_where_multiple()
    local array = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    local even = fsEnumerable:From(array)
        :Where(function(x) return x % 2 == 0 end)
        :ToTable()
    local odd = fsEnumerable:From(array)
        :Where(function(x) return x % 2 == 1 end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
    assertEquals(odd, { 1, 3, 5, 7, 9 })
end

function M:test_orderby()
    local array = fsEnumerable:From({ "z", "x", "a", "d" })
    local sorted = array
        :OrderBy(function(x, y) return x < y end)
        :ToTable()

    assertEquals(sorted, { "a", "d", "x", "z" })
end

function M:test_first()
    local array = fsEnumerable:From({ 1, 3, 5, 6, 8, 9 })
    local first = array
        :First(function(x) return x % 2 == 0 end)

    assertEquals(first, 6)
end

function M:test_indexof()
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("a"), 1)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("b"), 2)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("c"), 3)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("d"), nil)
end

function M:test_tolookup()
    local array = fsEnumerable:From({
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
        fsEnumerable
        :From({ 1, 2, 3 })
        :Reverse()
        :ToTable(),
        -- expected
        { 3, 2, 1 })

    assertEquals(
        fsEnumerable
        :From({ 1, 2, 3, 4 })
        :Reverse()
        :ToTable(),
        -- expected
        { 4, 3, 2, 1 })

    assertEquals(
        fsEnumerable
        :From({ 1 })
        :Reverse()
        :ToTable(),
        -- expected
        { 1 })

    assertEquals(
        fsEnumerable
        :From({ "a", "b", "c", "d", "e" })
        :Reverse()
        :ToTable(),
        -- expected
        { "e", "d", "c", "b", "a" })
end

function M:test_min()
    assertEquals(fsEnumerable:From({ 7, 5, 2 }):Min(), 2)

    assertEquals(fsEnumerable:From({
            { name = "a", value = 5 },
            { name = "b", value = 3 },
            { name = "c", value = 8 }
        })
        :Min(function(x) return x.value end),
        { name = "b", value = 3 })
end

function M:test_max()
    assertEquals(fsEnumerable:From({ 7, 5, 2 }):Max(), 7)

    assertEquals(fsEnumerable:From({
            { name = "a", value = 5 },
            { name = "b", value = 3 },
            { name = "c", value = 8 }
        })
        :Max(function(x) return x.value end),
        { name = "c", value = 8 })
end

function M:test_sum()
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Sum(), 6)

    assertEquals(fsEnumerable:From({
            { name = "a", value = 5 },
            { name = "b", value = 3 },
            { name = "c", value = 8 }
        })
        :Sum(function(x) return x.value end),
        16)
end

function M:test_take()
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(1):ToTable(), { 1 })
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(2):ToTable(), { 1, 2 })
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(3):ToTable(), { 1, 2, 3 })
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(4):ToTable(), { 1, 2, 3 })
end

function M:test_concat()
    assertEquals(fsEnumerable
        :From({ 1 })
        :Concat({ 2, 3 })
        :ToTable(),
        { 1, 2, 3 })

    assertEquals(fsEnumerable
        :From({})
        :Concat({ 2, 3 })
        :ToTable(),
        { 2, 3 })

    assertEquals(fsEnumerable
        :From({ 1 })
        :Concat({})
        :ToTable(),
        { 1 })

    assertEquals(fsEnumerable
        :From({ 1 })
        :Concat(fsEnumerable:From({ 2, 3 }))
        :ToTable(),
        { 1, 2, 3 })
end

function M:test_flatten()
    assertEquals(fsEnumerable
        :From({ { 1 }, { 2, 3 }, { 4, 5, 6 } })
        :Flatten()
        :ToTable(),
        { 1, 2, 3, 4, 5, 6 })
end

return M