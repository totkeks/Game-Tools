#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <Windows>

AppID := 1063730
; override executable name because there is a launcher executable
ExecutableName := "NewWorld.exe"
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableAutoHideTaskbar()
	EnableBorderlessWindowHotkey "!q", 2560, 1440

Steam.RunGameAndExitWhenClosed(AppID, DisableAutoHideTaskbar, ExecutableName)
