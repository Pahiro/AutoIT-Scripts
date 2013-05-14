#cs
Author: Bennet van der Gryp
Description:
#ce
AutoItSetOption("WinTitleMatchMode", 2)
#include <GUIConstantsEx.au3>
HotKeySet("{ESC}", "ExitProg")
$x = 3
While 1
	WinActivate("Firefox")
;~ 	MouseClick("left", 217, 85)
 	MouseMove(217, 85)
;~ 	Sleep(200)
;~ 	MouseMove(296,132)
;~ 	Sleep(200)
;~ 	MouseClick("left", 545, 195)
	$Hold = ClipGet()
	While $Hold = ClipGet()
		Sleep(200)
	WEnd
	WinActivate("Free Download Manager")
	MouseClick("left", 20,61)
	Sleep(1000)
	$hWnd = WinGetHandle("Add download")
	Send("^v")
	ControlSetText($hWnd,"",1011,$x & ".mp4")
	ControlClick($hWnd,"",1)
	WinActivate("Firefox")
;~ 	MouseClick("left", 1051, 310)
;~ 	Sleep(10000)
	$x -= 1
WEnd

Func ExitProg()
	Exit
EndFunc