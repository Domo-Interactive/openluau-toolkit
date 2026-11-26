# OpenLuau Toolkit

<img src="assets/domo-interactive-logo.png" alt="Domo Interactive" width="200">

Maintained by Domo Interactive.

A planned collection of modular Luau systems for independent Roblox developers.

**Status: architecture and documentation stage.** There are no implemented game systems, installable packages or published releases yet. The APIs and milestones described here are proposals. Runtime testing and production validation have not started.

## Purpose

OpenLuau Toolkit aims to make common gameplay rules reusable across different Roblox genres. Developers should be able to adopt one system, configure its rules and connect it to their own game without adopting a framework-wide loader, user interface or game loop.

The proposed focus is explicit state changes, server authority, predictable failure handling and examples that explain integration and misuse. These are design goals; they have not yet been demonstrated by software.

## Planned systems

| Area | Intended scope | Status |
| --- | --- | --- |
| Inventory and equipment | Stack limits, capacity, item definitions and equipment rules | First implementation candidate |
| Experience and progression | Configurable level curves, rewards and progression limits | Planned |
| Combat and damage | Validated damage resolution and configurable rules | Planned |
| Economy and shops | Integer currency, purchase validation and consistent state updates | Planned |
| Persistent player data | Versioned schemas, migrations and a storage adapter | Planned |
| Multiplayer networking | Request validation, authorisation and bounded client requests | Planned |
| Quests and achievements | Objectives, progress and repeatable reward policies | Planned |
| NPC behaviour and pathfinding | Behaviour policies, cancellable paths and recovery | Planned |
| Testing and debugging | Deterministic fixtures, integration tests and bounded diagnostics | Planned |
| Examples and tutorials | Small, independently reproducible integrations | Planned |

See the [roadmap](ROADMAP.md) for sequencing and completion criteria.

## Start here

- [Architecture](docs/architecture.md): module boundaries, dependencies and server/client placement.
- [Inventory design](docs/design/inventory.md): the first proposed module and its acceptance scenarios.
- [Development plan](docs/development.md): implementation order, tooling decisions and release gates.
- [Ecosystem research](docs/research/ecosystem.md): existing projects and the proposed differentiation.
- [Contribution guidelines](CONTRIBUTING.md): how to discuss and review changes at this stage.
- [Documentation index](docs/README.md): all project documentation.

There are no installation commands or executable examples at this stage. Implementation begins only after the project owner authorises it.

## Design commitments

- Keep gameplay rules separate from Roblox services and presentation where practical.
- Use strict Luau types and explicit dependencies when implementation starts.
- Treat client messages as requests; the server decides authoritative outcomes.
- Keep optional integrations behind adapters and avoid requiring unrelated modules.
- Document errors, lifecycle, limitations and supported environments alongside each module.
- Prefer existing, suitable libraries over reimplementing low-level infrastructure.

## Commercial use and project boundaries

Original toolkit material is released under the [MIT licence](LICENSE). Proprietary games can depend on the toolkit while keeping their own game-specific code, assets, balancing and design in separate repositories. Required copyright and licence notices must be preserved. Third-party dependencies retain their own licences; see [third-party notices](THIRD_PARTY_NOTICES.md).

Only generic infrastructure, public documentation and distributable examples belong here. See [scope and boundaries](docs/scope.md).

OpenLuau Toolkit is an independent project. It is not affiliated with Roblox or the Luau language project.
