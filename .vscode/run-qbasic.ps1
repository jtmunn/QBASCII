param(
    [string]$Program = "QBASCII.BAS"
)

# Only accept .BAS or .QBA files; fall back to default
if ($Program -notmatch '\.(BAS|QBA)$') {
    $Program = "QBASCII.BAS"
}

$launchBoxRoot = "C:\Users\Jeremy\LaunchBox"
$dosbox = Join-Path $launchBoxRoot "ThirdParty\DOSBox\DOSBox.exe"

if (-not (Test-Path $dosbox)) {
    throw "DOSBox not found at $dosbox"
}

$workspaceFolder = Split-Path $PSScriptRoot -Parent
if (-not $workspaceFolder.StartsWith($launchBoxRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Workspace must be inside $launchBoxRoot for this runner."
}

$qbasicDir = Split-Path $workspaceFolder -Parent
$baseConf = Join-Path $launchBoxRoot 'Games\MS-DOS\QBasic.conf'

$qbCommand = if ([string]::IsNullOrWhiteSpace($Program)) {
    'C:\QBASIC.EXE'
} else {
    'C:\QBASIC.EXE /RUN ' + $Program
}

# Copy QBasic.conf and append autoexec commands into a single conf
$runConf = Join-Path $PSScriptRoot 'dosbox-run.conf'
Copy-Item -Path $baseConf -Destination $runConf -Force
$autoexec = @"

[autoexec]
mount c "$qbasicDir"
c:
cd \QBASCII
$qbCommand
"@
Add-Content -Path $runConf -Value $autoexec -NoNewline

Start-Process -FilePath $dosbox -WorkingDirectory (Split-Path $dosbox -Parent) -ArgumentList "-noconsole -conf `"$runConf`""
