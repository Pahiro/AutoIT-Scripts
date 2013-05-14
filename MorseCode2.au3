#include <Clipboard.au3>
#Include <GDIPlus.au3>

;Local $hStatus; as LONG
;Local $token; as DWORD
Local $strFileName; as STRING
Local $pBitmap; as DWORD
;Local $bmpData; as BITMAPDATA
;Local $rc; as RECT
;Local $row; as LONG
;Local $col; as LONG
Local $pPixels; as DWORD PTR
If _ClipBoard_IsFormatAvailable($CF_BITMAP) <> 1 Then SetError(1, 0, 0)
If _ClipBoard_Open(0) <> 1 Then SetError(2, 0, 0)
If @error Then SetError(3, 0, 0)
$hBitmap = _ClipBoard_GetDataEx($CF_BITMAP)
If IsPtr($hBitmap) = 0 Then SetError(4, 0, 0)
_GDIPlus_Startup()
$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
If @error Or IsPtr($hImage) = 0 Then
	_ClipBoard_Close()
	_WinAPI_DeleteObject($hBitmap)
	_GDIPlus_Shutdown()
	Return SetError(5, 0, 0)
EndIf
_ClipBoard_Close()
_WinAPI_DeleteObject($hBitmap)
$pBitmap = $hImage

$BitmapData = _GDIPlus_BitmapLockBits($pBitmap, 0, 0, 100, 30, $GDIP_ILMREAD, $GDIP_PXF32RGB)

$Stride = DllStructGetData($BitmapData, "Stride")
$Width = DllStructGetData($BitmapData, "Width")
$Height = DllStructGetData($BitmapData, "Height")
$PixelFormat = DllStructGetData($BitmapData, "PixelFormat")
$Scan0 = DllStructGetData($BitmapData, "Scan0")

Local $Pos = 0
Local $Offset = 0
Local $String = ""

For $row = 0 To $Height-1
    For $col = 0 To $Width-1
        $pixel = DllStructCreate("dword", $Scan0 + $row * $Stride + $col*4)
        If Hex(DllStructGetData($pixel, 1)) = "FFFFFFFF" Then
			$Offset = $Pos - $Offset
;~ 			MsgBox(0,$Offset, $Pos)
			$String &= Chr($Offset)
			$Offset = $Pos
		EndIf
		$Pos += 1
    Next
;~     ConsoleWrite(@CRLF)
Next
ConsoleWrite($String & @CRLF)
;~ $String = "-... ....- ----- .. ---.. -.- . .-- --.- -.-."
$String = _TranslateFromMorse($String)
;~ _TranslateToMorse($String)


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