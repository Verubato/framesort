-- a dummy table that just accepts everything and does nothing
local void = {}
setmetatable(void, {
    __index = function(table, key)
        table[key] = function()
            return table
        end

        return table[key]
    end,
})

return void
