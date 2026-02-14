#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2

if not A_IsAdmin
{
    try
    {
        Run "*RunAs `"" A_ScriptFullPath "`""
    }
    ExitApp
}

;
; CHAPTER 1 start
;

#1::
!1::
{
    Run "explorer.exe /n, D:\"
    if WinWait("D: ahk_class CabinetWClass",, 1)
        WinActivate
}

!q::
{
    Run 'explorer.exe /n, "D:\d1 Downloads"'
    if WinWait("d1 Downloads ahk_class CabinetWClass",, 1) 
        WinActivate
}

!w::
{
    Run 'explorer.exe /n, "D:\d2 Screenshots"'
    if WinWait("d2 Screenshots ahk_class CabinetWClass",, 1)
        WinActivate
}

!d::
{
    Run 'explorer.exe /n, "D:\Zx\Wallpapers\Wallpapers\In Use"'
    if WinWait("In Use ahk_class CabinetWClass",, 1)
        WinActivate
}

!e::Send "^{PrintScreen}"

!r::Send "#{PrintScreen}"

!x::
{
    Send "#b"
    Sleep 10
    Send "{Enter}"
}

!3::
{
    Run "Taskmgr.exe"
    if WinWait("ahk_exe Taskmgr.exe",, 3)
    {
        WinMaximize
        WinActivate
    }
}

;
; CHAPTER 1 end
;
;
; CHAPTER 2 start
;

; Note: Multi Fofi Compatible

#HotIf WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass")
^+v:: {
    activeWindowNnoPath := getActiveWindowNnoPath()
    if !activeWindowNnoPath
        return

    lastClipboardAsList := getLastClipboardAsList()
    if (lastClipboardAsList.Length = 0)
        return

    for _, oldFilePath in lastClipboardAsList {
        fileNameWithoutExtension := getFileNameWithoutExtension(oldFilePath)
        newFilePath := getUniqueFileName(activeWindowNnoPath "\" fileNameWithoutExtension ".lnk")
        try FileCreateShortcut oldFilePath, newFilePath
    }
}
#HotIf

getActiveWindowNnoPath() {
    windowHandle := WinExist("A")
    comObject_object := ComObject("Shell.Application")
    for window in comObject_object.Windows {
        try {
            if (window.HWND = windowHandle)
                return window.Document.Folder.Self.Path
        }
    }
    return ""
}

getLastClipboardAsList() {
    lastClipboardAsList := []
    if !DllCall("OpenClipboard", "ptr", 0, "int")
        return lastClipboardAsList
    try {
        clipboardHandle := DllCall("GetClipboardData", "uint", 15, "ptr")
        if !clipboardHandle
            return lastClipboardAsList
        lengthOf_lastClipboardAsList := DllCall("shell32\DragQueryFileW", "ptr", clipboardHandle, "uint", 0xFFFFFFFF, "ptr", 0, "uint", 0, "uint")
        ; u^1 is length(list(lastClipboardAsList)) in python
        Loop lengthOf_lastClipboardAsList {
            lengthOfCurrentPathFromLoop := DllCall("shell32\DragQueryFileW", "ptr", clipboardHandle, "uint", A_Index-1, "ptr", 0, "uint", 0, "uint")
            buffer_object := Buffer((lengthOfCurrentPathFromLoop+1)*2)
            DllCall("shell32\DragQueryFileW", "ptr", clipboardHandle, "uint", A_Index-1, "ptr", buffer_object, "uint", lengthOfCurrentPathFromLoop+1, "uint")
            lastClipboardAsList.Push(StrGet(buffer_object))
        }
        return lastClipboardAsList
    } finally {
        DllCall("CloseClipboard")
    }
}

getFileNameWithoutExtension(filePath) {
    SplitPath filePath, , , , &fileNameWithoutExtension
    return fileNameWithoutExtension
}

getUniqueFileName(filePath) {
    if !FileExist(filePath)
        return filePath
    SplitPath filePath, &fileName, &parentPath, &fileExtension, &fileNameWithoutExtension
    i := 2
    loop {
        newFilePath := parentPath "\" fileNameWithoutExtension " (" i ")." fileExtension
        if !FileExist(newFilePath)
            return newFilePath
        i += 1
    }
}

;
; CHAPTER 2 end
;
;
; CHAPTER 3 start
;

^+c:: {
    primary := ClipboardAll()
    try {
        secondaryAsText := A_Clipboard
        if (secondaryAsText = "") {
            SoundPlay "*-1"
            return
        }
        A_Clipboard := secondaryAsText
        if !ClipWait(0.3) {
            SoundPlay "*-1"
            return
        }
        Send "^v"
    }
    finally {
        Sleep 50
        A_Clipboard := primary
    }
}

;
; CHAPTER 3 end
;
