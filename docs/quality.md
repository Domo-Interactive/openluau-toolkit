# Quality and validation plan

This is a validation design. There are currently no runtime tests, CI runs, benchmark results or verified game integrations.

## Checks by layer

| Layer | Required evidence before release |
| --- | --- |
| Documentation/configuration | Resolved relative links, parseable configuration, accurate status and preserved attribution |
| Pure rules | Strict type checks; deterministic success, rejection and boundary tests |
| State composition | All-or-nothing mutations, consistent profile revisions and no unexpected yielding during commit |
| Roblox adapters | Studio verification of service behaviour, server/client boundaries, startup, cancellation and cleanup |
| Persistence | Fault injection plus Studio/backend integration, old-schema fixtures, session loss and shutdown handling |
| Network requests | Runtime payload validation, ownership checks, bounded work and flood/replay cases |

## First-module tests

Use the [inventory acceptance scenarios](design/inventory.md) as behaviour contracts. Add generated bounded operation sequences to check conservation and no mutation on rejection where useful. Keep fixtures deterministic and failures reproducible. Tests must verify observable behaviour rather than copy the implementation's internal loops.

Invalid numeric cases include NaN, infinity, fractional values and values outside documented bounds. Check input aliases by retaining old state and mutating returned values. Test sparse slot storage explicitly.

## Integration fault cases

- Player disconnects during a pending operation.
- Profile fails to load, becomes unavailable or loses its active session.
- Save is throttled or times out; shutdown has limited remaining time.
- Client repeats, floods or alters requests, including a forged actor ID or price.
- Two server actions read the same profile revision and attempt conflicting updates.
- A migration throws, encounters an unknown schema or receives malformed stored data.
- A subscription, remote handler or path operation survives its owning object's destruction.

Specify the expected outcome before implementation. Do not treat a simulated backend as proof of platform behaviour, or describe an in-memory transaction as a durable guarantee.

## Performance and results

Set supported workload limits before claiming performance. Measure module version, runtime/Studio version, fixture size, procedure and observed results. Avoid comparative speed claims without reproducible measurements.

A validation record must say what ran, where it ran, the revision and the result. Mark unavailable checks as not run. Documentation review is not runtime validation; a passing CI status must correspond to real executed checks.
