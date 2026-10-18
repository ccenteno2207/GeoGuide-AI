"""Check the local name normalizer against Unicode 17 NFD conformance vectors.

Development-only verification using Python stdlib and the installed Dart SDK.
No data is fetched by the app, no dependency is added, and no repo file is edited.
"""

import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request


def download(name):
    url = f"https://www.unicode.org/Public/17.0.0/ucd/{name}"
    data = urllib.request.urlopen(url, timeout=60).read()
    print(f"{name} SHA256={hashlib.sha256(data).hexdigest()}")
    return data.decode("utf-8")


def main():
    rows = [line.split(";") for line in download("UnicodeData.txt").splitlines()]
    marks = {int(row[0], 16) for row in rows if row[2].startswith("M")}
    vectors = []
    for line in download("NormalizationTest.txt").splitlines():
        line = line.split("#")[0].strip()
        if not line or line.startswith("@"):
            continue
        columns = [list(map(lambda x: int(x, 16), value.split()))
                   for value in line.split(";")[:5]]
        for source, expected in [(0, 2), (1, 2), (2, 2), (3, 4), (4, 4)]:
            vectors.append([
                "".join(map(chr, columns[source])),
                "".join(chr(cp) for cp in columns[expected] if cp not in marks),
            ])
    task_temp = Path(tempfile.mkdtemp(prefix="geoguide-ui2-unicode-"))
    (task_temp / "vectors.json").write_text(json.dumps(vectors), encoding="utf-8")
    normalizer = (Path(__file__).resolve().parent.parent / "lib/features/discovery/presentation/unicode_name_normalization.dart").as_uri()
    runner = task_temp / "verify.dart"
    runner.write_text("""
import 'dart:convert';
import 'dart:io';
import 'NORMALIZER';
void main(List<String> args) {
  final vectors = jsonDecode(File(args.single).readAsStringSync()) as List;
  for (var i = 0; i < vectors.length; i++) {
    final row = vectors[i] as List;
    final expected = (row[1] as String).trim().replaceAll(RegExp(r'\\s+'), ' ').toLowerCase();
    if (normalizePoiName(row[0] as String) != expected) {
      throw StateError('NFD conformance failure at vector $i');
    }
  }
  print('PASS: ${vectors.length} official NFD + mark-removal vectors');
}
""".replace("NORMALIZER", normalizer), encoding="utf-8")
    subprocess.run([shutil.which("dart"), str(runner), str(task_temp / "vectors.json")], check=True)


if __name__ == "__main__":
    main()
