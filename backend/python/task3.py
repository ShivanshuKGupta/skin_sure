import os
import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing.image import load_img, img_to_array

# Suppress TensorFlow logs
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # Suppresses info and warning messages

# Load the trained EfficientNetB3 model
model = tf.keras.models.load_model("efficientnet_finetuned.keras")

def classify_image(image_path):

# Function to preprocess the image
    def preprocess_image(image_path, target_size):
        # Load the image
        img = load_img(image_path, target_size=target_size)
        # Convert the image to an array
        img_array = img_to_array(img)
        # Normalize pixel values to [0, 1]
        img_array = img_array / 255.0
        # Add a batch dimension
        img_array = np.expand_dims(img_array, axis=0)
        return img_array

    # Preprocess the image (EfficientNetB3 expects input size 300x300)
    preprocessed_image = preprocess_image(image_path, target_size=(300, 300))

    # Disable the progress bar
    tf.get_logger().setLevel('ERROR')  # Suppresses TensorFlow logs during prediction

    # Get predictions
    predictions = model.predict(preprocessed_image, verbose=0)

    # Interpret the predictions
    predicted_class = np.argmax(predictions, axis=1)

    labelMappings = {0: 'akiec', 1: 'bcc', 2: 'bkl', 3: 'df', 4: 'mel', 5: 'nv', 6: 'vasc'}
    print(labelMappings[predicted_class[0]])
