#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <Windows>
#Include <KeyTriggers>

RequireAdminPrivileges()

AppID := 2139460
ExecutableName := Steam.GetAppInfo(AppID).ExecutableName
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableBorderlessWindowHotkey "!q", 3440, 1440

Steam.RunGameAndExitWhenClosed(AppID)
