#Requires AutoHotkey v2.0
#SingleInstance Force

class ValveKeyValue {
	static ParseBinary(data, offset, size) {
		initialOffset := offset

		root := {}
		stack := [root]
		state := "parseType"
		key := ""
		valueType := ""

		While (offset - initialOffset < size) {
			char := NumGet(data, offset, "UChar")

			switch (state) {
				case "parseType":
					switch (char) {
						case 0:
							valueType := "object"
							state := "parseKey"

						case 1:
							valueType := "string"
							state := "parseKey"

						case 2:
							valueType := "int"
							state := "parseKey"

						case 8:
							stack.RemoveAt(stack.Length)
							state := "parseType"
					}

				case "parseKey":
					switch (char) {
						case 0:
							switch (valueType) {
								case "object":
									nestedObject := {}
									stack[stack.Length].%key% := nestedObject
									stack.Push(nestedObject)
									key := ""
									state := "parseType"

								case "string":
									state := "parseString"

								case "int":
									state := "parseInt"
							}

						default:
							key .= Chr(char)
					}

				case "parseString":
					switch (char) {
						case 0:
							stack[stack.Length].%key% := value
							value := ""
							key := ""
							state := "parseType"

						default:
							value .= Chr(char)
					}

				case "parseInt":
					stack[stack.Length].%key% := NumGet(data, offset, "UInt")
					offset += 3
					key := ""
					state := "parseType"

			}

			offset++
		}

		return root
	}

	static ParseTextFromFile(path) {
		content := FileRead(path)
		return ValveKeyValue.ParseText(content)
	}

	static ParseText(data) {
		root := {}
		stack := [root]
		state := "start"
		key := ""

		Loop Parse data {
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
}
