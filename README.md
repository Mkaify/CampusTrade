# 🎓 CampusTrade

A smart, student-focused marketplace app built for **UET Taxila**. CampusTrade bridges the gap between students who want to sell used items (books, electronics, hostel gear) and those looking to buy them at affordable prices.

> **Final Year Project (FYP)** - Software Engineering Department

---

## 📱 Features

### 🛍️ Marketplace
* **Buy & Sell:** Users can list items with photos, prices, and detailed descriptions.
* **Smart Search:** Filter items by category (Books, Electronics, Hostel, etc.) or search by name.
* **Cloudinary Integration:** High-speed image uploads for product listings.

### 🤖 AI-Powered (Gemini)
* **Auto-Descriptions:** Integrated **Google Gemini AI** to automatically write catchy, sales-focused descriptions for items based on just a title and price.

### 💬 Real-Time Social Chat
* **In-App Messaging:** Buyers can chat directly with sellers without leaving the app.
* **Inbox System:** A dedicated "Messages" screen to track all active conversations.
* **Smart Profiles:** Chat interface displays the sender's real name and profile photo.

### 🔐 Authentication & Profiles
* **University Verified:** Restricts login to university emails (`@students.uettaxila.edu.pk`) to ensure a safe, trusted community.
* **User Profiles:** Students can update their display name and profile picture, which appear across the app.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Backend:** Firebase (Auth, Firestore Database)
* **AI Model:** Google Gemini 1.5 Flash
* **Storage:** Cloudinary (Images)
* **State Management:** `setState` & Streams

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK installed.
* A Firebase project setup.
* A Cloudinary account.
* A Google AI Studio API Key.

### Installation

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/your-username/campustrade.git](https://github.com/your-username/campustrade.git)
    cd campustrade
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**
    * Create a Firebase project.
    * Download `google-services.json` and place it in `android/app/`.
    * Enable **Authentication** (Email/Password) and **Firestore**.

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📸 Screenshots

| Login Screen | Home Feed | AI Listing | Chat System |
|:---:|:---:|:---:|:---:|
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 🤝 Contributing

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

**Developed with ♥ by Muhammad Kaif**