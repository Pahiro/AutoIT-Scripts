#cs
Author: Bennet van der Gryp
Description: List of movies in a text file. Fix up the file for further processing.
#ce
$File = FileOpen("G:\Movies.txt")
While 1
	$Line = FileReadLine($File)
	If @error = -1 then ExitLoop
	If StringInStr($Line, "Title: ") Then
		$Title = StringReplace($Line, "Title: ","")
	EndIf
	If StringInStr($Line, "Poster: ") Then
		$Poster = StringReplace($Line, "Poster: ","")
		ConsoleWrite($Poster & @CRLF)
		If $Poster <> "Could Not Find!" Then
			InetGet($Poster, "G:\New Folder\" & $Title & "\folder.jpg")
		EndIf
	EndIf
WEnd