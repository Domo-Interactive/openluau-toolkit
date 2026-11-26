# Roadmap

All implementation milestones below are planned. There are no released modules. Milestones are ordered by dependencies and evidence of usefulness, with no delivery dates promised.

## Foundation — current stage

- [x] Define repository scope, architecture and contribution expectations.
- [x] Review relevant ecosystem projects and document a proposed focus.
- [x] Specify the first module and a behaviour-based validation plan.
- [x] Establish the public repository under its verified owner.
- [ ] Obtain explicit project-owner authorisation to begin implementation.

## Milestone 1 — a useful standalone inventory module

Implement bounded item definitions, stack/capacity rules and all-or-nothing add, remove and move operations. Support deterministic identifiers and caller-provided configuration. Keep networking, persistence, equipment, user interfaces and trading outside this release.

Completion requires strict type checking, reproducible behaviour tests, documented errors, two distinct configuration examples and a verified Studio integration without other toolkit modules. Establish the pinned toolchain and real CI checks alongside the module.

## Milestone 2 — progression and damage rules

Add independent progression and damage modules. Progression covers level curves, caps and boundary behaviour. Damage covers eligibility policies, bounded inputs and explicit resolution results. Equipment follows as a separate inventory-dependent extension.

Completion requires each module to work independently, negative/adversarial scenarios to pass and dependencies and runtime assumptions to be documented. Damage rules do not imply a complete hit-detection or lag-compensation system.

## Milestone 3 — a server-authoritative gameplay slice

Introduce a validated request boundary, a single-profile economy/purchase operation and player-data integration. Evaluate an existing persistence backend before selecting an adapter. Exercise the flow: request purchase, validate on the server, apply currency/inventory changes, persist and restore a versioned profile.

Completion requires tests for malformed and repeated requests, denied access, insufficient funds, capacity errors, concurrency, session loss, migrations and shutdown. In-memory mutation and durable storage have distinct guarantees. Cross-player trades, cross-server transactions and exactly-once external payments are outside this milestone.

## Milestone 4 — quests, achievements and NPCs

Build quests and achievements on explicit progress events and reward policies. Add cancellable NPC behaviour and pathfinding adapters only after the earlier boundaries have been exercised.

Completion requires reward replay tests, versioned quest state, blocked-path/cancellation scenarios and a documented NPC resource budget.

## Milestone 5 — wider integration and release maintenance

Publish tutorials and small examples for distinct genres. Gather permission-based feedback from real developers, resolve integration failures and improve compatibility notes. Release stable APIs only when the corresponding behaviour and support limits are documented and tested.

Track usefulness through reproducible integrations, issue resolution and actual external feedback. Do not manufacture adoption statistics or maintenance history. Testing and debugging support grows with each milestone rather than waiting until this final stage.
