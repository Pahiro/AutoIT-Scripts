#include <Constants.au3>
#Region Variables
#cs - 24/04/2013 - Bennet van der Gryp
This is a program to pull data from MQ and post those details
into SAP. Please do not attempt to modify this program without
the proper background knowledge and know-how.

This program was written as a replacement for the old program
because the previous one kept requiring a restart.

SAP GUI is not installed on this server. Therefore startrfc.exe 
has to be used. startrfc.exe is supplied by SAP and has the 
required COM objects included inside the file. I've tried 
registering the OCX files without installing SAP GUI but it 
didn't work so this will be the solution for now.
#ce 
Global $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc") ;Catch COM errors
Global $IniFile 
If $CmdLine[0] Then
   $IniFile = $CmdLine[1]
Else 
   $IniFile = "qtof_britehouse_1.ini"
EndIf;Parameter for the INI file
;Global $LogonControl = ObjCreate("SAP.LogonControl.1")
;Global $FunctionControl = ObjCreate("SAP.Functions")
;Global $oConnection
Global $User = IniRead($IniFile,"SAPServer","Username","")
Global $Password = IniRead($IniFile,"SAPServer","Password","")
Global $System = IniRead($IniFile,"SAPServer","System","FID")
Global $AppServer = IniRead($IniFile,"SAPServer","AppServer","")
Global $SysNumber = IniRead($IniFile,"SAPServer","SysNumber","00")
Global $Client = IniRead($IniFile,"SAPServer","Client","100")
Global $Language = IniRead($IniFile,"SAPServer","Language","E")
Global $RFC = IniRead($IniFile,"SAPServer","RFC","Z_ZAFI_INBOUND_INTERFACES")
Global $RFCExec = IniRead($IniFile,"Settings","StartRFC","")
Global $Program = IniRead($IniFile,"SAPServer","Program","ZFI_I90_UPLOAD")

Global $iniServer = IniRead($IniFile, "Settings", "MQServer", "")
Global $iniQM = IniRead($IniFile, "Settings", "QueueManager", "")
Global $iniQueue = IniRead($IniFile, "Settings", "Queue", "")

#EndRegion Variables
#Region Accessing MQ
EnvSet("MQSERVER", $iniServer) ;MQ Server
$MQSess  = ObjCreate("MQAX200.MQSession")
$QMgr = ObjCreate("MQAX200.MQQueueManager")
$QMgr = $MQSess.AccessQueueManager($iniQM) ;Queue Manager
ConsoleWrite("Connected" & @CRLF)
$Queue = $QMgr.AccessQueue($iniQueue, 2) ;Queue (2=MQOO_INPUT, 16=MQOO_OUTPUT)
While 1
   SendSciTE_Command("menucommand:420") ;Clear Console (Comment out for compile)
   $GetMsg = $MQSess.AccessMessage
   $GetMsg.CharacterSet = 1047 ;EBCDIC (Initial message format)
   $GetOptions = $MQSess.AccessGetMessageOptions()
   $Queue.Get($GetMsg, $GetOptions)
   $GetMsg.CharacterSet = 437 ;ASCII (Convert to ASCII format)
   If $Queue.ReasonCode = 2033 Then ;When there aren't any new messages sleep for 2 seconds.
	  Sleep(2000)
   Else
#EndRegion Accessing MQ
#Region Write File
	  $MsgData = $GetMsg.MessageData
;Write File Section
	  
	  $FilePath = IniRead($IniFile,"Settings","Directory","") & _
		 "DQ" & IniRead($IniFile, "Settings", "QueueManager", "") & "_" & _
		 StringMid($MsgData, 3, 8) & "_" & StringMid($MsgData, 11, 6) & ".txt"
	  
	  $oFile = FileOpen($FilePath, 2)
	  FileWrite($oFile, $MsgData)
	  FileClose($oFile)
