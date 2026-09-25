# Build outside Documents when Windows Controlled Folder Access blocks AAPT2.
# Leaves Windows protection and the original source tree unchanged.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$mobileRoot = Split-Path -Parent $PSScriptRoot
$stageRoot = Join-Path ([IO.Path]::GetTempPath()) ('deliverpuyo-android-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stageRoot | Out-Null
Write-Host "Temporary workspace and logs: $stageRoot"

# No deletion, cache copying, environment files, or junction traversal.
& robocopy $mobileRoot $stageRoot /E /XJ /XD build .dart_tool .gradle .git /XF '.env' '.env.*' /NFL /NDL /NJH /NJS /NP /R:0 /W:0
if ($LASTEXITCODE -ge 8) { throw "Copy failed: $LASTEXITCODE" }

Push-Location -LiteralPath $stageRoot
try {
    & flutter pub get *> (Join-Path $stageRoot 'pub-get.log')
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed; see $stageRoot\pub-get.log" }
    if ((Get-FileHash -LiteralPath 'pubspec.lock').Hash -ne
        (Get-FileHash -LiteralPath (Join-Path $mobileRoot 'pubspec.lock')).Hash) {
        throw 'Dependency lock changed in the temporary workspace; APK not copied.'
    }
    & flutter build apk --debug *> (Join-Path $stageRoot 'build-debug.log')
    $buildExit = $LASTEXITCODE
    Set-Content -LiteralPath (Join-Path $stageRoot 'build-exit.txt') -Value $buildExit
    Get-Content -LiteralPath (Join-Path $stageRoot 'build-debug.log') -Tail 15
    if ($buildExit -ne 0) { throw "Android build failed ($buildExit); see $stageRoot\build-debug.log" }

    $apkRelativePath = 'build\app\outputs\flutter-apk\app-debug.apk'
    $builtApk = Join-Path $stageRoot $apkRelativePath
    if (!(Test-Path -LiteralPath $builtApk) -or (Get-Item -LiteralPath $builtApk).Length -le 0) {
        throw 'Build did not produce a nonempty APK.'
    }
    $destination = Join-Path $mobileRoot $apkRelativePath
    & robocopy (Split-Path -Parent $builtApk) (Split-Path -Parent $destination) app-debug.apk /NFL /NDL /NJH /NJS /NP /R:0 /W:0
    if ($LASTEXITCODE -ge 8) { throw "APK compiled successfully at $builtApk, but delivery failed ($LASTEXITCODE). Windows protection was not changed." }
    if ((Get-FileHash -LiteralPath $builtApk).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) {
        throw 'APK copy verification failed.'
    }
    Get-Item -LiteralPath $destination | Select-Object FullName, Length
} finally {
    Pop-Location
}
