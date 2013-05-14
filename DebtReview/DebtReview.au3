#include <IE.au3>
#include <Array.au3>
#include <File.au3>
#cs
Author: Bennet van der Gryp
Description: This program automates screen clicks for a very repetitive task in the Debt Review department for Standard Bank
#ce
#AutoIt3Wrapper_run_debug_mode=Y
HotKeySet("{ESC}","ExitF")
HotKeySet("{PAUSE}","PauseF")
_IEErrorHandlerRegister()
;~ If @DesktopHeight <> 900 OR @DesktopWidth <> 1440 Then
;~            MsgBox(48, "Error!", "This program will not function on any screen resolution other than 1440x900." & @CRLF & "Your screen resolution is currently set to " & @DesktopWidth & "x" & @DesktopHeight)
;~            Exit
;~ EndIf
$URL = IniRead("settings.ini","Internet","URL","http://sapdevbp.sbic.co.za:53100/irj/portal")

$oIE = _IECreate($URL)
$oForm = _IEFormGetObjByName($oIE, "logonForm")
$oUsrName = _IEFormElementGetObjByName($oForm, "j_user")
$oPssWOrd = _IEFormElementGetObjByName($oForm, "j_password")
$USR = IniRead("settings.ini","Internet","Username","Username")
$PSW = IniRead("settings.ini","Internet","Password","Password")
Global $X1 = IniRead("settings.ini","Resolution","X1","0")
Global $Y1 = IniRead("settings.ini","Resolution","Y1","0")
Global $X2 = IniRead("settings.ini","Resolution","X2","0")
Global $Y2 = IniRead("settings.ini","Resolution","Y2","0")
Global $X3 = IniRead("settings.ini","Resolution","X3","0")
Global $Y3 = IniRead("settings.ini","Resolution","Y3","0")
Global $X4 = IniRead("settings.ini","Resolution","X4","0")
Global $Y4 = IniRead("settings.ini","Resolution","Y4","0")
Global $X5 = IniRead("settings.ini","Resolution","X5","0")
Global $Y5 = IniRead("settings.ini","Resolution","Y5","0")
Global $X6 = IniRead("settings.ini","Resolution","X6","0")
Global $Y6 = IniRead("settings.ini","Resolution","Y6","0")
Global $X7 = IniRead("settings.ini","Resolution","X7","0")
Global $Y7 = IniRead("settings.ini","Resolution","Y7","0")
Global $X8 = IniRead("settings.ini","Resolution","X8","0")
Global $Y8 = IniRead("settings.ini","Resolution","Y8","0")
Global $X9 = IniRead("settings.ini","Resolution","X9","0")
Global $Y9 = IniRead("settings.ini","Resolution","Y9","0")
Global $X10 = IniRead("settings.ini","Resolution","X10","0")
Global $Y10 = IniRead("settings.ini","Resolution","Y10","0")
Global $X11 = IniRead("settings.ini","Resolution","X11","0")
Global $Y11 = IniRead("settings.ini","Resolution","Y11","0")
Global $X12 = IniRead("settings.ini","Resolution","X12","0")
Global $Y12 = IniRead("settings.ini","Resolution","Y12","0")

_IEFormElementSetValue($oUsrName, $USR)
_IEFormElementSetValue($oPssWord, $PSW)

$oLogon = _IEFormElementGetObjByName ($oForm, "uidPasswordLogon")
_IEAction($oLogon, "click")
_IELoadWait($oIE)
_IELinkClickByText($oIE, "Debt Review")
Sleep(5000)
WinSetState("Debt Review", "", @SW_MAXIMIZE)
$FilePath = IniRead("settings.ini","File","Path","C:\TEMP\testcase1.txt")

