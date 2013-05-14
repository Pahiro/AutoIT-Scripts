#cs
Author: Bennet van der Gryp
Description:
#ce
#include <Inet.au3>
#include <String.au3>
#include <Array.au3>
#include <IE.au3>

HotKeySet("{ESC}","ExitProg")

Global $ValidData[339][2],$oIE
$LET = "'"
$URL = "http://m.facebook.com/friends.php?pa&start=" & $LET & "&end=Z&refid=5"
$oIE = _IECreate($URL)
$SourceCode = _IEBodyReadHTML($oIE)
;~ $SourceCode = _INetGetSource($URL)
$Names = _StringBetween($SourceCode, "<span>", '</div>')
$Images = _StringBetween($SourceCode,'src="','" width')
;~ _ArrayDisplay($Images)
$Y = 0
While 1
	For $x = 1 to 9
		$String = $Names[$x]
		$String = StringLeft($String, StringInStr($String,"</SPAN>")-1)
		$ValidData[$Y][0] = $String
		
		$IMG = InetRead($Images[$x],8)
		$File = FileOpen("C:\TEMP\FBOOK\" & $String & ".jpg",10)
		Consolewrite("C:\TEMP\FBOOK\" & $String & ".jpg")
		FileWrite($File, $IMG)
		FileClose($File)
		
		$String = $Names[$x]
		$String = StringMid($String, StringInStr($String, "tel:")+4,StringLen($String)-StringInStr($String, '>Call</a>')+3)
		If $String > 0 Then $ValidData[$Y][1] = $String
		
		$Y += 1
		If $Y = 339 Then ExitLoop
	Next
;~ 	_ArrayDisplay($ValidData)
	$LET = StringLeft($Names[10],4)
	If $Y = 339 then ExitLoop
	$URL = "http://m.facebook.com/friends.php?pa&start=" & $LET & "&end=Z&refid=5"
	If StringInStr($SourceCode, "Zoran") Then ExitLoop
	_IENavigate($oIE,$URL)
	_IELoadWait($oIE)
	$SourceCode = _IEBodyReadHTML($oIE)
	$Names = _StringBetween($SourceCode, "<span>", '</div>')
	$Images = _StringBetween($SourceCode,'src="','" width')
WEnd
Dim $COMPLETE
For $X = 0 to 338
	ConsoleWrite($ValidData[$X][0] & "," & $ValidData[$X][1] & @CRLF)
	$COMPLETE = $ValidData[$X][0] & "," & $ValidData[$X][1] & @CRLF
Next
$FileT = FileOpen("C:\TEMP\FBOOK\CONTACTS.txt",10)
FileWrite($FileT, $COMPLETE)
FileClose($FileT)

Func ExitProg()
	_IEQuit($oIE)
	Exit
EndFunc