local _, addon = ...

---Default configuration.
addon.Defaults = {
    Version = 6,
    Debug = {
        Enabled = false
    },
    Arena = {
        Enabled = true,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Group,
    },
    Dungeon = {
        Enabled = true,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Role,
    },
    World = {
        Enabled = true,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Group,
    },
    Raid = {
        Enabled = false,
        PlayerSortMode = addon.PlayerSortMode.Top,
        GroupSortMode = addon.GroupSortMode.Role,
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
