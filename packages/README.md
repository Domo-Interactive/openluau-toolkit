# Packages

Four independently loadable source modules are implemented. Each is a single strict Luau file without runtime dependencies.

| Package | Source | API guide |
| --- | --- | --- |
| Inventory and equipment | [Inventory.luau](inventory/src/Inventory.luau) | [Inventory](inventory/README.md) |
| Experience and progression | [Progression.luau](progression/src/Progression.luau) | [Progression](progression/README.md) |
| Combat and damage | [Combat.luau](combat/src/Combat.luau) | [Combat](combat/README.md) |
| Economy and shops | [Economy.luau](economy/src/Economy.luau) | [Economy](economy/README.md) |

There is no package-manager publication or tagged release. Load the source directly using the [usage guide](../docs/usage.md). The modules are checked in standalone Luau; their intended Roblox ModuleScript loading pattern has not been executed in Studio.
