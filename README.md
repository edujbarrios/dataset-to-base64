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

## Jsonnet structure specification

### Root object

| Field | Type | Description |
| --- | --- | --- |
| `dataset_name` | string | Dataset identifier (from `-DatasetName` or dataset folder name). |
| `root` | string | Root folder name of the scanned dataset directory. |
| `count` | number | Total number of converted image files. |
| `samples` | array<object> | Per-image entries with metadata and Base64 content. |
| `by_id` | object | Map keyed by `id` (`rel_path`) for direct lookup. |

### `samples[]` item

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `id` | string | Yes | Image identifier using normalized relative path (`/`). |
| `file_name` | string | Yes | Original file name. |
| `rel_path` | string | Yes | Relative path from dataset root. |
| `abs_path` | string | No | Absolute path when `-IncludeAbsolutePaths` is used. |
| `ext` | string | Yes | Lowercase extension without leading dot. |
| `mime_type` | string | Yes | MIME type derived from extension. |
| `image_base64` | string | Yes | Full Base64 image payload. |

### `by_id` entry

Each key is the same value as `samples[].id` and points to:

| Field | Type | Description |
| --- | --- | --- |
| `mime_type` | string | MIME type for the image. |
| `image_base64` | string | Full Base64 image payload. |

## Author

- Eduardo Barrios (GitHub: [@edujbarrios](https://github.com/edujbarrios))

## Notes

- Output is written as UTF-8 without BOM.
- Files are discovered recursively and sorted by full path.
