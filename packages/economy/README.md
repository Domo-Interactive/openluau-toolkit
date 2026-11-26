# Economy and shops

Source: [Economy.luau](src/Economy.luau). No runtime dependencies. Checked in standalone Luau, including composition with the inventory module; Studio integration is unverified.

```lua
local wallet, problem = Economy.create(100)
assert(wallet, problem)
local catalogue, catalogueError = Economy.createCatalogue({
    potion = { itemId = "potion", price = 15, maxQuantity = 5 },
})
assert(catalogue, catalogueError)
local purchase, purchaseError = Economy.purchase(wallet, bag, catalogue, "potion", 2, Inventory.add)
assert(purchase, purchaseError)
-- purchase.wallet.balance == 70; purchase.inventory contains two more potions.
-- wallet and bag are unchanged. Commit both returned values together.
```

Load the modules using the [usage guide](../../docs/usage.md). `bag` must be a state constructed by Inventory with a matching potion definition and sufficient capacity. Other inventory implementations can provide the same pure operation contract.

## API

| Function | Contract |
| --- | --- |
| `create(balance?, maxBalance?)` | Return `(wallet, nil)` or `(nil, "invalid_balance")`. Defaults: zero balance and a maximum of 1,000,000,000,000. |
| `credit(wallet, amount)` | Return a new wallet or reject overflow/invalid input. Zero is accepted. |
| `debit(wallet, amount)` | Return a new wallet or reject insufficient funds/invalid input. Zero is accepted. |
| `createCatalogue(offers)` | Snapshot and freeze offers keyed by offer ID. Each entry defines `itemId`, integer unit `price` and optional `maxQuantity`. Empty catalogues are allowed. |
| `purchase(wallet, inventory, catalogue, offerId, quantity, addItems)` | Calculate a new wallet and inventory together, or reject the purchase. |

Wallets expose `balance` and `maxBalance`. Purchase results expose `wallet`, `inventory`, `offerId`, `itemId`, `quantity` and `totalCost`.

The injected `addItems(inventory, itemId, quantity)` returns `(newInventory, nil)` or `(nil, errorCode)`. It must be pure, synchronous and non-yielding. `Inventory.add` meets that contract. Custom adapter exceptions propagate as programmer errors. A mutating adapter can change the original inventory and is outside the guarantee.

Prices come from the supplied server-owned catalogue, never a client price. Funds are checked before calling the inventory adapter. An inventory rejection returns no wallet update. Commit both success values to the authoritative profile without yielding, preserving any other profile fields. The consuming game must serialise conflicting requests.

This is an in-memory calculation. Repeated calls from the same old state compute repeated results. There is no request deduplication, storage, trading, distributed transaction, sale-back system or real-money receipt handling.

## Bounds and errors

Balances/amounts are non-negative integers up to 1,000,000,000,000; a wallet can configure a lower cap. Unit prices are integers from zero to 1,000,000,000. Per-purchase quantity is a positive integer up to the offer's configured limit (default/global maximum 1,000,000). Catalogues contain at most 1,024 offers. IDs are 1–96 bytes. The maximum price/quantity product is below the exact-integer limit of Luau numbers.

| Code | Meaning |
| --- | --- |
| `invalid_balance` | Starting balance/cap is invalid or the starting balance exceeds the cap. |
| `invalid_amount` | A credit/debit amount is fractional, negative, non-finite or out of bounds. |
| `balance_limit` | A credit would exceed the wallet's cap. |
| `insufficient_funds` | A debit or purchase exceeds the balance. |
| `invalid_catalogue` | Offers have the wrong container type. |
| `invalid_offer` | An offer ID, entry, item ID, price, quantity limit or count is invalid. |
| `invalid_offer_id` | A purchase's offer ID is not a bounded, non-empty string. |
| `unknown_offer` | The requested offer is absent. |
| `invalid_quantity` | Purchase quantity is outside the offer's positive integer bounds. |
| `invalid_inventory_adapter` | The injected adder is not a function. |
| `inventory_rejected` | The adder rejected without its own code. An adder's provided error code, such as `inventory_full`, is otherwise forwarded unchanged. |

Wallets and catalogues must originate from the constructors. The built-in wallet work is constant; purchase cost depends on the injected inventory function.
