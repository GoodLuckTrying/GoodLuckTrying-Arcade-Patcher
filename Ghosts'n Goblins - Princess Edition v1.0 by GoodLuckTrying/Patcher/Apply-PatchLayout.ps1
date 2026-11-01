param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'gngprincess', 'gngprincessa', 'gngprincessb', 'gngprincessc', 'gngprincesst',
        'makprincess', 'makprincessb', 'makprincessc', 'makprincessg',
        'gngprincessenh', 'gngprincessaenh', 'gngprincessbenh', 'gngprincesscenh',
        'gngprincesstenh', 'makprincessenh', 'makprincessbenh', 'makprincesscenh',
        'makprincessgenh'
    )]
    [string]$BuildType,

    [Parameter(Mandatory = $true)]
    [string]$ScriptDir,

    [Parameter(Mandatory = $false)]
    [ValidateSet('folder', 'zip')]
    [string]$OutputMode = 'folder',

    [Parameter(Mandatory = $false)]
    [string]$OutputRoot
)

$ErrorActionPreference = 'Stop'
$ScriptDir = (Resolve-Path -LiteralPath $ScriptDir).Path
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = $ScriptDir
} else {
    if (-not (Test-Path -LiteralPath $OutputRoot)) {
        New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
    }
    $OutputRoot = (Resolve-Path -LiteralPath $OutputRoot).Path
}

$builds = @{
    gngprincess       = 'gng'
    gngprincessa      = 'gnga'
    gngprincessb      = 'gngb'
    gngprincessc      = 'gngc'
    gngprincesst      = 'gngt'
    makprincess       = 'makaimur'
    makprincessb      = 'makaimurb'
    makprincessc      = 'makaimurc'
    makprincessg      = 'makaimurg'
    gngprincessenh    = 'gng'
    gngprincessaenh   = 'gnga'
    gngprincessbenh   = 'gngb'
    gngprincesscenh   = 'gngc'
    gngprincesstenh   = 'gngt'
    makprincessenh    = 'makaimur'
    makprincessbenh   = 'makaimurb'
    makprincesscenh   = 'makaimurc'
    makprincessgenh   = 'makaimurg'
}

$sourceFolder = $builds[$BuildType]
$layoutPath = Join-Path $ScriptDir 'Patching Layout.csv'
$flipsPath = Join-Path $ScriptDir 'flips.exe'
$patchesDir = Join-Path $ScriptDir 'patches\princess'
$sourceFolderPath = Join-Path $ScriptDir $sourceFolder
$sourceZipPath = Join-Path $ScriptDir "$sourceFolder.zip"
$outputFolder = Join-Path $OutputRoot $BuildType
$outputZip = Join-Path $OutputRoot "$BuildType.zip"
$tempSourceFolder = $null
$tempOutputFolder = $null

foreach ($requiredPath in @($layoutPath, $flipsPath, $patchesDir)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required patcher file or directory not found: $requiredPath"
    }
}

$sections = @{}
$currentSection = $null
$currentRows = [System.Collections.ArrayList]@()
$sectionNames = @($builds.Values | Sort-Object -Unique)

foreach ($line in Get-Content -LiteralPath $layoutPath) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        if ($currentSection) {
            $sections[$currentSection] = @($currentRows.ToArray())
            $currentSection = $null
            $currentRows = [System.Collections.ArrayList]@()
        }
        continue
    }

    $columns = @($line.Split(',') | ForEach-Object { $_.Trim() })
    if ($columns.Count -eq 5 -and $columns[0] -in $sectionNames) {
        if ($currentSection) {
            $sections[$currentSection] = @($currentRows.ToArray())
        }
        $currentSection = $columns[0]
        $currentRows = [System.Collections.ArrayList]@()
        continue
    }

    if (-not $currentSection -or $columns.Count -ne 5 -or [string]::IsNullOrWhiteSpace($columns[0])) {
        throw "Invalid patch layout row in ${layoutPath}: $line"
    }
    [void]$currentRows.Add($columns)
}
if ($currentSection) {
    $sections[$currentSection] = @($currentRows.ToArray())
}

