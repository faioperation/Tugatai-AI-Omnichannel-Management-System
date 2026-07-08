# Roberto - Multi-Tenant Mobile Dashboard

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

Roberto is a modern, premium multi-tenant mobile dashboard built with Flutter. It provides a comprehensive suite of tools for business owners to manage their operations, customer relationships, and AI-driven features in one seamless interface.

## ✨ Key Features

- **🤖 AI Agent Management**: Define and manage AI agent behaviors with custom system prompts to automate customer interactions.
- **📊 Overview Dashboard**: Get real-time insights with statistical cards, trend analysis, and business performance metrics.
- **👥 CRM (Customer Relationship Management)**: Track leads, manage customer data, and streamline follow-ups.
- **🏘️ Tenant Management**: Seamlessly manage multiple business tenants within a single system architecture.
- **🛒 Order Booking**: Efficiently handle order workflows, from booking to fulfillment.
- **💬 Centralized Inbox**: A unified messaging hub for all customer communications across different channels.
- **⚙️ Business Settings & Subscriptions**: Comprehensive control over business profiles, branding, and subscription billing.
- **🔔 Notifications**: Real-time alerts and management for critical business events.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Cross-platform support)
- **Language**: [Dart](https://dart.dev)
- **UI Components**: Custom reusable widgets with support for Dark/Light mode.
- **State Management**: Scalable architecture designed for high performance.
- **Icons & Assets**: Premium SVG integration for sharp visuals on all resolutions.

## 🛠️ Project Structure

The project follows a modular, feature-based architecture:

```text
lib/
├── app/               # App-wide configurations (colors, themes)
├── common/            # Shared widgets and utilities
└── features/          # Feature-specific modules
    ├── AiAgent/       # AI configuration and prompts
    ├── Auth/          # Authentication flows
    ├── CRM/           # Lead and customer management
    ├── Inbox/         # Messaging system
    ├── Orderbooking/  # Order workflows
    ├── Tenant Management/ # Multi-tenant controls
    └── ...            # Other feature modules
```

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- Android Studio / VS Code with Flutter/Dart extensions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/roberto-multi-tenant.git
   ```
2. Navigate to the project directory:
   ```bash
   cd roberto-multi-tenant
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

*Built with ❤️ for professional business management.*
