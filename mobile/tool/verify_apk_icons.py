"""Read-only verification of packaged Material icons; Python standard library only."""

import argparse
import hashlib
import json
import zipfile
from pathlib import Path


def verify(apk: Path) -> dict:
    prefix = "assets/flutter_assets/"
    with zipfile.ZipFile(apk) as archive:
        font = archive.read(prefix + "fonts/MaterialIcons-Regular.otf")
        if font[:4] != b"OTTO":
            raise ValueError("Invalid MaterialIcons OpenType signature")
        manifest = json.loads(archive.read(prefix + "FontManifest.json"))
        if not any(
            family.get("family") == "MaterialIcons"
            and any(
                item.get("asset") == "fonts/MaterialIcons-Regular.otf"
                for item in family.get("fonts", [])
            )
            for family in manifest
        ):
            raise ValueError("MaterialIcons is not declared in FontManifest")
        if not archive.read(prefix + "AssetManifest.bin"):
            raise ValueError("Empty AssetManifest.bin")
        return {
            "result": "PASS",
            "material_font_bytes": len(font),
            "flutter_assets": sum(name.startswith(prefix) for name in archive.namelist()),
            "sha256": hashlib.sha256(apk.read_bytes()).hexdigest().upper(),
        }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    args = parser.parse_args()
    try:
        print(json.dumps(verify(args.apk)))
    except (OSError, KeyError, ValueError, zipfile.BadZipFile) as error:
        parser.exit(1, f"FAIL: {error}\n")
