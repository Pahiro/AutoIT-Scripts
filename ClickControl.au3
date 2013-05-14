#cs
Author: Bennet van der Gryp
Description: Clicker for pop-up when attaching to Outlook.
#ce
While 1
	If WinExists("Microsoft Office Outlook", "A program is trying") Then
		WinActivate("Microsoft Office Outlook","A program is trying")
		$Arr = ControlGetPos ( "Microsoft Office Outlook", "A program is trying", 4774 )
		MouseClick("left", $Arr[0] + 1950,$Arr[1] + 460,1)
	EndIf
	Sleep(200)
WEnd