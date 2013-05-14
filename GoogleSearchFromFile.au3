#include <File.au3>
HotKeySet("^s","SendKey")
Global $File
Global $Count
Global $Pos = 0
$File = FileOpen("list.txt",0)
$Count = _FileCountLines("list.txt")
While 1
	Sleep(200)
WEnd

Func SendKey()
	$Pos += 1
	Send("^a")
	Sleep(200)
	$Str = FileReadLine($File)
	ToolTip($Pos & " of " & $Count)
	IF @error = -1 Then Exit
	Send($Str)
	Sleep(200)
	Send("{ENTER}")
EndFunc