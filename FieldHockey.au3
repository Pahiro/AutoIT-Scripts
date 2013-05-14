#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <Array.au3>
#include <WindowsConstants.au3>

Dim $Arr[11] = ["G","S","LB","CB","RB","LL","CL","RL","LF","CF","RF"]
Local $X, $Y, $Start, $Count, $xHold, $yHold, $hPen
Global $hGUI, $hImage, $hGraphic
Global $HasBall = 10
Global $ArrItem[1], $XArr[1], $YArr[1], $ArrImage[1]
Global $Clicked, $Clicked2
; Create GUI
$hGUI = GUICreate("Field Hockey v0.1", @DesktopWidth, @DesktopHeight)
GUISetBkColor ( 0x92D050, $hGui )
GUISetState()

; Load PNG image
_GDIPlus_StartUp()
$hImage   = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\HockeyField.png")

; Draw PNG image
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
$hPen = _GDIPlus_PenCreate(0xFFFFFFFF, 6)
#region Field Frame
_GDIPlus_GraphicsDrawLine($hGraphic,@DesktopWidth-50, @DesktopHeight-50, 50, @DesktopHeight-50, $hPen)
_GDIPlus_GraphicsDrawLine($hGraphic,50, @DesktopHeight-50, 50, 50, $hPen)
_GDIPlus_GraphicsDrawLine($hGraphic,50, 50, @DesktopWidth-50, 50, $hPen)
_GDIPlus_GraphicsDrawLine($hGraphic,@DesktopWidth-50, 50, @DesktopWidth-50, @DesktopHeight-50, $hPen)
#endregion
_GDIPlus_GraphicsDrawLine($hGraphic,(@DesktopWidth-50)*0.5, 50, (@DesktopWidth-50)*0.5, @DesktopHeight-50, $hPen) ; Middle Line
_GDIPlus_GraphicsDrawLine($hGraphic,(@DesktopWidth-50)*0.25, 50, (@DesktopWidth-50)*0.25, @DesktopHeight-50, $hPen) ;Left Quarter Line
_GDIPlus_GraphicsDrawLine($hGraphic,(@DesktopWidth-50)*0.75, 50, (@DesktopWidth-50)*0.75, @DesktopHeight-50, $hPen) ;Right Quarter Line

_GDIPlus_GraphicsDrawRect($hGraphic,50, @DesktopHeight*0.5 - 75, 50, 150, $hPen) ;Home Goal
_GDIPlus_GraphicsDrawRect($hGraphic,@DesktopWidth-100, @DesktopHeight*0.5 - 75, 50, 150, $hPen) ;Visitor's Goal
;~ _GDIPlus_GraphicsDrawImage($hGraphic, $hImage, 0, 0)
$File = FileOpen(@ScriptDir & "\GamePlans\GamePlan01.txt")
$Line = FileReadLine($File)
$ArrPos = StringSplit($Line, "|")
For $Z = 0 to 10
	$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\" & $Arr[$Z] & ".png")
	
	$Start = StringInStr($ArrPos[$Z+1], ":") + 1
	$Count = StringInStr($ArrPos[$Z+1], ",") - $Start
	$X = StringMid($ArrPos[$Z+1], $Start, $Count)/739*@DesktopWidth
	_ArrayAdd($XArr, $X)
	$Start = StringInStr($ArrPos[$Z+1], ",") + 1
	$Count = StringInStr($ArrPos[$Z+1], "|") - $Start
	$Y = StringMid($ArrPos[$Z+1], $Start, $Count)/572*@DesktopHeight
	_ArrayAdd($YArr, $Y)
	_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $X, $Y)
	_ArrayAdd($ArrImage, $hImage)
	If $HasBall = $Z+1 Then
		$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\B.png")
		$BallX = $X
		$BallY = $Y-16
		_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $BallX, $BallY)
	EndIf
;~ 	$Hold = guictrlcreateinput("", $X,$Y, 50, 50)
;~     GUICtrlSetBkColor(-15, $GUI_BKCOLOR_TRANSPARENT)
;~ 	_ArrayAdd($ArrItem, $Hold)
	ConsoleWrite($Arr[$Z] & ":" & $X & "," & $Y & "|")
;~ 	Exit
Next
;~ _ArrayDisplay($ArrItem)
; Loop until user exits
 While 1
	$msg = GUIGetMsg()
	$mouse = GUIGetCursorInfo($hGUI)
	Switch $msg
	Case $GUI_EVENT_CLOSE
			_GDIPlus_GraphicsDispose($hGraphic)
			_GDIPlus_ImageDispose($hImage)
			_GDIPlus_ShutDown()
			Exit
	Case Else
		If $mouse[2] = 1 Then
			$aMPos = MouseGetPos()
			If $Clicked = 0 Then
				Select
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[1], $YArr[1], 25, 25)
						ToolTip("Goalie")
						$Clicked = 1
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[2], $YArr[2], 25, 25)
						ToolTip("Sweeper")
						$Clicked = 2
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[3], $YArr[3], 25, 25)
						ToolTip("Left Back")
						$Clicked = 3
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[4], $YArr[4], 25, 25)
						ToolTip("Center Back")
						$Clicked = 4
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[5], $YArr[5], 25, 25)
						ToolTip("Right Back")
						$Clicked = 5
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[6], $YArr[6], 25, 25)
						ToolTip("Left Link")
						$Clicked = 6
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[7], $YArr[7], 25, 25)
						ToolTip("Center Link")
						$Clicked = 7
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[8], $YArr[8], 25, 25)
						ToolTip("Right Link")
						$Clicked = 8
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[9], $YArr[9], 25, 25)
						ToolTip("Left Forward")
						$Clicked = 9
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[10], $YArr[10], 25, 25)
						ToolTip("Center Forward")
						$Clicked = 10
					Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[11], $YArr[11], 25, 25)
						ToolTip("Right Forward")
						$Clicked = 11
					Case Else
						$Clicked = 0
					EndSelect

				If $xHold = "" AND $yHold = "" AND $Clicked <> 0 Then
					$xHold = $aMPos[0]
					$yHold = $aMPos[1]
				EndIf
				EndIf
		ElseIf $mouse[2] = 0 Then
			;Mouse Resleased!
			If $Clicked <> 0 Then
