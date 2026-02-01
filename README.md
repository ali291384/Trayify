<p align="center">
  <picture>
    <img alt="Trayify Logo" src="assets/Logo.svg" width="300">
  </picture>
</p>

<p align="center">
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
  </a>
  <img src="https://img.shields.io/badge/Version-1.0-blue.svg" alt="Version 1.0">
</p>

**Trayify** is a seamless Windows utility that lets you "trayify" any application—minimizing it to the system tray instead of the taskbar to keep your workspace clean.

> **Focus on what matters.** Tuck away background apps like Spotify, Discord, or terminals without closing them.

## ⚡ Features

* **Shift-to-Tray:** Just hold `Shift` while minimizing a window to send it to the tray.
* **Smart Icons:** Automatically extracts the correct high-res icon from the application.
* **Restoration:** Left-click the tray icon to restore the window instantly.
* **Unicode Support:** Fully supports special characters in window titles.
* **Lightweight:** Built on AutoHotkey v2 for minimal memory usage.

## 📦 Installation

1.  Download and install [AutoHotkey v2](https://www.autohotkey.com/).
2.  Clone this repository.
3.  Run `src/Trayify.ahk`.

## 🪄 Usage

1.  **To Hide:** Hold **`Shift`** and click the **Minimize button** (_) on any window.
2.  **To Restore:** Click the **Trayify icon** in your system tray area.

## 🔧 Under the Hood

Trayify uses Windows API hooks to intercept window events:
* **Event Hook:** Uses `SetWinEventHook` to detect minimization actions.
* **Icon Management:** Implements `Shell_NotifyIconW` to handle tray interactions reliably.

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.