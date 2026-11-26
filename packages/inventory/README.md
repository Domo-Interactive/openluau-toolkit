# Inventory and equipment

Source: [Inventory.luau](src/Inventory.luau). No runtime dependencies. Checked in standalone Luau; Studio integration is unverified.

## Setup

```lua
local bag, problem = Inventory.create(6, {
    potion = { maxStack = 10 },
    sword = { maxStack = 1, equipmentSlot = "hand" },
}, { hand = true })
assert(bag, problem)

local nextBag, addError = Inventory.add(bag, "potion", 12)
assert(nextBag, addError)
-- Slots 1 and 2 contain 10 and 2 potions; bag remains empty.
```

Load `Inventory` using the [usage guide](../../docs/usage.md). The constructor copies and freezes definitions, equipment configuration and state. Public records have read-only fields; nested maps are also frozen at runtime.

## API

All operations use dot calls. Mutations return `(newState, nil)` or `(nil, errorCode)`. Expected rejections leave input state unchanged.

| Function | Contract |
| --- | --- |
| `create(capacity, definitions, equipmentSlots?)` | Construct an empty bag. Definitions map item IDs to `{ maxStack, equipmentSlot? }`; equipment slots map names to `true`. |
| `add(state, itemId, quantity)` | Accept the full quantity or reject it. Fill matching stacks in slot order, then empty slots. |
| `remove(state, itemId, quantity)` | Remove the full quantity in slot order or reject it. Empty stacks disappear; removing equipped items unequips them. |
| `move(state, from, to)` | Move a whole stack into an empty slot, or fully merge matching stacks if they fit. No swap or partial move. A same-slot move is a no-op for an occupied slot. |
| `count(state, itemId)` | Return `(total, nil)` or `(nil, "unknown_item")`. |
| `list(state)` | Return a frozen, dense array of `{ slot, itemId, quantity }` in slot order. |
| `equip(state, slot)` | Equip the item at an owned bag slot into its definition's equipment slot. Replace the previous selection without deleting it. |
| `unequip(state, name)` | Clear a configured equipment slot; an empty slot is a successful no-op. |
| `getEquipped(state, name)` | Return `(stack, nil)`, `(nil, nil)` for an empty configured slot, or `(nil, "invalid_equipment_slot")`. |

State exposes `capacity`, frozen `definitions`, sparse `slots`, configured `equipmentSlots` and `equipped` bag-slot indexes. Use the returned state rather than editing it. Do not use `#state.slots` for capacity or item count. An equip selection follows a moved stack.

Equippable items must have `maxStack = 1`, and their equipment slot must be configured at construction. Multiple copies of an item may be owned in separate slots; equipment selects a particular slot. There is no durability, instance metadata, Roblox Tool visual or automatic character modification.

## Bounds

Capacity: 1–512 slots. Definitions: 1–1,024 entries. Equipment slots: at most 32. Identifiers: 1–96 bytes. Stack limits and add/remove quantities: positive integers up to 1,000,000. Fractional, NaN, infinite and out-of-range quantities are rejected. A bag may contain more than 1,000,000 total units, but each add/remove operation is bounded separately.

## Rejections

| Code | Meaning |
| --- | --- |
| `invalid_capacity` | Capacity is outside its integer bounds. |
| `invalid_definitions` | Definitions/configuration have invalid structure, IDs or entry counts. |
| `invalid_stack_limit` | A maximum stack size is outside its integer bounds. |
| `invalid_equipment_slots` | Equipment configuration contains invalid names, values or too many slots. |
| `invalid_equipment_slot` | A definition or query refers to an unconfigured/invalid equipment slot. |
| `equipment_must_not_stack` | An equippable definition has a stack limit other than one. |
| `invalid_item_id` | A mutation's item ID is not a bounded, non-empty string. |
| `unknown_item` | The item has no definition; also returned for an invalid count-query ID. |
| `invalid_quantity` | A mutation quantity is not a bounded positive integer. |
| `inventory_full` | The complete addition cannot fit. |
| `insufficient_items` | The complete removal cannot be satisfied. |
| `invalid_slot` | A bag slot index is outside capacity or is not an integer. |
| `empty_slot` | An equip/move source has no stack. |
| `incompatible_target` | A move targets a different occupied item. |
| `stack_full` | The full source stack cannot merge into its target. |
| `not_equippable` | The selected item's definition has no equipment slot. |

States must originate from `create` and these operations. There is no deserialised-state validator, persistence, networking or authorisation layer. Definition/slot enumeration and mutations are bounded linear work in the configured capacity.
