#include <File.au3>
#include <Array.au3>
#include <String.au3>
$f = FileRead("english.txt")
Global $DictData=StringSplit($f, @CRLF)
Global $File = FileOpen("words.txt")
Global $Perm[1]
Global $TrueArr[1], $Arr[1]
$String = FileRead($File)
$TrueArr = StringSplit($String, @CRLF)

For $x = 1 to $TrueArr[0] Step 4
	_ArrayAdd($Arr,$TrueArr[$x])
Next

For $x = 1 to 10
	ToolTip($Arr[$x])
	$str = _Find($Arr[$x])
Next

Func _Find($string) ;Rather do this one. Check if all letters are present in a word, and there are no additional letters.
	Local $Found = False
	$CharArr = StringSplit($string,"")
	$IT_DD = $DictData
	While 1
		For $Item in $IT_DD
			$Comp = ""
			For $X = 1 to StringLen($string)
				$Comp &= "#"
			Next
			$lv_item = $Item
			If StringInStr($lv_item, $CharArr[1]) Then	
				For $Char in $CharArr
					If StringInStr($lv_item, $Char) > 0 Then
						$lv_item = StringReplace($lv_item, $Char, "#", 0)
					EndIf
				Next
				If $lv_item = $Comp Then
					Consolewrite($Item & ",")
					$Found = True
					ExitLoop				
				EndIf
			EndIf
		Next
		If $Found = True Then ExitLoop
	WEnd	
EndFunc

Func _Scramble($S) ;Random Scrambling is too slow.
	Local $work = StringSplit($S, ""), $max = $work[0]
	Local $out = ""
	$StrLen = StringLen($S)
	$Backup = $work
	
	For $i= 1 to $StrLen
		$rnd = Random(1, $StrLen+1-$i, 1)
		If $rnd = 0 Then $rnd = 1
		$out &= $work[$rnd]
		_ArrayDelete($work,$rnd)
	Next
	
	$work = $Backup
	Return $out
EndFunc

Func _IsWord($Word) ;Check if our scramble is in the dictionary
	If _ArraySearch($DictData, $Word) > 0 Then
		ConsoleWrite($Word & ",")
	EndIf
EndFunc
