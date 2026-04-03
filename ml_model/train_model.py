import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
import tensorflow as tf
import numpy as np

# Load dataset
data = pd.read_csv("ml_model/Crop_recommendation.csv")

# Features and labels
X = data[['N','P','K','temperature','humidity','ph','rainfall']]
y = data['label']

# Encode crop names
encoder = LabelEncoder()
y_encoded = encoder.fit_transform(y)

# Train test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y_encoded, test_size=0.2, random_state=42
)

# Train model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Accuracy
accuracy = model.score(X_test, y_test)
print("Model accuracy:", accuracy)

# Convert to TensorFlow model
input_layer = tf.keras.Input(shape=(7,))
x = tf.keras.layers.Dense(32, activation="relu")(input_layer)
x = tf.keras.layers.Dense(32, activation="relu")(x)
output_layer = tf.keras.layers.Dense(len(encoder.classes_), activation="softmax")(x)

tf_model = tf.keras.Model(input_layer, output_layer)

tf_model.compile(
    optimizer="adam",
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"]
)

tf_model.fit(X_train, y_train, epochs=50)

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(tf_model)
tflite_model = converter.convert()

# Save model
with open("crop_model.tflite", "wb") as f:
    f.write(tflite_model)

print("TFLite model created!")