$File = FileOpen($FilePath, 0)
$FirstLines = ""
While 1
                $Line = FileReadLine($File)
                If @error = -1 then 
                                MsgBox(0,"Message!", "Reached the end of the file. Process complete.")
                                exitloop
                EndIf
                $FirstLines &= $Line & @CRLF
                $BPID = StringLeft($Line, StringInStr($Line,"#",0,1)-1)
                $Line = StringRight($Line, StringLen($Line)- StringLen($BPID)-1)
                $AccFromFile = StringLeft($Line, StringInStr($Line,"#",0,1)-1)
                $Notepad = StringRight($Line, StringLen($Line) - StringLen($AccFromFile) - 1)

                MouseClick("Left",$X1,$Y1,1) ;BPID
                Sleep(1000)
                Send($BPID) ;From File
                MouseClick("Left",$X2,$Y2,1) ;Go
                Sleep(5000)
                MouseClick("Left",$X3,$Y3,1) ;Account Data
                Sleep(3000)
                ProcessPage($BPID, $AccFromFile, $Notepad)
                Sleep(5000)
;~            $Msg = MsgBox(1,"Continue","Please click save. Do you wish to continue with the next record? Please ensure errors were resolved first.",262144)
;~            If $Msg = 2 Then
;~                            $LastLines = ""
;~                            While 1 
;~                                            $Line = FileReadLine($File)
;~                                            If @error = -1 then exitloop
;~                                            $LastLines &= $Line & @CRLF
;~                            WEnd
;~                            FileClose($File)
;~                            $File1 = FileOpen($FilePath,2)
;~                            $ComPath = IniRead("settings.ini","File","Complete","C:\TEMP\testcasecomplete.txt")
;~                            $File2 = FileOpen($ComPath,1)
;~                            FileWrite($File1, $LastLines)
;~                            FileWrite($File2, $FirstLines)
;~                            FileClose($File1)
;~                            FileClose($File2)
;~                            Exit
;~            EndIf
                MouseClick("Left",$X4,$Y4,1) ;Open new button
                Send("{ENTER}")
                Sleep(500)
                MouseClick("Left",$X5,$Y5,1) ;Main debt review window.
                Sleep(1000)
WEnd

Func ProcessPage(ByRef $BPID, ByRef $AccFromFile, ByRef $Notepad)
                $Found = 0
                For $x = 0 to 10
                                MouseClick("Left",$X6,($Y6 + $x*21),2,1) ;Account Data Copy
                                ClipPut("1")
                                Send("^c")
                                Sleep(200)
                                $Return = ClipGet()
                                Sleep(200)
                                $Result = StringInStr($Return, $AccFromFile)
                                If $Result <> 0 Then
                                                $Pos = MouseGetPos()
                                                MouseClick("Left", 53, $Pos[1],1,1) ;If account found select account.
                                                Sleep(1000)
                                                $Found = 1
                                ElseIf $x = 10 and $Return < 10 Then
                                                If $Found <> 1 Then
                                                                $Pos = MouseGetPos()
                                                                MouseClick("Left",$Pos[0]+$X7,$Pos[1]+$Y7,1); Next Page
                                                                $x = -1
                                                                Sleep(2000)
                                                Else
                                                                ExitLoop
                                                EndIf                                     
                                ElseIf $Return < 10 and $x <> 10 Then
                                                ExitLoop ;No more pages
                                EndIf
                Next
                $Pos = MouseGetPos()
                MouseClick("Left",$Pos[0]-$X8, $Pos[1]+$Y8,1);Add new
                $Pos = MouseGetPos()
                Sleep(1000)
                MouseClick("Left",$Pos[0]+$X9, $Pos[1]-$Y9,1);Drop down
                Send("a")
                Send("{ENTER}")
                Send("{TAB}")
;~                 Send(@MDAY & "." & @MON & "." & @YEAR)
                Send("{TAB}")
                Send(@MDAY & "." & @MON & "." & @YEAR)
                MouseClick("Left", $X10,$Y10,1) ;Notepad tab
                Sleep(200)
                MouseClick("Left", $X11,$Y11,1) ;Notepad content window
                Send($Notepad)
;~            MouseMove($X12,$Y12) ; Save Button
                MouseClick("Left", $X12,$Y12,1) ; Save Button
EndFunc
Func ExitF()
                Exit
EndFunc
Func PauseF()
                MsgBox(0,"Paused","Application paused. Click OK to continue.")
EndFunc
