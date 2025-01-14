import io
import os
import sys

from task12 import mask_image

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding="utf-8")

while True:
    input_file_path = input()
    if input_file_path == "exit":
        break
    output_file_path = input()

    folder = os.path.dirname(output_file_path)

    if folder:
        os.makedirs(folder, exist_ok=True)
    try:
        mask_image(input_file_path, output_file_path)
        print(f"Success: Mask applied and saved successfully to {output_file_path}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

    sys.stdout.flush()
