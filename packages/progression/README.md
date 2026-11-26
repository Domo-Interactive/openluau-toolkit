# Experience and progression

Source: [Progression.luau](src/Progression.luau). No runtime dependencies. Checked in standalone Luau; Studio integration is unverified.

```lua
local state, problem = Progression.create({ 0, 100, 250 }, {
    [2] = { coins = 10 },
    [3] = { skillPoints = 1 },
})
assert(state, problem)
local award, awardError = Progression.award(state, 125)
assert(award, awardError)
-- award.state.level == 2; award.state.experience == 125.
-- award.rewards[1] describes 10 coins, without crediting a wallet.
```

Load `Progression` using the [usage guide](../../docs/usage.md).

## API

| Function | Contract |
| --- | --- |
| `create(thresholds, rewards?)` | Return `(state, nil)` or `(nil, errorCode)`. A dense cumulative-XP array starts at zero for level one and increases strictly. Its length is the maximum level. |
| `award(state, amount)` | Return `(award, nil)` or `(nil, "invalid_experience")`. Accept non-negative integer XP, capped at the last threshold. |
| `toNextLevel(state)` | Return XP needed for the next level, or zero at the level cap. |

The award result contains frozen `state`, `gainedLevels`, `rewards` and `acceptedExperience`. The new state's total XP is capped; experience beyond the final threshold is discarded. A one-entry `{ 0 }` curve creates a character already at the cap.

Rewards map level numbers to dictionaries of reward IDs and positive integer amounts. Level one cannot grant rewards. Grants contain `{ level, id, amount }`, ordered by ascending level and then reward ID. Crossing multiple levels returns each configured grant for those levels.

Rewards are descriptions. The caller must apply them while committing `award.state`, with suitable concurrency and request handling. Advancing from that returned state does not emit the same level rewards again. Replaying an old state can replay grants; no durable delivery, transaction or deduplication is implemented.

## Bounds and errors

Curves have 1–1,000 levels. Thresholds and per-operation XP are integers from zero to 1,000,000,000. Each level can define at most 64 reward IDs, with 1–96 byte IDs and integer amounts from 1 to 1,000,000,000. Configuration is copied and frozen.

| Code | Meaning |
| --- | --- |
| `invalid_configuration` | The curve/reward configuration has the wrong container type. |
| `invalid_curve` | Thresholds are sparse, not strictly increasing, outside bounds or do not start at zero. |
| `invalid_reward` | Reward level, dictionary, ID, amount or count is invalid. |
| `invalid_experience` | XP is negative, fractional, non-finite or above its bound. |

States must be created by this module. No prestige system, stat scaling, persistence, networking or automatic economy integration is included. Award work is bounded by the number of crossed levels and their configured rewards.
