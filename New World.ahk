#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <WindowManagement>
#Include <KeyTriggers>

AppID := 1063730
ExecutableName := Steam.GetAppInfo(AppID).ExecutableName
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableBorderlessWindowHotkey "!q", 2560, 1440

Steam.RunGameAndExitWhenClosed(AppID)
