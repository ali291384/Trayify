#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ==============================================================================
; ADMIN PRIVILEGES (REQUIRED FOR INTERACTING WITH ADMIN WINDOWS)
; ==============================================================================
if not A_IsAdmin
{
    try {
        Run "*RunAs `"" A_ScriptFullPath "`""
    }
    ExitApp
}

; ==============================================================================
; SET TRAY ICON AND TOOLTIP
; ==============================================================================
A_IconTip := "Trayify"
IconPath := A_ScriptDir . "\..\assets\TrayIcon.ico"
if FileExist(IconPath) {
    TraySetIcon(IconPath)
}


; ==============================================================================
; CONFIGURATION & CONSTANTS
; ==============================================================================
WM_USER := 0x400
WM_TRAY_CALLBACK := WM_USER + 1 ; Custom message ID for our tray interactions
WM_LBUTTONUP := 0x202       ; Left click release
NIM_ADD := 0x00000000
NIM_DELETE := 0x00000002
NIF_MESSAGE := 0x00000001
NIF_ICON := 0x00000002
NIF_TIP := 0x00000004

; Store hidden windows to handle cleanup: Map(hwnd -> hIcon)
HiddenWindows := Map()

; Listen for our custom Tray Message (when user clicks an icon)
OnMessage(WM_TRAY_CALLBACK, OnTrayIconClick)

; Hook into system minimize events
HookProc := CallbackCreate(OnMinimizeEvent, "F", 7)
hHook := DllCall("SetWinEventHook", "UInt", 0x16, "UInt", 0x16, "Ptr", 0, "Ptr", HookProc, "UInt", 0, "UInt", 0, "UInt", 0)

; Cleanup on exit
OnExit(RestoreAllOnExit)

Return

; ==============================================================================
; EVENT: MINIMIZE START
; ==============================================================================
OnMinimizeEvent(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    if (idObject != 0) ; Not a window object
        return

    if !GetKeyState("Shift", "P") ; Only if Shift is held
        return

    try {
        ; FILTER: Don't minimize the Desktop (Progman/WorkerW) or Taskbar (Shell_TrayWnd)
        class := WinGetClass(hwnd)
        if (class = "Shell_TrayWnd" || class = "Progman" || class = "WorkerW")
            return

        ; Prevent duplicate hiding
        if HiddenWindows.Has(hwnd)
            return

        title := WinGetTitle(hwnd)

        ; 1. Hide the Window
        WinHide(hwnd)

        ; 2. Get the Window's Icon (Try Big, then Small, then Class)
        hIcon := 0
        try hIcon := SendMessage(0x7F, 1, 0, hwnd) ; WM_GETICON (Big)
        if !hIcon
            try hIcon := SendMessage(0x7F, 0, 0, hwnd) ; WM_GETICON (Small)
        if !hIcon
            try hIcon := DllCall("GetClassLongPtr", "Ptr", hwnd, "Int", -14, "Ptr") ; GCL_HICON

        ; If we still have no icon, load a generic system icon
        if !hIcon
            try hIcon := LoadPicture("shell32.dll", "Icon1", &type)

        ; 3. Create the Tray Icon
        AddTrayIcon(hwnd, hIcon, title)

        ; 4. Track it
        HiddenWindows[hwnd] := hIcon

    } catch as err {
        ; Silently fail if permissions prevent access
    }
}

; ==============================================================================
; TRAY ICON MANAGEMENT (FIXED FOR UNICODE)
; ==============================================================================
AddTrayIcon(hwnd, hIcon, tooltip) {
    ; Determine offsets based on architecture (x64 vs x86)
    ; This ensures the Icon handle and Tooltip string land in the correct memory slots.
    if (A_PtrSize == 8) { ; 64-bit
        off_hIcon := 32
        off_szTip := 40
    } else { ; 32-bit
        off_hIcon := 20
        off_szTip := 24
    }

    ; Construct NOTIFYICONDATA structure
    nid := Buffer(960, 0)

    NumPut("UInt", nid.Size, nid, 0)             ; cbSize
    NumPut("Ptr", A_ScriptHwnd, nid, A_PtrSize)  ; hWnd
    NumPut("UInt", hwnd, nid, A_PtrSize * 2)     ; uID
    NumPut("UInt", NIF_MESSAGE | NIF_ICON | NIF_TIP, nid, A_PtrSize * 2 + 4) ; uFlags
    NumPut("UInt", WM_TRAY_CALLBACK, nid, A_PtrSize * 2 + 8) ; uCallbackMessage
    NumPut("Ptr", hIcon, nid, off_hIcon)         ; hIcon

    ; Tooltip: Write UTF-16 string
    StrPut(SubStr(tooltip, 1, 127), nid.Ptr + off_szTip, "UTF-16")

    ; IMPORTANT: Use Shell_NotifyIconW (Wide/Unicode) to read the tooltip correctly
    DllCall("shell32\Shell_NotifyIconW", "UInt", NIM_ADD, "Ptr", nid)
}

RemoveTrayIcon(hwnd) {
    nid := Buffer(960, 0)
    NumPut("UInt", nid.Size, nid, 0)
    NumPut("Ptr", A_ScriptHwnd, nid, A_PtrSize)
    NumPut("UInt", hwnd, nid, A_PtrSize * 2)

    ; Use Shell_NotifyIconW for consistency
    DllCall("shell32\Shell_NotifyIconW", "UInt", NIM_DELETE, "Ptr", nid)
}

; ==============================================================================
; INTERACTION HANDLER
; ==============================================================================
OnTrayIconClick(wParam, lParam, msg, hwnd) {
    ; wParam = The uID we set (which is the HWND of the hidden window)
    ; lParam = The mouse event (e.g., WM_LBUTTONUP)

    targetHwnd := wParam

    if (lParam = WM_LBUTTONUP) {
        RestoreWindow(targetHwnd)
    }
}

RestoreWindow(hwnd) {
    if !HiddenWindows.Has(hwnd)
        return

    ; Restore Window
    if WinExist(hwnd) {
        WinShow(hwnd)
        WinRestore(hwnd)
        WinActivate(hwnd)
    }

    ; Remove Icon
    RemoveTrayIcon(hwnd)

    ; Cleanup Map
    HiddenWindows.Delete(hwnd)
}

; ==============================================================================
; CLEANUP
; ==============================================================================
RestoreAllOnExit(ExitReason, ExitCode) {
    for hwnd, hIcon in HiddenWindows {
        if WinExist(hwnd)
            WinShow(hwnd)
        RemoveTrayIcon(hwnd)
    }
    if IsSet(hHook)
        DllCall("UnhookWinEvent", "Ptr", hHook)
}