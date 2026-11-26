# Combat and damage

Source: [Combat.luau](src/Combat.luau). No runtime dependencies. Checked in standalone Luau; Studio integration is unverified.

```lua
local target, problem = Combat.create(100, 20)
assert(target, problem)
local hit, damageError = Combat.damage(target, 40, {
    canDamage = true, -- Derived by trusted server game logic.
    flatReduction = 5,
})
assert(hit, damageError)
-- hit.absorbed == 20; hit.healthDamage == 15; hit.state.health == 85.
```

Load `Combat` using the [usage guide](../../docs/usage.md).

## API

| Function | Contract |
| --- | --- |
| `create(maxHealth, shield?)` | Return `(state, nil)` at full health, with shield defaulting to zero; reject invalid bounds. |
| `damage(state, amount, rules?)` | Return `(damage, nil)` or `(nil, errorCode)`. Reject denied attacks or dead targets. |
| `heal(state, amount)` | Return `(newState, nil)` or `(nil, errorCode)`. Cap healing at maximum health and reject dead targets. |

State contains frozen `health`, `maxHealth` and `shield`. A damage result contains frozen `state`, actual `healthDamage`, actual shield `absorbed`, and a `killed` flag. Existing state is unchanged.

Rules are optional: `canDamage` defaults to allowed, `flatReduction` to zero, `multiplier` to one and `shieldPiercing` to false. Resolution is `max(0, amount - flatReduction) * multiplier`, then shield absorption unless piercing, then remaining damage against health. Applied damage cannot reduce health or shield below zero. Fractional health/damage values are supported. Healing does not replenish shields or resurrect targets.

`canDamage` represents a trusted game decision. This module does not validate a hit, identify a player, apply team rules, implement range/cooldowns or prevent client spoofing. The caller must determine those facts before invoking it.

## Bounds and errors

Maximum health: greater than zero and at most 1,000,000,000. Initial shield and reduction: zero to 1,000,000,000. Raw damage/healing: greater than zero and at most 1,000,000,000. Multiplier: zero to 100. All numbers must be finite.

| Code | Meaning |
| --- | --- |
| `invalid_health` | Maximum health or initial shield is invalid. |
| `invalid_damage` | Raw damage is non-positive, non-finite or outside its bound. |
| `invalid_rules` | Rules contain invalid booleans or numeric bounds. |
| `damage_denied` | The caller supplied `canDamage = false`. |
| `target_dead` | Damage or healing targets a state whose health is zero. |
| `invalid_healing` | Healing is non-positive, non-finite or outside its bound. |

Use states returned by this module. There is no Humanoid adapter, weapon system, animation, hit detection, networking or persistence. Resolution performs constant work with no background lifecycle.
