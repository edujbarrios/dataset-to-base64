# dataset-to-base64

Convert an image dataset directory into a single Jsonnet file containing Base64-encoded image content and metadata.

## Repository structure

- `dataset_to_base64_jsonnet.ps1`: Main conversion script.
- `examples/sample_dataset_structure.jsonnet`: Example output structure.
- `.gitattributes`: Jsonnet file attributes.

## Requirements

- PowerShell 7+ (recommended)
- Read access to your dataset directory

## Supported image formats

- `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.bmp`, `.tif`, `.tiff`

## Usage

```powershell
./dataset_to_base64_jsonnet.ps1 -DatasetDir "C:\data\images" -OutputFile "C:\out\dataset.jsonnet"
```

Optional parameters:

- `-DatasetName "custom_name"`
- `-IncludeAbsolutePaths`

## Output schema

Generated Jsonnet includes:

- `dataset_name`: Dataset identifier.
- `root`: Root folder name.
- `count`: Number of images converted.
- `samples`: Array of per-image entries (`id`, `file_name`, `rel_path`, `ext`, `mime_type`, `image_base64`, and optional `abs_path`).
- `by_id`: Object map keyed by `id` with `mime_type` and `image_base64`.

See `examples/sample_dataset_structure.jsonnet` for a full sample shape.

## Notes

- Output is written as UTF-8 without BOM.
- Files are discovered recursively and sorted by full path.
