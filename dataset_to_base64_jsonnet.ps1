<#
.SYNOPSIS
Converts an entire image dataset into Base64 and writes it to a Jsonnet file.

.DESCRIPTION
Recursively scans a dataset directory, reads each supported image as binary,
encodes it as Base64, and writes all entries into a single .jsonnet file.

.PARAMETER DatasetDir
Root directory containing images.

.PARAMETER OutputFile
Path to the output .jsonnet file.

.PARAMETER DatasetName
Optional dataset name. Defaults to the dataset directory name.

.PARAMETER IncludeAbsolutePaths
If set, includes abs_path for each sample.

.EXAMPLE
.\dataset_to_base64_jsonnet.ps1 -DatasetDir "C:\data\images" -OutputFile "C:\out\dataset.jsonnet"

.EXAMPLE
.\dataset_to_base64_jsonnet.ps1 -DatasetDir "C:\data\images" -OutputFile "C:\out\dataset.jsonnet" -DatasetName "benchmark_images"

.EXAMPLE
.\dataset_to_base64_jsonnet.ps1 -DatasetDir "C:\data\images" -OutputFile "C:\out\dataset.jsonnet" -IncludeAbsolutePaths
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DatasetDir,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$OutputFile,

    [Parameter(Mandatory = $false)]
    [string]$DatasetName = "",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeAbsolutePaths
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-MimeType {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    switch -Regex ($Path.ToLowerInvariant()) {
        '\.jpg$|\.jpeg$' { return 'image/jpeg' }
        '\.png$'         { return 'image/png' }
        '\.gif$'         { return 'image/gif' }
        '\.webp$'        { return 'image/webp' }
        '\.bmp$'         { return 'image/bmp' }
        '\.tif$|\.tiff$' { return 'image/tiff' }
        default          { return 'application/octet-stream' }
    }
}

function Get-ExtensionLower {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $ext = [System.IO.Path]::GetExtension($Path)
    if ([string]::IsNullOrWhiteSpace($ext)) {
        return ""
    }

    return $ext.TrimStart('.').ToLowerInvariant()
}

function Convert-FileToBase64 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    return [System.Convert]::ToBase64String($bytes)
}

function ConvertTo-QuotedJsonString {
    param(
        [AllowNull()]
        [string]$Value
    )

    return ($Value | ConvertTo-Json -Compress)
}

if (-not (Test-Path -LiteralPath $DatasetDir -PathType Container)) {
    throw "Dataset directory does not exist: $DatasetDir"
}

$datasetFullPath = [System.IO.Path]::GetFullPath($DatasetDir)

if ([string]::IsNullOrWhiteSpace($DatasetName)) {
    $DatasetName = Split-Path -Path $datasetFullPath -Leaf
}

$supportedExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.tif', '.tiff')

$files = Get-ChildItem -LiteralPath $datasetFullPath -Recurse -File |
    Where-Object { $_.Extension.ToLowerInvariant() -in $supportedExtensions } |
    Sort-Object FullName

if (-not $files -or $files.Count -eq 0) {
    throw "No supported image files were found under: $DatasetDir"
}

$outputDirectory = Split-Path -Path $OutputFile -Parent
if (-not [string]::IsNullOrWhiteSpace($outputDirectory) -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$sampleEntries = New-Object System.Collections.Generic.List[string]
$byIdEntries = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    $fullPath = $file.FullName
    $relativePath = [System.IO.Path]::GetRelativePath($datasetFullPath, $fullPath).Replace('\', '/')
    $fileName = $file.Name
    $extension = Get-ExtensionLower -Path $fullPath
    $mimeType = Get-MimeType -Path $fullPath
    $base64Content = Convert-FileToBase64 -Path $fullPath

    $sampleLines = New-Object System.Collections.Generic.List[string]
    $sampleLines.Add("    {")
    $sampleLines.Add("      id: $(ConvertTo-QuotedJsonString $relativePath),")
    $sampleLines.Add("      file_name: $(ConvertTo-QuotedJsonString $fileName),")
    $sampleLines.Add("      rel_path: $(ConvertTo-QuotedJsonString $relativePath),")
    if ($IncludeAbsolutePaths) {
        $sampleLines.Add("      abs_path: $(ConvertTo-QuotedJsonString $fullPath),")
    }
    $sampleLines.Add("      ext: $(ConvertTo-QuotedJsonString $extension),")
    $sampleLines.Add("      mime_type: $(ConvertTo-QuotedJsonString $mimeType),")
    $sampleLines.Add("      image_base64: $(ConvertTo-QuotedJsonString $base64Content)")
    $sampleLines.Add("    }")
    $sampleEntries.Add(($sampleLines -join "`n"))

    $byIdLines = New-Object System.Collections.Generic.List[string]
    $byIdLines.Add("    [$(ConvertTo-QuotedJsonString $relativePath)]: {")
    $byIdLines.Add("      mime_type: $(ConvertTo-QuotedJsonString $mimeType),")
    $byIdLines.Add("      image_base64: $(ConvertTo-QuotedJsonString $base64Content)")
    $byIdLines.Add("    }")
    $byIdEntries.Add(($byIdLines -join "`n"))
}

$rootValue = Split-Path -Path $datasetFullPath -Leaf

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("{")
$lines.Add("  dataset_name: $(ConvertTo-QuotedJsonString $DatasetName),")
$lines.Add("  root: $(ConvertTo-QuotedJsonString $rootValue),")
$lines.Add("  count: $($files.Count),")
$lines.Add("  samples: [")

for ($i = 0; $i -lt $sampleEntries.Count; $i++) {
    if ($i -lt $sampleEntries.Count - 1) {
        $lines.Add($sampleEntries[$i] + ",")
    }
    else {
        $lines.Add($sampleEntries[$i])
    }
}

$lines.Add("  ],")
$lines.Add("  by_id: {")

for ($i = 0; $i -lt $byIdEntries.Count; $i++) {
    if ($i -lt $byIdEntries.Count - 1) {
        $lines.Add($byIdEntries[$i] + ",")
    }
    else {
        $lines.Add($byIdEntries[$i])
    }
}

$lines.Add("  }")
$lines.Add("}")

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($OutputFile, ($lines -join "`n"), $utf8NoBom)

Write-Host "Done. Converted $($files.Count) images to Base64 and wrote:"
Write-Host $OutputFile
