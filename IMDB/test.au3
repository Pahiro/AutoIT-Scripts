#cs
Author: Bennet van der Gryp
Description: Test Script
#ce
HotKeySet("{ESC}", "ExitProg")
#include <Debug.au3>
_DebugSetup ("Dir Move", True,2)
$search = FileFindFirstFile("G:\SrcMovies\*.*")
While 1
	$sFile = FileFindNextFile($search)
;~ 	$sFile = FileReadline($File)
	If @error Then ExitLoop
;~ 	$MovieName = StringLeft($sFile,StringLen($sFile)-4)
	$MovieName = $sFile
;~ 	
;~ 	Exit
	$Date = _GetDate($MovieName)
	ConsoleWrite($Date & @CRLF)
	If $Date <> "0</P" Then
		_Move($Date,$MovieName)
	EndIf
WEnd

Func _GetDate(ByRef $MovieName)
	$Date = 0
	$File = FileOpen("G:\SrcMovies\" & $MovieName & "\mymovies.xml")
	While 1
		$Line = FileReadLine($File)
		If @error = 1 Then
			ExitLoop
		EndIf
		If StringInStr($Line, "<ProductionYear>") <> 0 Then
			$Date = StringMid($Line, 19, 4)
;~ 			$Date = StringRight($Date, 4)
;~ 			MsgBox(0,"",$Date)
			ExitLoop
		EndIf	
	WEnd
	Return $Date
	FileClose($File)
EndFunc

Func _Move(ByRef $Date, ByRef $MovieName)
	$Source = "G:\SrcMovies\" & $MovieName
	$Dest = "G:\Movies\" & $MovieName & " (" & $Date & ")"
	$SearchFile = FileFindFirstFile("G:\SrcMovies\" & $MovieName & "\*.*")
	While 1 
		$sFile = FileFindNextFile($SearchFile)
		If @error = 1 then ExitLoop
		FileMove($Source & "\" & $sFile, $Dest & "\" & $sFile, 8)
		DirRemove($Source)
		_DebugOut ("Directory Move attempted." & " @error = " & @error & "."  & @CRLF & $MovieName & " (" & $Date & ")" & @CRLF & $sFile) 
	WEnd
;~ 	DirMove($Source, $Dest, 1)
;~ 	Exit
EndFunc
;~ While 1
;~ 	Send("{SPACE}")
;~ 	Sleep(200)
;~ 	Send("{DOWN}")
;~ WEnd

Func ExitProg()
	Exit
EndFunc