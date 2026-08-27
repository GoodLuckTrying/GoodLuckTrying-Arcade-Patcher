# Apply patch layout from Patching Layout.csv
# Usage: .\Apply-PatchLayout.ps1 -BuildType <name> -ScriptDir "path"

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('ghoulsmaiden','ghoulsknight','ghoulsumaiden','ghoulsuknight','daimakaimaiden','daimakaiknight')]
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

if (-not ('Crc32Util' -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.IO;
public static class Crc32Util {
    static readonly uint[] Table = MakeTable();
    static uint[] MakeTable() {
        uint[] t = new uint[256];
        for (uint i = 0; i < 256; i++) {
            uint c = i;
            for (int j = 0; j < 8; j++)
                c = ((c & 1) != 0) ? (0xEDB88320u ^ (c >> 1)) : (c >> 1);
            t[i] = c;
        }
        return t;
    }
    public static uint ComputeFile(string path) {
        uint crc = 0xFFFFFFFF;
        using (FileStream fs = File.OpenRead(path)) {
            byte[] buf = new byte[65536];
            int n;
            while ((n = fs.Read(buf, 0, buf.Length)) > 0) {
                for (int i = 0; i < n; i++)
                    crc = Table[(crc ^ buf[i]) & 0xFF] ^ (crc >> 8);
            }
        }
        return crc ^ 0xFFFFFFFF;
    }
}
"@
}

function Get-BpsCrcs {
    param([string]$Path)
    $fs = [IO.File]::OpenRead($Path)
    try {
        if ($fs.Length -lt 16) { return $null }
        $magic = New-Object byte[] 4
        [void]$fs.Read($magic, 0, 4)
        if ([Text.Encoding]::ASCII.GetString($magic) -ne 'BPS1') { return $null }
        [void]$fs.Seek(-12, [IO.SeekOrigin]::End)
        $footer = New-Object byte[] 12
        [void]$fs.Read($footer, 0, 12)
        return @{
            Source = [BitConverter]::ToUInt32($footer, 0)
            Target = [BitConverter]::ToUInt32($footer, 4)
        }
    } finally {
        $fs.Close()
    }
}

function Get-CrcStatus {
    param([string]$BpsPath, [string]$SourcePath, [string]$OutputPath)
    $bpsCrcs = Get-BpsCrcs $BpsPath
    if (-not $bpsCrcs) { return 'CRC ?' }
    $srcOk = ([Crc32Util]::ComputeFile($SourcePath) -eq $bpsCrcs.Source)
    if (-not $OutputPath -or -not (Test-Path $OutputPath)) {
        if ($srcOk) { return 'CRC OK' } else { return 'CRC WRONG' }
    }
    $dstOk = ([Crc32Util]::ComputeFile($OutputPath) -eq $bpsCrcs.Target)
    if ($srcOk -and $dstOk) { return 'CRC OK' }
    return 'CRC WRONG'
}

# Map build type to CSV section name, source folder, patches folder, output folder, and CSV column indices (1-based)
# Columns: 1=source, 2=maiden_bps, 3=maiden_out, 4=knight_bps, 5=knight_out
$config = @{
    ghoulsmaiden   = @{ SECTION = 'ghouls';   ROMS_DIR = 'ghouls';   PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'ghoulsmaiden';   BpsCol = 2; OutCol = 3 }
    ghoulsknight   = @{ SECTION = 'ghouls';   ROMS_DIR = 'ghouls';   PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'ghoulsknight';   BpsCol = 4; OutCol = 5 }
    ghoulsumaiden  = @{ SECTION = 'ghoulsu';  ROMS_DIR = 'ghoulsu';  PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'ghoulsumaiden';  BpsCol = 2; OutCol = 3 }
    ghoulsuknight  = @{ SECTION = 'ghoulsu';  ROMS_DIR = 'ghoulsu';  PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'ghoulsuknight';  BpsCol = 4; OutCol = 5 }
    daimakaimaiden = @{ SECTION = 'daimakai'; ROMS_DIR = 'daimakai'; PATCHES_DIR = 'patches\maiden_artoria'; OUTPUT_DIR = 'daimakaimaiden'; BpsCol = 2; OutCol = 3 }
    daimakaiknight = @{ SECTION = 'daimakai'; ROMS_DIR = 'daimakai'; PATCHES_DIR = 'patches\knight_artoria'; OUTPUT_DIR = 'daimakaiknight'; BpsCol = 4; OutCol = 5 }
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
        $extractDir = Join-Path $env:TEMP "ghouls-patcher-src-$([Guid]::NewGuid().ToString('N'))"
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
        $extractDir = Join-Path $env:TEMP "ghouls-patcher-src-$([Guid]::NewGuid().ToString('N'))"
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
    $tempOutputDir = Join-Path $env:TEMP "ghouls-patcher-out-$([Guid]::NewGuid().ToString('N'))"
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
$sectionNames = @('ghouls', 'ghoulsu', 'daimakai')

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
        [void]$p.StandardOutput.ReadToEnd()
        [void]$p.StandardError.ReadToEnd()
        $p.WaitForExit()
        if ($p.ExitCode -eq 0 -and (Test-Path $outputPath)) {
            $crcNote = Get-CrcStatus $bpsPath $sourcePath $outputPath
            Write-Host "  Patched: $sourceFile + $bpsFile -> $outputFile  $crcNote"
            $patched++
        } else {
            $crcNote = Get-CrcStatus $bpsPath $sourcePath $null
            Write-Host "  [ERROR] Failed to apply $bpsFile to $sourceFile (exit $($p.ExitCode))  $crcNote"
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
