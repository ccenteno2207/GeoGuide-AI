import json
import tempfile
import unittest
import zipfile
from pathlib import Path

from verify_apk_icons import verify


class ApkIconsChecks(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="geoguide-apk-icons-")
        self.addCleanup(self.directory.cleanup)
        self.apk = Path(self.directory.name) / "fixture.apk"
        self.assets = {
            "fonts/MaterialIcons-Regular.otf": b"OTTO" + b"fixture",
            "FontManifest.json": json.dumps(
                [{"family": "MaterialIcons", "fonts": [{"asset": "fonts/MaterialIcons-Regular.otf"}]}]
            ).encode(),
            "AssetManifest.bin": b"fixture",
        }

    def write(self):
        with zipfile.ZipFile(self.apk, "w") as archive:
            for name, content in self.assets.items():
                archive.writestr("assets/flutter_assets/" + name, content)

    def test_complete_bundle_is_accepted(self):
        self.write()
        self.assertEqual(verify(self.apk)["result"], "PASS")

    def test_missing_font_is_rejected(self):
        del self.assets["fonts/MaterialIcons-Regular.otf"]
        self.write()
        with self.assertRaises(KeyError):
            verify(self.apk)

    def test_corrupted_font_is_rejected(self):
        self.assets["fonts/MaterialIcons-Regular.otf"] = b"invalid"
        self.write()
        with self.assertRaises(ValueError):
            verify(self.apk)

    def test_wrong_font_family_is_rejected(self):
        self.assets["FontManifest.json"] = b'[{"family":"Other","fonts":[]}]'
        self.write()
        with self.assertRaises(ValueError):
            verify(self.apk)

    def test_missing_asset_manifest_is_rejected(self):
        del self.assets["AssetManifest.bin"]
        self.write()
        with self.assertRaises(KeyError):
            verify(self.apk)


if __name__ == "__main__":
    unittest.main()
