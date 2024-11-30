# Imports
import os

import cv2
import numpy as np
import tensorflow as tf

# Constants
model_path = "HAM10000_segmentation_model.h5"
image_size = 224

# Load the segmentation model
model = tf.keras.models.load_model(model_path)
print("Segmentation model loaded!")


# Function to Retain Only the Largest Contiguous Region
def get_largest_contiguous_region(mask, threshold=0.5):
    """
    Post-processes the predicted mask to retain only the largest contiguous region.

    Args:
        mask (numpy.ndarray): The predicted mask from the model (shape: H x W).
        threshold (float): Threshold to binarize the mask.

    Returns:
        numpy.ndarray: Processed mask with only the largest contiguous region.
    """
    # Binarize the mask
    binary_mask = (mask > threshold).astype(np.uint8)

    # Find connected components
    num_labels, labels, stats, _ = cv2.connectedComponentsWithStats(
        binary_mask, connectivity=8
    )

    # Identify the largest component (exclude background, which is label 0)
    largest_label = 1 + np.argmax(
        stats[1:, cv2.CC_STAT_AREA]
    )  # Offset by 1 for the background
    largest_region = (labels == largest_label).astype(np.uint8)

    return largest_region


# Hair removal function
def hair_removal(image):
    """
    Removes hair artifacts from the image using morphological operations.
    """
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (17, 17))
    blackhat = cv2.morphologyEx(gray_image, cv2.MORPH_BLACKHAT, kernel)
    _, hair_mask = cv2.threshold(blackhat, 10, 255, cv2.THRESH_BINARY)
    return cv2.inpaint(image, hair_mask, inpaintRadius=1, flags=cv2.INPAINT_TELEA)


def mask_image(input_image_path: str, output_image_path: str) -> None:
    """
    Apply the predicted segmentation mask to the input image (with hair removal)
    and save the masked image to the specified output path.

    Args:
        input_image_path (str): Path to the input image file.
        output_image_path (str): Path to save the masked image.
    """

    # Load the input image
    image = cv2.imread(input_image_path)
    if image is None:
        raise FileNotFoundError(f"Input image not found at {input_image_path}")
    original_size = image.shape[:2]  # Store original size for later use

    # Hair removal
    image_no_hair = hair_removal(image)

    # Preprocess image for the model
    resized_image = cv2.resize(image_no_hair, (image_size, image_size))
    normalized_image = resized_image / 255.0  # Normalize to [0, 1]
    input_image = np.expand_dims(normalized_image, axis=0)  # Add batch dimension

    # Predict the mask
    predicted_mask = model.predict(input_image)[0]  # Remove batch dimension
    # predicted_mask = (predicted_mask > 0.5).astype(np.uint8)  # Threshold to binary mask
    # Post-process the mask to retain only the largest contiguous region
    predicted_mask = get_largest_contiguous_region(predicted_mask)

    # Resize predicted mask to the original image size
    predicted_mask_resized = cv2.resize(
        predicted_mask, (original_size[1], original_size[0])
    )
    predicted_mask_3ch = cv2.merge(
        [predicted_mask_resized] * 3
    )  # Convert to 3 channels

    # Apply the mask to the original image
    masked_image = cv2.bitwise_and(image_no_hair, predicted_mask_3ch * 255)

    # Save the masked image
    os.makedirs(os.path.dirname(output_image_path), exist_ok=True)
    cv2.imwrite(output_image_path, masked_image)
