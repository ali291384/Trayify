# Trayify 📥

**Trayify** is a seamless Windows utility that lets you "trayify" any application—minimizing it to the system tray instead of the taskbar to keep your workspace clean.

> **Focus on what matters.** Tuck away background apps like Spotify, Discord, or terminals without closing them.

## ⚡ Features

* [cite_start]**Shift-to-Tray:** Just hold `Shift` while minimizing a window to send it to the tray[cite: 9].
* [cite_start]**Smart Icons:** Automatically extracts the correct high-res icon from the application[cite: 14].
* [cite_start]**Restoration:** Left-click the tray icon to restore the window instantly[cite: 35].
* [cite_start]**Unicode Support:** Fully supports special characters in window titles[cite: 31].
* **Lightweight:** Built on AutoHotkey v2 for minimal memory usage.

## 📦 Installation

1.  Download and install [AutoHotkey v2](https://www.autohotkey.com/).
2.  Clone this repository.
3.  Run `src/Trayify.ahk`.

## 🎮 Usage

1.  **To Hide:** Hold **`Shift`** and click the **Minimize button** (_) on any window.
2.  **To Restore:** Click the **Trayify icon** in your system tray area.

## 🔧 Under the Hood

Trayify uses Windows API hooks to intercept window events:
* [cite_start]**Event Hook:** Uses `SetWinEventHook` to detect minimization actions[cite: 6].
* [cite_start]**Icon Management:** Implements `Shell_NotifyIconW` to handle tray interactions reliably[cite: 32].

## 📄 License

[MIT](LICENSE)