# AgroVision Flutter App

Fully offline Flutter Android app with local crop recommendation, yield prediction, and season suggestion.

## Key points

- No API calls, no internet dependency.
- Dataset embedded at `assets/dataset/crop_dataset.csv`.
- Model files embedded at:
  - `assets/models/crop_model.tflite`
  - `assets/models/yield_model.tflite`
- If model loading fails, fallback local prediction logic uses dataset nearest-neighbor + agronomic rules.

## Build

1. Install Flutter SDK.
2. In `mobile_app`, run:
   - `flutter pub get`
   - `flutter create .` (only needed once to generate Android platform folders if absent)
   - `flutter build apk`

## Project structure

- `lib/screens/prediction_screen.dart`
- `lib/screens/analytics_screen.dart`
- `lib/widgets/input_card.dart`
- `lib/widgets/result_card.dart`
- `lib/widgets/chart_card.dart`
- `lib/services/local_prediction_service.dart`
