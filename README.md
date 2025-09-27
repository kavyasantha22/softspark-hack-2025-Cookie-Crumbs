# SparkPlay ⚡

**A social app for spontaneous local activities and instant connections**

SparkPlay helps people discover and create spontaneous activities ("Sparks") in their local area. Whether it's a pickup basketball game, study session, or coffee meetup, SparkPlay makes it easy to find like-minded people nearby and spark new connections.

## 📱 Features

### 🗺️ **Discovery & Exploration**
- **Interactive Map**: View all nearby Sparks on an integrated map
- **Smart Search**: Find activities by name, location, or description
- **Real-time Updates**: See live participant counts and availability

### ⚡ **Create & Join Sparks**
- **Quick Creation**: Create activities with photos, locations, and duration
- **One-Active-Spark Rule**: Smart logic prevents over-commitment
- **Instant Feedback**: Join/leave sparks with immediate confirmations

### 🔔 **Smart Notifications**
- **Automatic Reminders**: Get notified before your Sparks start
- **Ending Alerts**: Know when activities are about to end
- **Customizable Timing**: Set your preferred notification intervals
- **Rich Content**: Emoji-rich notifications with clear messaging

### 👤 **Profile & History**
- **Activity History**: Track your joined and created Sparks
- **Status Management**: See active vs. completed activities
- **Notification Settings**: Full control over alert preferences

## 🛠️ **Technical Stack**

- **Platform**: iOS 16.0+
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Architecture**: MVVM with ObservableObject
- **Persistence**: Local JSON storage
- **Maps**: MapKit with custom annotations
- **Camera**: UIKit integration via UIViewControllerRepresentable
- **Notifications**: UserNotifications framework

## 🚀 **Getting Started**

### **Prerequisites**

1. **macOS Ventura (13.0) or later**
2. **Xcode 15.0 or later**
3. **iOS device running iOS 16.0+ OR iOS Simulator**
4. **Apple Developer Account** (for device deployment)

### **Installation Steps**

#### **1. Clone the Repository**
```bash
git clone https://github.com/yourusername/SparkPlay.git
cd SparkPlay
```

#### **2. Open in Xcode**
```bash
open SparkPlay.xcodeproj
```

Or:
- Launch **Xcode**
- Choose **"Open a project or file"**
- Navigate to `SparkPlay.xcodeproj` and select it

#### **3. Configure Project Settings**

##### **Bundle Identifier** (Required for device deployment)
1. Select **SparkPlay** project in the navigator
2. Choose **SparkPlay** target
3. Go to **"Signing & Capabilities"** tab
4. Change **Bundle Identifier** to something unique:
   ```
   com.yourname.sparkplay
   ```

##### **Team Selection** (Required for device deployment)
1. In **"Signing & Capabilities"**
2. Select your **Team** from the dropdown
3. Ensure **"Automatically manage signing"** is checked
4. Xcode will automatically create provisioning profiles

#### **4. Build the Project**

##### **For Simulator:**
1. Select **simulator** from the device menu (e.g., "iPhone 15 Pro")
2. Press **⌘+B** or click **"Build"**
3. Press **⌘+R** or click **"Run"**

##### **For Physical Device:**
1. Connect your **iPhone/iPad** via USB
2. **Trust the computer** on your device if prompted
3. Select your **device** from the device menu
4. **Enable Developer Mode** on your device:
   - Settings → Privacy & Security → Developer Mode → Enable
5. Press **⌘+R** or click **"Run"**

#### **5. Trust Developer Certificate** (Physical device only)
1. On your device: **Settings → General → VPN & Device Management**
2. Find your **Apple ID** under "Developer App"
3. Tap **"Trust [Your Apple ID]"**
4. Confirm **"Trust"**

#### **6. Enable Permissions**
When you first run the app, you'll be prompted for:
- **📍 Location Services**: Required for map features
- **🔔 Notifications**: Required for Spark reminders
- **📷 Camera Access**: Required for adding photos to Sparks

Tap **"Allow"** for all permissions to get the full experience.

## 📖 **How to Use SparkPlay**

### **🏠 Home Screen**
- **Browse Sparks**: Scroll through nearby activities
- **Search**: Use the search bar to find specific activities
- **Map View**: Tap the map to see full-screen view with all Sparks
- **Join Activity**: Tap "View" on any Spark to see details and join

### **➕ Creating a Spark**
1. Tap the **large + button** in the tab bar
2. Fill in **Activity Name** (e.g., "Basketball Game")
3. Add a **photo** using "Insert Picture" button
4. Set **duration** using the picker (or "Not Ending")
5. Choose **number of people needed**
6. Pick **location** using the map picker
7. Add a **description**
8. Tap **"Add Spark"**

### **👤 Profile & Settings**
- **Profile Tab**: View your activity history
- **Notifications**: Customize alert preferences
- **Test Features**: Use demo buttons to test notifications

### **🔔 Notification Testing**
1. Go to **Profile → Notifications**
2. Tap **"Test Notification"** for immediate test
3. Tap **"Demo: Quick Spark (2 min)"** for a demo activity
4. Background the app and wait for scheduled notifications

