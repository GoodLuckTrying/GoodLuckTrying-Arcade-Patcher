# Apply patch layout from Patching Layout.csv
# Usage: .\Apply-PatchLayout.ps1 -BuildType <name> -ScriptDir "path"

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet(
        'gngmaiden','gngknight','gngmaidena','gngknighta','gngmaidenb','gngknightb',
        'gngmaidenc','gngknightc','gngmaident','gngknightt',
        'makmaiden','makknight','makmaidenb','makknightb','makmaidenc','makknightc','makmaideng','makknightg',
        'gngmaidenenh','gngknightenh','gngmaidenaenh','gngknightaenh','gngmaidenbenh','gngknightbenh',
        'gngmaidencenh','gngknightcenh','gngmaidentenh','gngknighttenh',
        'makmaidenenh','makknightenh','makmaidenbenh','makknightbenh','makmaidencenh','makknightcenh','makmaidengenh','makknightgenh'
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

# Map build type to CSV section name, source folder, patches folder, output folder, and CSV column indices (1-based)
# Columns: 1=source, 2=maiden_bps, 3=maiden_out, 4=knight_bps, 5=knight_out
$config = @{
    gngmaiden    = @{ SECTION = 'gng';      ROMS_DIR = 'gng';      PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaiden';    BpsCol = 2; OutCol = 3 }
    gngknight    = @{ SECTION = 'gng';      ROMS_DIR = 'gng';      PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknight';    BpsCol = 4; OutCol = 5 }
    gngmaidena   = @{ SECTION = 'gnga';     ROMS_DIR = 'gnga';    PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidena';   BpsCol = 2; OutCol = 3 }
    gngknighta   = @{ SECTION = 'gnga';     ROMS_DIR = 'gnga';    PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknighta';   BpsCol = 4; OutCol = 5 }
    gngmaidenb   = @{ SECTION = 'gngb';     ROMS_DIR = 'gngb';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidenb';   BpsCol = 2; OutCol = 3 }
    gngknightb   = @{ SECTION = 'gngb';     ROMS_DIR = 'gngb';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightb';   BpsCol = 4; OutCol = 5 }
    gngmaidenc   = @{ SECTION = 'gngc';     ROMS_DIR = 'gngc';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidenc';   BpsCol = 2; OutCol = 3 }
    gngknightc   = @{ SECTION = 'gngc';     ROMS_DIR = 'gngc';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightc';   BpsCol = 4; OutCol = 5 }
    gngmaident   = @{ SECTION = 'gngt';     ROMS_DIR = 'gngt';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaident';   BpsCol = 2; OutCol = 3 }
    gngknightt   = @{ SECTION = 'gngt';     ROMS_DIR = 'gngt';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightt';   BpsCol = 4; OutCol = 5 }
    makmaiden    = @{ SECTION = 'makaimur'; ROMS_DIR = 'makaimur'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaiden';    BpsCol = 2; OutCol = 3 }
    makknight    = @{ SECTION = 'makaimur'; ROMS_DIR = 'makaimur'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknight';    BpsCol = 4; OutCol = 5 }
    makmaidenb   = @{ SECTION = 'makaimurb'; ROMS_DIR = 'makaimurb'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaidenb';  BpsCol = 2; OutCol = 3 }
    makknightb   = @{ SECTION = 'makaimurb'; ROMS_DIR = 'makaimurb'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightb';  BpsCol = 4; OutCol = 5 }
    makmaidenc   = @{ SECTION = 'makaimurc'; ROMS_DIR = 'makaimurc'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaidenc';  BpsCol = 2; OutCol = 3 }
    makknightc   = @{ SECTION = 'makaimurc'; ROMS_DIR = 'makaimurc'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightc';  BpsCol = 4; OutCol = 5 }
    makmaideng   = @{ SECTION = 'makaimurg'; ROMS_DIR = 'makaimurg'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaideng';  BpsCol = 2; OutCol = 3 }
    makknightg   = @{ SECTION = 'makaimurg'; ROMS_DIR = 'makaimurg'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightg';  BpsCol = 4; OutCol = 5 }

    # Enhanced Artoria outputs — same stock sources as non-enh (gng, gnga, ...)
    gngmaidenenh    = @{ SECTION = 'gngenh';      ROMS_DIR = 'gng';      PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidenenh';    BpsCol = 2; OutCol = 3 }
    gngknightenh    = @{ SECTION = 'gngenh';      ROMS_DIR = 'gng';      PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightenh';    BpsCol = 4; OutCol = 5 }
    gngmaidenaenh   = @{ SECTION = 'gngaenh';     ROMS_DIR = 'gnga';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidenaenh';   BpsCol = 2; OutCol = 3 }
    gngknightaenh   = @{ SECTION = 'gngaenh';     ROMS_DIR = 'gnga';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightaenh';   BpsCol = 4; OutCol = 5 }
    gngmaidenbenh   = @{ SECTION = 'gngbenh';     ROMS_DIR = 'gngb';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidenbenh';   BpsCol = 2; OutCol = 3 }
    gngknightbenh   = @{ SECTION = 'gngbenh';     ROMS_DIR = 'gngb';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightbenh';   BpsCol = 4; OutCol = 5 }
    gngmaidencenh   = @{ SECTION = 'gngcenh';     ROMS_DIR = 'gngc';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidencenh';   BpsCol = 2; OutCol = 3 }
    gngknightcenh   = @{ SECTION = 'gngcenh';     ROMS_DIR = 'gngc';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknightcenh';   BpsCol = 4; OutCol = 5 }
    gngmaidentenh   = @{ SECTION = 'gngtenh';     ROMS_DIR = 'gngt';     PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'gngmaidentenh';   BpsCol = 2; OutCol = 3 }
    gngknighttenh   = @{ SECTION = 'gngtenh';     ROMS_DIR = 'gngt';     PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'gngknighttenh';   BpsCol = 4; OutCol = 5 }
    makmaidenenh    = @{ SECTION = 'makaimurenh'; ROMS_DIR = 'makaimur'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaidenenh';    BpsCol = 2; OutCol = 3 }
    makknightenh    = @{ SECTION = 'makaimurenh'; ROMS_DIR = 'makaimur'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightenh';    BpsCol = 4; OutCol = 5 }
    makmaidenbenh   = @{ SECTION = 'makaimurbenh'; ROMS_DIR = 'makaimurb'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaidenbenh';  BpsCol = 2; OutCol = 3 }
    makknightbenh   = @{ SECTION = 'makaimurbenh'; ROMS_DIR = 'makaimurb'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightbenh';  BpsCol = 4; OutCol = 5 }
    makmaidencenh   = @{ SECTION = 'makaimurcenh'; ROMS_DIR = 'makaimurc'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaidencenh';  BpsCol = 2; OutCol = 3 }
    makknightcenh   = @{ SECTION = 'makaimurcenh'; ROMS_DIR = 'makaimurc'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightcenh';  BpsCol = 4; OutCol = 5 }
    makmaidengenh   = @{ SECTION = 'makaimurgenh'; ROMS_DIR = 'makaimurg'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'makmaidengenh';  BpsCol = 2; OutCol = 3 }
    makknightgenh   = @{ SECTION = 'makaimurgenh'; ROMS_DIR = 'makaimurg'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'makknightgenh';  BpsCol = 4; OutCol = 5 }
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

# Parse CSV: rows grouped by first-column section
$lines = Get-Content $csvPath
$sections = @{}
$currentSection = $null
$currentRows = [System.Collections.ArrayList]@()
$sectionNames = @(
    'gng','gng1','makaimur','gnga','gngb','gngc','gngt','makaimurb','makaimurc','makaimurg',
    'gngenh','gngaenh','gngbenh','gngcenh','gngtenh','makaimurenh','makaimurbenh','makaimurcenh','makaimurgenh'
)

foreach ($line in $lines) {
    if ($line -match '^\s*$') {
        if ($currentSection) {
            $sections[$currentSection] = @($currentRows.ToArray())
            $currentRows = [System.Collections.ArrayList]@()
            $currentSection = $null
        }
        continue
    }
    $cols = @(($line -split ',') | ForEach-Object { $_.Trim() })
    if ($cols.Count -ge 5) {
        $first = $cols[0]
        if ($first -in $sectionNames) {
            if ($currentSection) {
                $sections[$currentSection] = @($currentRows.ToArray())
                $currentRows = [System.Collections.ArrayList]@()
            }
            $currentSection = $first
            continue
        }
        if ($currentSection) {
            [void]$currentRows.Add($cols)
        }
    }
}
if ($currentSection) {
    $sections[$currentSection] = @($currentRows.ToArray())
}

$rows = $sections[$sectionName]
if (-not $rows -or $rows.Count -eq 0) {
    Write-Error "No rows found in CSV for section: $sectionName"
}

# Create output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "[OK] Created output folder: $outputDir"
} else {
    Write-Host "Output folder: $outputDir"
}

$bpsCol = $cfg.BpsCol - 1
$outCol = $cfg.OutCol - 1
$srcCol = 0

$copied = 0
$patched = 0
$errors = 0

foreach ($row in $rows) {
    $sourceFile = $row[$srcCol]
    $bpsFile   = $row[$bpsCol]
    $outputFile = $row[$outCol]
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
