#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <Windows>

AppID := 570
ExecutableName := Steam.GetAppInfo(AppID).ExecutableName
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableAutoHideTaskbar()

Steam.RunGameAndExitWhenClosed(AppID, DisableAutoHideTaskbar)
