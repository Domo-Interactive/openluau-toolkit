# Contributing

The project is currently defining its architecture and first useful module. Documentation corrections, concrete use cases and design reviews are welcome. Game-system implementation is paused until the project owner explicitly authorises that stage.

## Propose a change

Open an issue explaining the developer problem, an example of the expected behaviour and why an existing library or a smaller change would not address it. For a new module or dependency, discuss the design before writing an implementation.

Keep proposals genre-independent. Use fictional item identifiers and synthetic data. Do not include private game assets, player records or proprietary code.

## Prepare a pull request

1. Fork the repository and create a focused branch.
2. Make one coherent change with documentation in Australian English.
3. Describe the resulting behaviour and any compatibility consequences.
4. Record checks actually performed, including their environment and outcome. State when a check was not run.
5. Confirm that you can contribute the material under the repository's MIT licence. Preserve any required third-party notices.

A maintainer reviews changes before merging. A proposal or pull request does not imply a commitment to implement or provide a response within a fixed period.

## Documentation review

Check relative links, current/planned status, terminology and source attribution. Do not present proposed APIs as callable functions. Research documents should link to primary sources and distinguish upstream facts from project decisions.

## Implementation standards for the authorised stage

- Use `--!strict` for Luau source and exported types for public interfaces.
- Keep module initialisation free of implicit network, persistence or global game-state changes.
- Accept dependencies explicitly; keep the dependency graph acyclic.
- Define expected failures, bounds, cleanup and server/client access.
- Include behaviour tests for edge cases and misuse. Cover engine interactions in Roblox Studio separately.
- Add an example only when it works with the documented version.

The [development plan](docs/development.md) and [quality plan](docs/quality.md) define the intended checks. Tool versions, commands and CI will be introduced and verified when implementation is authorised; no runtime checks are currently configured.

## Discussion and reporting

Keep reviews specific and respectful. Address behaviour and evidence. Use the repository's Issues tab for ordinary defects or proposals. Follow the [security policy](SECURITY.md) for vulnerabilities.
