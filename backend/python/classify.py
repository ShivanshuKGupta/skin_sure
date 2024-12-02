import sys

from task3 import classify_image

while True:
    input_file_path = input()
    if input_file_path == "exit":
        break
    try:
        print(classify_image(input_file_path))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
    sys.stdout.flush()
