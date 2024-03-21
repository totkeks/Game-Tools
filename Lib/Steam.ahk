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
					return value.executable
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

Class Steam {
 	static Apps {
		get {
			if (!HasProp(this, "_Apps")) {
				this.LoadAppInfo()
			}
			return this._Apps
		}
	}

	static Libraries {
		get {
			if (!HasProp(this, "_Libraries")) {
				this.LoadLibraries()
			}
			return this._Libraries
		}
	}

	; Locate the `appinfo.vdf` file and then parse it
	static LoadAppInfo() {
		data := FileRead("C:\Program Files (x86)\Steam\appcache\appinfo.vdf", "RAW")
		this.ParseAppInfo(data)
	}

	; Parses the binary appinfo.vdf from a buffer object `data`
	static ParseAppInfo(data) {
		magic := NumGet(data, 0, "UInt")
		universe := NumGet(data, 4, "UInt")

		apps := Map()
		offset := 8

		while true {
			appID := NumGet(data, offset, "UInt")
			if (appID == 0) {
				break
			}

			app := AppInfo(data, &offset)
			this.EnrichAppInfoWithLibraryData(app)

			apps.Set(appID, app)
		}

		this._Apps := apps
	}

	static EnrichAppInfoWithLibraryData(app) {
		for folder in this.Libraries {
			appmanifestFile := folder "\steamapps\appmanifest_" app.appID ".acf"

			if (FileExist(appmanifestFile)) {
				appManifest := ValveKeyValue.ParseTextFromFile(appmanifestFile)

				app.InstallationDirectory := folder "\steamapps\common\" appManifest.AppState.installdir
			}
		}
	}

	static LoadLibraries() {
		data := FileRead("C:\Program Files (x86)\Steam\steamapps\libraryfolders.vdf")
		vdf := ValveKeyValue.ParseText(data)

		folders := []
		for index, folder in vdf.libraryfolders.OwnProps() {
			folders.Push(folder.path)
		}

		this._Libraries := folders
	}

	static CheckForAndAskToCreateStartMenuShortcut(appID) {
		app := this.GetAppInfo(appID)
		shortcutPath := A_StartMenu "\Programs\Steam\" app.Name ".lnk"

		if (!FileExist(shortcutPath)) {
			answer := MsgBox("Currently there is no start menu entry for " app.Name ". Do you want to create a start menu entry to launch this AHK script & " app.Name " together?", "Create Start Menu Shortcut", "YesNo")

			if (answer == "Yes") {
				FileCreateShortcut A_ScriptFullPath, shortcutPath, A_ScriptDir,, "Run " app.Name " and its companion AHK script", app.FullExecutablePath
			}
		}
	}

	; Remove references so AHK can clean up the memory
	static Cleanup() {
		this._Apps := unset
		this._Libraries := unset
	}

	static RunGameAndExitWhenClosed(AppID, CleanupFunction := unset) {
		executableName := this.GetAppInfo(AppID).ExecutableName

		; don't start the game twice, e.g. when reloading the script
		if (!ProcessExist(executableName)) {
			Run("steam://rungameid/" AppID)
		}

		this.Cleanup()
		ProcessWait(executableName)
		ProcessWaitClose(executableName)

		if (IsSet(CleanupFunction)) {
			CleanupFunction()
		}

		ExitApp()
	}


	static GetAppInfo(appID) {
		return this.Apps.Get(appID)
	}
}
