#cs
Author: Bennet van der Gryp
Description: Attempt at creating a morse code translater/creater for HackThisSite
#ce
#include <GuiConstantsEx.au3>
#include <ScreenCapture.au3>
#include <WinAPI.au3>
#include <String.au3>
#Include <Array.au3>
Global $Arr, $ArrS[1][1]

$Return = _TranslateToMorse("Bennet")
_WriteToImage($Return)
$Return = _ReadFromImage()
_TranslateFromMorse($Return)

Func _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight, $iStride = 0, $iPixelFormat = 0x0026200A, $pScan0 = 0)
    Local $aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", $iWidth, "int", $iHeight, "int", $iStride, "int", $iPixelFormat, "ptr", $pScan0, "int*", 0)
    If @error Then Return SetError(@error, @extended, 0)
    Return $aResult[6]
EndFunc ;==>_GDIPlus_BitmapCreateFromScan0

Func _TranslateToMorse($String)
	$Return = ""
	$Arr = StringSplit($String, "")
	For $X = 1 To $Arr[0]	
		Select 
			Case $Arr[$X] = "a"
				$Return &= ".-" & " "
			Case $Arr[$X] = "b"
				$Return &= "-..." & " "
			Case $Arr[$X] = "c"
				$Return &= "-.-." & " "
			Case $Arr[$X] = "d"
				$Return &= "-.." & " "
			Case $Arr[$X] = "e"
				$Return &= "." & " "
			Case $Arr[$X] = "f"
				$Return &= "..-." & " "
			Case $Arr[$X] = "g"
				$Return &= "--." & " "
			Case $Arr[$X] = "h"
				$Return &= "...." & " "
			Case $Arr[$X] = "i"
				$Return &= ".." & " "
			Case $Arr[$X] = "j"
				$Return &= ".---" & " "
			Case $Arr[$X] = "k"
				$Return &= "-.-" & " "
			Case $Arr[$X] = "l"
				$Return &= ".-.." & " "
			Case $Arr[$X] = "m"
				$Return &= "--" & " "
			Case $Arr[$X] = "n"
				$Return &= "-." & " "
			Case $Arr[$X] = "o"
				$Return &= "---" & " "
			Case $Arr[$X] = "p"
				$Return &= ".--." & " "
			Case $Arr[$X] = "q"
				$Return &= "--.-" & " "
			Case $Arr[$X] = "r"
				$Return &= ".-." & " "
			Case $Arr[$X] = "s"
				$Return &= "..." & " "
			Case $Arr[$X] = "t"
				$Return &= "-" & " "
			Case $Arr[$X] = "u"
				$Return &= "..-" & " "
			Case $Arr[$X] = "v"
				$Return &= "...-" & " "
			Case $Arr[$X] = "w"
				$Return &= ".--" & " "
			Case $Arr[$X] = "x"
				$Return &= "-..-" & " "
			Case $Arr[$X] = "y"
				$Return &= "-.--" & " "
			Case $Arr[$X] = "z"
				$Return &= "--.." & " "
			Case $Arr[$X] = "."
				$Return &= ".-.-.-" & " "
			Case $Arr[$X] = ","
				$Return &= "--..--" & " "
			Case $Arr[$X] = "?"
				$Return &= "..--.." & " "
			Case $Arr[$X] = "/"
				$Return &= "-..-." & " "
			Case $Arr[$X] = "@"
				$Return &= ".--.-." & " "
			Case $Arr[$X] = "1"
				$Return &= ".----" & " "
			Case $Arr[$X] = "2"
				$Return &= "..---" & " "
			Case $Arr[$X] = "3"
				$Return &= "...--" & " "
			Case $Arr[$X] = "4"
				$Return &= "....-" & " "
			Case $Arr[$X] = "5"
				$Return &= "....." & " "
			Case $Arr[$X] = "6"
				$Return &= "-...." & " "
			Case $Arr[$X] = "7"
				$Return &= "--..." & " "
			Case $Arr[$X] = "8"
				$Return &= "---.." & " "
			Case $Arr[$X] = "9"
				$Return &= "----." & " "
			Case $Arr[$X] = "0"
				$Return &= "-----" & " "
			Case $Arr[$X] = " "
				$Return &= "/ "
 			Case Else
				$Return &= $Arr[$X]
		EndSelect
	Next
	$Return = StringUpper($Return)
	ConsoleWrite($Return & @CRLF)
	ClipPut($Return)
	Return $Return
EndFunc

