import sys
from task3 import classify_image

if len(sys.argv) != 2:
    print(f"Usage: python3 {sys.argv[0]} <input_file_path>")
    sys.exit(1)

input_file_path = sys.argv[1]

classify_image(input_file_path)
