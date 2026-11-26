# Development and maintenance

## Current scope

The project owner authorised small implementations of inventory/equipment, progression, combat and economy, with basic checks and usage instructions. Those four rule modules now exist. Networking, persistence, interfaces, Studio demonstrations, tagged prereleases and external feedback are outside this stage.

## Reproduce the checks

Install Python 3, then run these commands from a clean checkout:

```sh
python3 scripts/bootstrap.py
python3 scripts/check.py
```

The installer pins official Luau **0.748**, verifies its archive SHA-256 checksum and installs only the interpreter and analyser into the ignored `.tools/luau` directory. It has platform entries for Linux, macOS and Windows; execution was checked on Linux x86-64. To use a manually installed toolchain instead, put `luau` and `luau-analyze` on PATH. When `.tools/luau` exists, it takes priority.

The check command analyses every Luau source, example and test file, runs 22 behaviour scenarios and runs the combined example. The same commands are configured in a read-only GitHub Actions job, with checkout pinned to an exact upstream commit.

## Implementation choices

- Each gameplay module is one source file, with strict exported types and no runtime dependencies.
- Returned records and nested state/configuration are frozen. Mutations return new state, with stable error strings for expected rejection.
- Inventory uses sparse, bounded slot indexes; equippable items have stack size one.
- Progression accepts explicit cumulative thresholds and emits reward descriptions for levels crossed by the current operation.
- Combat performs numeric resolution with a caller-supplied permission decision; it does not detect hits.
- Economy injects a pure inventory function rather than importing a mandatory framework or package loader.

The [API guides](../packages/README.md) and [usage guide](usage.md) give exact contracts and limitations. No shared runtime kernel, custom networking layer or persistence engine was introduced.

## Make a focused change

Start from a reproducible defect or a concrete reusable need. Update the smallest relevant module and its documentation. Add a behaviour check when it protects a real contract, then run the check command. Report what actually ran. Keep future proprietary games and their configuration in separate repositories.

API changes are currently unreleased and must be noted in the changelog. Do not add a release number, package-manager manifest or compatibility claim without verifying the corresponding distribution. Studio verification, broader integration tests and a formal prerelease can be added when useful; they are not compulsory prerequisites for submitting an accurate programme application.
