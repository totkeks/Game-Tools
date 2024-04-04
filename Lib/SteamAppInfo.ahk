#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ValveKeyValue.ahk

Class AppInfo {
	static FIXED_DATA_SIZE := 60

	__New(buf, &offset) {
		; Header, 8 bytes
		this.appID := NumGet(buf, offset, "UInt"), offset += 4
		this.size := NumGet(buf, offset, "UInt"), offset += 4

		; Fixed data, 60 bytes
		this.infoState := NumGet(buf, offset, "UInt"), offset += 4
		this.lastUpdated := NumGet(buf, offset, "UInt"), offset += 4
		this.picsToken := NumGet(buf, offset, "Int64"), offset += 8
		offset += 20 ; ignore 20 bytes of SHA1
		this.changeNumber := NumGet(buf, offset, "UInt"), offset += 4
		offset += 20 ; ignore 20 bytes of SHA1
		this.dataOffset := offset
		this.buffer := buf
		offset += this.size - AppInfo.FIXED_DATA_SIZE
	}

	data {
		get {
			if (!HasProp(this, "_data")) {
				this._data := ValveKeyValue.ParseBinary(this.buffer, this.dataOffset, this.size - AppInfo.FIXED_DATA_SIZE)
			}
			return this._data
		}
	}

	Name => this.data.appinfo.common.name

	ExecutablePath {
		get {
			launch := this.data.appinfo.config.launch

			For index, value in launch.OwnProps() {
				if (value.config.oslist = "windows") {
					return StrReplace(value.executable, "/", "\")
				}
			}
		}
	}

	ExecutableName {
		get {
			SplitPath(this.ExecutablePath, &name)
			return name
		}
	}

	FullExecutablePath => this.InstallationDirectory "\" this.ExecutablePath
}
