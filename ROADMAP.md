# Roadmap

The first four gameplay areas now have source implementations and basic standalone checks. They are unreleased. No Studio integration, production deployment or external adoption is claimed.

## Completed initial scope

- [x] Establish the public repository and technical documentation.
- [x] Implement configurable inventory stacks, capacity and equipment rules.
- [x] Implement experience thresholds, level caps and reward descriptions.
- [x] Implement bounded health, shield, damage and healing rules.
- [x] Implement integer wallets, shop catalogues and composed purchase results.
- [x] Check strict Luau types, 22 behaviour scenarios and a combined command-line example.
- [x] Provide API/error documentation and a reproducible pinned development toolchain.

## Maintain the current modules

Fix defects, keep the source and examples aligned, and review public API changes. The next practical validation options are checking the intended ModuleScript integration in Studio and incorporating real integration feedback. Neither is a prerequisite for submitting an accurate programme application.

A tagged prerelease, package-manager distribution, broader testing and additional examples are optional future work. There is no release date or commitment to those activities in the current scope.

## Future systems — not implemented

| Area | Proposed direction |
| --- | --- |
| Persistent player data | Versioned profiles, migrations and a reviewed session-aware backend adapter |
| Networking | Runtime message validation, authorisation, bounded requests and lifecycle management |
| Quests and achievements | Explicit progress events, completion rules and reward application |
| NPCs and pathfinding | Cancellable movement, blocked-path recovery and bounded scheduling |

These systems need separate authorisation and designs. Current modules remain usable without them. Record actual maintenance and adoption as it occurs; do not manufacture metrics or development history.
