"""Install the pinned official Luau command-line tools for development checks."""

import hashlib
import io
import os
from pathlib import Path
import platform
import urllib.request
import zipfile

VERSION = "0.748"
ASSETS = {
    "Linux": ("luau-ubuntu.zip", "e6905c04dbccaeff54ca4986b0017f125db5aa301bcb34d0446355cbfee5bc83"),
    "Darwin": ("luau-macos.zip", "1f9f958573901cf24c2149124ace9322d5ec590e041f12833176a940888c399f"),
    "Windows": ("luau-windows.zip", "072b06454fb0fa5c355a6aaae361a01c4d35d120a37d0fe4fd1a880a9ffebeab"),
}


def main():
    system = platform.system()
    if system not in ASSETS:
        raise SystemExit(f"Unsupported system: {system}. Install Luau {VERSION} manually.")
    if system == "Linux" and platform.machine() not in ("x86_64", "AMD64"):
        raise SystemExit("The official Ubuntu binaries require x86-64. Build Luau from source on this architecture.")
    asset, expected = ASSETS[system]
    url = f"https://github.com/luau-lang/luau/releases/download/{VERSION}/{asset}"
    request = urllib.request.Request(url, headers={"User-Agent": "OpenLuau-Toolkit-development"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != expected:
        raise SystemExit("Luau archive checksum mismatch; nothing installed.")
    destination = Path(__file__).resolve().parents[1] / ".tools" / "luau"
    destination.mkdir(parents=True, exist_ok=True)
    suffix = ".exe" if system == "Windows" else ""
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        for name in ("luau", "luau-analyze"):
            filename = name + suffix
            target = destination / filename
            target.write_bytes(archive.read(filename))
            if os.name != "nt":
                target.chmod(0o755)
    print(f"Installed official Luau {VERSION} tools in {destination}")


if __name__ == "__main__":
    main()
