$Count = 0
$Lines = ""
;~ For $fnr = 1 to 5
For $nr = 0 to 1000
;~  ToolTip("File " & $fnr & ":" & $nr)
	ToolTip("File " & ":" & $nr)
	$File = FileOpen("C:\TEMP\SAP\PROS_PRD_SAP_DELTA3_INPUT.TXT_delta" & $nr & "_error")
	If $File <> -1 Then
		While 1
			$Line = FileReadLine($File)
			If @error = -1 Then ExitLoop
			If $Line <> "" AND StringInStr($Line, "Errors:") = 0 Then
				$Lines &= $Line & @CRLF
				$Count += 1				
			EndIf
		WEnd
	EndIf
Next
;~ Next
$FileWrite = FileOpen("C:\TEMP\SAP\COMPLETE.txt", 10)
FileWrite($FileWrite, $Lines)
FileWrite($FileWrite, @CRLF)
FileWrite($FileWrite, "Errors:" & $Count)
FileClose($FileWrite)
FileClose($File)
ConsoleWrite("Errors:" & $Count & @CRLF)