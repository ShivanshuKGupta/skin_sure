def mask_image(input_image_path: str, output_image_path: str) -> None:
    """
    Apply the predicted segmentation mask to the input image (with hair removal)
    and save the masked image to the specified output path.

    Args:
        input_image_path (str): Path to the input image file.
        output_image_path (str): Path to save the masked image.
    """
    #Imports
    import os
    import numpy as np
    import tensorflow as tf
    import cv2

    # Constants
    model_path = "HAM10000_segmentation_model.h5"
    image_size = 224

    # Load the segmentation model
    model = tf.keras.models.load_model(model_path)
    print("Model loaded successfully.")

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
    predicted_mask = (predicted_mask > 0.5).astype(np.uint8)  # Threshold to binary mask

    # Resize predicted mask to the original image size
    predicted_mask_resized = cv2.resize(predicted_mask, (original_size[1], original_size[0]))
    predicted_mask_3ch = cv2.merge([predicted_mask_resized] * 3)  # Convert to 3 channels

    # Apply the mask to the original image
    masked_image = cv2.bitwise_and(image_no_hair, predicted_mask_3ch * 255)

    # Save the masked image
    folder = os.path.dirname(output_image_path)
    if folder:
        os.makedirs(folder, exist_ok=True)
    cv2.imwrite(output_image_path, masked_image)
    print(f"Masked image saved to: {output_image_path}")