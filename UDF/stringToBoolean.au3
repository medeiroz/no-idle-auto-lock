#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Func _StringToBoolean($value)
	return $value == True Or $value == "True" Or $value == "true" Or $value == 1 Or $value = "1"
EndFunc
