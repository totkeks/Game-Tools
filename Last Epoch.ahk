#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <WindowManagement>
#Include <KeyTriggers>

HotIfWinActive "ahk_exe Last Epoch.exe"

EnableBorderlessWindow 2560, 1440

; Automatically Roar after Rampage
SendKeyWhenKeyIsHeldFor "f", "Backspace", 300
