# Basic behaviour checks

[run.luau](run.luau) contains 22 behaviour scenarios for the four modules and the shop/inventory integration. The small runner reports each failure and exits unsuccessfully when an assertion fails.

From the repository root:

```sh
python3 scripts/bootstrap.py
python3 scripts/check.py
```

The command also performs strict static analysis and runs the combined command-line example. Luau 0.748 is pinned and checksum-verified. The GitHub Actions workflow runs the same commands.

Checks cover stack/capacity rules, immutable state, equipment movement/removal, progression thresholds/caps/rewards, damage/shield/healing rules, integer money, offer validation and successful/rejected composed purchases. The [quality record](../docs/quality.md) describes the limits. No Studio, network, storage or production checks are claimed.
