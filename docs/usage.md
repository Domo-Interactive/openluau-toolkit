# Loading and state guide

## Standalone Luau

The source modules contain no Roblox service calls or internal requires. The checked command-line example uses relative string paths:

```lua
local Inventory = require("../packages/inventory/src/Inventory")
```

Relative paths resolve from the requiring file. Run the [basic example](../examples/basic.luau) through the documented check command.

## Roblox ModuleScripts — intended integration

Copy only the modules you need from `packages/*/src/*.luau` into ModuleScripts named Inventory, Progression, Combat and Economy. Place authoritative modules and configuration in a server-only folder, for example `ServerScriptService/OpenLuau`.

From a server Script in that folder, the intended loading pattern is:

```lua
local Inventory = require(script.Parent.Inventory)
local Economy = require(script.Parent.Economy)
```

Copy the source into each ModuleScript rather than pasting CLI require paths into the game. A Script outside that folder must adjust its Instance references. No Rojo project, Wally package, plugin or framework is required for this source-copy route. This Studio pattern has not been executed here; only standalone Luau checks are recorded.

## Values, state and errors

Construct state with the module's constructor. Public mutations return `(result, nil)` on success or `(nil, errorCode)` on expected rejection. Check the result before reading fields. The module README lists operation-specific errors and bounds.

Do not modify returned state or its nested configuration. The implementation freezes records and takes copies of caller configuration. Inventory slot storage is sparse: use `Inventory.list`, or the declared capacity and explicit indexes, rather than the length operator on `state.slots`.

Keep the current state in a server-owned profile and replace it after a successful operation. Old states remain valid snapshots. Replaying an old snapshot also replays its earlier state; immutability is not request deduplication or persistence.

## Purchase composition

`Economy.purchase` accepts a pure inventory-adder function. `Inventory.add` implements that contract directly:

```lua
local result, problem = Economy.purchase(wallet, bag, catalogue, "potion", 2, Inventory.add)
if result then
    profile = { wallet = result.wallet, inventory = result.inventory }
else
    print(problem)
end
```

Retain other profile fields when composing this into a larger game. Commit both returned values together without yielding. The adapter must be synchronous, non-yielding and must not change its input. An adapter that mutates state or performs I/O breaks these guarantees. Programmer errors thrown by an adapter propagate to the caller.

This operation calculates an in-memory result. It does not save a profile, coordinate servers, deduplicate requests or implement real-money purchase receipts.

## Rewards and damage permission

`Progression.award` returns reward descriptions for newly crossed levels. Apply those rewards with the new progression state in the same authoritative operation. It does not directly credit an economy wallet or remember external delivery.

`Combat.damage` accepts a `canDamage` decision from trusted server code. The consuming game determines ownership, hit validity, distance, teams and cooldowns. A client must not supply the permission, price or final outcome as trusted data.
