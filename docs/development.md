# Development and release plan

## Current boundary

Only documentation and repository configuration are prepared. There is no executable source, dependency manifest, runtime test harness, Rojo project or CI workflow. Do not create these until the project owner explicitly authorises the implementation stage.

## First implementation sequence

1. Resolve the inventory design's exact API, maximum input sizes and state representation in a short design review.
2. Choose and pin a small toolchain from official releases. Verify it on a clean checkout before documenting commands.
3. Implement inventory validation and pure state transitions with strict types and no engine service dependency.
4. Add meaningful tests for the published operation contracts, invariants and rejected inputs.
5. Add a minimal server-side Studio example and verify client/server placement and module cleanup where relevant.
6. Review the API documentation and run the release gates. Publish the first prerelease only after it contains working software.

## Tooling decisions to verify

| Need | Intended approach | Decision gate |
| --- | --- | --- |
| Source language | Strict Luau | Public types and strict checks pass |
| Studio synchronisation | Rojo project for the first runnable example | Verified engine placement and reproducible build |
| Formatting | StyLua with a pinned configuration/version | Formatter check works on a clean checkout |
| Type analysis | Luau tooling with correct runtime definitions | Standalone and Roblox-specific code analysed in their correct environments |
| Rule tests | Supported Luau runtime and a small maintained runner | Real assertions, repeatable results and failing exit status on failure |
| Engine tests | Roblox Studio server/client integration harness | Reproducible procedure and documented limits on automation |
| Dependencies | Review before choosing Wally or another route | Licence, maintenance, pinning and reproducibility checked |
| CI | Implement verified commands as checks | Executes real checks; no placeholder green badges |

Rojo is the planned source workflow, not a runtime dependency. Do not pin an arbitrary version or choose an archived test framework just because an old tutorial uses it. Headless rule tests cannot establish DataStore or multiplayer correctness in Studio.

## Dependency review

Record the problem solved, upstream maintenance, supported runtime, licence, transitive requirements and exact selected version. Prefer optional adapters around existing primitives. Review ProfileStore as a persistence candidate rather than writing session-locking infrastructure from scratch. No candidate is currently installed or approved as a dependency.

When dependencies are introduced, commit the applicable lockfile and required notices. Verify first-party source rather than copying third-party implementations from tutorials.

## Release gates

The first usable prerelease needs working source, a repeatable toolchain, successful contract tests, correct runtime placement, a verified example, API/error documentation, licence review and a changelog describing the actual change. Document failures and unsupported behaviour.

Adopt semantic versioning once code releases start. Changes to a prerelease API must be recorded explicitly. Publish a release artefact or package only after verifying its contents against its tag. Do not publish a documentation scaffold as a functional module release.

Start with one verified distribution route. Decide separate package versioning when a second package creates a real need; avoid release automation for a collection of empty folders.

## Maintainer work

Use Issues for reproducible defects, design decisions and integration feedback. Use pull requests for reviewable changes. Update examples when APIs change and retain migration notes for released behaviour. Record actual testing environments and feedback with permission. Maintenance claims should be supported by public work, without invented backdated commits or metrics.
