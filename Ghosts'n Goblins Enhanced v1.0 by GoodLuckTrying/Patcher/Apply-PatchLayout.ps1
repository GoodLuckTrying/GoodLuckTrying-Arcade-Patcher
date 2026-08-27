# Apply patch layout from Patching Layout.csv
# Builds Enhanced romsets from vanilla stock ROMs + BPS patches in patches\
# Usage: .\Apply-PatchLayout.ps1 -BuildType <name> -ScriptDir "path"

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet(
        'gngenh','gngaenh','gngbenh','gngcenh','gngtenh',
        'makaimurenh','makaimurbenh','makaimurcenh','makaimurgenh'
    )]
    [string]$BuildType,

    [Parameter(Mandatory=$true)]
    [string]$ScriptDir,

    [Parameter(Mandatory=$false)]
    [ValidateSet('folder', 'zip')]
    [string]$OutputMode = 'folder'
)

$ErrorActionPreference = 'Stop'
$ScriptDir = $ScriptDir.TrimEnd('\')
$csvPath = Join-Path $ScriptDir "Patching Layout.csv"
$flipsPath = Join-Path $ScriptDir "flips.exe"

if (-not (Test-Path $flipsPath)) {
    Write-Error "flips.exe not found at: $flipsPath"
}
if (-not (Test-Path $csvPath)) {
    Write-Error "Patching Layout.csv not found at: $csvPath"
}

# Map build type to CSV section, vanilla source folder, patches folder, and output folder
# CSV columns: 1=source, 2=bps (empty = copy), 3=output name
$config = @{
    gngenh       = @{ SECTION = 'gngenh';       ROMS_DIR = 'gng';      PATCHES_DIR = 'patches'; OUTPUT_DIR = 'gngenh' }
    gngaenh      = @{ SECTION = 'gngaenh';      ROMS_DIR = 'gnga';     PATCHES_DIR = 'patches'; OUTPUT_DIR = 'gngaenh' }
    gngbenh      = @{ SECTION = 'gngbenh';      ROMS_DIR = 'gngb';     PATCHES_DIR = 'patches'; OUTPUT_DIR = 'gngbenh' }
    gngcenh      = @{ SECTION = 'gngcenh';      ROMS_DIR = 'gngc';     PATCHES_DIR = 'patches'; OUTPUT_DIR = 'gngcenh' }
    gngtenh      = @{ SECTION = 'gngtenh';      ROMS_DIR = 'gngt';     PATCHES_DIR = 'patches'; OUTPUT_DIR = 'gngtenh' }
    makaimurenh  = @{ SECTION = 'makaimurenh';  ROMS_DIR = 'makaimur'; PATCHES_DIR = 'patches'; OUTPUT_DIR = 'makaimurenh' }
    makaimurbenh = @{ SECTION = 'makaimurbenh'; ROMS_DIR = 'makaimurb'; PATCHES_DIR = 'patches'; OUTPUT_DIR = 'makaimurbenh' }
    makaimurcenh = @{ SECTION = 'makaimurcenh'; ROMS_DIR = 'makaimurc'; PATCHES_DIR = 'patches'; OUTPUT_DIR = 'makaimurcenh' }
    makaimurgenh = @{ SECTION = 'makaimurgenh'; ROMS_DIR = 'makaimurg'; PATCHES_DIR = 'patches'; OUTPUT_DIR = 'makaimurgenh' }
}

$cfg = $config[$BuildType]
$sectionName = $cfg.SECTION
$romsBaseName = $cfg.ROMS_DIR
$outputBaseName = $cfg.OUTPUT_DIR
$romsFolder = Join-Path $ScriptDir $romsBaseName
$romsZip = Join-Path $ScriptDir "$romsBaseName.zip"
$patchesDir = Join-Path $ScriptDir $cfg.PATCHES_DIR
$outputDir = Join-Path $ScriptDir $outputBaseName
$outputZip = Join-Path $ScriptDir "$outputBaseName.zip"
$tempRomsDir = $null
$tempOutputDir = $null

function Resolve-RomSource {
    param(
        [string]$FolderPath,
        [string]$ZipPath,
        [switch]$PreferZip
    )

    if ($PreferZip -and (Test-Path $ZipPath)) {
        $extractDir = Join-Path $env:TEMP "gng-patcher-src-$([Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $extractDir | Out-Null
        Write-Host "Source: zip $ZipPath (extracted to temp)"
        Expand-Archive -Path $ZipPath -DestinationPath $extractDir -Force
        $script:tempRomsDir = $extractDir
        return $extractDir
    }
    if (Test-Path $FolderPath) {
        Write-Host "Source: folder $FolderPath"
        return $FolderPath
    }
    if (Test-Path $ZipPath) {
        $extractDir = Join-Path $env:TEMP "gng-patcher-src-$([Guid]::NewGuid().ToString('N'))"
        New-Item -ItemType Directory -Path $extractDir | Out-Null
        Write-Host "Source: zip $ZipPath (extracted to temp)"
        Expand-Archive -Path $ZipPath -DestinationPath $extractDir -Force
        $script:tempRomsDir = $extractDir
        return $extractDir
    }

    Write-Error "Source ROMs not found. Expected folder '$FolderPath' or zip '$ZipPath'"
}

function Write-RomZip {
    param([string]$SourceDir, [string]$ZipPath)

    if (Test-Path $ZipPath) {
        Remove-Item $ZipPath -Force
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir, $ZipPath)
    Write-Host "[OK] Created zip: $ZipPath"
}

if ($OutputMode -eq 'folder') {
    $romsDir = Resolve-RomSource -FolderPath $romsFolder -ZipPath $romsZip
    Write-Host "Output: folder $outputDir"
} else {
    $romsDir = Resolve-RomSource -FolderPath $romsFolder -ZipPath $romsZip -PreferZip
    $tempOutputDir = Join-Path $env:TEMP "gng-patcher-out-$([Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $tempOutputDir | Out-Null
    $outputDir = $tempOutputDir
    Write-Host "Output: zip $outputZip (building in temp folder)"
}
if (-not (Test-Path $patchesDir)) {
    Write-Error "Patches folder not found: $patchesDir"
}

# Parse CSV: 3 columns (source, bps, out); section header rows use section name in col 1
$lines = Get-Content $csvPath
$sections = @{}
$currentSection = $null
$currentRows = [System.Collections.ArrayList]@()
$sectionNames = @(
    'gngenh','gngaenh','gngbenh','gngcenh','gngtenh','makaimurenh','makaimurbenh','makaimurcenh','makaimurgenh'
)

foreach ($line in $lines) {
    if ($line -match '^\s*$' -or $line -match '^,,\s*$') {
        if ($currentSection) {
            $sections[$currentSection] = @($currentRows.ToArray())
            $currentRows = [System.Collections.ArrayList]@()
            $currentSection = $null
        }
        continue
    }
    $cols = @(($line -split ',') | ForEach-Object { $_.Trim() })
    if ($cols.Count -lt 1) { continue }
    $first = $cols[0]
    if ($first -in $sectionNames) {
        if ($currentSection) {
            $sections[$currentSection] = @($currentRows.ToArray())
            $currentRows = [System.Collections.ArrayList]@()
        }
        $currentSection = $first
        continue
    }
    if ($currentSection -and $cols.Count -ge 3 -and $first) {
        [void]$currentRows.Add($cols)
    }
}
if ($currentSection) {
    $sections[$currentSection] = @($currentRows.ToArray())
}

$rows = $sections[$sectionName]
if (-not $rows -or $rows.Count -eq 0) {
    Write-Error "No rows found in CSV for section: $sectionName"
}

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "[OK] Created output folder: $outputDir"
} else {
    Write-Host "Output folder: $outputDir"
}

