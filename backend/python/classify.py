import io
import sys

# from task3 import classify_image
from mobile_net import mobileNetPrediction

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding="utf-8")

while True:
    input_file_path = input()
    if input_file_path == "exit":
        break
    try:
        # print(classify_image(input_file_path))
        label = mobileNetPrediction(input_file_path)
        print(f"PREDICTION:{label}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
    sys.stdout.flush()
