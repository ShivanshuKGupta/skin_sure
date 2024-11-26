import os
import shutil
import sys

if len(sys.argv) != 3:
    print(f"Usage: python3 {sys.argv[0]} <input_file_path> <output_file_path>")
    sys.exit(1)

input_file_path = sys.argv[1]
output_file_path = sys.argv[2]

os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

# write code to segment the input file

shutil.copyfile(input_file_path, output_file_path)
