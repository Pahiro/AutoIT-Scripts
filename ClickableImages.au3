#include <GuiConstantsEx.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#cs
Author: Unknown
Description: Sample script
#ce
Opt("MouseCoordMode", 2) ;1=absolute, 0=relative, 2=client

Global $hGUI, $hGraphicGUI, $hBMPBuff

_Main()
Func _Main()
    Local $hBMP, $hBitmap, $hGraphic, $hImage, $iX, $iY, $hClone, $t, $aMPos
    Local $GuiSizeX = 400, $GuiSizeY = 300
    Local $pngFile = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir") _
             & "\Examples\GUI\Advanced\Images\Button.png"

    ; Create GUI
    $hGUI = GUICreate("GDI+", $GuiSizeX, $GuiSizeY)
    ;GUISetBkColor(0xFFFFEF)
    GUISetState()

    _GDIPlus_Startup()

    $hBitmap = _GDIPlus_ImageLoadFromFile($pngFile)
    $hGraphicGUI = _GDIPlus_GraphicsCreateFromHWND($hGUI)
    $hBMPBuff = _GDIPlus_BitmapCreateFromGraphics($GuiSizeX, $GuiSizeY, $hGraphicGUI)
    $hGraphic = _GDIPlus_ImageGetGraphicsContext($hBMPBuff)

    _GDIPlus_GraphicsDrawImage($hGraphic, $hBitmap, 0, 0)
    GUIRegisterMsg(0xF, "MY_PAINT"); Register PAINT-Event 0x000F = $WM_PAINT (WindowsConstants.au3)
    GUIRegisterMsg(0x85, "MY_PAINT") ; $WM_NCPAINT = 0x0085 (WindowsConstants.au3)Restore after Minimize.
    _GDIPlus_GraphicsDrawImage($hGraphicGUI, $hBMPBuff, 0, 0)

    Do
        $aMPos = MouseGetPos()
        If ispressed("01") Then
            Select
                Case _WinAPI_PtInRectEx($aMPos[0], $aMPos[1], 5, 5, 112, 56)
                    MsgBox(0, "", " Top button clicked", 1)
                Case _PointInEllipse($aMPos[0], $aMPos[1], 122, 100, 132, 45)
                    MsgBox(0, "", "Middle elliptic button clicked", 1)
                Case _WinAPI_PtInRectEx($aMPos[0], $aMPos[1], 5, 192, 112, 243)
                    MsgBox(0, "", "Lowest button clicked", 1)
            EndSelect
        EndIf
    Until GUIGetMsg() = $GUI_EVENT_CLOSE

    ; Clean up resources
    _GDIPlus_GraphicsDispose($hGraphicGUI)
    _GDIPlus_GraphicsDispose($hGraphic)
    _GDIPlus_BitmapDispose($hBitmap)
    _GDIPlus_BitmapDispose($hBMPBuff)
    _GDIPlus_Shutdown()

EndFunc ;==>_Main


; ($xPt, $yPt) - x, y position of the point to check
; $xTL, $yTL, Top left x Pos, top left Y position of the rectangle encompassing the ellipse.
; $w, $h - The width an height of ellipse
; http://www.autoitscript.com/forum/index....p?showtopic=89034&view=findpos
;
Func _PointInEllipse($xPt, $yPt, $xTL, $yTL, $w, $h)
    Local $bInside = False, $a = $w / 2, $b = $h / 2
    Local $c1X, $c2X, $dist, $xc = $xTL + $a, $yc = $yTL + $b
    $c1X = $xc - ($a ^ 2 - $b ^ 2) ^ (1 / 2); 1st focal point x position
    $c2X = $xc + ($a ^ 2 - $b ^ 2) ^ (1 / 2); 2nd focal point x position
    $dist = (($xPt - $c1X) ^ 2 + ($yPt - $yc) ^ 2) ^ 0.5 + (($xPt - $c2X) ^ 2 + ($yPt - $yc) ^ 2) ^ 0.5
    If $dist <= $w Then $bInside = Not $bInside
    Return $bInside
EndFunc ;==>_PointInEllipse

; ($iX, $iY)    - x, y position of the point to check
; ($iLeft, $iTop)   - x, y position of the top left corner of rectangle
; ($iRight, $iBottom) - x, y position of the bottom right corner of rectangle
; http://www.autoitscript.com/forum/index....p?showtopic=89034&view=findpos
;
Func _WinAPI_PtInRectEx($iX, $iY, $iLeft, $iTop, $iRight, $iBottom)
    Local $aResult
    Local $tRect = DllStructCreate($tagRECT)
    DllStructSetData($tRect, "Left", $iLeft)
    DllStructSetData($tRect, "Top", $iTop)
    DllStructSetData($tRect, "Right", $iRight)
    DllStructSetData($tRect, "Bottom", $iBottom)
    $aResult = DllCall("User32.dll", "int", "PtInRect", "ptr", DllStructGetPtr($tRect), "int", $iX, "int", $iY)
    If @error Then Return SetError(@error, 0, False)
    Return $aResult[0] <> 0
EndFunc ;==>_WinAPI_PtInRectEx

; Copied from ...\Include\Misc.au3 File
Func IsPressed($sHexKey)
    Local $a_R = DllCall('user32.dll', "int", "GetAsyncKeyState", "int", '0x' & $sHexKey)
    If Not @error And BitAND($a_R[0], 0x8000) = 0x8000 Then Return 1
    Return 0
EndFunc ;==>IsPressed

;Func to redraw on PAINT MSG
Func MY_PAINT($hWnd, $msg, $wParam, $lParam)
    _GDIPlus_GraphicsDrawImage($hGraphicGUI, $hBMPBuff, 0, 0)
    _WinAPI_RedrawWindow($hGUI, "", "", BitOR($RDW_INVALIDATE, $RDW_FRAME, $RDW_ALLCHILDREN)) ;
    Return $GUI_RUNDEFMSG
EndFunc ;==>MY_PAINT