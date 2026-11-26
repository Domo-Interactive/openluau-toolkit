# Changelog

No version has been released. Changes below describe the initial implementation, without implying a published package or production validation.

## Unreleased

### Added

- Standalone strict Luau inventory/equipment, progression, combat and economy modules.
- Immutable state transitions, bounded values, stable rejection codes and configurable gameplay rules.
- Consistent shop purchase results through an injected inventory operation.
- Module API documentation and a combined command-line example.
- Pinned official Luau 0.748 development tools with SHA-256 verification.
- Strict analysis and 22 basic behaviour tests, with a GitHub Actions workflow for the same checks.
- Initial architecture, scope, ecosystem research, contribution templates and MIT licence.

### Validation

Strict analysis, all 22 behaviour tests and the command-line example pass on Linux x86-64. Roblox Studio, multiplayer, persistence and production use have not been validated. No runtime dependencies or third-party implementation code are bundled.
