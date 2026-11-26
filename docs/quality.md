# Quality record

## Checks executed

The initial implementation was checked on Linux x86-64 using the official Luau **0.748** command-line tools. Run `python3 scripts/bootstrap.py` and `python3 scripts/check.py` to reproduce the checks.

| Check | Observed result |
| --- | --- |
| Strict type analysis and Luau linting | Passed for all four modules, the test runner and the example |
| Basic behaviour scenarios | 22 passed, 0 failed |
| Combined command-line example | Passed: equipment, purchase, progression and shielded damage |
| Module runtime dependencies | None |

The GitHub Actions workflow runs the same commands. A workflow file alone is not evidence of a successful hosted run; consult the actual run result for a given commit.

## Covered behaviour

- Inventory stack/capacity rules, deterministic removal/movement, rejected changes and immutable configuration/state.
- Equipment replacement, ownership, slot configuration, movement and automatic unequipping on removal.
- Progression exact/multiple thresholds, capped experience, reward order and no repeated reward descriptions when advancing from the returned state.
- Combat permission rejection, flat reduction, multiplier, shields, piercing, health bounds and healing.
- Integer money, balance limits, catalogue snapshots and successful/rejected shop purchases composed with the actual inventory module.
- Selected invalid inputs, including negative, fractional, NaN and infinite values where relevant.

These are basic contract checks, not exhaustive testing, benchmarking or a security audit.

## Not executed or implemented

Roblox Studio loading, multiplayer requests, hit detection, storage, session loss, save failures, cross-server operations and production use have not been validated. No external developer adoption or performance result is claimed.

Module states/configuration must come from the constructors and remain server-owned. An arbitrary deserialised state is outside that contract. Economy composition depends on a pure, synchronous, non-yielding inventory adapter. Progression rewards require the caller to commit delivery with the new progression state.

Broader integration checks can be introduced when corresponding adapters exist. Current correctness claims stay limited to the rule-module behaviour above.
