
While 1
	WinWaitActive("Enter Package/Request")
	Sleep(200)
	Send("{TAB 4}")
	Send("{ENTER}")
	Sleep(500)
	WinWaitActive("Complete")
	Sleep(200)
	Send("{TAB 8}")
	Send("{ENTER}")
	Sleep(3000)
	Send("^{F3}")
WEnd