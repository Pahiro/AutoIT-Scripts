#cs
Author: Bennet van der Gryp
Description:
#ce
#include <File.au3>
#include <Array.au3>
#include <String.au3>
#include <Inet.au3>
#include <Excel.au3>

Dim $FileListFixed

$Path = "C:\Users\Bennet van der Gryp\eBooks\mobi"

$FileList = _FileListToArray($Path)
$oExcel = _ExcelBookNew()
$Row = 1
For $FileName In $FileList
	If Not IsNumber($FileName) Then
		$FileName = StringLeft($FileName, StringLen($FileName) - 5)
		
		$URL1 = "http://www.amazon.com/gp/aw/s/ref=is_box_?k="
		$URL2 = $FileName
		$URL3 = "&x=0&y=0"
		$URL = $URL1 & $URL2 & $URL3
		$SrcCode = _INetGetSource($URL)
		$PATH = _StringBetween($SrcCode, '<a href="/gp/aw/d/', '">')
		$PATH[0] = StringReplace($PATH[0], "mp_s_a_1","aw_d_detail")
		$PATH[0] = StringReplace($PATH[0], "?","?pd=1&")
;~ 			MsgBox(0,"SRC", $PATH[0])			
		$URL = "http://www.amazon.com/gp/aw/d/" & $PATH[0]
;~ 			ConsoleWrite($URL)
		$SrcCode = _INetGetSource($URL)
		$ReleaseDate = _StringBetween($SrcCode, 'Release date:&#160;', '<br />')
		ConsoleWrite($ReleaseDate[0] & " : ")
		ConsoleWrite($FileName & @CRLF)
;~ 			ConsoleWrite($SrcCode)
;~ 			ConsoleWrite(_INetGetSource('http://www.autoitscript.com'))
;~ 			Exit
		_ExcelWriteCell($oExcel, $ReleaseDate[0], $Row, 1)
		_ExcelWriteCell($oExcel, $FileName, $Row, 2)
		$Row += 1
	EndIf

Next
;~ http://www.amazon.com/gp/aw/d/1406862894/ref=aw_d_detail?pd=1&qid=1315474818&sr=8-1
;~ http://www.amazon.com/gp/aw/d/1406862894/ref=mp_s_a_1?qid=1315474818&sr=8-1