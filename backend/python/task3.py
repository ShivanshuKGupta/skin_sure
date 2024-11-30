import os

import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import img_to_array, load_img

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

model = tf.keras.models.load_model("efficientnet_finetuned.keras")
print("Classification model loaded!")


def classify_image(image_path):
    def preprocess_image(image_path, target_size):
        img = load_img(image_path, target_size=target_size)
        img_array = img_to_array(img)
        img_array = img_array / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        return img_array

    preprocessed_image = preprocess_image(image_path, target_size=(300, 300))
    tf.get_logger().setLevel("ERROR")
    predictions = model.predict(preprocessed_image, verbose=0)
    predicted_class = np.argmax(predictions, axis=1)
    labelMappings = {
        0: "akiec",
        1: "bcc",
        2: "bkl",
        3: "df",
        4: "mel",
        5: "nv",
        6: "vasc",
    }
    return labelMappings[predicted_class[0]]
