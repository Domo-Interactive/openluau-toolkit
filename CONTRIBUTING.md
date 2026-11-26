# Contributing

The initial implementation covers inventory/equipment, progression, combat and economy. Focused fixes, documentation corrections and concrete use cases are welcome. Discuss additional systems or dependencies before expanding the scope.

## Propose and review a change

1. Explain the developer problem and observable expected behaviour in an issue or pull request.
2. Make one coherent change using Australian English in documentation.
3. Keep gameplay rules independent of Roblox services, presentation and unrelated modules.
4. Update the module's API/error documentation and add a meaningful regression check when behaviour changes.
5. Run `python3 scripts/check.py` and report actual results. State any checks not run.
6. Preserve applicable licences and confirm that contributed material can be distributed under the repository's MIT licence.

Install the pinned development tools with `python3 scripts/bootstrap.py`. The [development guide](docs/development.md) describes the workflow. Studio integration and a formal release are not required for each change to these pure rule modules.

## Code expectations

Use strict Luau types, explicit configuration and bounded inputs. Existing module states and results are immutable; mutations return new state or an expected error without changing the input. Keep dictionary iteration deterministic where it affects observable output.

The economy inventory adapter must be pure, synchronous and non-yielding. Progression rewards are descriptions for the consuming game to apply alongside the new state. Do not add hidden storage, remotes, global state or automatic background work.

Use synthetic data. Keep credentials, private application materials, proprietary game code/assets and player records outside this repository. Do not imply production validation, upstream endorsement or adoption without evidence.

A maintainer reviews changes before merging. No fixed response time is promised. Use [SECURITY.md](SECURITY.md) for vulnerabilities and keep discussion specific and respectful.
