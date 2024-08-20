#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <Windows>

AppID := 289070
; override executable name because it defaults to the non-DX12 version
ExecutableName := "CivilizationVI_DX12.exe"
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableAutoHideTaskbar()
	EnableBorderlessWindowHotkey "!q", 2560, 1440

Steam.RunGameAndExitWhenClosed(AppID, DisableAutoHideTaskbar, ExecutableName)
