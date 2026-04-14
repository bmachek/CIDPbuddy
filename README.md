# CIDP Buddy

CIDP Buddy is a premium, comprehensive medication and symptom management application specifically designed for patients with Chronic Inflammatory Demyelinating Polyneuropathy (CIDP). It helps users manage complex infusion schedules, track inventory of medications and supplies, and monitor their health journey through a detailed vitals and symptom diary.

## ✨ Key Features

### 💊 Medication & Infusion Management
- **Detailed Tracking**: Support for both infusions (IVIG/SCIG) and pill-based medications.
- **Batch Tracking**: Record batch numbers and body weight for every infusion to ensure precise documentation.
- **Intake Logs**: Maintain a complete history of all past treatments.

### 📦 Inventory & Supply Management
- **Smart Stock Tracking**: Automatically decrements stock when doses are logged.
- **Accessory Management**: Track medical supplies (needles, syringes, etc.) linked to specific medications.
- **Low Stock Warnings**: Visual indicators and alerts based on "days remaining" logic.

### 📅 Smart Scheduling
- **Flexible Planning**: Support for daily, weekly, interval-based, or specific weekday schedules.
- **Automated Appointments**: Generates upcoming treatment tasks based on your defined rhythm.
- **Notifications**: Precise reminders for upcoming intakes using local notifications.

### 📔 Vitals & Symptom Diary
- **Vitals Monitor**: Track Blood Pressure, Heart Rate, Temperature, and Body Weight.
- **CIDP Metrics**: Specialized scoring for Strength, Sensory, Fatigue, Pain, and Balance.
- **History View**: Review trends and notes to share with your healthcare providers.

### 🛒 Order Wizard
- **Automated Calculations**: Calculates exactly what you need to order based on current stock and upcoming requirements.
- **Delivery Tracking**: Manage pending orders and confirm deliveries to update inventory automatically.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) for robust, reactive local storage.
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart) for health data visualization.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest stable version)
- Dart SDK

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/bmachek/CIDPbuddy.git
    cd CIDPbuddy
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate Database Code**:
    This project uses `drift` for database operations. You must run the code generator:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the application**:
    ```bash
    flutter run
    ```

## 📝 Development Guidelines

- **Code Generation**: Always run `build_runner` after modifying database schemas or `part` files.
- **Linting**: Ensure code adheres to the rules defined in `analysis_options.yaml`.
- **Formatting**: Use `flutter format .` before committing.

## 🛡 License

This project is private and for personal use.

---
*Developed with care for the CIDP community.*
