# Redex Demo - Flutter Drag and Drop App

A Flutter application demonstrating drag and drop functionality with a clean architecture and state management approach.

## Overview

This application showcases a grid-based drag and drop interface using Flutter's built-in drag and drop capabilities. The app features a responsive grid layout where items can be dragged and reordered.

## Features

- Grid-based layout with draggable items
- Responsive design that adapts to different screen sizes
- Bottom navigation with multiple screens
- Custom theme colors
- State persistence during drag operations

## Technical Specifications

### Environment Requirements
- Flutter SDK: ^3.6.1
- Dart SDK: ^3.6.1

### State Management
The application uses:
- **flutter_bloc**: ^9.0.0 - For state management
- **equatable**: ^2.0.7 - For value equality comparisons

### Project Structure

lib/
├── blocs/ # BLoC state management
├── models/ # Data models
├── screens/ # UI screens
├── themes/ # Theme configurations
└── widgets/ # Reusable widgets

### Key Dependencies
flutter_bloc: ^9.0.0

## Architecture

The app follows a clean architecture pattern with:
- BLoC pattern for state management
- Separation of concerns between UI and business logic
- Modular widget structure for reusability

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- BLoC library contributors