#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <Windows>

AppID := 2074920
ExecutableName := "M1-Win64-Shipping.exe"
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableAutoHideTaskbar()
	EnableBorderlessWindowHotkey "!q", 3440, 1440

Steam.RunGameAndExitWhenClosed(AppID, DisableAutoHideTaskbar, ExecutableName)
