HotKeySet("{ESC}", "ES")

WinActivate("Untitled - Paint")
$CountX = 1
$CountY = 1
For $y = 1 to 640 STEP 21.25
	For $x = 1 to 640 STEP 21.25
		$Arr = PixelSearch(776+$x,262+$y, 776+21+$x,262+21+$y, 0xED1C24) ;776, 262   796,282
		If @error = 1 Then
;~ 			MsgBox(0, "","")
		EndIf
		WinActivate("Minesweeper")
		If IsArray($Arr) Then
			MouseClick("right", $Arr[0]-729, $Arr[1]+25) ;95,289  ;836,263
		Else
			MouseClick("left",781-729+$x,267+25+$y)
		EndIf
;~ 		MouseMove(776+$x, 262+$y)
	Next
	$CountY += 1
Next
Func ES()
	Exit
EndFunc