$copied = 0
$patched = 0
$errors = 0

foreach ($row in $rows) {
    $sourceFile = $row[0]
    $bpsFile    = $row[1]
    $outputFile = $row[2]
    if (-not $sourceFile) { continue }
    if ([string]::IsNullOrWhiteSpace($outputFile)) { $outputFile = $sourceFile }

    $sourcePath = Join-Path $romsDir $sourceFile
    $outputPath = Join-Path $outputDir $outputFile

    if (-not (Test-Path $sourcePath)) {
        Write-Host "  [SKIP] Source not found: $sourceFile"
        continue
    }

    if ([string]::IsNullOrWhiteSpace($bpsFile) -or $bpsFile -eq '?') {
        Copy-Item -Path $sourcePath -Destination $outputPath -Force
        Write-Host "  Copied: $sourceFile -> $outputFile"
        $copied++
    } else {
        $bpsPath = Join-Path $patchesDir $bpsFile
        if (-not (Test-Path $bpsPath)) {
            Write-Host "  [ERROR] Patch not found: $bpsFile"
            $errors++
            continue
        }
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $flipsPath
        $psi.Arguments = " --apply `"$bpsPath`" `"$sourcePath`" `"$outputPath`""
        $psi.UseShellExecute = $false
        $psi.RedirectStandardError = $true
        $psi.RedirectStandardOutput = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        $p.WaitForExit()
        if ($p.ExitCode -eq 0 -and (Test-Path $outputPath)) {
            Write-Host "  Patched: $sourceFile + $bpsFile -> $outputFile"
            $patched++
        } else {
            Write-Host "  [ERROR] Failed to apply $bpsFile to $sourceFile (exit $($p.ExitCode))"
            $errors++
        }
    }
}

Write-Host ""
Write-Host "Summary: $copied copied, $patched patched, $errors error(s)"

if ($errors -eq 0 -and $OutputMode -eq 'zip') {
    try {
        Write-RomZip -SourceDir $outputDir -ZipPath $outputZip
    } catch {
        Write-Host "[ERROR] Failed to create zip: $outputZip"
        Write-Host $_.Exception.Message
        $errors++
    }
}

if ($tempRomsDir -and (Test-Path $tempRomsDir)) {
    Remove-Item $tempRomsDir -Recurse -Force -ErrorAction SilentlyContinue
}
if ($tempOutputDir -and (Test-Path $tempOutputDir)) {
    Remove-Item $tempOutputDir -Recurse -Force -ErrorAction SilentlyContinue
}

if ($errors -gt 0) { exit 1 }
exit 0
