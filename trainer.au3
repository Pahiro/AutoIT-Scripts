
HotKeySet("{ESC}","ExProg")
MouseClick("left",722,743,1,1)
While 1
	$coord = PixelSearch(289,275,779,765,0xFF0000)
	If @error <> 1 Then
		MouseClick("left",$coord[0]+5,$coord[1]+13,1,1)
	EndIf
	sleep(100)
WEnd
Func ExProg()
	Exit
EndFunc