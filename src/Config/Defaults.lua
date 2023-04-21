local _, addon = ...

---Default configuration.
addon.Defaults = {
    Version = 10,
    Logging = {
        Enabled = false
    },
    Arena = {
        Enabled = true,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Group,
        Reverse = false
    },
    Dungeon = {
        Enabled = true,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Role,
        Reverse = false
    },
    World = {
        Enabled = true,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Group,
        Reverse = false
    },
    Raid = {
        Enabled = false,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Role,
        Reverse = false
    },
    SortingMethod = {
        TaintlessEnabled = true,
        TraditionalEnabled = false
    },
    Appearance = {
        Party = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0
            },
        },
        Raid = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0
            }
        }
    }
}
