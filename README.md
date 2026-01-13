# MemCull

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[中文文档](./README_ZH.md)

MemCull is a simple and elegant image organization app designed to help you quickly clean up your photo gallery. It uses a Tinder-like swiping interface to make sorting through hundreds of photos a breeze.

## ✨ Features

- **Intuitive Swiping**: Swipe up to delete, swipe down to keep.
- **Glassmorphic UI**: A modern, clean design with blur effects and smooth animations.
- **Reverse Geocoding**: View where your photos were taken using EXIF metadata (powered by Amap, currently supports mainland China).
- **Recycle Bin**: Review your deleted photos before permanently removing them from your device.
- **Batch Processing**: High-performance photo loading and processing using sqflite database.
- **Multi-language Support**: Supports English, Simplified Chinese, and Traditional Chinese (Hong Kong/Taiwan).
- **Performance Optimized**: Concurrent asset loading and advanced image preloading for a lag-free experience.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [sqflite](https://pub.dev/packages/sqflite)
- **Asset Management**: [photo_manager](https://pub.dev/packages/photo_manager)
- **Localization**: Flutter Localizations (i18n)

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (v3.10.7 or higher)
- Android Studio / VS Code with Flutter extension
- An Android device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/MemCull.git
   cd MemCull
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Amap Key (Optional, for location display):
   - Register at [Amap Open Platform](https://lbs.amap.com/).
   - Create a "Web Service" key.
   - Enter the key in the app's location configuration screen.

4. Run the app:
   ```bash
   flutter run
   ```

## 📸 Screenshots

*(Add screenshots here later)*

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [photo_manager](https://pub.dev/packages/photo_manager) for excellent media library access.
- [Amap](https://lbs.amap.com/) for reverse geocoding services.