$rows = @($sections[$sourceFolder])
if ($rows.Count -eq 0) {
    throw "No ROM layout entries found for '$BuildType' (section '$sourceFolder') in $layoutPath"
}

if (Test-Path -LiteralPath $sourceFolderPath -PathType Container) {
    $sourceDirectory = $sourceFolderPath
} elseif (Test-Path -LiteralPath $sourceZipPath -PathType Leaf) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $tempSourceFolder = Join-Path ([System.IO.Path]::GetTempPath()) "gng-patcher-source-$([Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $tempSourceFolder | Out-Null
    [System.IO.Compression.ZipFile]::ExtractToDirectory($sourceZipPath, $tempSourceFolder)
    $sourceDirectory = $tempSourceFolder
} else {
    throw "Source ROMs not found. Expected '$sourceFolderPath' or '$sourceZipPath'."
}

if ($OutputMode -eq 'zip') {
    $tempOutputFolder = Join-Path ([System.IO.Path]::GetTempPath()) "gng-patcher-output-$([Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $tempOutputFolder | Out-Null
    $outputDirectory = $tempOutputFolder
} else {
    if (-not (Test-Path -LiteralPath $outputFolder)) {
        New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
    }
    $outputDirectory = $outputFolder
}

try {
    $copied = 0
    $patched = 0
    if ($BuildType.EndsWith('enh')) {
        $patchColumn = 3
        $outputColumn = 4
    } else {
        $patchColumn = 1
        $outputColumn = 2
    }

    foreach ($row in $rows) {
        $sourceFile = $row[0]
        $patchFile = $row[$patchColumn]
        $outputFile = $row[$outputColumn]
        if ([string]::IsNullOrWhiteSpace($sourceFile) -or [string]::IsNullOrWhiteSpace($outputFile)) {
            throw "Invalid layout row for '$BuildType': source and output filenames are required."
        }

        $sourcePath = Join-Path $sourceDirectory $sourceFile
        $outputPath = Join-Path $outputDirectory $outputFile
        if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
            throw "Source ROM not found: $sourcePath"
        }

        if ([string]::IsNullOrWhiteSpace($patchFile)) {
            Copy-Item -LiteralPath $sourcePath -Destination $outputPath -Force
            $copied++
            continue
        }

        $patchPath = Join-Path $patchesDir $patchFile
        if (-not (Test-Path -LiteralPath $patchPath -PathType Leaf)) {
            throw "BPS patch not found: $patchPath"
        }

        if (Test-Path -LiteralPath $outputPath) {
            Remove-Item -LiteralPath $outputPath -Force
        }
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $flipsPath
        $processInfo.Arguments = '--apply "' + $patchPath + '" "' + $sourcePath + '" "' + $outputPath + '"'
        $processInfo.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::Start($processInfo)
        $process.WaitForExit()
        $exitCode = $process.ExitCode
        $process.Dispose()
        if ($exitCode -ne 0 -or -not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
            throw "Failed to apply '$patchPath' to '$sourcePath' (Flips exit code $exitCode)."
        }
        $patched++
    }

    if ($OutputMode -eq 'zip') {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        if (Test-Path -LiteralPath $outputZip) {
            Remove-Item -LiteralPath $outputZip -Force
        }
        [System.IO.Compression.ZipFile]::CreateFromDirectory($outputDirectory, $outputZip)
        Write-Host "[OK] Created zip: $outputZip"
    }

    Write-Host "[$BuildType] $copied copied, $patched patched."
} finally {
    if ($tempSourceFolder -and (Test-Path -LiteralPath $tempSourceFolder)) {
        Remove-Item -LiteralPath $tempSourceFolder -Recurse -Force
    }
    if ($tempOutputFolder -and (Test-Path -LiteralPath $tempOutputFolder)) {
        Remove-Item -LiteralPath $tempOutputFolder -Recurse -Force
    }
}
