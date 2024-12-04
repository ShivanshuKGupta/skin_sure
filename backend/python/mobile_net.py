import cv2
import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.preprocessing import LabelEncoder
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.models import load_model

# Load metadata and initialize Label Encoder
metadata_file = "augment_data/augmented_metadata.csv"
metadata = pd.read_csv(metadata_file)
label_encoder = LabelEncoder()
label_encoder.fit(metadata["dx"])
image_size = 224

# Register Custom Metrics
custom_metrics = {}

for i in range(len(label_encoder.classes_)):

    def class_accuracy(y_true, y_pred, class_index=i):
        class_pred = tf.argmax(y_pred, axis=-1)
        class_true = tf.argmax(y_true, axis=-1)
        class_mask = tf.equal(class_true, class_index)
        acc = tf.reduce_mean(
            tf.cast(
                tf.equal(
                    class_pred[class_mask],
                    tf.cast(class_true[class_mask], tf.int64),
                ),
                tf.float32,
            )
        )
        return acc

    # Ensure each function is uniquely named and registered
    metric_name = f"accuracy_class_{i}"
    class_accuracy.__name__ = metric_name
    tf.keras.utils.register_keras_serializable(package="Custom")(class_accuracy)
    custom_metrics[metric_name] = class_accuracy

# Paths to models
segmentation_model_path = "augment_data/HAM10000_segmentation_model.h5"
classification_model_path = "augment_data/new_mobilenet_classification_model.keras"

# Load Models
segmentation_model = tf.keras.models.load_model(segmentation_model_path)
classification_model = load_model(
    classification_model_path,
    custom_objects=custom_metrics,  # Provide the registered custom metrics
)

print("Models loaded successfully!")


def mobileNetPrediction(image_path) -> str:

    # Preprocessing Functions
    def hair_removal(image):
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (17, 17))
        blackhat = cv2.morphologyEx(gray_image, cv2.MORPH_BLACKHAT, kernel)
        _, hair_mask = cv2.threshold(blackhat, 10, 255, cv2.THRESH_BINARY)
        return cv2.inpaint(image, hair_mask, inpaintRadius=1, flags=cv2.INPAINT_TELEA)

    def preprocess_image(image_path):
        image = cv2.imread(image_path)
        image = cv2.resize(hair_removal(image), (image_size, image_size))
        image = cv2.resize(image, (image_size, image_size))
        return image / 255.0  # Normalize to [0, 1]

    def get_largest_contiguous_region(mask, threshold=0.5):
        binary_mask = (mask > threshold).astype(np.uint8)
        num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(
            binary_mask, connectivity=8
        )
        largest_label = 1 + np.argmax(
            stats[1:, cv2.CC_STAT_AREA]
        )  # Offset by 1 for background
        largest_region = (labels == largest_label).astype(np.uint8)
        return largest_region

    # Prediction Pipeline
    def predict_classification(image_path):
        # Preprocess image
        input_image = preprocess_image(image_path)
        # Ensure input_image is in float32 and within range [0, 1]
        input_image = input_image.astype(np.float32)

        input_image_expanded = np.expand_dims(input_image, axis=0)

        # Generate mask using segmentation model
        predicted_mask = segmentation_model.predict(input_image_expanded)[0, :, :, 0]
        largest_region_mask = get_largest_contiguous_region(predicted_mask)
        largest_region_mask_resized = cv2.resize(
            largest_region_mask, (image_size, image_size)
        )
        largest_region_mask_3ch = cv2.merge([largest_region_mask_resized] * 3)

        # Combine image and mask
        largest_region_mask_3ch = (
            largest_region_mask_3ch.astype(np.float32) / 255.0
        )  # Normalize to [0, 1]
        largest_region_mask_3ch = cv2.resize(
            largest_region_mask_3ch, (input_image.shape[1], input_image.shape[0])
        )

        combined_image = cv2.addWeighted(
            input_image, 0.8, largest_region_mask_3ch, 0.2, 0
        )

        # Preprocess inputs for classification model
        input_image_preprocessed = preprocess_input(
            np.expand_dims(input_image * 255.0, axis=0)
        )
        combined_image_preprocessed = preprocess_input(
            np.expand_dims(combined_image * 255.0, axis=0)
        )

        # Predict using classification model
        predictions = classification_model.predict(
            [input_image_preprocessed, combined_image_preprocessed]
        )
        predicted_label = label_encoder.inverse_transform([np.argmax(predictions)])

        # Class probabilities
        class_probabilities = dict(zip(label_encoder.classes_, predictions[0]))

        return predicted_label[0], class_probabilities

    predicted_label, class_probabilities = predict_classification(image_path)

    print("Predicted label:", predicted_label)
    print("\nClass probabilities:")
    for cls, prob in class_probabilities.items():
        print(f"{cls}: {prob:.4f}")
    return predicted_label


# image_path = "augment_data/augmented_images/ISIC_0033670_aug_5063.jpg"
# mobileNetPrediction(image_path)
