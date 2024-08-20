#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <Windows>
#Include <KeyTriggers>

AppID := 899770
ExecutableName := Steam.GetAppInfo(AppID).ExecutableName
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableBorderlessWindowHotkey "!q", 2560, 1440

	; Automatically Roar after Rampage
	SendKeyWhenKeyIsHeldFor "f", "Backspace", 300

Steam.RunGameAndExitWhenClosed(AppID)
