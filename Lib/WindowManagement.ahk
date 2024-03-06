Global WS_BORDER := 0x00800000
Global WS_CAPTION := 0x00C00000
Global WS_SIZEBOX := 0x00040000

EnableBorderlessWindow(TargetWidth, TargetHeight) {
	Hotkey "!q", ToggleBorderlessWindow

	MonitorGetWorkArea , &WLeft, &WTop, &WRight, &WBottom
	Left := Max((WRight - TargetWidth) // 2, 0)
	Top := Max((WBottom - TargetHeight) // 2, 0)
	Width := Min(TargetWidth, WRight)
	Height := Min(TargetHeight, WBottom)

	ToggleBorderlessWindow(key) {
		WinSetStyle "^" WS_CAPTION | WS_SIZEBOX | WS_BORDER, "A"
		WinMove Left, Top, Width, Height, "A"
	}
}
