#include <GuiConstants.au3>
#include <GuiConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <Timers.au3>
#include <Date.au3>

HotKeySet("{ESC}", "_Exit")

Global $hGUI, $Label
$hGUI = GUICreate("Wedding Countdown", 800, 50, -1, -1, $WS_POPUP)
;~ GUISetBkColor($GUI_BKCOLOR_TRANSPARENT, -1)
$Label = GUICtrlCreateLabel("00 days 00  hours 00 seconds",0,0,800,50)
GUICtrlSetFont ($Label, 32)
GUISetState()
$Data = "00 days 00  hours 00 miuntes 00 seconds"
$Timer = _Timer_SetTimer($hGUI, 1000, "_Update")

Do
	GUICtrlSetData($Label, $Data)
	$msg = GUIGetMsg()
	Sleep(200)
Until $msg = $GUI_EVENT_CLOSE

Func _Update($hWnd, $Msg, $iIDTimer, $dwTime)
	$sType = "s"
	$Now = _NowCalc()
	$Then = "2011/06/25 11:00:00"
;~ 	$MidNight = @Year & "/" & @MON & "/" & @MDAY + 1 & " 00:00:00"
;~ 	ConsoleWrite($Now & @CRLF)
	$Secs = _DateDiff($sType, $Now, $Then)
	
	$Mins = Int($Secs / 60)
	$Secs = $Secs - ($Mins * 60)
	
	$Hours = Int($Mins / 60)
	$Mins = $Mins - ($Hours * 60)
	
	$Days = Int($Hours / 24)
	$Hours = $Hours - ($Days * 24)
	
	$Data = $Days & " days " &  $Hours & " hours " & $Mins & " minutes " & $Secs & " seconds."
;~ 	ConsoleWrite($Secs & @CRLF)
	GUISetState(@SW_LOCK)
	GUICtrlSetData($Label, $Data)
	GUISetState(@SW_UNLOCK)
EndFunc

Func _Exit()
	Exit
EndFunc
