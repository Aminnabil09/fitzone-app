# FitZone - Your Ultimate Sports Store

A Flutter mobile application for a sports store with modern UI, animations, and smart features.

## Features

- **Splash Screen**: Animated splash screen with fade, scale, and rotation animations
- **Login Screen**: User authentication with form validation
- **Home Screen**: 
  - Store section with product grid
  - Search functionality
  - Price filter slider
  - Category filtering
  - Profile icon in AppBar
  - Carousel banner with auto-play
- **Categories Screen**: 14 different categories including:
  - Gym & Fitness
  - Football
  - Basketball
  - Running
  - Clothing
  - Shoes
  - Accessories
  - Equipment
  - Nutrition
  - Outdoor & Adventure
  - Yoga & Wellness
  - Kids & Youth
  - Boxing & Combat
  - Deals & Collections
- **Product Detail Screen**: 
  - Hero animations
  - Color and size selection
  - Quantity selector
  - Add to cart and Buy now buttons
- **Cart Screen**: 
  - List view of cart items
  - Quantity management
  - Total price calculation
- **Chat Screen**: 
  - Smart AI assistant
  - User messages on right, AI responses on left
  - Context-aware responses
- **Profile Screen**: 
  - User information
  - Menu items (Order History, Shipping Address, Wishlist, etc.)
  - Logout functionality

## Technical Features

- **AppBar Management**: Custom styled AppBar with leading and action buttons
- **List View**: Used in cart screen and chat screen
- **Grid View**: Used in home screen and categories screen
- **Multiple Button Types**: ElevatedButton, IconButton, TextButton, CircleAvatar buttons
- **Navigation**: Navigator widget with named routes
- **Text Fields**: Custom styled input fields with validation
- **Flutter Slider**: RangeSlider for price filtering
- **Drawer**: Ready for implementation (can be added)
- **Routing**: Multiple separated pages with proper navigation
- **Stateless & Stateful Widgets**: Mix of both widget types
- **Responsive Design**: MediaQuery and LayoutBuilder for adaptive layouts
- **Animations**:
  - Implicit Animations: AnimatedBuilder, FadeTransition, SlideTransition
  - Explicit Animations: AnimationController with custom curves
  - Hero Animations: Product card to detail screen transition
  - Carousel Background: Auto-playing carousel with indicators

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd fitzone_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── product.dart         # Product model
│   └── cart_item.dart       # Cart item model
├── screens/
│   ├── splash_screen.dart   # Splash screen with animations
│   ├── login_screen.dart    # Login page
│   ├── home_screen.dart     # Home page with store
│   ├── categories_screen.dart # Categories page
│   ├── product_detail_screen.dart # Product details
│   ├── cart_screen.dart     # Shopping cart
│   ├── chat_screen.dart     # AI chat assistant
│   └── profile_screen.dart  # User profile
├── widgets/
│   ├── product_card.dart    # Product card widget
│   └── carousel_banner.dart # Carousel banner widget
├── services/
│   ├── auth_service.dart    # Authentication service
│   └── cart_service.dart    # Cart management service
└── utils/
    └── app_theme.dart       # App theme configuration
```

## Dependencies

- `carousel_slider`: For carousel banner functionality
- `shared_preferences`: For storing user login state
- `http`: For future API integration

## Navigation Flow

1. Splash Screen → Login Screen (if not logged in) or Home Screen (if logged in)
2. Login Screen → Home Screen (after successful login)
3. Home Screen → Categories, Product Detail, Cart, Chat, Profile
4. Profile Screen → Login Screen (on logout)

## Notes

- The app uses a dark theme matching the design
- Product images are placeholders (you can add actual images to `assets/images/`)
- The chat AI provides context-aware responses based on user queries
- Cart state persists during the session
- All screens are responsive and adapt to different screen sizes

## Future Enhancements

- Add actual product images
- Implement backend API integration
- Add user authentication with Firebase
- Implement payment gateway
- Add order tracking
- Enhance AI chat with more sophisticated responses






