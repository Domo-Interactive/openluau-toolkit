# Decision 0001: independently usable gameplay modules

Status: accepted and used for the initial four rule modules. Broader engine integrations remain outside the current scope.

## Context

The long-term scope includes many gameplay systems. Implementing the whole catalogue at once would make it difficult to validate individual behaviour or explain what a developer must adopt. Existing projects already supply frameworks and infrastructure primitives.

## Decision

Begin with an inventory rule module and define explicit contracts before adding engine adapters. Keep each gameplay module independently usable where its responsibility permits. Use explicit dependency injection and composition in the consuming game. Keep authoritative integration on the server. Evaluate existing persistence and utility libraries before adding equivalent infrastructure.

Use one repository to keep related documentation and reviews together. Defer package manifests, tool versions, release automation and a shared runtime core until working code creates a need.

## Consequences

Developers retain control over presentation, game loop and preferred framework. Rule modules can be exercised deterministically. Integration examples and adapters require deliberate work rather than being hidden behind a universal loader. The project must define ownership, cleanup and cross-module consistency explicitly.

The initial inventory scope omits unique equipment metadata, trading and persistence. Configurable equipment-slot rules are included. These need later designs. Breadth remains a roadmap objective rather than a first-release requirement.

## Alternatives considered

- A framework-wide service locator: offers a uniform lifecycle but imposes adoption and initialisation conventions.
- A mandatory ECS: useful for some games but unnecessary for the first inventory rule contract.
- Implementing all systems together: provides breadth at the cost of reviewable, demonstrable correctness.
- Replacing established utility and persistence libraries: adds maintenance obligations without a demonstrated use-case advantage.

Revisit the decision when real integration evidence shows a boundary is unhelpful. Record the reason and compatibility consequences of any change.
