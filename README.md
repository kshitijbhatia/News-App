# News App

## ScreenShots

### Home Page
![Home page crop](https://github.com/kshitijbhatia/News-App/assets/108986570/fb259d14-a96f-4554-825b-82705240044b)

### Login and Register Page
![Authentication](https://github.com/kshitijbhatia/News-App/assets/108986570/0dccb964-64fa-425e-8c0f-6c94a0e185c2)

### Update Page
![Update Page](https://github.com/kshitijbhatia/News-App/assets/108986570/2e63a6e7-2dbe-48ac-ab1a-24ba3b700387)

### Error Page
![Error Page](https://github.com/kshitijbhatia/News-App/assets/108986570/1c5edb82-2025-4498-ab5b-6b5688c89ab6)

## Description
This app fetches captivating articles from a website and presents them on the home page, providing users with a curated selection of intriguing news. Implemented with pagination, users can seamlessly explore more articles by scrolling to the bottom of the screen. Additionally, tapping on an article navigates the user to a web page within the app, offering an immersive reading experience without leaving the app's environment.

## Key Features

- **Dynamic Content**: Stay informed with the latest news articles fetched from a website and displayed on the home page.
- **In-App Web View**: Dive deeper into articles by tapping on them to view the full content within the app, providing a seamless reading experience.
- **Intuitive UI**: Enjoy a user-friendly interface designed to enhance navigation and engagement, ensuring a delightful user experience.
- **Secure Authentication**: Access the app securely with Firebase Authentication, providing peace of mind and safeguarding user accounts.
- **Customized News by Country**: Utilize Firebase Remote Config to personalize news content based on country, enabling users to stay updated with relevant news from their region.
- **Profile Management**: Users have a profile page where they can update or delete their details, ensuring control over their account information.
- **Profile Picture Setting**: Users can personalize their profile by setting their own profile picture, adding a personal touch to their account.

## Technical Stack

This Flutter project utilizes the following technologies and libraries:

- **Flutter 3.19.5**: Provides the foundation for building a cross-platform mobile application.
- **Dart 3.3.3**: The programming language used to develop the app's logic.
- **cached_network_image (version ^3.3.1)**: Offers caching support for network images, optimizing performance by reducing network requests for frequently accessed images.
- **dio (version ^5.4.2+1)**: A powerful HTTP client for making network requests, used for fetching data from APIs.
- **shimmer (version ^3.0.0)**: Offers shimmer effect loading placeholders for UI elements, enhancing user experience during data fetching.
- **webview_flutter (version ^4.7.0)**: Enables the integration of web views within the Flutter app, allowing for in-app browsing of web content.
- **shared_preferences (version ^2.2.2)**: Allows for simple key-value pair storage, useful for storing user preferences or settings locally.
- **uuid (version ^4.3.3)**: Generates unique identifiers for tasks or users in the app.
- **intl (version ^0.19.0)**: Provides internationalization and localization support for the app's text and date formatting.
- **image_picker (version ^1.0.6)**: Allows users to pick images from their device's gallery or camera.
- **firebase_storage (version ^11.7.2)**: Provides access to Firebase Cloud Storage for storing user-generated content like images or files.
- **firebase_remote_config (version ^4.4.2)**: Enables remote configuration of app settings or parameters from the Firebase console.
- **firebase_analytics (version ^10.10.2)**: Allows for tracking user interactions and events within the app for analytics purposes.
- **firebase_crashlytics (version ^3.5.1)**: Provides crash reporting and analysis to help diagnose and fix app crashes.
- **cloud_firestore (version ^4.16.0)**: Allows for real-time data synchronization and storage with Firebase Firestore, enabling efficient data management.
- **firebase_core (version ^2.27.0)**: Provides essential Firebase core functionality required for Firebase services to function properly.
- **firebase_auth (version ^4.17.8)**: Enables user authentication with Firebase Authentication for secure access control and user management.



## Setup

Run the following commands from your terminal:

1) `https://github.com/kshitijbhatia/News-App.git` to clone this repository 

2) `flutter pub get` in the project root directory to install all the required dependencies.



