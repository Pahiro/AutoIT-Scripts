#include <File.au3>

_filelist('C:\TEMP\Test')

Func _filelist($searchdir)
Dim $Data
$search = FileFindFirstFile($searchdir & "\*.*")	   
If $search = -1 Then return -1				
While 1
	$file = FileFindNextFile($search)				
	If @error Then				   
	  FileClose($search)			   
	  return									 
	Elseif  $file = "."  or $file = ".." Then		 
	  ContinueLoop												
	ElseIf stringinstr(FileGetAttrib($searchdir & "\" & $file),"D") then		
	  _filelist($searchdir & "\" & $file)		 
  EndIf
	If stringinstr($file, ".txt") Then
;~ 		ConsoleWrite($searchdir & "\" & $file & @crlf )
		$oFile = FileOpen($searchdir & "\" & $file, 0)
		While 1
			$line = FileRead($file)
			ConsoleWrite($line)
			If @error = -1 Then ExitLoop
			If StringLeft($line, 2) = 'DL' Then
				$Data &= $line & @CRLF
				ConsoleWrite($line & @CRLF)
			ElseIf StringLeft($line, 2) = 'DD' Then
				$Data &= $line & @CRLF
				ConsoleWrite($line & @CRLF)
			EndIf
		Wend
		FileClose($oFile)
;~ 		ConsoleWrite($Data)
	EndIf
	
WEnd
EndFunc