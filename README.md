Casey's Code Test

A Flutter application that demonstrates interaction with the JSONPlaceholder API, implementing CRUD operations for posts and comments.

Features

View all posts with their respective comments in an expandable list

Create new posts with input validation

Update existing posts with validation

Error handling and loading states

Comprehensive test coverage (unit, widget, and integration tests)

Getting Started

Prerequisites

Flutter SDK (>=3.0.0)

Xcode (for iOS development)

CocoaPods (for iOS dependencies)

An Apple Developer account (for iOS device testing)

Installation

Install Flutter:

brew install flutter

Install CocoaPods:

brew install cocoapods

Install dependencies:

flutter pub get
cd ios
pod install
cd ..

Running the App

# Run on simulator
flutter run

# Run on physical device
flutter run -d <device-id>

Testing

Running Unit Tests

flutter test

Running Integration Tests

flutter test integration_test/app_test.dart

Project Structure

lib/
├── models/
│   ├── post.dart          # Post data model
│   └── comment.dart       # Comment data model
├── providers/
│   └── post_provider.dart # State management
├── screens/
│   ├── posts_screen.dart       # Main posts list
│   └── create_post_screen.dart # Create/Edit post
├── services/
│   └── api_service.dart   # API interactions
└── main.dart             # App entry point

Architecture

Provider pattern for state management

RESTful API integration with JSONPlaceholder

Comprehensive error handling and loading states

Unit, widget, and integration tests

Known Limitations

JSONPlaceholder API doesn't persist changes

Changes are only reflected in local state

No offline support

Future Improvements

Add offline support using local storage

Implement pagination for posts list

Add search and filtering

Enhance error recovery mechanisms

# CaseysCodeTest