#EndRegion Write File
#Region Execute RFC
	  $foo = Run(@ComSpec & " /c " & $RFCExec & " -3 -h " & $AppServer & " -s " & $SysNumber & " -F " & $RFC & " -u " & $User & " -p " & $Password & " -c " & $Client & " -l " & $Language & " -E FNAME=" & $FilePath & " -E PNAME=" & $Program, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	  $errcount = 0
	  Sleep(200) ;For stability
	  While 1
		 $line = StdoutRead($foo)
		 If @error Then ExitLoop
		 Consolewrite($line)
		 $LogFile = FileOpen(StringReplace($FilePath, "\In\","\Logs\"), 2)
		 FileWrite($LogFile, $Line)
		 FileClose($LogFile)
		 FileMove($FilePath, StringReplace($FilePath, "\In\","\Out\"))
	  WEnd

	  While 1
		 $errcount += 1
		 $line = StderrRead($foo)
		 If @error Then ExitLoop
		 Consolewrite($line)
		 If StringMid($line, StringInStr($line, "ERRNO")+12, 5) = 10061 Then ;Retry if server is down
			$foo = Run(@ComSpec & " /c " & $RFCExec & " -3 -h " & $AppServer & " -s " & $SysNumber & " -F " & $RFC & " -u " & $User & " -p " & $Password & " -c " & $Client & " -l " & $Language & " -E FNAME=" & $FilePath & " -E PNAME=" & $Program, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
			TrayTip("Error", "No response from SAP system, retrying. Attempt " & $errcount, 30)
			Sleep(60000);Wait for 1 minute before trying again.
		 EndIf
		 FileMove($FilePath, StringReplace($FilePath, "\In\","\Errors\"))
	  WEnd
#cs - SAP SECTION (Missing LogonControl and FunctionControl on the system
	  $Auth = Connect()
	  If $Auth = True Then
		 $FunctionControl.RemoveAll
		 $FunctionControl.Connection = $oConnection
		 $RFC_POST = $FunctionControl.Add ($RFC)
		 $strExport1 = $RFC_POST.Exports("FNAME")
		 $strExport2 = $RFC_POST.Exports("PNAME")
		 $strExport1.Value = $FilePath
		 $strExport2.Value = "ZFI_I90_UPLOAD"
		 $RFC_POST.Call
	  Else 
		 ConsoleWrite("Username or Password incorrect for " & $System & ".")
	  EndIf
#ce 
   EndIf
WEnd
#EndRegion Execute RFC

#Region Catch COM errors
Func _ErrFunc($oError)
   ConsoleWrite(@HOUR & ":" & @MIN & ":" & @SEC & " " & $oError.description & @CRLF)
EndFunc   ;==>_ErrFunc
#EndRegion Catch COM errors

#Region SAP GUI LogonControl (Currently Not Used)
#cs
Func Connect()   
   Dim $LoggedIn = False
   $oConnection = $LogonControl.NewConnection
   $oConnection.System = $System
   $oConnection.ApplicationServer = $AppServer
   $oConnection.SystemNumber = $SysNumb
   
   $oConnection.User = $User
   $oConnection.Password = $Password
   $oConnection.Client = $Client
   $oConnection.Language = $Language
   $LoggedIn = $oConnection.Logon(0, True)
   Return $LoggedIn
EndFunc
#ce
#EndRegion SAP GUI LogonControl (Currently Not Used)

Func SendSciTE_Command($sCmd)
	Local $Scite_hwnd = WinGetHandle("DirectorExtension")
	Local $WM_COPYDATA = 74
	Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
	DllStructSetData($CmdStruct, 1, $sCmd)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
	DllStructSetData($COPYDATA, 1, 1)
	DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
	DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
	DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $Scite_hwnd, _
			'Int', $WM_COPYDATA, 'HWnd', 0, _
			'Ptr', DllStructGetPtr($COPYDATA))
EndFunc   ;==>SendSciTE_Command
