# Reminder

A simple reminder app built with Flutter that lets you create tasks, schedule notifications, and manage your reminders directly on your device.

## Features

- **Create reminders**: Add a task with a title, date, and time.
- **Edit reminders**: Update an existing task and its scheduled notification.
- **Delete reminders**: Remove tasks and cancel their scheduled notifications.
- **Local data storage**: Keep tasks saved on your device using Hive CE.
- **Scheduled notifications**: Receive notifications at the times you choose.
- **Timezone support**: Schedule notifications using the device's local timezone.
- **Lightweight and local-first**: No backend or account is required for the app's core functionality.

## Getting Started

### Prerequisites

- Flutter SDK installed ([installation guide](https://docs.flutter.dev/get-started/install))
- A connected device or emulator

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/TunarAlasgarzade/reminder.git
   cd reminder
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## Tech Stack

- Flutter 
- Dart
- hive_ce
- flutter_local_notifications
- timezone
- provider