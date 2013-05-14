$File = FileOpen("G:\Movies.txt")
While 1
	$Line = FileReadLine($File)
	If @error = -1 then ExitLoop
	If StringInStr($Line, "Title: ") Then
		$Title = StringReplace($Line, "Title: ","")
	EndIf
	If StringInStr($Line, "Rating: ") Then
		$Rating = StringReplace($Line, "Rating: ","")
		ConsoleWrite($Rating & @CRLF)
		If $Rating <> "Could Not Find!" AND $Rating <> "-" Then
			DirMove("G:\New Folder\" & $Title,"G:\Done\" & $Title & " [" & $Rating & "]")
		EndIf
	EndIf
WEnd