#include <Excel.au3>
#include <Array.au3>

HotKeySet("{PAUSE}", "ExitProg")
Global $Msg

Send("!{TAB}")
Sleep(200)
Send("^{HOME}")
Sleep(200)
Send("{DOWN 7}")
Sleep(200)
Send("{RIGHT}")
While 1
	Prog()
	Check()
	NextL()
WEnd

Func ExitProg()
	Exit
EndFunc

Func Prog()
	Sleep(200)
	Send("{F2}")
	Send("+{HOME}")
	Sleep(200)
	Send("^c")
	Send("{ESC}")
	$Msg = ClipGet()
	Send("{RIGHT}")
	Sleep(200)
	Send("{F2}")
	Send("+{HOME}")
	Send("^c")
	Send("{ESC}")
	Sleep(200)
	$Msg = ClipGet() & " " & $Msg
	$Msg = StringStripCR($Msg)
EndFunc

Func NextL()
	Send("{LEFT}")
	Send("{DOWN}")
	ConsoleWrite(@CRLF)
EndFunc

Func Check()
	If FileExists("E:\450s\" & $Msg & ".xlsx") Then
		
		Send("{RIGHT}")
		Send("{F2}")
		Send("+{HOME}")
		Sleep(200)
		Send("^c")
		Send("{ESC}")
		$Test1 = ClipGet()
		$Test1 = StringStripCR($Test1)
		$Test1 &= "/50 Wasn't insterested in extra classes."
		
		Send("{RIGHT}")
		Send("{F2}")
		Send("+{HOME}")
		Sleep(200)
		Send("^c")
		Send("{ESC}")
		$Port1 = ClipGet()
		$Port1 = StringStripCR($Port1)
		$Port1 &= "/30 Wasn't insterested in extra classes."
		
		Send("{RIGHT}")
		Send("{F2}")
		Send("+{HOME}")
		Sleep(200)
		Send("^c")
		Send("{ESC}")
		$Port2 = ClipGet()
		$Port2 = StringStripCR($Port2)
		$Port2 &= "/20 Wasn't insterested in extra classes."
		
		Send("{RIGHT}")
		Send("{F2}")
		Send("+{HOME}")
		Sleep(200)
		Send("^c")
		Send("{ESC}")
		$Test2 = ClipGet()
		$Test2 = StringStripCR($Test2)
		$Test2 &= "/50 Wasn't insterested in extra classes."
		
		Send("{LEFT 4}")
		Send("^o")
		Sleep(200)
		Send("E:\450s\" & $Msg & ".xlsx")
		Send("{ENTER}")
		ConsoleWrite("E:\450s\" & $Msg & ".xlsx" & @CRLF)
		Sleep(600)
		Send("^{HOME}")
		Sleep(200)
		Send("{DOWN 7}")
		Sleep(200)
		Send("{RIGHT 4}")
		Send($Test1)
		Send("{ENTER}")
		Send($Port1)
		Send("{ENTER}")
		Send("{DEL}")
		Send("{ENTER}")
		Send($Port2)
		Send("{ENTER}")
		Send($Test2)
		Send("{ENTER}")
		Send("!f")
		Send("c")
		Send("y")
		Sleep(1000)
	EndIf
EndFunc