#cs
Author: Bennet van der Gryp
Description: Decrypter for MD5
#ce
#include <String.au3>
$strPassword = "Bennet"
$strString = "95" & @CRLF & "QGG-V33-OEM-0B1-1.1" & @CRLF & "Z93-Z29-OEM-BNX-1.1" & @CRLF & "IQ0-PZI-OEM-PK0-1.1" & @CRLF & "UM4-VDL-OEM-B9O-1.1" & @CRLF & "L0S-4R2-OEM-UQL-1.1" & @CRLF & "JBL-EYQ-OEM-ABB-1.1" & @CRLF & "NL1-3V3-OEM-L4C-1.1" & @CRLF & "7CQ-1ZR-OEM-U3I-1.1" & @CRLF & "XX0-IHL-OEM-5XK-1.1" & @CRLF & "KJQ-RXG-OEM-TW8-1.1" & @CRLF & "OZR-LW1-OEM-5EM-1.1" & @CRLF & "0B8-6K5-OEM-EFN-1.1" & @CRLF & "OE2-20L-OEM-SSI-1.1" & @CRLF & "0ME-HAE-OEM-9XB-1.1"

$strPasswordMD5 = md5($strPassword)
$intMD5Total = evalCrossTotal($strPasswordMD5)
Local $arrEncryptedValues[1]
$StringLen = StringLen($strString)

For $i = 0 to $StringLen
	$arrEncryptedValues = Asc(_StringBetween($strString, $i, 1)) + (_StringBetween($strPasswordMD5, $i,1)) - $intMD5Total
	$intMD5Totla = evalCrossTotal(_StringBetween(md5(_StringBetween($strString,0,$i+1)), 0,16) & _StringBetween(md5($intMD5Total,0,16))
Next
$str = _ArrayToString($arrEncryptedValues)
Consolewrite($str)

Func evalCrossTotal($strMD5)
	$intTotal = 0
	$arrMD5Chars = StringSplit($strMD5, 1)
	For $value in $arrMD5Chars
		$intTotal += $value
	Next
	Return $intTotal
EndFunc

Func md5($strPassword)
	
EndFunc