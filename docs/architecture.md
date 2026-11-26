# Architecture

**Design status:** proposed implementation architecture. No modules or APIs exist yet.

## Composition

Use a single repository with independently usable packages. Each package separates deterministic rule code from Roblox integration. A game's composition root supplies dependencies, starts integration explicitly and owns cleanup. Requiring a module must not start remotes, mutate player state or open storage sessions.

Avoid a shared runtime kernel until a concrete repeated requirement justifies one. Shared value types can be extracted later without creating a global state manager.

| Layer | Responsibility | Allowed dependencies |
| --- | --- | --- |
| Rules | Validate bounded values and calculate state changes | Luau standard library and narrow value types |
| Application operations | Apply a gameplay action to authoritative state | Required rule packages and explicit adapter contracts |
| Roblox adapters | Connect players, services, remotes and persistence | Application operations, Roblox services and selected upstream libraries |
| Presentation/examples | Display state and demonstrate integration | Public read models and request contracts |

## Package organisation

The current `packages/` directory contains documentation only. When a package is authorised, add `src/`, `tests/` and a README inside its own directory. Separate `rules`, `server` and `shared` source only when each has an actual purpose. Add a client adapter only where needed.

Avoid a root aggregate module that requires everything. Individual package manifests and a release build should expose only that package's documented dependencies. Do not publish empty packages or manifests claiming an available version.

## Intended dependency direction

| Module | Gameplay dependencies | Integration boundary |
| --- | --- | --- |
| Inventory | None | Caller supplies definitions and identifiers |
| Progression | None | Caller supplies level curve and reward policy |
| Damage | None | Server supplies validated context and eligibility policy |
| Equipment | Inventory | Game supplies slot and compatibility rules |
| Economy/purchase | Inventory for a purchase; currency rules remain independent | One authoritative profile operation |
| Player data | No mandatory gameplay module | Storage backend and schema migrations |
| Networking | No mandatory gameplay module | Calls explicit server handlers after validation |
| Quests/achievements | No direct dependency on economy or progression | Receives progress events; injected reward handler |
| NPCs/pathfinding | No mandatory gameplay module | Roblox pathfinding, scheduling and movement adapters |

Networking and storage adapters wrap gameplay; rule packages never import them. No cycles are permitted. Add dependencies only when the operation actually requires them.

## Server and client placement

Authoritative modules, persistence adapters and hidden game configuration belong in server-only containers such as `ServerScriptService` or `ServerStorage`. Selected shared schemas and client-safe modules may live in `ReplicatedStorage`. Client presentation belongs in client containers. A package build and Studio example must verify this mapping before release.

Client requests identify an action and permitted parameters. They never set balances, grant items, award XP or declare trusted damage outcomes. The server derives the actor from the connection and validates types, finite numeric bounds, collection sizes, ownership, timing and context before applying an operation. Rate limiting complements these checks.

See Roblox's [client/server security guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary). Static Luau types do not replace runtime validation.

## State and failure behaviour

For initial rule modules, return a new state/result on success and a defined error on expected rejection. A rejected operation leaves the input state unchanged. Caller-supplied definitions and state must not be mutated through returned aliases.

Operations on one player's currency and inventory must run against one authoritative profile revision. Validate and calculate the complete change before committing it. Serialise conflicting operations or use revision checks, and never yield between validation and in-memory commit. External I/O occurs outside that critical section.

An atomic in-memory change is not a durable distributed transaction. Persistence design must separately define when data is saved, how a lost session stops mutations, and what a crash or timeout can lose. Cross-profile trades and payment receipts need separate designs.

Expected input rejection uses stable error codes with documented meanings. Broken programmer invariants may raise errors. Asynchronous adapters must define completion, cancellation, timeout and cleanup behaviour explicitly. No universal promise or event implementation is selected yet.

## Persistence and migration

Prefer an adapter to an existing session-aware backend, subject to dependency review. Store versioned plain-data snapshots. Migrations must be ordered, deterministic, validated and tested with old fixtures. Never overwrite an unreadable profile with defaults automatically.

Persisted definitions use stable IDs; public clients receive only the necessary projection. An unrecoverable load or lost storage session must prevent authoritative mutations rather than silently continuing with an unsaved profile.

## Lifecycle and diagnostics

Adapters must expose explicit start and stop/destroy behaviour. Disconnect events, cancel pending work and release sessions on exit. Test repeated creation/destruction and partial startup failures.

Diagnostics should include operation type, safe correlation identifiers and error codes. Bound log volume. Keep raw remote payloads, credentials and stored player records out of default logs.
