# Example

[basic.luau](basic.luau) is a working standalone integration of all four modules. It creates a bag, equips a sword, buys two potions, awards level-up experience and resolves shielded damage.

Run `python3 scripts/bootstrap.py`, then `python3 scripts/check.py` from the repository root. To run just the example on Linux/macOS after installation, use `.tools/luau/luau examples/basic.luau`.

The example's string-path requires target the standalone Luau CLI. In Roblox Studio, replace those lines with references to the corresponding ModuleScript Instances; see [usage](../docs/usage.md). A Studio demonstration has not been run.

The example keeps all state in memory, uses synthetic definitions and resets on exit. It does not include a user interface, networking, persistent data, real-money purchases or proprietary game material.
