$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
$template = Join-Path $root '.godot-web-runtime\AppData\Roaming\Godot\export_templates\4.7.2.stable\web_nothreads_release.zip'
if (-not (Test-Path -LiteralPath $godot)) { throw "Godot 4.7.2 console executable not found: $godot" }
if (-not (Test-Path -LiteralPath $template)) { throw "Godot Web template not found: $template" }
$env:APPDATA = Join-Path $root '.godot-web-runtime\AppData\Roaming'
$env:LOCALAPPDATA = Join-Path $root '.godot-web-runtime\AppData\Local'
& $godot --headless --path $root --export-release 'Web' 'web-export/index.html'
if ($LASTEXITCODE -ne 0) { throw "Godot Web export failed with exit code $LASTEXITCODE" }
Write-Host "Web export ready: $(Join-Path $root 'web-export\index.html')"
