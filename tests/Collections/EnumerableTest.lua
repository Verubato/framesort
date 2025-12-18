---@type Enumerable
local fsEnumerable
local M = {}

function M:setup()
    local addon = {
        Utils = {},
        Collections = {},
    }

    local module = loadfile("..\\src\\Collections\\Enumerable.lua")
    assert(module)

    module("UnitTest", addon)

    fsEnumerable = addon.Collections.Enumerable
end

function M:test_new_instance()
    local table = { 1, 2, 3 }
    local one = fsEnumerable:From(table):ToTable()
    local two = fsEnumerable:From(table):ToTable()

    -- should not be the same instance
    assert(one ~= two)
end

function M:test_totable()
    local array = fsEnumerable:From({ "a", "b", "c" })
    local test = array:ToTable()

    assertEquals(test, { "a", "b", "c" })
end

function M:test_map()
    local array = fsEnumerable:From({ "a", "b", "c" })
    local mapped = array
        :Map(function(x)
            return x .. x
        end)
        :ToTable()

    assertEquals(mapped, { "aa", "bb", "cc" })
end

function M:test_where()
    local array = fsEnumerable:From({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
    local even = array
        :Where(function(x)
            return x % 2 == 0
        end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
end

function M:test_where_multiple()
    local array = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    local even = fsEnumerable
        :From(array)
        :Where(function(x)
            return x % 2 == 0
        end)
        :ToTable()
    local odd = fsEnumerable
        :From(array)
        :Where(function(x)
            return x % 2 == 1
        end)
        :ToTable()

    assertEquals(even, { 2, 4, 6, 8, 10 })
    assertEquals(odd, { 1, 3, 5, 7, 9 })
end

function M:test_orderby()
    local array = fsEnumerable:From({ "z", "x", "a", "d" })
    local sorted = array
        :OrderBy(function(x, y)
            return x < y
        end)
        :ToTable()

    assertEquals(sorted, { "a", "d", "x", "z" })
end

function M:test_first()
    assertEquals(
        fsEnumerable:From({ 1, 3, 5, 6, 8, 9 }):First(function(x)
            return x % 2 == 0
        end),
        6
    )
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):First(), "a")
end

function M:test_last()
    assertEquals(
        fsEnumerable:From({ 1, 3, 5, 6, 8, 9 }):Last(function(x)
            return x % 2 == 0
        end),
        8
    )
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):Last(), "c")
end

function M:test_nth()
    assertEquals(
        fsEnumerable:From({ 1, 2, 3 }):Nth(0, function(_)
            return true
        end),
        nil
    )
    assertEquals(
        fsEnumerable:From({ 1, 2, 3, 4, 5, 6 }):Nth(2, function(x)
            return x % 2 == 0
        end),
        4
    )
    assertEquals(
        fsEnumerable:From({ 1, 2, 3, 4, 5, 6 }):Nth(4, function(x)
            return x % 2 == 0
        end),
        nil
    )
    assertEquals(
        fsEnumerable:From({ 1, 2, -1, 3, 6, -4, 8, 9, -2 }):Nth(3, function(x)
            return x < 0
        end),
        -2
    )
end

function M:test_any()
    assertEquals(fsEnumerable:From({}):Any(), false)
    assertEquals(
        fsEnumerable:From({ 1, 3, 5, 6 }):Any(function(x)
            return x % 2 == 0
        end),
        true
    )
    assertEquals(
        fsEnumerable:From({ 1, 3, 5 }):Any(function(x)
            return x % 2 == 0
        end),
        false
    )
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):Any(), true)
end

function M:test_all()
    assertEquals(
        fsEnumerable:From({}):All(function()
            return true
        end),
        false
    )
    assertEquals(
        fsEnumerable:From({ 1, 3, 5 }):All(function(x)
            return x % 2 == 1
        end),
        true
    )
    assertEquals(
        fsEnumerable:From({ 1, 2, 3 }):All(function(x)
            return x % 2 == 0
        end),
        false
    )
    assertEquals(
        fsEnumerable:From({ "a" }):All(function(x)
            return x ~= nil
        end),
        true
    )
end

function M:test_indexof()
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("a"), 1)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("b"), 2)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("c"), 3)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):IndexOf("d"), nil)
end

function M:test_last_indexof()
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):LastIndexOf("c"), 3)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):LastIndexOf("b"), 2)
    assertEquals(fsEnumerable:From({ "a", "a", "a" }):LastIndexOf("a"), 3)
    assertEquals(fsEnumerable:From({ "a", "b", "c" }):LastIndexOf("d"), nil)
