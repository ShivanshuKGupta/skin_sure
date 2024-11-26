import os
import sys

if len(sys.argv) != 3:
    print(f"Usage: python3 {sys.argv[0]} <input_file_path> <output_file_path>")
    sys.exit(1)

input_file_path = sys.argv[1]
output_file_path = sys.argv[2]

folder = os.path.dirname(output_file_path)
if folder:
    os.makedirs(folder, exist_ok=True)

# from task1 import final_segment_image
from task12 import mask_image

mask_image(input_file_path, output_file_path)
