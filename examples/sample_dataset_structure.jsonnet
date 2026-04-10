{
  dataset_name: "my_dataset",
  root: "my_dataset",
  count: 2,
  samples: [
    {
      id: "class_a/image_001.jpg",
      file_name: "image_001.jpg",
      rel_path: "class_a/image_001.jpg",
      ext: "jpg",
      mime_type: "image/jpeg",
      image_base64: "<base64-content>"
    },
    {
      id: "class_b/image_002.png",
      file_name: "image_002.png",
      rel_path: "class_b/image_002.png",
      ext: "png",
      mime_type: "image/png",
      image_base64: "<base64-content>"
    }
  ],
  by_id: {
    ["class_a/image_001.jpg"]: {
      mime_type: "image/jpeg",
      image_base64: "<base64-content>"
    },
    ["class_b/image_002.png"]: {
      mime_type: "image/png",
      image_base64: "<base64-content>"
    }
  }
}
