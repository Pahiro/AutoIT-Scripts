#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <Array.au3>

HotKeySet("{ESC}", "_Exit")

$var = FileOpen(@ScriptDir & "\SpeedRead.txt")
$Content = FileRead($var)
$Arr = StringSplit($Content, " ")
;~ _ArrayDisplay($Arr)
SpeedRead(6,400)

Func SpeedRead(ByRef $nr, ByRef $speed)
	$hGUI = GUICreate("Words", 800, 50, -1, -1, $WS_POPUP)
	GUISetBkColor(0xE0FFFF)
	$Label = GUICtrlCreateLabel("",0,0,800,50)
	GUICtrlSetFont ($Label, 32)
	GUISetState()
	$x = 1
	$y = $nr
	$Str = ""
	$Mark = ""
	
	While 1
		While $x <> $y
			$Str &= $Arr[$x] & " "
			$x += 1
		WEnd
		
		GUICtrlSetData($Label, $Str)
		Sleep($speed)
		GUICtrlSetData($Label, "")
		
		$Answ = InputBox("What did you see?", "Type out the words that you saw.", $Mark, "", -1, -1, 500, 100)
		$Answ = StringReplace($Answ, ",", "")
		$Answ = StringReplace($Answ, ".", "")
		$Answ = StringLower($Answ)
		$Answ = StringStripWS($Answ, 8)
		$Backup = $Str
		$Str = StringReplace($Str, ",", "")
		$Str = StringReplace($Str, ".", "")
		$Str = StringLower($Str)
		$Str = StringStripWS($Str, 8)
		
		If $Answ = $Str Then
			$Mark = "Correct!"
		Else
			$Mark = $Backup
		EndIf

		$Str = ""
		$y += $nr
;~ 		ConsoleWrite($y)
	WEnd
EndFunc

Func _Exit()
	Exit
EndFunc