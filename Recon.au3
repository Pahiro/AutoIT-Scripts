#include <Array.au3>
Global $MissingArr[1]
$oMissing = FileOpen("D:\Recon\MissingDocuments.txt")
While 1
   $MissingLine = FileReadLine($oMissing)
   If @error Then ExitLoop
   _ArrayAdd($MissingArr, $MissingLine)
WEnd
_ArrayDelete($MissingArr, 1)

$Data = _filelist('D:\Recon\Files')

$oFile = FileOpen("D:\Recon\Result.txt",1)

FileWrite($oFile, $Data)
FileClose($oFile)

Func _filelist($searchdir)
   Dim $Data
   Dim $Count = 0
   Dim $Flag
   Dim $line
   
   $search = FileFindFirstFile($searchdir & "\*.*")	   
   If $search = -1 Then Exit				
   While 1
	  $Count += 1
	  $file = FileFindNextFile($search)
	  If @error Then				   
		 FileClose($search)			   
		 ExitLoop
	  Elseif  $file = "."  or $file = ".." Then		 
		 ContinueLoop												
	  EndIf

	  If stringinstr($file, ".txt") Then
		 $oFile = FileOpen($searchdir & "\" & $file, 0)
		 While 1
			If $Flag = 'X' Then
			   $Flag = ''
			Else
			   $line = FileReadLine($oFile)
			EndIf
			If @error = -1 Then ExitLoop
			If StringLeft($line, 2) = 'DD' Then
			   For $x = 1 to _ArraySize($MissingArr)-1
				  If StringMid($line, 27, 13) = $MissingArr[$x] Then
					 $Flag = 'X'
				  EndIf
			   Next
			   If $Flag = 'X' Then
				  $Data &= $line & @CRLF
				  While 1 
					 $line = FileReadLine($oFile)
					 If @error = -1 Then ExitLoop
					 If StringLeft($line, 2) = 'DD' Then
						ExitLoop
					 EndIf
					 $Data &= $line & @CRLF					 
				  WEnd
			   EndIf
			EndIf
		 WEnd
		 FileClose($oFile)
	  EndIf
;~ 	  ConsoleWrite($Data)
;~ 	  If $Count = 10 Then ExitLoop
   WEnd
   Return $Data
EndFunc

Func _ArraySize( $aArray )
	SetError( 0 )
	
	$index = 0
	
	Do
		$pop = _ArrayPop( $aArray )
		$index = $index + 1
	Until @error = 1
	
	Return $index - 1
EndFunc