## 🏗️ **Project Structure**

```
SparkPlay/
├── 📱 Core/                    # App foundation
│   ├── SparkPlayApp.swift      # Main app entry point
│   └── MainTabView.swift       # Root tab navigation
├── 📊 Models/                  # Data structures
│   ├── EventModel.swift        # Spark/Event data model
│   └── UserModel.swift         # User profile model
├── 🎭 Views/                   # User interface
│   ├── Home/                   # Discovery & exploration
│   │   ├── HomeView.swift      # Main screen
│   │   └── MapAccessView.swift # Full-screen map
│   ├── Profile/                # User management
│   │   ├── ProfileView.swift   # Profile & history
│   │   └── NotificationSettingsView.swift # Notification preferences
│   ├── Spark/                  # Activity management
│   │   ├── AddSparkView.swift  # Create new Spark
│   │   └── SparkDetailView.swift # Spark details & join
│   └── Common/                 # Reusable components
│       ├── CameraCapture.swift # Photo capture
│       ├── ImagePicker.swift   # Photo library
│       └── LocationPickerView.swift # Location selection
├── ⚙️ Services/                # Business logic
│   ├── EventStore.swift        # Spark data management
│   └── NotificationManager.swift # Notification handling
├── 🛠️ Utilities/              # Helper classes
│   └── LocationManager.swift   # Location services
└── 📚 Documentation/           # Guides & docs
    ├── DEMO_GUIDE.md          # Demo instructions
    ├── TESTING_CHEAT_SHEET.md # Quick testing reference
    └── CODEBASE_MAP.md        # Developer navigation
```

## 🧪 **Testing & Demo**

### **Quick Test (30 seconds)**
1. Open app → Allow permissions
2. Profile → Notifications → "Test Notification"
3. Should see immediate notification

### **Full Demo (2-5 minutes)**
1. **Profile → Notifications → "Demo: Quick Spark (2 min)"**
2. **Join the demo Spark** (get join notification)
3. **Background app** for 1 minute
4. **Receive ending notification**

For detailed testing instructions, see [`TESTING_CHEAT_SHEET.md`](SparkPlay/TESTING_CHEAT_SHEET.md)

## 🐛 **Troubleshooting**

### **Build Errors**
- **"No team selected"**: Add your Apple ID in Xcode Preferences → Accounts
- **"Bundle identifier in use"**: Change bundle ID to something unique
- **"Missing imports"**: Clean build folder (⌘+Shift+K) and rebuild

### **Runtime Issues**
- **Notifications not working**: Check iOS Settings → SparkPlay → Notifications
- **Location not working**: Check iOS Settings → SparkPlay → Location
- **Camera not working**: Check iOS Settings → SparkPlay → Camera

### **Device Deployment**
- **"Untrusted Developer"**: Settings → General → Device Management → Trust
- **"Could not launch"**: Enable Developer Mode in iOS Settings
- **"Provisioning profile"**: Ensure valid Apple Developer account

## 🎨 **App Architecture**

### **Data Flow**
```
SparkPlayApp (Entry Point)
    ↓
MainTabView (Navigation)
    ↓
HomeView ↔ EventStore ↔ UserStore
    ↓
SparkDetailView ↔ NotificationManager
```

### **Key Patterns**
- **MVVM**: Views observe data stores via `@EnvironmentObject`
- **Single Source of Truth**: `EventStore` and `UserStore` manage all data
- **Reactive UI**: SwiftUI automatically updates when data changes
- **Service Layer**: Business logic separated from UI components

## 🚀 **Features Showcase**

### **Smart Business Logic**
- **One-Spark-Per-User**: Prevents over-commitment to activities
- **Auto-Closing**: Sparks close when full or time expires
- **Real-Time Status**: UI reflects current availability instantly

### **Professional UI/UX**
- **Gradient Themes**: Vibrant "spark" color scheme throughout
- **Custom Components**: Unique map markers and status indicators
- **Smooth Animations**: Polished transitions and interactions
- **Responsive Design**: Works on all iPhone sizes

### **Advanced Notifications**
- **Smart Scheduling**: Automatic reminders based on Spark timing
- **Rich Content**: Emojis and clear messaging
- **User Control**: Customizable timing and preferences
- **Deep Linking Ready**: Notification taps can open specific Sparks

## 📄 **License**

This project is created for educational purposes as part of a hackathon. Feel free to use and modify for learning and non-commercial purposes.

## 🤝 **Contributing**

This is a hackathon project, but suggestions and improvements are welcome! Please:

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Open** a Pull Request

## 💬 **Support**

Having trouble? Check out:
- [`DEMO_GUIDE.md`](SparkPlay/DEMO_GUIDE.md) - Complete demo instructions
- [`TESTING_CHEAT_SHEET.md`](SparkPlay/TESTING_CHEAT_SHEET.md) - Quick testing reference
- [`CODEBASE_MAP.md`](SparkPlay/CODEBASE_MAP.md) - Developer navigation guide

---

**Made with ⚡ by Kavya, Farhan, Revael, Geraldo for Spark-Soft Hackathon 2025**

*SparkPlay - Where spontaneous connections begin!*
