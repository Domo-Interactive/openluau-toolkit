# Scope and project boundaries

## Intended users

Independent Roblox developers who need reusable gameplay building blocks and want control over their own game loop, architecture and presentation. Luau is the implementation language. Roblox is the integration target; selected rule modules should be testable without engine services, but portability to every Luau runtime is not promised.

## Public toolkit

Include generic algorithms and policies, configurable definitions, explicit adapter contracts, tests with synthetic fixtures, documentation and small examples with redistributable material.

A feature belongs in the toolkit when its behaviour is understandable without a particular game's story, map, asset collection or balancing. Require at least two meaningfully different configuration scenarios before calling a module genre-independent.

## Private games

Keep proprietary games in separate repositories outside this checkout. They can consume released toolkit versions and implement their own adapters. Game maps, characters, animation, monetisation design, tuning, unpublished business information and player data remain there.

Use a pinned release or commit when a usable version exists. Generalise a private-game improvement before proposing it upstream; remove game-specific assumptions and material the contributor cannot redistribute. Repository ignore rules are local convenience and do not replace this separation.

## Exclusions from the initial release

- A complete game, starter-world asset pack or universal game framework.
- A custom loader, global service locator or compulsory entity-component system.
- A UI framework, renderer, animation library or networking codec.
- Real-money purchases, cross-player trades or cross-server economic transactions.
- A new session-locking persistence engine or general-purpose anti-cheat product.
- Automatic support for every existing framework or package manager.

These exclusions keep the first release independently useful and small enough to validate. Wider systems in the roadmap need their own requirements and evidence before implementation.

## Commercial use

The project's MIT licence permits commercial use of original toolkit material subject to its terms. Keeping game repositories separate does not remove the requirement to preserve applicable notices when distributing toolkit code. Third-party packages and assets retain their own licences.