;~ 				ToolTip("")
				$hPen = _GDIPlus_PenCreate(0xFFFF0000, 2)
				$aMPos = MouseGetPos()
				_GDIPlus_GraphicsDrawLine($hGraphic, $xHold, $yHold, $aMPos[0], $aMPos[1], $hPen)
				$xHold = ""
				$yHold = ""
;~ 				_GDIPlus_ImageDispose($ArrImage[$Clicked])
				$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\" & $Arr[$Clicked-1] & ".png")
				_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $aMPos[0]-15,$aMPos[1]-15)
				If $HasBall = $Clicked Then
					$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\B.png")
					$BallX = $aMPos[0]-15
					$BallY = $aMPos[1]-30
					_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $BallX, $BallY)
				EndIf
				_ArrayDelete($XArr, $Clicked)
				_ArrayDelete($YArr, $Clicked)
				_ArrayInsert($XArr, $Clicked, $aMPos[0]-15)
				_ArrayInsert($YArr, $Clicked, $aMPos[1]-15)
				$Clicked = 0
			EndIf
		EndIf
		If $mouse[3] = 1 Then
			;Passing the ball.
			$aMPos = MouseGetPos()
			Select
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[1], $YArr[1], 25, 25)
					ToolTip("Goalie")
					$Clicked2 = 1
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[2], $YArr[2], 25, 25)
					ToolTip("Sweeper")
					$Clicked2 = 2
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[3], $YArr[3], 25, 25)
					ToolTip("Left Back")
					$Clicked2 = 3
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[4], $YArr[4], 25, 25)
					ToolTip("Center Back")
					$Clicked2 = 4
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[5], $YArr[5], 25, 25)
					ToolTip("Right Back")
					$Clicked2 = 5
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[6], $YArr[6], 25, 25)
					ToolTip("Left Link")
					$Clicked2 = 6
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[7], $YArr[7], 25, 25)
					ToolTip("Center Link")
					$Clicked2 = 7
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[8], $YArr[8], 25, 25)
					ToolTip("Right Link")
					$Clicked2 = 8
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[9], $YArr[9], 25, 25)
					ToolTip("Left Forward")
					$Clicked2 = 9
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[10], $YArr[10], 25, 25)
					ToolTip("Center Forward")
					$Clicked2 = 10
				Case _PointInEllipse($aMPos[0], $aMPos[1], $XArr[11], $YArr[11], 25, 25)
					ToolTip("Right Forward")
					$Clicked2 = 11
			EndSelect
		ElseIf $mouse[3] = 0 Then
			If $Clicked2 <> 0 Then
				$HasBall = $Clicked2
				$hPen = _GDIPlus_PenCreate(0xFF000000, 1)
				$aMPos = MouseGetPos()
				_GDIPlus_GraphicsDrawLine($hGraphic, $BallX+25, $BallY+45, $aMPos[0], $aMPos[1], $hPen)
				$BallX = $aMPos[0]-30
				$BallY = $aMPos[1]-50
				$xHold = ""
				$yHold = ""
;~ 				$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\" & $Arr[$Clicked-1] & ".png")
;~ 				_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $aMPos[0]-15,$aMPos[1]-15)
				If $HasBall = $Clicked2 Then
					$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\GamePlans\Pics\B.png")
					_GDIPlus_GraphicsDrawImage($hGraphic, $hImage, $aMPos[0]-35, $aMPos[1]-27)
				EndIf
				_ArrayDelete($XArr, $Clicked2)
				_ArrayDelete($YArr, $Clicked2)
				_ArrayInsert($XArr, $Clicked2, $aMPos[0]-15)
				_ArrayInsert($YArr, $Clicked2, $aMPos[1]-15)
				$Clicked2 = 0
			EndIf
		EndIf
	EndSwitch
WEnd

_GDIPlus_GraphicsDispose($hGraphicGUI)
_GDIPlus_GraphicsDispose($hGraphic)
;~ _GDIPlus_BitmapDispose($hBitmap)
;~ _GDIPlus_BitmapDispose($hBMPBuff)
_GDIPlus_Shutdown()

Func _PointInEllipse($xPt, $yPt, $xTL, $yTL, $w, $h)
    Local $bInside = False, $a = $w / 2, $b = $h / 2
    Local $c1X, $c2X, $dist, $xc = $xTL + $a, $yc = $yTL + $b
    $c1X = $xc - ($a ^ 2 - $b ^ 2) ^ (1 / 2); 1st focal point x position
    $c2X = $xc + ($a ^ 2 - $b ^ 2) ^ (1 / 2); 2nd focal point x position
    $dist = (($xPt - $c1X) ^ 2 + ($yPt - $yc) ^ 2) ^ 0.5 + (($xPt - $c2X) ^ 2 + ($yPt - $yc) ^ 2) ^ 0.5
    If $dist <= $w Then $bInside = Not $bInside
    Return $bInside
EndFunc ;==>_PointInEllipse
