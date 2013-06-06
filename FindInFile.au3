#include <Array.au3>

$aArray = _FindInFile('findinfile', @ScriptDir, '*.au3;*.txt')
_ArrayDisplay($aArray)
Func _FindInFile($sSearch, $sFilePath, $sMask = '*', $fRecursive = True, $fLiteral = Default, $fCaseSensitive = Default, $fDetail = Default)
    Local $sCaseSensitive = '/i', $sDetail = '/m', $sRecursive = ''
    If $fCaseSensitive Then
        $sCaseSensitive = ''
    EndIf
    If $fDetail Then
        $sDetail = '/n'
    EndIf
    If $fLiteral Then
        $sSearch = ' /c:' & $sSearch
    EndIf
    If $fRecursive Or $fRecursive = Default Then
        $sRecursive = '/s'
    EndIf
    If $sMask = Default Then
        $sMask = '*'
    EndIf

    $sFilePath = StringRegExpReplace($sFilePath, '[\\/]+\z', '') & '\'
    Local Const $aMask = StringSplit($sMask, ';')
    Local $iPID = 0, $sOutput = ''
    For $i = 1 To $aMask[0]
        $iPID = Run(@ComSpec & ' /c ' & 'findstr ' & $sCaseSensitive & ' ' & $sDetail & ' ' & $sRecursive & ' "' & $sSearch & '" "' & $sFilePath & $aMask[$i] & '"', @SystemDir, @SW_HIDE, 6)
        While 1
            $sOutput &= StdoutRead($iPID)
            If @error Then
                ExitLoop
            EndIf
        WEnd
    Next

    Return StringSplit(StringStripWS(StringStripCR($sOutput), 3), @LF)
EndFunc   ;==>_FindInFile