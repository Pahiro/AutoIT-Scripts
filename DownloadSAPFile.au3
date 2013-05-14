#cs
Author: Bennet van der Gryp
Description: Download mulitple files from SAP server.
#ce
#include <SAP.au3>
#include <File.au3>
#include <Array.au3>
HotKeySet("{ESC}","ExitProg")
;~ _SAPSessAttach("Downloads File from Server to WS")
;~ WinActivate("Downloads File from Server to WS")
$File = FileOpen("C:\TEMP\errors.txt")
Sleep(3000)
While 1
	$Line = FileReadLine($File)
	If @error = -1 then ExitLoop
;~ 	_SAPObjValueSet("usr/txtP_OUTFIL", "C:\TEMP\SAP\" & $Line)
;~ 	_SAPObjValueSet("usr/txtP_INFILE", "/usr/sap/CDQ/" & $Line) 
;~ 	_SAPVKeysSend("F8")
	Send("{HOME}")
	Send("+{END}")
	Send("/usr/sap/CDQ/archive/" & $Line)
	Send("{HOME}")
	Send("+{END}")
	Send("/usr/sap/CDQ/archive/" & $Line)
	Send("{TAB}")
	Send("{HOME}")
	Send("+{END}")
	Send("C:\TEMP\SAP\" & $Line)
	Send("{F8}")
	Sleep(600)
WEnd

Func ExitProg()
	Exit
EndFunc