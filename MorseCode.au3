#include <Array.au3>
Local $Ver[1]
$Count = 0
$String = ""
HotKeySet("{ESC}", "ExitProg")
$next = 0
For $Y = 525 to 554
	$x = 0
	$x = PixelSearch(556,$Y,665,$Y,16777215) ;Find the first white pixel in the row.
	If @error = 1 Then ExitLoop ;If there wasn't a pixel found in this row, exit.
 	Consolewrite($x[0] & "," & $x[1] & ":" &  _GetPos($x[0],$x[1],556,525,665,554) & @CRLF)
	$String &= Chr($x[0]-556+$next) ;ASCII = Coord[x]-StartingPoint+leftover pixels from the previous row.
	$Error = @error
	While $Error <> 1
		$hold = $x[0]
		$x = PixelSearch($x[0]+1,$Y,665,$Y,16777215)
		If @error = 1 then 
			$next = 665 - $hold
			ExitLoop
		EndIf
		Consolewrite($x[0] & "," & $x[1] & ":" &  _GetPos($x[0],$x[1],556,525,665,554) & @CRLF)
		$Store = $x[0] - $hold
		$String &= Chr($Store)
	WEnd
Next
ConsoleWrite($String)

Func _GetPos($WX, $WY, $SX, $SY, $EX, $EY)
	$XOffset = $WX - $SX ;Which column
	$YOffset = $WY - $SY+1 ;Which row (Start counting at 1)
	$NumberofColumns = $EY - $SY ;Number of cells per column
	$CurrentCell = ($YOffset-1) * $NumberofColumns + $XOffset ;All cells up until last row, + cells in current row
	Return $NumberofColumns ;$CurrentCell
EndFunc

Func ExitProg()
	Exit
EndFunc