#cs
Author: Bennet van der Gryp
Description: This moved any *.avi files into their own folders. An attempt to standardise my Movie collection.
#ce
$search = FileFindFirstFile("G:\New Folder\*.*")  

If $search = -1 Then
	MsgBox(0, "Error", "No files/directories matched the search pattern")
	Exit
EndIf
;~ $sFile = FileFindNextFile($search)
;~ $sFile = FileFindNextFile($search)
While 1
	$sFile = FileFindNextFile($search)
	If @error Then ExitLoop
	$MovieName = StringLeft($sFile,StringLen($sFile)-4)
	If Not StringInStr($sFile, "Part") Then
		FileMove("G:\New Folder\" & $sFile, "G:\New Folder\" & $MovieName & "\" & $sFile,8)
	EndIf
WEnd