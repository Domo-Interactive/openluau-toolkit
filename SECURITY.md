# Security policy

No executable modules or supported runtime releases exist yet. The design's use of server authority is a requirement for future implementation, not evidence of a security audit.

## Reporting

Use GitHub's **Report a vulnerability** option on this repository's Security tab if private vulnerability reporting is enabled. Include the affected version, a minimal reproduction, impact and any suggested mitigation. Use synthetic data and a place you control.

If that option is unavailable, open an issue asking the maintainer to establish a private reporting channel. Do not include exploit instructions or sensitive details in that public request. There is no dedicated security email address or response-time commitment at this stage.

Ordinary documentation defects can be reported through Issues.

## Intended boundaries

The server will own inventory, currency, damage and progression outcomes. Future modules must validate runtime values, authorisation and request frequency. Luau type annotations alone do not validate remote messages. See the [architecture](docs/architecture.md) and [quality plan](docs/quality.md).
