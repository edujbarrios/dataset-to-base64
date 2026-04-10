Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetScript = Join-Path -Path $scriptDirectory -ChildPath "scripts/dataset_to_base64_jsonnet.ps1"

if (-not (Test-Path -LiteralPath $targetScript -PathType Leaf)) {
    throw "Target script not found: $targetScript"
}

& $targetScript @args
