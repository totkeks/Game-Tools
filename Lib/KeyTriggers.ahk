SendKeyWhenKeyIsHeldFor(KeyToSend, KeyToHold, HoldTime) {
	Hotkey "~" KeyToHold, OnKeyHold

	OnKeyHold(key) {
		StartTime := A_TickCount

		; Wait for the key to be released
		KeyWait KeyToHold

		if (A_TickCount - StartTime > HoldTime) {
			Send KeyToSend
		}
	}
}
