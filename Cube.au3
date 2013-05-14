#cs
Author: Bennet van der Gryp
Description: Cube - Messing with OpenGL
#ce

#Include <string.au3>
#include <misc.au3>
#include "GlPluginUtils.au3"
AutoItSetOption( "TrayIconHide", 1 )
Dim $lpszDevice
Dim $lpszDeviceID
Dim $lpszOpenFlags
Dim $lpszRequest
Dim $lpszFlags
Dim $lpszCommand
Dim $lpszReturnString
Dim $cchReturn
Dim $mciError
$lpszDevice = "new type waveaudio"
$lpszOpenFlags = "alias mywave"
$lpszFlags = ""
$lpszCommand = StringFormat( "open %s %s %s", $lpszDevice, $lpszOpenFlags, $lpszFlags)
$lpszReturnString = _StringRepeat( " ", 100)
$cchReturn = StringLen($lpszReturnString)
$mciError = _mciSendString($lpszCommand, $lpszReturnString, $cchReturn, 0);
If $mciError[0] <> 0 Then _mciShowError($mciError[0])
$lpszDeviceID = "mywave"
$lpszRequest = "level"
$lpszFlags = ""
$lpszCommand = StringFormat( "status %s %s %s", $lpszDeviceID, $lpszRequest, $lpszFlags);
$point = 0



$Title = "Au3GlPlugin - Example"

;defining window
DefineGlWindow( 400, 300, $Title )
;setting back color
SetClearColor( 1.0, 1.0, 1.0 )

;creating light 0
CreateLight( 0, 300, 300, 300 )
SetLightAmbient( 0, 0.2, 0.2, 0.2 )
SetLightDiffuse( 0, 0.7, 0.7, 0.7 )
SetLightSpecular( 0, 1.0, 1.0, 1.0 )

;creating an object
$Object1 = ObjectCreate( )
;creating a shape in object
$head = AddSphere( $Object1, 0, 10, 0, 60, 10, 10, .255, .128, .064, 1.0 )
$leye = AddSphere( $Object1, -20, 30, 40, 20, 10, 10, .5, .8, .4, 1.0 )
$reye = AddSphere( $Object1, 20, 30, 40, 20, 10, 10, .5, .8, .4, 1.0 )
$mouth = AddCube( $Object1, 3, 1, 2, 0.4, 1.0, 0.4, 1.0 )

;ShapeRotate( $Object1, $Cube, 0, 20, 0 )

;setting to print the object
SetPrint( $Object1 )

;setting camera parameters
SetCamera( 0, 30, 200, 0, 10, 0 )

Opt( "WinTitleMatchMode", 3 )
WinWait( $Title )
$CheckWindowTimer = TimerInit( )
$X = 0
$up = False
While 1
    SceneDraw( )
    If $X = 10 Then
        $X = $X - .5
        $up = False
    ElseIf $X = -10 Then
        $X = $X + .5
        $up = True
    EndIf
    If $up = False Then $X = $X - .5
    If $up = True Then $X = $X + .5
    ObjectRotate( $Object1, $X, $X, $X )
    $mciError = _mciSendString($lpszCommand, $lpszReturnString, $cchReturn, 0);
    If $mciError[0] <> 0 Then _mciShowError($mciError[0])
    $vol = $mciError[2]
    If $vol > 20 Then $vol = $vol/3
    If $vol < 3 Then $vol = 1
    
    ShapeScale( $Object1, $mouth, 10, $vol, 70 )
    Sleep(20)
    ;ConsoleWrite($vol&@CRLF)
        If TimerDiff( $CheckWindowTimer ) > 1000 Then
        If WinExists( $Title ) = 0 Then ExitLoop
        $CheckWindowTimer = TimerInit( )
    EndIf
WEnd

    
Func SpecialEvents()
    Exit
EndFunc

Func _mciSendString($lpszCommand, $lpszReturnString, $cchReturn, $hwndCallback)
    Return DllCall("winmm.dll", "long", "mciSendStringA", "str", $lpszCommand, "str", $lpszReturnString, "long", $cchReturn, "long", 0)
EndFunc   ;==>_mciSendString
Func _mciShowError($mciError)
    Dim $errStr; Error message
    $errStr = _StringRepeat( " ", 100) ; Reserve some space for the error message
    $Result = DllCall("winmm.dll", "long", "mciGetErrorStringA", "long", $mciError, "string", $errStr, "long", StringLen($errStr))
    MsgBox(0, "MCI test", "MCI Error Number " & $mciError & ":" & $Result[2])
EndFunc   ;==>_mciShowError