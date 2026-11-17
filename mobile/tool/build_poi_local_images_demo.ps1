[CmdletBinding()]
param(
  [string]$SourceDirectory = 'D:\Proyectos\Desarrollo\Ruteo\Imagenes',
  [string]$FlutterCommand = 'flutter',
  [string]$BuildRoot = '',
  [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

$mobileSource = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repoRoot = (Resolve-Path (Join-Path $mobileSource '..')).Path
$sourceRoot = (Resolve-Path $SourceDirectory).Path
if ([string]::IsNullOrWhiteSpace($BuildRoot)) {
  $buildRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("rutea-poi-local-demo-" + [guid]::NewGuid().ToString('N'))
} else {
  $buildRoot = [System.IO.Path]::GetFullPath($BuildRoot)
}
$expected = @(
  @{ Id='02000000-0000-0000-0000-000000000001'; File='Santa rosa de quives.png'; Sha='0EE69A45559A9E4A715F7B4193930EAFB79145D277A9A18D8543D57E4DC592C5' },
  @{ Id='02000000-0000-0000-0000-000000000002'; File='petroglifos de checta.png'; Sha='3B2940F2AD8EC60F0CF877F74F82DC3E307E8843250AF4E55140ED6DCDAB74BE' },
  @{ Id='02000000-0000-0000-0000-000000000003'; File='Plaza de armas de canta.png'; Sha='B09D081FDA65691A1D4BA0EA528B6EB875DFB2145F28846C3ADF7AC31D955858' },
  @{ Id='02000000-0000-0000-0000-000000000004'; File='Plaza de Armas de obrajillo.png'; Sha='D8BA0829948F38CB0DCDAD5520F2059387614D94C0D07311B424DB20DB01FF16' },
  @{ Id='02000000-0000-0000-0000-000000000005'; File='Iglesia San juan Bautista de obrajillo.png'; Sha='14742670885D8F782CA2013908ABEDFA365FB29F249B5F83886C9CCA58E4F875' }
)

function Assert-SourceImage($item) {
  $path = Join-Path $sourceRoot $item.File
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing source image: $($item.File)" }
  $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
  if ($actual -ne $item.Sha) { throw "SHA-256 mismatch for $($item.File): $actual" }
  $image = [System.Drawing.Image]::FromFile($path)
  try {
    if ($image.RawFormat.Guid -ne [System.Drawing.Imaging.ImageFormat]::Png.Guid -or $image.Width -lt 1 -or $image.Height -lt 1) {
      throw "Invalid PNG image: $($item.File)"
    }
  } finally { $image.Dispose() }
  return $path
}

function Copy-MobileProject([string]$destination) {
  New-Item -ItemType Directory -Path $destination -Force | Out-Null
  & robocopy $mobileSource $destination /E /XD .dart_tool build .idea .vscode /NFL /NDL /NJH /NJS /NP | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit code $LASTEXITCODE" }
}

function Invoke-Flutter([string]$workingDirectory, [string[]]$arguments) {
  Push-Location $workingDirectory
  try {
    & $FlutterCommand @arguments
    if ($LASTEXITCODE -ne 0) { throw "flutter $($arguments -join ' ') failed with exit code $LASTEXITCODE" }
  } finally { Pop-Location }
}

function Get-ApkEntries([string]$apkPath) {
  $archive = [System.IO.Compression.ZipFile]::OpenRead($apkPath)
  try {
    $result = @{}
    foreach ($entry in $archive.Entries) {
      if ($entry.FullName.EndsWith('/')) { continue }
      $stream = $entry.Open()
      try {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try { $hash = ([System.BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-', '') }
        finally { $sha.Dispose() }
      } finally { $stream.Dispose() }
      $result[$entry.FullName] = $hash
    }
    return $result
  } finally { $archive.Dispose() }
}

function Assert-StandardApkHasNoPhotos([string]$apkPath) {
  if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) { throw "Missing standard APK: $apkPath" }
  $entries = Get-ApkEntries $apkPath
  foreach ($item in $expected) {
    if ($entries.Values -contains $item.Sha) { throw "Standard APK contains image bytes for $($item.Id)" }
    if ($entries.Keys | Where-Object { $_ -match [regex]::Escape("assets/demo/poi_images/$($item.Id).png") -or $_ -match [regex]::Escape($item.File) }) {
      throw "Standard APK contains a demo photo asset path/name for $($item.Id)"
    }
  }
  Write-Output "STANDARD_APK_ISOLATION_PASS $apkPath"
}

function Assert-DemoApk([string]$apkPath) {
  if (-not (Test-Path -LiteralPath $apkPath -PathType Leaf)) { throw "Missing demo APK: $apkPath" }
  $entries = Get-ApkEntries $apkPath
  $prefix = 'assets/flutter_assets/assets/demo/poi_images/'
  $demoEntries = @($entries.Keys | Where-Object { $_.StartsWith($prefix) })
  if ($demoEntries.Count -ne $expected.Count) { throw "Demo APK has $($demoEntries.Count) demo photo assets; expected exactly $($expected.Count)" }
  foreach ($item in $expected) {
    $entry = "$prefix$($item.Id).png"
    if (-not $entries.ContainsKey($entry)) { throw "Demo APK is missing $entry" }
    if ($entries[$entry] -ne $item.Sha) { throw "Demo APK image hash mismatch for $($item.Id)" }
    if (@($entries.Values | Where-Object { $_ -eq $item.Sha }).Count -ne 1) {
      throw "Demo APK does not contain exactly one copy of image bytes for $($item.Id)"
    }
  }
  $apkHash = (Get-FileHash -LiteralPath $apkPath -Algorithm SHA256).Hash
  $apkSize = (Get-Item -LiteralPath $apkPath).Length
  Write-Output "DEMO_APK_ISOLATION_PASS $apkPath SIZE=$apkSize SHA256=$apkHash"
}

# Validate the closed source inventory before copying the project or starting any build.
$validatedSources = @{}
foreach ($item in $expected) { $validatedSources[$item.Id] = Assert-SourceImage $item }
if ($ValidateOnly) {
  Write-Output 'SOURCE_INVENTORY_VALIDATION_PASS'
  exit 0
}

New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
Write-Output "STAGING_ROOT $buildRoot"

# Standard debug and release artifacts are built from a clean copy without any photo files.
$standardRoot = Join-Path $buildRoot 'standard-mobile'
if (-not (Test-Path -LiteralPath $standardRoot -PathType Container)) {
  Copy-MobileProject $standardRoot
  Invoke-Flutter $standardRoot @('pub', 'get')
}
$standardDebug = Join-Path $standardRoot 'build\app\outputs\flutter-apk\app-debug.apk'
$standardRelease = Join-Path $standardRoot 'build\app\outputs\flutter-apk\app-release.apk'
Invoke-Flutter $standardRoot @('build', 'apk', '--debug')
Assert-StandardApkHasNoPhotos $standardDebug
Invoke-Flutter $standardRoot @('build', 'apk', '--release')
Assert-StandardApkHasNoPhotos $standardRelease

# The internal demo is a separate copy. Images and the pubspec asset declaration never enter the worktree.
$demoRoot = Join-Path $buildRoot 'internal-demo-mobile'
Copy-MobileProject $demoRoot
$assetsRoot = Join-Path $demoRoot 'assets\demo\poi_images'
New-Item -ItemType Directory -Path $assetsRoot -Force | Out-Null
foreach ($item in $expected) {
  $sourcePath = $validatedSources[$item.Id]
  Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $assetsRoot "$($item.Id).png")
}
$pubspec = Join-Path $demoRoot 'pubspec.yaml'
$text = Get-Content -LiteralPath $pubspec -Raw
$needle = '(?m)^(  uses-material-design: true)$'
if ($text -notmatch $needle) { throw 'Could not safely add isolated assets to temporary pubspec.yaml' }
$text = [regex]::Replace($text, $needle, ('$1' + "`n  assets:`n    - assets/demo/poi_images/"), 1)
Set-Content -LiteralPath $pubspec -Value $text -NoNewline -Encoding utf8
Invoke-Flutter $demoRoot @('pub', 'get')
Invoke-Flutter $demoRoot @('test', 'test/features/discovery/presentation/poi_local_demo_images_test.dart', '--dart-define=UI2_POI_LOCAL_IMAGES_DEMO=true')
Invoke-Flutter $demoRoot @('build', 'apk', '--debug', '--dart-define=UI2_POI_LOCAL_IMAGES_DEMO=true')
$demoApk = Join-Path $demoRoot 'build\app\outputs\flutter-apk\app-debug.apk'
Assert-DemoApk $demoApk
Write-Output 'BUILD_ISOLATION=PASS'
