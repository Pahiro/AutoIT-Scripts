#include <String.au3>
#include <array.au3>
#include <Inet.au3>
#cs
Author: Bennet van der Gryp
Description: This program downloads all pictures from DeviantART based on a search string.
#ce
$Count = 0
$end = 10
$folder = "skirt"
;~ $folder = "weddings"
While 1
	ConsoleWrite(@CRLF & "Page " & $Count & " - ")
	$Count += 1
	$URL = "http://browse.deviantart.com/photography/people/?q=" & $folder & "&order=9" & "&offset="  & 24 * $Count
;~ 	$URL = "http://browse.deviantart.com/photography/people/" & $folder & "/?order=9" & "&offset="  & 24 * $Count
	$Source = _INetGetSource($URL)
	$image = _StringBetween($Source,'<img width=', '"></a></span>')
	For $record in $image
		$pos = StringInStr($record, "http")
		$record = StringMid($record, $pos)
		$record = StringReplace($record, "/150/", "/",1)
		$record = StringReplace($record, "th", "fc",1)
		$number = StringMid($record, 10,2)
		$filename = StringMid($record, 48)
		If Not FileExists("C:\TEMP\DeviantART\" & $folder & "\" & $filename) Then
;~ 			InetGet($record, "C:\TEMP\DeviantART\" & $folder & "\" & $filename)
			$img = InetRead($record)
			ConsoleWrite(@error & " ")
			If @error <> 0 Then
				ConsoleWrite($record & @crlf)
			Else
				$File = FileOpen("C:\TEMP\DeviantART\" & $folder & "\" & $filename,2+16+8)
				FileWrite($File,$img)
				FileClose($File)
			EndIf
		Else
			ConsoleWrite("2 ")
		EndIf
		
	Next
	If $Count >= $end Then
		Exit
	EndIf
WEnd



;~ # Artistic Nude
;~ # Body Art
;~ # Classic Portraits
;~ # Cosplay
;~ # Emotive Portraits
;~ # Expressive
;~ # Fashion Portraits
;~ # Fetish Portraits
;~ # Glamour Portraits
;~ # Infants and Children
;~ # Miscellaneous
;~ # Pin-up
;~ # Self-Portraits
;~ # Spontaneous Portraits
;~ # Weddings