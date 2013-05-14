#include <File.au3>
#include <Array.au3>
#cs
Author: Bennet van der Gryp
Description: Update books with metadata.
#ce
Dim $ArrBatch[1000][10]

$Arr = _FileListToArray("C:\Users\Bennet van der Gryp\eBooks\mobi", "*.mobi")
$Y = 0
For $Item in $Arr
	$ArrBatch[$Y][0] = $Item
	$Item = StringReplace($Item, ".mobi", "")
	$File = StringSplit($Item, " - ",1)
	$X = 1
	For $Row in $File
		$ArrBatch[$Y][$X] = $Row
		$X += 1
	Next
	$Y += 1
;~ 	$Index = _ArrayMaxIndex($Arr)
Next

_ArrayDelete($ArrBatch,0)

$File = FileOpen("TitleAuth.bat",2)

$Y = 0
$MaxInd = _ArrayMaxIndex($ArrBatch)
For $Y = 0 To 998
	If $ArrBatch[$Y][0] = "" Then
		ExitLoop
	EndIf
	FileWrite($File, 'mobi2mobi "' & $ArrBatch[$Y][0] & '" --outfile "' & $ArrBatch[$Y][0] & '" --author "' & $ArrBatch[$Y][$ArrBatch[$Y][1]+1] & '" ')
	If $ArrBatch[$Y][1] = 2 Then
		FileWrite($File, '--title "' & $ArrBatch[$Y][2] & '"')
	ElseIf $ArrBatch[$Y][1] = 3 Then
		FileWrite($File, '--title "' & $ArrBatch[$Y][2] & " - " & $ArrBatch[$Y][3] & '"')
	EndIf
	FileWrite($File, @crlf)
;~ 	Exit
Next

FileClose($File)

