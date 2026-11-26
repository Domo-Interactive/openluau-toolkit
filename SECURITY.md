# Security policy

The current source implements pure gameplay rules for inventory, progression, combat and economy. It is unreleased and has not been security-audited or validated in production.

## Integration boundary

Keep state, catalogues, definitions and permission decisions on the server. The modules validate operation values and freeze their returned records. They expect states/configuration created by their constructors; arbitrary deserialised or client-supplied tables must not be treated as trusted state.

The modules do not authenticate remote requests, detect hits, enforce attack cooldowns, prevent replay, manage storage sessions or provide persistent transactions. `canDamage` is an input from trusted game logic, not proof of authorisation. Apply progression rewards while committing the corresponding new progression state.

The injected shop inventory function must be pure, synchronous and non-yielding. Callers must commit the returned wallet and inventory together and serialise conflicting operations. A mutating adapter breaks the stated failure guarantees.

See [usage](docs/usage.md) and [quality](docs/quality.md) for the implemented guarantees and checks.

## Reporting

Use GitHub's **Report a vulnerability** option if private reporting is enabled on this repository. Include the revision, a minimal reproduction with synthetic data and the impact.

If that option is unavailable, open an issue asking for a private reporting channel without including exploit instructions or sensitive details. There is no dedicated security email or response-time commitment at this stage. Ordinary defects can use the bug-report form.
