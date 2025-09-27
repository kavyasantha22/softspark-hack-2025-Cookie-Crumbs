# SparkPlay - Project Structure

## 📁 Folder Organization

### 🏗️ **Core/**
App-level components and main navigation
- `SparkPlayApp.swift` - Main app entry point
- `MainTabView.swift` - Root tab navigation controller

### 📊 **Models/**
Data structures and domain models
- `EventModel.swift` - Spark/Event data model with computed properties
- `UserModel.swift` - User profile and preferences data model

### 🎭 **Views/**
All user interface components organized by feature

#### **Views/Home/**
Main discovery and exploration interface
- `HomeView.swift` - Main screen with map, search, and spark list
- `MapAccessView.swift` - Full-screen map view with spark markers

#### **Views/Profile/**
User profile and settings interface
- `ProfileView.swift` - User profile with spark history
- `NotificationSettingsView.swift` - Notification preferences and controls

#### **Views/Spark/**
Spark creation and detail interfaces
- `AddSparkView.swift` - Create new spark form with image/location pickers
- `SparkDetailView.swift` - Detailed spark view with join/leave functionality

#### **Views/Common/**
Reusable UI components
- `CameraCapture.swift` - Camera integration for photo capture
- `ImagePicker.swift` - Photo library picker component
- `LocationPickerView.swift` - Map-based location selector

### ⚙️ **Services/**
Business logic and data management
- `EventStore.swift` - Spark data persistence and business logic
- `NotificationManager.swift` - Local notification scheduling and management

### 🛠️ **Utilities/**
Helper classes and utilities
- `LocationManager.swift` - Core Location wrapper for user location

### 🎨 **Assets.xcassets/**
App icons, colors, and image assets

## 🔄 Data Flow

```
SparkPlayApp (Entry)
    ↓
MainTabView (Navigation)
    ↓
HomeView ↔ EventStore ↔ UserStore
    ↓
SparkDetailView ↔ NotificationManager
```

## 🏗️ Architecture

- **MVVM Pattern**: Views observe stores via `@EnvironmentObject`
- **Single Source of Truth**: `EventStore` and `UserStore` manage all data
- **Reactive UI**: SwiftUI automatically updates when published data changes
- **Service Layer**: Business logic separated from UI in dedicated services

## 📱 Key Features

- **One-Spark-Per-User**: Business logic prevents joining multiple active sparks
- **Local Notifications**: Smart scheduling with user preferences
- **Offline-First**: Local JSON persistence with optional sync ready
- **Real-Time Updates**: UI reflects data changes immediately
- **Camera Integration**: Native photo capture for spark images
- **Location Services**: Apple Maps integration for spark locations

## 🚀 Getting Started

1. Open `SparkPlay.xcodeproj` in Xcode
2. Main entry point: `Core/SparkPlayApp.swift`
3. Home screen: `Views/Home/HomeView.swift`
4. Data layer: `Services/EventStore.swift`

## 📋 Future Enhancements

- Add deep linking for notification taps
- Implement real-time chat for sparks
- Add push notifications for remote updates
- Integrate with backend API
- Add social features (friends, sharing)
