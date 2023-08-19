local M = {
    AddonName = "Test",
}

function M:DependenciesFromXml()
    local xmlFilePath = "..\\src\\Load.xml"
    local dependencies = {}

    for line in io.lines(xmlFilePath) do
        local file = string.match(line, [[file="(.*)"]])

        if file ~= "WoW\\WoW.lua" and file ~= "Namespace.lua" then
            dependencies[#dependencies + 1] = file
        end
    end

    return dependencies
end

function M:LoadDependencies(addonTable, dependencies)
    for _, fileName in ipairs(dependencies) do
        local module = loadfile("..\\src\\" .. fileName)
        assert(module ~= nil, "Failed to load " .. fileName)

        module(M.AddonName, addonTable)
    end
end

function M:GenerateUnits(count, isRaid)
    isRaid = isRaid or count > 5

    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and count or count - 1
    local members = {}

    -- raids don't have the "player" token
    if not isRaid then
        table.insert(members, "player")
    end

    for i = 1, toGenerate do
        table.insert(members, prefix .. i)
    end

    return members
end

function M:UnitExists(unit, members)
    for _, x in pairs(members) do
        if x == unit then
            return true
        end
    end

    return false
end

function M:CopyTable(table)
    local new = {}

    for key, value in pairs(table) do
        new[key] = value
    end

    return new
end

return M
