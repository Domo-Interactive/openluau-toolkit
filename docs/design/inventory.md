# Inventory module design

**Status:** proposed first implementation. Names below describe operations and data; they are not released API signatures.

## First useful scope

A deterministic inventory rule module with no Roblox service, persistence, networking or UI dependency. It manages stackable, fungible items in a bounded set of slots. Definitions and capacity are caller-configurable.

Version one excludes unique equipment metadata, durability, trading, world drops and automatic persistence. Equipment can later use a separately specified extension rather than forcing every inventory item into a gear model.

## Data model

| Value | Proposed contract |
| --- | --- |
| Item ID | Non-empty, bounded string that identifies an immutable server-owned definition |
| Item definition | Stable ID and positive integer maximum stack size; optional game metadata stays outside the rule engine |
| Slot | Empty or a stack containing item ID and positive integer quantity |
| Inventory state | Schema version, bounded positive integer capacity and slots addressed from 1 to capacity |
| Item quantity | Finite positive integer within the configured operation bound |
| Definition set | Explicitly supplied to the operation; unknown IDs are rejected |

Use a slot representation whose empty positions do not rely on Lua's length operator for sparse arrays. Validate capacity and slot indexes explicitly. Document an encoding for persistence separately from the in-memory representation.

Apply hard limits to capacity, definition count and input string lengths. Decide concrete defaults and maximum supported bounds during implementation, document them, and exercise them in tests. Do not rely on the floating-point safe-integer ceiling as an economic or gameplay policy.

## Operation contracts

| Operation | Success | Rejection |
| --- | --- | --- |
| Create/validate | Returns valid state for supplied capacity and definitions | Invalid schema, bounds, unknown IDs or overfull stacks |
| Add | Fills matching stacks in slot order, then empty slots; returns a new state | Full quantity cannot fit, invalid quantity or unknown definition |
| Remove | Removes the requested quantity in deterministic slot order | Insufficient quantity or invalid input |
| Move | Moves to an empty slot or merges matching stacks when the full source quantity fits | Out-of-range slots, incompatible occupied target or insufficient target stack space |
| Count/query | Returns quantities or a detached read view | Invalid query input |

Add and remove are all-or-nothing. No partial acceptance is implied. Moving a slot onto itself is a successful no-op. Swapping incompatible stacks and moving a partial source stack are outside the initial contract.

Expected rejection codes should distinguish invalid input, unknown item, insufficient items, insufficient capacity and incompatible target. Export the final error set alongside the API. Error results must not leak mutable references to internal state.

## Invariants

- Quantities are finite integers, greater than zero and no greater than the definition's stack limit.
- Slot indexes are within the configured capacity.
- No operation changes its input state or definition objects.
- Rejected mutations preserve every input quantity and slot.
- Add increases the requested item total by exactly the accepted quantity; remove decreases it by exactly that quantity.
- Move preserves every item total and capacity.
- A returned state does not allow later mutation of a previous state through shared mutable stack objects.
- Equal valid inputs and definitions produce equal results in a documented order.

## Acceptance scenarios

| Scenario | Expected result |
| --- | --- |
| Add 12 units with stack limit 10 to three empty slots | Two stacks, quantities 10 and 2, in slot order |
| Add 4 units to an existing stack of 8 with limit 10 | Existing stack reaches 10; next available slot receives 2 |
| Add 3 units when only 2 units of space remain | Rejection; no state change |
| Remove 6 units spread across stacks of 4 and 5 | First stack empties; second contains 3 |
| Remove more units than exist | Rejection; no state change |
| Move into a matching stack that cannot fit the entire source | Rejection; no partial merge |
| Move a stack into an empty slot | Source empties; target contains the same stack values |
| Submit zero, negative, fractional, NaN or infinite quantity | Rejection before calculating or iterating over a mutation |
| Read or mutate slot zero or a slot beyond capacity | Rejection |
| Mutate a returned stack after a successful operation | Earlier input state remains unchanged |
| Use a saved state with a removed item definition | Explicit validation failure; game decides recovery policy |
| Use a six-slot collectible bag and a forty-slot resource container | Same module; distinct definitions and capacity configuration |

## Integration proof

After implementation is authorised, verify the rules in a supported standalone Luau runtime and in a minimal Studio example. Keep the example state on the server and document its reset-on-exit behaviour. It must require no other toolkit gameplay module. A later networking example will add malicious-client scenarios; the standalone module alone does not secure a game.
