# Yu-Gi-Oh! TCG Application

A comprehensive Flutter application for Yu-Gi-Oh! Trading Card Game enthusiasts that allows users to browse, search, and manage their card collection.

## Features

### Card Management
- **Browse Cards**: Explore the extensive Yu-Gi-Oh! card database
- **Card Details**: View detailed information about each card including effects, attributes, and types
- **Card Image Viewer**: High-resolution card image viewing with zoom capabilities
- **Search Functionality**: Find cards by name, type, attribute, or effect text

### Deck Building
- **Create Custom Decks**: Build and save your own Yu-Gi-Oh! decks
- **Deck Management**: Edit, update, or delete your existing decks
- **Deck Details**: View detailed deck composition and statistics

### User Features
- **User Authentication**: Secure login system for user accounts
- **Favorites**: Mark cards as favorites for quick access
- **Price History Tracking**: Monitor card price trends and history
- **Profile Management**: Customize your user profile and preferences

### Additional Features
- **Local Notifications**: Get updates about new cards and features
- **Offline Access**: View your saved cards and decks even without internet connection
- **Location Services**: Find nearby card shops or tournaments (using Geolocator)
- **Image Upload**: Upload images of physical cards to your collection
- **Settings**: Customize app appearance and behavior

## Technical Details

### Architecture
The application follows a clean architecture approach with:
- **Provider Pattern**: For state management
- **Repository Pattern**: For data access and management
- **Service Layer**: For business logic and external API communication

### Dependencies
- **State Management**: Provider
- **HTTP Requests**: HTTP, Dio
- **Local Storage**: SQLite, Shared Preferences
- **UI Components**: Flutter Material Design
- **Charts**: FL Chart for price history visualization
- **Image Handling**: Cached Network Image, Image Picker
- **Location Services**: Geolocator, Geocoding
- **Sensors**: Sensors Plus for enhanced user experience
- **Notifications**: Flutter Local Notifications

### APIs
The application integrates with Yu-Gi-Oh! card databases to fetch the latest card information, pricing, and availability.

## Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/tugasakhirpraktikum.git
```

2. Navigate to the project directory:
```
cd yugioh-card-app
```

3. Install dependencies:
```
flutter pub get
```

4. Run the application:
```
flutter run
```

## Requirements
- Flutter SDK ^3.7.2
- Dart SDK ^3.7.2
- Android SDK or iOS development environment for mobile deployment

## Future Improvements
- Card trading functionality
- Integration with official tournament platforms
- Support for different game formats
- Card scanning using device camera
- Push notifications for price alerts
- Community features and social sharing


## Credits
Developed by *Me n V0* as a final practical project.

Data provided by Yu-Gi-Oh! API by YGOPRODeck.
