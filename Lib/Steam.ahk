#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ValveKeyValue.ahk
#Include SteamAppInfo.ahk

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
			folders.Push(StrReplace(folder.path, "\\", "\"))
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

	static RunGameAndExitWhenClosed(AppID, CleanupFunction := unset, ExecutableNameOverride := unset) {
		if (IsSet(ExecutableNameOverride)) {
			executableName := ExecutableNameOverride
		} else {
			executableName := this.GetAppInfo(AppID).ExecutableName
		}

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
