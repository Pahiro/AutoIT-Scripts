#Include <File.au3>
#Include <Array.au3>
#Include <Pyro.au3>

$Dir = "C:\Users\Bennet van der Gryp\Downloads\Nanotech\Reading Material\IEEE.org\"
$FileList=_FileListToArray($Dir)
If @Error=1 Then
    MsgBox (0,"","No Folders Found.")
    Exit
EndIf
If @Error=4 Then
    MsgBox (0,"","No Files Found.")
    Exit
EndIf

For $x = 1 to $FileList[0]
	$Property = "CreationDate"
	$Prop = _PDFProperty($Dir & $FileList[$x], $Property)
	$String = StringRight($Prop,StringLen($Prop)-2)
	ConsoleWrite($Prop)
;~ 	_FileRename($Dir & $FileList[$x], $Dir & $String & ".pdf")
;~ 	_ArrayDisplay($Prop)
Next


Func _FileRename($s_Source, $s_Destination, $i_Flag = 0)
    Local $i
    $i = FileMove($s_Source, $s_Destination, $i_Flag)
    Return $i
EndFunc


