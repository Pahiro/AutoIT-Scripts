#cs
Author: Bennet van der Gryp
Description: Test file
#ce
;Variables
Global $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc") ;Catch COM errors
Global $IniFile 
If $CmdLine[0] Then
   $IniFile = $CmdLine[1]
Else 
   $IniFile = "qtof_I90_1.ini"
EndIf;Parameter for the INI file
Global $LogonControl = ObjCreate("SAP.LogonControl.1")
Global $FunctionControl = ObjCreate("SAP.Functions")
Global $oConnection

;Accessing MQ
EnvSet("MQSERVER", IniRead($IniFile, "Settings", "MQServer", "")) ;MQ Server
$MQSess  = ObjCreate("MQAX200.MQSession")
$QMgr = ObjCreate("MQAX200.MQQueueManager")
$QMgr = $MQSess.AccessQueueManager(IniRead($IniFile, "Settings", "QueueManager", "")) ;Queue Manager
ConsoleWrite("Connected" & @CRLF)
$Queue = $QMgr.AccessQueue(IniRead($IniFile, "Settings", "Queue", ""), 2) ;Queue (2=MQOO_INPUT, 16=MQOO_OUTPUT)
While($Queue.completionCode <> -1)
   $GetMsg = $MQSess.AccessMessage
   $GetOptions = $MQSess.AccessGetMessageOptions
   $Queue.Get($GetMsg, $GetOptions)
   If $Queue.ReasonCode = 2033 Then ;When there aren't any new messages sleep for 2 seconds.
	  Sleep(2000)
   Else
	  $MsgData = $GetMsg.MessageData
;Write File Section
	  $FilePath = IniRead($IniFile,"Settings","Directory","") & _
		 "DQ" & IniRead($IniFile, "Settings", "QueueManager", "") & "_" & _
		 StringMid($MsgData, 3, 8) & "_" & StringMid($MsgData, 11, 6) & ".txt"
	  
	  $oFile = FileOpen($FilePath, 2)
	  FileWrite($oFile, $MsgData)
	  FileClose($oFile)
;SAP Section
	  $Auth = Connect()
	  If $Auth = True Then
		 $FunctionControl.RemoveAll
		 $FunctionControl.Connection = $oConnection
		 $RFC_POST = $FunctionControl.Add (IniRead($IniFile,"SAPServer","RFC","Z_ZAFI_INBOUND_INTERFACES"))
		 $strExport1 = $RFC_POST.Exports("FNAME")
		 $strExport2 = $RFC_POST.Exports("PNAME")
		 $strExport1.Value = $FilePath
		 $strExport2.Value = "ZFI_I90_UPLOAD"
		 $RFC_POST.Call
	  Else 
		 ConsoleWrite("Username or Password incorrect for " & $System & ".")
	  EndIf
   EndIf
WEnd

Func _ErrFunc($oError)
   ConsoleWrite($oError.description & @CRLF)
EndFunc   ;==>_ErrFunc

Func Connect()
   $User = IniRead($IniFile,"SAPServer","Username","RFCUSER")
   $Password = IniRead($IniFile,"SAPServer","Password","saeagle")
   $System = IniRead($IniFile,"SAPServer","System","FID")
   $AppServer = IniRead($IniFile,"SAPServer","AppServer","10.60.17.157")
   $SysNumber = IniRead($IniFile,"SAPServer","SysNumber","00")
   $Client = IniRead($IniFile,"SAPServer","Client","100")
   $Language = IniRead($IniFile,"SAPServer","Language","E")
   
   Dim $LoggedIn = False
   $oConnection = $LogonControl.NewConnection
   $oConnection.System = $System
   $oConnection.ApplicationServer = $AppServer
   $oConnection.SystemNumber = $SysNumber

   $oConnection.User = $User
   $oConnection.Password = $Password
   $oConnection.Client = $Client
   $oConnection.Language = $Language
   $LoggedIn = $oConnection.Logon(0, True)
   Return $LoggedIn
EndFunc