# Planned module catalogue

Everything in this catalogue is a design target. No implementation is available. Modules will have their own public types, configuration reference, errors, lifecycle notes and supported-runtime statement when built.

| Module | Included responsibility | Outside its responsibility | Key validation |
| --- | --- | --- | --- |
| Inventory | Definition lookup, stack limits, bounded capacity, add/remove/move | UI, trading, persistence and world pickups | Quantity conservation, unchanged state on rejection |
| Equipment | Configurable slots and item compatibility | Character visuals or forced Roblox Tool usage | Slot conflicts and atomic unequip/equip |
| Progression | XP bounds, configured thresholds, level caps | Reward storage and user interface | Exact boundaries, multi-level gains, invalid curves |
| Damage | Eligibility and damage policy, explicit result | Animation, universal hit detection and lag compensation | Dead targets, unauthorised actors, non-finite inputs |
| Economy | Bounded integer currency and purchase planning | Real-money billing or distributed trading | Overflow, repeat requests, full inventory and stale state |
| Player data | Schema versions, migrations and backend integration | A replacement storage platform or global leaderboard | Session loss, failed load/save, old schemas |
| Networking | Runtime schemas, authorisation hooks and request limits | A new serialisation protocol or complete anti-cheat | Oversized payloads, spoofed identity and request flooding |
| Quests/achievements | Configurable objectives, progress and completion policy | Genre-specific quest content | Duplicate events, repeated rewards and schema changes |
| NPCs/pathfinding | Scheduling, cancellation and blocked-path recovery | Bespoke combat AI or a universal movement controller | Invalid paths, despawn, contention and cleanup |
| Diagnostics/test support | Deterministic fixtures and safe, bounded instrumentation | Hosted analytics service | Repeatability and absence of sensitive payloads |

## Cross-module scenario

A generic shop can connect the inventory, economy, networking and player-data adapters. A client sends an item ID and quantity. The server validates the request and obtains price and eligibility from authoritative configuration. One application operation calculates the currency and inventory change against the same player profile, then the persistence adapter saves that versioned state according to its documented policy.

That example will need to distinguish an in-memory success from a durable save. It must not claim cross-server atomicity or exactly-once execution. The first inventory milestone stays independent of this later integration.

## Documentation required for each implementation

Explain the smallest setup, exported values and types, accepted ranges, configuration, failure results, state ownership, complexity limits, lifecycle and tested environments. Include a runnable minimal example and at least one rejected operation. Describe what the module does not guarantee.
