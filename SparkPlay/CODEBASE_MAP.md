# 🗺️ SparkPlay Codebase Map

## 🚀 Quick Navigation

### Starting Points
- **App Entry**: `Core/SparkPlayApp.swift`
- **Main UI**: `Core/MainTabView.swift`
- **Home Screen**: `Views/Home/HomeView.swift`

### Core Data
- **Spark Logic**: `Services/EventStore.swift`
- **User Logic**: `Models/UserModel.swift`
- **Notifications**: `Services/NotificationManager.swift`

### Key Features
- **Create Spark**: `Views/Spark/AddSparkView.swift`
- **Spark Details**: `Views/Spark/SparkDetailView.swift`
- **Profile**: `Views/Profile/ProfileView.swift`
- **Map**: `Views/Home/MapAccessView.swift`

### Utilities
- **Location**: `Utilities/LocationManager.swift`
- **Camera**: `Views/Common/CameraCapture.swift`
- **Location Picker**: `Views/Common/LocationPickerView.swift`

## 📂 File Relationships

```
Core/SparkPlayApp.swift
├── Core/MainTabView.swift
├── Views/Home/HomeView.swift
│   ├── Services/EventStore.swift
│   ├── Views/Home/MapAccessView.swift
│   └── Views/Spark/SparkDetailView.swift
├── Views/Profile/ProfileView.swift
│   └── Views/Profile/NotificationSettingsView.swift
└── Views/Spark/AddSparkView.swift
    ├── Views/Common/CameraCapture.swift
    └── Views/Common/LocationPickerView.swift
```

## 🔧 Adding New Features

### New View
1. Create in appropriate `Views/` subfolder
2. Add to relevant parent view
3. Update environment objects if needed

### New Model
1. Add to `Models/` folder
2. Make `Codable` for persistence
3. Add computed properties for UI logic

### New Service
1. Create in `Services/` folder
2. Make `ObservableObject` for SwiftUI
3. Inject via `@EnvironmentObject`

## 🎯 Common Tasks

### Add a new Spark feature
- Model: `Models/EventModel.swift`
- Logic: `Services/EventStore.swift`
- UI: `Views/Spark/SparkDetailView.swift`

### Add a user preference
- Model: `Models/UserModel.swift`
- UI: `Views/Profile/ProfileView.swift`

### Add a notification type
- Logic: `Services/NotificationManager.swift`
- Settings: `Views/Profile/NotificationSettingsView.swift`

### Add a map feature
- Main Map: `Views/Home/HomeView.swift`
- Full Map: `Views/Home/MapAccessView.swift`
- Location Utils: `Utilities/LocationManager.swift`
