#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <WindowManagement>
#Include <KeyTriggers>

AppID := 899770
ExecutableName := "Last Epoch.exe"

HotIfWinActive "ahk_exe" ExecutableName
	EnableBorderlessWindow 2560, 1440

	; Automatically Roar after Rampage
	SendKeyWhenKeyIsHeldFor "f", "Backspace", 300

CheckForAndAskToCreateStartMenuShortcut(AppID)
RunGameAndExitWhenClosed(AppID, ExecutableName)
