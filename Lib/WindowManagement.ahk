Global WS_BORDER := 0x00800000
Global WS_CAPTION := 0x00C00000
Global WS_SIZEBOX := 0x00040000

Global ABM_GETSTATE := 0x4
Global ABM_SETSTATE := 0xA
Global ABS_NORMAL := 0x0
Global ABS_AUTOHIDE := 0x1

EnableBorderlessWindowHotkey(Key, TargetWidth, TargetHeight) {
	Hotkey Key, ToggleBorderlessWindow

	ToggleBorderlessWindow(key) {
		static PreviousStyle := 0

		MonitorGetWorkArea(, &WLeft, &WTop, &WRight, &WBottom)
		Left := Max((WRight - TargetWidth) // 2, 0)
		Top := Max((WBottom - TargetHeight) // 2, 0)
		Width := Min(TargetWidth, WRight)
		Height := Min(TargetHeight, WBottom)

		CurrentStyle := WinGetStyle("A")
		if (CurrentStyle & WS_CAPTION) {
			WinSetStyle("-" WS_CAPTION | WS_SIZEBOX | WS_BORDER, "A")
			WinMove(Left, Top, Width, Height, "A")
			PreviousStyle := CurrentStyle
		} else {
			WinSetStyle(PreviousStyle, "A")
		}
	}
}

SendTaskbarMessage(Message, Parameter := 0) {
	; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
	; https://learn.microsoft.com/en-us/windows/win32/api/shellapi/ns-shellapi-appbardata
	; typedef struct _AppBarData {
	; 	DWORD  cbSize;
	; 	HWND   hWnd;
	; 	UINT   uCallbackMessage;
	; 	UINT   uEdge;
	; 	RECT   rc;
	; 	LPARAM lParam;
	;  } APPBARDATA, *PAPPBARDATA;

	; hWnd is aligned, so cbSize is not 4 bytes but pointer size
	AppBarData := Buffer(A_PtrSize + A_PtrSize + 4 + 4 + 16 + A_PtrSize, 0)

	NumPut("UInt", AppBarData.Size, AppBarData)
	NumPut("Int64", Parameter, AppBarData, AppBarData.Size - A_PtrSize)

	return DllCall("Shell32\SHAppBarMessage", "UInt", Message, "Ptr", AppBarData)
}

EnableAutoHideTaskbar() {
	SendTaskbarMessage(ABM_SETSTATE, ABS_AUTOHIDE)
}

DisableAutoHideTaskbar() {
	SendTaskbarMessage(ABM_SETSTATE, ABS_NORMAL)
}

ToggleAutoHideTaskbar() {
	if (SendTaskbarMessage(ABM_GETSTATE) = ABS_AUTOHIDE) {
		DisableAutoHideTaskbar()
	} else {
		EnableAutoHideTaskbar()
	}
}
