#AutoIt3Wrapper_AU3Check_Parameters= -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#include <OutlookEX.au3>

$iOL_Debug = 2
Global $oOutlook = _OL_Open()

; *****************************************************************************
; Example 1
; Send a html mail to the current user.
; Add an attachment and set importance to high.
; *****************************************************************************
Global $sCurrentUser = $oOutlook.GetNameSpace("MAPI" ).CurrentUser.Name

While @error <> 0
	If WinExists("Microsoft Office Outlook", ) Then
		WinActivate("Microsoft Office Outlook","A program is trying")
;~ 		ControlClick("Microsoft Office Outlook","A program is trying",4774)
		$Arr = ControlGetPos ( "Microsoft Office Outlook", "A program is trying", 4774 )
		MouseClick("left", $Arr[0] + 1950,$Arr[1] + 460,1)
	EndIf
WEnd