end

function M:test_todictionary()
    local array = fsEnumerable:From({
        { letter = "a", word = "apple" },
        { letter = "b", word = "banana" },
        { letter = "c", word = "carrot" },
    })

    local dict = array:ToDictionary(function(x)
        return x.letter
    end, function(x)
        return x.word
    end)

    assertEquals(dict, {
        ["a"] = "apple",
        ["b"] = "banana",
        ["c"] = "carrot",
    })
end

function M:test_todictionary_with_duplicates()
    local array = fsEnumerable:From({
        { letter = "a", word = "apple" },
        { letter = "a", word = "artichoke" },
        { letter = "b", word = "banana" },
        { letter = "c", word = "carrot" },
        { letter = "c", word = "chives" },
        { letter = "c", word = "cinnamon" },
    })

    local dict = array:ToDictionary(function(x)
        return x.letter
    end, function(x)
        return x.word
    end)

    assertEquals(dict, {
        ["a"] = "artichoke",
        ["b"] = "banana",
        ["c"] = "cinnamon",
    })
end

function M:test_reverse()
    assertEquals(
        fsEnumerable:From({ 1, 2, 3 }):Reverse():ToTable(),
        -- expected
        { 3, 2, 1 }
    )

    assertEquals(
        fsEnumerable:From({ 1, 2, 3, 4 }):Reverse():ToTable(),
        -- expected
        { 4, 3, 2, 1 }
    )

    assertEquals(
        fsEnumerable:From({ 1 }):Reverse():ToTable(),
        -- expected
        { 1 }
    )

    assertEquals(
        fsEnumerable:From({ "a", "b", "c", "d", "e" }):Reverse():ToTable(),
        -- expected
        { "e", "d", "c", "b", "a" }
    )
end

function M:test_min()
    assertEquals(fsEnumerable:From({ 7, 5, 2 }):Min(), 2)

    assertEquals(
        fsEnumerable
            :From({
                { name = "a", value = 5 },
                { name = "b", value = 3 },
                { name = "c", value = 8 },
            })
            :Min(function(x)
                return x.value
            end),
        { name = "b", value = 3 }
    )
end

function M:test_max()
    assertEquals(fsEnumerable:From({ 7, 5, 2 }):Max(), 7)

    assertEquals(
        fsEnumerable
            :From({
                { name = "a", value = 5 },
                { name = "b", value = 3 },
                { name = "c", value = 8 },
            })
            :Max(function(x)
                return x.value
            end),
        { name = "c", value = 8 }
    )
end

function M:test_sum()
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Sum(), 6)

    assertEquals(
        fsEnumerable
            :From({
                { name = "a", value = 5 },
                { name = "b", value = 3 },
                { name = "c", value = 8 },
            })
            :Sum(function(x)
                return x.value
            end),
        16
    )
end

function M:test_take()
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(1):ToTable(), { 1 })
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(2):ToTable(), { 1, 2 })
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(3):ToTable(), { 1, 2, 3 })
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Take(4):ToTable(), { 1, 2, 3 })
end

function M:test_concat()
    assertEquals(fsEnumerable:From({ 1 }):Concat({ 2, 3 }):ToTable(), { 1, 2, 3 })
    assertEquals(fsEnumerable:From({}):Concat({ 2, 3 }):ToTable(), { 2, 3 })
    assertEquals(fsEnumerable:From({ 1 }):Concat({}):ToTable(), { 1 })
    assertEquals(fsEnumerable:From({ 1 }):Concat(fsEnumerable:From({ 2, 3 })):ToTable(), { 1, 2, 3 })
end

function M:test_flatten()
    assertEquals(fsEnumerable:From({ { 1 }, { 2, 3 }, { 4, 5, 6 } }):Flatten():ToTable(), { 1, 2, 3, 4, 5, 6 })
    assertEquals(fsEnumerable:From({ {}, { 1, 2 }, {}, { 3, 4, 5 }, {}, { 6 } }):Flatten():ToTable(), { 1, 2, 3, 4, 5, 6 })
end

function M:test_distinct()
    assertEquals(fsEnumerable:From({ 1, 2, 3 }):Distinct():ToTable(), { 1, 2, 3 })
    assertEquals(fsEnumerable:From({ 1, 2, 2, 3, 3, 3 }):Distinct():ToTable(), { 1, 2, 3 })
    assertEquals(fsEnumerable:From({ "a", "a", "a", "b", "c", "d", "e", "e" }):Distinct():ToTable(), { "a", "b", "c", "d", "e" })
end

return M
