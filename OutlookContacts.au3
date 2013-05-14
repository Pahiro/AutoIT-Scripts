#include <Array.au3>
HotKeySet("{F1}", "EXITPROG")
$File = FileOpen("C:\TEMP\FBOOK\FBOOK.txt")
WinActivate("Contacts - Microsoft Outlook")

While 1
	$Line = FileReadLine($File)
	If @error <> 0 Then
		ExitLoop
	EndIf
	$AR = StringSplit($Line, ",")
	If $AR[2] <> "" Then
		Send("{ENTER}")
		While WinExists($AR[1] & " - Contact") = 0
;~ 			ConsoleWrite($AR[1] & @CRLF)
			Sleep(200)
		WEnd
		Send("{TAB 4}")
		Send("{ENTER}")
		While WinExists("Add Contact Picture") = 0
			Sleep(200)
		WEnd
		Send("C:\TEMP\FBOOK\" & $AR[1] & ".jpg")
		Send("{ENTER}")
		Sleep(200)
		Send("{ESC}")
		Send("{ENTER}")
		Send("{DOWN}")
;~ 		Exit
;~ 		Send($AR[1])
;~ 		Send("{TAB 8}")
;~ 		Send($AR[2])
;~ 		Send("{ENTER}")
	EndIf
;~ 	If WinExists("Duplicate Contact Detected") Then
;~ 		Send("{ESC 3}")
;~ 	EndIf
WEnd

Func EXITPROG()
	Exit
EndFunc