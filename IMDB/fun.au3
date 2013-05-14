#include <Inet.au3>
#cs
Author: Bennet van der Gryp
Description: I hated typing in my username and password every bloody day at Standard Bank
#ce
While 1
	If WinExists("Connect to 00172MBXJNB0206.za.sbicdirectory.com") Then
		WinActivate("Connect to 00172MBXJNB0206.za.sbicdirectory.com")
		Send("AA{!}{&}17")
		While WinExists("Connect to 00172MBXJNB0206.za.sbicdirectory.com")
			Sleep(200)
		WEnd
;~ 		Send("{ENTER}")
	EndIf
	If WinExists("Windows Security") Then
		WinActivate("Windows Security")
		Send("SBICZA01\A159994")
		Send("{TAB}")
		Send("AA{!}{&}17")
;~ 		Send("{ENTER}")
		While WinExists("Windows Security")
			Sleep(200)
		WEnd
	EndIf
WEnd