#cs
Author: Bennet van der Gryp
Description:
#ce
#AutoIt3Wrapper_AU3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#include <OutlookEX.au3>
#include <Array.au3>
#include <OutlookEX.au3>
Global $oOutlook = _OL_Open()
Global $Arr[1]
Global $Theme
Global $Today
HotKeySet("{F1}", "ViewAgain")
$File = FileOpen("Drawings.txt", 0)

While 1
	$Line = FileReadLine($File)
	If @error = -1 then ExitLoop
	_ArrayAdd($Arr, $Line)
WEnd
While 1
	If $Today <> @MDAY Then
		$Num = Random(1,100, 1)
		If $Arr[$Num] <> "Done" Then
			$Theme = $Arr[$Num]
;~ 			MsgBox(0,"Theme for Today", $Theme)
	 		$Arr[$Num] = "Done"
			$Today = @MDAY
			SendTo($Theme)
		EndIf
	EndIf
	Sleep(200)
WEnd

Func ViewAgain()
	MsgBox(0,"Theme for Today", $Theme)
EndFunc

Func SendTo($Theme)
	_OL_Wrapper_SendMail($oOutlook, "bennetvdg@gmail.com", "", "", "Theme for Today", $Theme, 0, $olFormatHTML)
EndFunc