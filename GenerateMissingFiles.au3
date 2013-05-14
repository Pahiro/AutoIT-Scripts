$FileRead = FileOpen("C:\TEMP\SAP\SAP2-5.txt",0)

While 1
    $nr = FileReadLine($FileRead)
	If @error = -1 Then 
		ExitLoop
	Else
		ToolTip($nr)
		$nr2 = StringLeft($nr, 1)
		$nr = StringRight($nr, StringLen($nr) - 2)
		$FileWrite = FileOpen("C:\TEMP\SAP\PROS_QAT_SAP" & $nr2 & "_INPUT.TXT_init" & $nr & "_error",10)
		FileWrite($FileWrite, "Errors:0")
		FileClose($FileWrite)
	EndIf
Wend

FileClose($FileRead)