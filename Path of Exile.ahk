#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <Steam>
#Include <WindowManagement>
#Include <KeyTriggers>

AppID := 238960
ExecutableName := Steam.GetAppInfo(AppID).ExecutableName
Steam.CheckForAndAskToCreateStartMenuShortcut(AppID)

HotIfWinActive "ahk_exe" ExecutableName
	EnableBorderlessWindowHotkey "!q", 2560, 1440

	; Stash tab scrolling
	^WheelUp::SendInput "{Left}"
	^WheelDown::SendInput "{Right}"

	; Available chat commands
	; https://www.poewiki.net/wiki/Chat#Commands
	SendChatMessage(message) {
		BlockInput true
		; Send the `Close All User Interface` key
		SendInput "{XButton1}"
		Sleep 2
		SendInput "{Enter}"
		Sleep 2
		SendInput message
		SendInput "{Enter}"
		BlockInput false
	}

	F2::SendChatMessage("/remaining")
	F3::SendChatMessage("/hideout")
	F4::SendChatMessage("/leave")
	F5::SendChatMessage("/exit")

Steam.RunGameAndExitWhenClosed(AppID)
