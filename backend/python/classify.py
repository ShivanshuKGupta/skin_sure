import sys

# from task3 import classify_image
from mobile_net import mobileNetPrediction

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
