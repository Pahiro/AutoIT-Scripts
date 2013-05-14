#include <String.au3>
#include <array.au3>
#include <Inet.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <IE.au3>
#include <Excel.au3>
#cs
Author: Bennet van der Gryp
Description: Download metadata for a list of series in a spreadsheet. IMDB scraper.
#ce
;~ $oExcel = _ExcelBookNew()
$oExcel = _ExcelBookAttach("C:\TEMP\Series.xlsx")
If @error <> 0 then Exit

$File = FileOpen("C:\TEMP\Series.txt",0)
If $file = -1 Then
    MsgBox(0, "Error", "Unable to open file.")
    Exit
EndIf
$Count = 0
While 1
	$Count += 1
	$Line = FileReadLine($File)
	$Line = StringReplace($Line, "_", " ")
	If @error = -1 then ExitLoop
	_ExcelWriteCell($oExcel, $Line, $Count, 1)
	$url = "http://m.imdb.com/find?q="
	$url &= $Line
	$url &= "&button=Search"
	
	$source = _INetGetSource($url)
	If @error = 0 Then
	;~ 	$file2 = FileOpen("C:\TEMP\Find.htm")
	;~ 	$source = FileRead($file2)
		
		$Title = _StringBetween($source, '<a href="/title/', '/" onClick')
		If IsArray($Title) Then
			_ExcelWriteCell($oExcel, $Title[0], $Count, 2)
			
			$url = "http://m.imdb.com/title/"
			$url &= $Title[0]
			$url &= "/"
			
			$source = _INetGetSource($url)
			If @error = 0 Then
			;~ 	$file2 = FileOpen("C:\TEMP\" & $Title[0] & ".htm")
			;~ 	$source = FileRead($file2)
				
				$Rating = _StringBetween($source, '<strong>', '</strong>')
				If IsArray($Rating) Then
					$Rating = Clean($Rating)
					_ExcelWriteCell($oExcel, $Rating[0], $Count, 3)
				EndIf
				$Genre = _StringBetween($source, '<h1>Genre</h1>','</div>')
				If IsArray($Genre) Then
					$Genre = Clean($Genre)
					_ExcelWriteCell($oExcel, $Genre[0], $Count, 4)
				EndIf
				$Summary = _StringBetween($source, '<h1>Plot Summary</h1>', "</div>")
				If IsArray($Summary) Then
					$Summary = Clean($Summary)
					$Summary[0] = StringReplace($Summary[0], '<a href="/title/' & $Title[0] & '/plotsummary">Full Summary</a>', "")
					_ExcelWriteCell($oExcel, $Summary[0], $Count, 5)
				EndIf
	;~ 			ConsoleWrite(@CRLF & @CRLF)
			;~ 	Exit
			EndIf
		EndIf
	EndIf
WEnd

Func Clean(Byref $Array)
	$Array[0] = StringReplace($Array[0], @LF, "")
	$Array[0] = StringReplace($Array[0], "<p>", "")
	$Array[0] = StringReplace($Array[0], "</p>", "")
	$Array[0] = StringStripWS($Array[0], 7)
	Return $Array
EndFunc