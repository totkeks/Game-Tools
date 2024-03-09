ReadVdfFromFile(path) {
	content := FileRead(path)

	root := {}
	stack := [root]
	state := "start"
	key := ""

	Loop Parse content {
		char := A_LoopField

		switch (state) {
			case "start":
				switch (char) {
					case "}":
						stack.RemoveAt(stack.Length)
					case "`"":
						state := "parseKey"
				}

			case "parseKey":
				switch (char) {
					case "`"":
						state := "findValue"
					default:
						key .= char
				}

			case "findValue":
				switch (char) {
					case "{":
						nestedObject := {}
						stack[stack.Length].%key% := nestedObject
						stack.Push(nestedObject)
						state := "start"
						key := ""
					case "`"":
						state := "readValue"
				}

			case "readValue":
				switch (char) {
					case "`"":
						stack[stack.Length].%key% := value
						state := "start"
						value := ""
						key := ""
					default:
						value .= char
				}
		}
	}

	return root
}

GetLibraryFolders() {
	vdf := ReadVdfFromFile(EnvGet("ProgramFiles(x86)") "\Steam\steamapps\libraryfolders.vdf")

	folders := []

	For index, folder in vdf.libraryfolders.OwnProps() {
		folders.Push(folder.path)
	}

	return folders
}

GetAppDetails(appID) {
	for folder in GetLibraryFolders() {
		appmanifestFile := folder "\steamapps\appmanifest_" appID ".acf"

		if (FileExist(appmanifestFile)) {
			appManifest := ReadVdfFromFile(appmanifestFile)

			return {
				Name: appManifest.AppState.name,
				Directory: folder "\steamapps\common\" appManifest.AppState.installdir
			}
		}
	}
}

CheckForAndAskToCreateStartMenuShortcut(AppID) {
	appDetails := GetAppDetails(AppID)
	shortcutPath := A_StartMenu "\Programs\Steam\" appDetails.Name ".lnk"

	if (!FileExist(shortcutPath)) {
		answer := MsgBox("Currently there is no start menu entry for " appDetails.Name ". Do you want to create a start menu entry to launch this AHK script & " appDetails.Name " together?", "Create Start Menu Shortcut", "YesNo")

		if (answer == "Yes") {
			; TODO: find a way to get the actual executable location using the Steam console and app_info_print
			executablePath := appDetails.Directory "\" appDetails.Name ".exe"
			FileCreateShortcut A_ScriptFullPath, shortcutPath, A_ScriptDir,, "Run " appDetails.Name " and its companion AHK script", executablePath
		}
	}
}

RunGameAndExitWhenClosed(AppID, ExecutableName) {
	; don't start the game twice, e.g. when reloading the script
	if (!ProcessExist(ExecutableName)) {
		Run("steam://rungameid/" AppID)
	}
	ProcessWait(ExecutableName)
	ProcessWaitClose(ExecutableName)
	ExitApp()
}
