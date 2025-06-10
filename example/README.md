# qr_code_scanner Example App

This example Flutter app demonstrates how to use the `qr_code_scanner` plugin to scan QR codes and extract monetary amounts from the scanned data.

## Features

- Scan QR codes using the device camera.
- Extract and display monetary amounts from scanned QR code data.
- Display a running total of all scanned amounts.
- Undo the last scanned value.
- Responsive UI with camera preview and overlay.

## Getting Started

### Prerequisites

- Flutter SDK installed (https://flutter.dev/docs/get-started/install)
- A device or emulator with camera support
- For web, a modern browser with camera access enabled

### Running the Example

1. Navigate to the example directory:

```bash
cd example
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the app on your desired platform:

```bash
flutter run
```

You can run the app on Android, iOS, or Web platforms.

## How It Works

- The app starts with a home screen showing the app name and a button to open the QR scanner.
- When the scanner is opened, the camera view is displayed with a red overlay.
- As QR codes are scanned, the app extracts the monetary amount from the scanned text and adds it to a list of scanned values.
- The total sum of all scanned amounts is displayed on the screen.
- You can undo the last scanned value using the "Undo Last Value" button.
- The scanned values are displayed in a list on the screen.

## Code Overview

- `main.dart` contains the main app and the QR scanner widget.
- The QR scanner uses the `qr_code_scanner` plugin to access the camera and scan QR codes.

## Notes

- This app is a prototype and is designed for demonstration and learning purposes.
- Make sure to grant camera permissions when prompted.

## Credits

QR scanner flutter app: https://github.com/juliuscanute/qr_code_scanner
