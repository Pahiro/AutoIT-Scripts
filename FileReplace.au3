;~ $file = FileOpen("C:\TEMP\UnitTestFile.txt", 0)
;~ MsgBox(0, "File handle:",$file)
;~ Dim $Lines
;~ While 1
;~ 	$line = FileReadLine($file)
;~ 	MsgBox(0,"",$line)
;~     If @error = -1 Then ExitLoop
;~ 	If StringMid($line, 1, 2) = 'DL' Then
;~ 		If StringMid($line, 80, 3) <> "   " Then
;~ 			$line = StringReplace($line, StringMid($line,80,5), '00' & StringMid($line, 80,3))
;~ 			MsgBox(0, "Line read:", StringMid($line, 80, 5))
;~ 		EndIf
;~ 	EndIf
;~ 	If $line <> "" Then
;~ 		$Lines &= $line & @CRLF
;~ 	EndIf
;~ Wend
;~ FileClose($file)

;~ $file2 = FileOpen("C:\TEMP\1.txt", 2)
;~ FileWrite($file2, $Lines)
;~ FileClose($file2)y
HotKeySet("{ESC}", "F_Exit")

While 1
	Sleep(1000)
	Send("{DOWN}")
	Sleep(200)
	Send("+{F12}")
	Sleep(2000)
	Send("{SPACE}")
WEnd

Func F_Exit()
	Exit
EndFunc