Func _TranslateFromMorse($String)
	$Return = ""
	$String = StringReplace($String, "/", " / ")
	$Arr = StringSplit($String, " ")
	For $X = 1 To $Arr[0]	
		Select 
			Case $Arr[$X] = ".-"
				$Return &= "a"
			Case $Arr[$X] = "-..."
				$Return &= "b"
			Case $Arr[$X] = "-.-."
				$Return &= "c"
			Case $Arr[$X] = "-.."
				$Return &= "d"
			Case $Arr[$X] = "."
				$Return &= "e"
			Case $Arr[$X] = "..-."
				$Return &= "f"
			Case $Arr[$X] = "--."
				$Return &= "g"
			Case $Arr[$X] = "...."
				$Return &= "h"
			Case $Arr[$X] = ".."
				$Return &= "i"
			Case $Arr[$X] = ".---"
				$Return &= "j"
			Case $Arr[$X] = "-.-"
				$Return &= "k"
			Case $Arr[$X] = ".-.."
				$Return &= "l"
			Case $Arr[$X] = "--"
				$Return &= "m"
			Case $Arr[$X] = "-."
				$Return &= "n"
			Case $Arr[$X] = "---"
				$Return &= "o"
			Case $Arr[$X] = ".--."
				$Return &= "p"
			Case $Arr[$X] = "--.-"
				$Return &= "q"
			Case $Arr[$X] = ".-."
				$Return &= "r"
			Case $Arr[$X] = "..."
				$Return &= "s"
			Case $Arr[$X] = "-"
				$Return &= "t"
			Case $Arr[$X] = "..-"
				$Return &= "u"
			Case $Arr[$X] = "...-"
				$Return &= "v"
			Case $Arr[$X] = ".--"
				$Return &= "w"
			Case $Arr[$X] = "-..-"
				$Return &= "x"
			Case $Arr[$X] = "-.--"
				$Return &= "y"
			Case $Arr[$X] = "--.."
				$Return &= "z"
			Case $Arr[$X] = ".-.-.-"
				$Return &= "."
			Case $Arr[$X] = "--..--"
				$Return &= ","
			Case $Arr[$X] = "..--.."
				$Return &= "?"
			Case $Arr[$X] = "-..-."
				$Return &= "/"
			Case $Arr[$X] = ".--.-."
				$Return &= "@"
			Case $Arr[$X] = ".----"
				$Return &= "1"
			Case $Arr[$X] = "..---"
				$Return &= "2"
			Case $Arr[$X] = "...--"
				$Return &= "3"
			Case $Arr[$X] = "....-"
				$Return &= "4"
			Case $Arr[$X] = "....."
				$Return &= "5"
			Case $Arr[$X] = "-...."
				$Return &= "6"
			Case $Arr[$X] = "--..."
				$Return &= "7"
			Case $Arr[$X] = "---.."
				$Return &= "8"
			Case $Arr[$X] = "----."
				$Return &= "9"
			Case $Arr[$X] = "-----"
				$Return &= "0"
			Case $Arr[$X] = "/"
				$Return &= " "
			Case Else
				$Return &= $Arr[$X]
		EndSelect
	Next
	$Return = StringUpper($Return)
	ConsoleWrite($Return & @CRLF)
	ClipPut($Return)
	Return $Return
EndFunc

Func OnAutoItExit()
;~    ' Unlock the bits
    _GDIPlus_BitmapUnlockBits($pBitmap, $BitmapData)

;~    ' // Cleanup
    If $pBitmap Then _GDIPlus_ImageDispose($pBitmap)

;~    ' // Shutdown GDI+
    _GDIPlus_Shutdown()
EndFunc   ;==>OnAutoItExit

Func _WriteToImage(ByRef $Return)
	$ArrS = StringToASCIIArray($Return)
;~ 	_ArrayDisplay($ArrS)
	Local $hBitmap, $hImage, $hGraphics

	; Initialize GDI+ library
	_GDIPlus_Startup ()

	$hBitmap = _ScreenCapture_Capture ("",0, 0, 100, 30) ;Had a lot of difficulty creating an HBITMAP that would save.
	$hImage = _GDIPlus_BitmapCreateFromHBITMAP ($hBitmap)
	$hGraphics = _GDIPlus_ImageGetGraphicsContext ($hImage)
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, 101, 41)
	$hPen = _GDIPlus_PenCreate(0xFFFFFFFF)
	$Count = 0
	Dim $X, $Y = 0
	For $Value in $ArrS
;~ 		MsgBox(0,"",$Value)
		$X += $Value
		If $X > 100 Then
			$X -= 100
			$Y += 1
		EndIf
		ConsoleWrite($X & "  ")
		_GDIPlus_GraphicsDrawLine($hGraphics, $X, $Y, $X+1, $Y, $hPen)
		_GDIPlus_GraphicsDrawLine($hGraphics, $X+1, $Y, $X+2, $Y)
	Next
	; Save resultant image
	$r = _GDIPlus_ImageSaveToFile ($hImage, @ScriptDir & "\code.jpg")
	ConsoleWrite($r)
	; Clean up resources
	_GDIPlus_PenDispose ($hPen)
	_GDIPlus_ImageDispose ($hImage)
	_WinAPI_DeleteObject ($hBitmap)

	; Shut down GDI+ library
	_GDIPlus_ShutDown ()
EndFunc

Func _ReadFromImage()
	Local $strFileName
	Local $pBitmap
	Local $pPixels
	Local $Count
	Local $Return
	_GDIPlus_Startup()
	$strFileName = @ScriptDir & "\code.jpg"

	$pBitmap = _GDIPlus_ImageLoadFromFile($strFileName)

	$BitmapData = _GDIPlus_BitmapLockBits($pBitmap, 0, 0, 100, 30, $GDIP_ILMREAD, $GDIP_PXF32RGB)
	$Stride = DllStructGetData($BitmapData, "Stride")
	$Width = DllStructGetData($BitmapData, "Width")
	$Height = DllStructGetData($BitmapData, "Height")
	$PixelFormat = DllStructGetData($BitmapData, "PixelFormat")
	$Scan0 = DllStructGetData($BitmapData, "Scan0") ;Scan line
	$LastValue = 0
	ConsoleWrite(@CRLF)
	For $row = 0 To $Height - 1
		For $col = 0 To $Width - 1
			$pixel = DllStructCreate("dword", $Scan0 + $row * $Stride + $col*4)
			If Hex(DllStructGetData($pixel, 1)) = "FFFFFFFF" Then
;~ 				ConsoleWrite($row & $col & " ")
				$Val = $row & $col
				$Val -= $LastValue
				ConsoleWrite($Val & " ")
				$LastValue = $row & $col
;~ 				ConsoleWrite($LastValue & " ")
;~ 				$Count = 0 
			EndIf
		Next
	Next
	ConsoleWrite(@CRLF & $Return &@CRLF)
EndFunc