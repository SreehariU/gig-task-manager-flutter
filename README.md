# 📅 Gig Task Manager

A Flutter-based task and schedule management app with **calendar integration**, **task filtering**, and **Firebase backend**. Designed to help users plan their day, manage priorities, and track work efficiently.

---

## ✨ Features

### ✅ Task Management
- Create, edit, and delete tasks
- Mark tasks as **completed / incomplete**
- Assign **priority levels**: Low, Medium, High
- Tasks automatically filtered to show **today's tasks**
- Swipe to delete tasks with confirmation

### 📆 Schedule & Calendar
- Calendar view using `table_calendar`
- Add schedules for specific dates and time ranges
- View schedules **per selected day**
- Edit and delete schedules
- Schedules stored securely in Firebase
- Real-time updates using Firestore streams

### 🔍 Filters
- Filter tasks by:
  - Priority (Low / Medium / High)
  - Status (All / Completed / Incomplete)
- Filters work together with **today-only view**

### 🔐 Authentication
- Firebase Authentication
- User-specific data (each user sees only their tasks & schedules)

### ☁️ Backend
- Firebase Firestore
- Real-time sync
- Structured per user:
  ```
  users/{userId}/tasks
  users/{userId}/schedules
  ```

---

## 🛠 Tech Stack

- **Flutter** (Material 3)
- **Dart**
- **Riverpod** (state management)
- **Firebase**
  - Authentication
  - Cloud Firestore
- **table_calendar**

---

## 📂 Project Structure

```
lib/
├── app/
│   └── home_screen.dart
├── features/
│   ├── auth/
│   │   ├── auth_provider.dart
│   │   ├── auth_screen.dart
│   │   └── register_screen.dart
│   └── tasks/
│       ├── models/
│       │   ├── task_model.dart
│       │   └── schedule_model.dart
│       ├── screens/
│       │   ├── task_list_screen.dart
│       │   ├── add_task_screen.dart
│       │   ├── calendar_screen.dart
│       │   └── add_schedule_screen.dart
│       ├── task_provider.dart
│       ├── task_filter_provider.dart
│       └── schedule_provider.dart
├── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Firebase account
- Android Studio / VS Code with Flutter extensions

### 1️⃣ Clone the repository

```bash
git clone https://github.com/your-username/gig_task_manager.git
cd gig_task_manager
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Firebase Setup

1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com/)

2. **Enable the following services:**
   - Authentication (Email/Password method)
   - Cloud Firestore

3. **Add Firebase to your Flutter app:**

   **For Android:**
   - Download `google-services.json`
   - Place it in `android/app/`

   **For iOS:**
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`

4. **Install FlutterFire CLI** (optional but recommended):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### 4️⃣ Configure Firestore Security Rules

In your Firebase Console, go to **Firestore Database > Rules** and add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{collection=**}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5️⃣ Run the app

```bash
flutter run
```

**Or for a specific device:**

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device_id>
```

---

## 📱 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 📌 Current Behavior

### Task View
- Shows only tasks for **today**
- Filters still apply (priority & status)

### Calendar View
- Selecting a date updates schedules list
- Only schedules for that day are shown

---

## 🧠 Future Improvements

- [ ] Auto-convert schedules to tasks on the scheduled day
- [ ] Push notifications & reminders
- [ ] Drag-and-drop schedule editing
- [ ] Weekly / monthly analytics dashboard
- [ ] Offline support with local caching
- [ ] Dark mode theme
- [ ] Task categories/tags
- [ ] Search functionality
- [ ] Export tasks to CSV/PDF

---

## 🐛 Troubleshooting

### Firebase not working?
1. Ensure `google-services.json` / `GoogleService-Info.plist` are in the correct directories
2. Run `flutter clean` and `flutter pub get`
3. Rebuild the app

### Calendar not displaying?
- Check that `table_calendar` is properly installed in `pubspec.yaml`
- Run `flutter pub get`

### Build errors?
```bash
flutter clean
flutter pub get
flutter run
```


---

## 👤 Author

**Sreehari Upas**  
Flutter Developer | Firebase | Mobile Apps

- GitHub: [@SreehariU](https://github.com/SreehariU)


---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- `table_calendar` package contributors
- Riverpod for state management

---

## 📸 Screenshots

_Coming soon..._

---

**⭐ If you found this helpful, please star the repository!**
