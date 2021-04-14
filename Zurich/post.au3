#cs
Author: Bennet van der Gryp
Description: Post a file to the IBM MQ queue.
#ce
;Variables
Global $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc") ;Catch COM errors
Global $IniFile = "qtof_I90_1.ini" ;Parameter for the INI file

;Accessing MQ
EnvSet("MQSERVER", "") ;MQ Server
$MQSess  = ObjCreate("MQAX200.MQSession")
$QMgr = ObjCreate("MQAX200.MQQueueManager")
$QMgr = $MQSess.AccessQueueManager("") ;Queue Manager
ConsoleWrite("Connected" & @CRLF)
$Queue = $QMgr.AccessQueue("ZAE.SAP.AQ002", 16) ;Queue (2=MQOO_INPUT, 16=MQOO_OUTPUT)
$QMgr.Commit
$PutMsg = $MQSess.AccessMessage
$oFile = FileOpen("D:\MQQ\Inbound\I90\AQ002\In\DQZAESAPQQM1_20130402_07061059.txt")
$Data = FileRead($oFile)
$PutMsg.MessageData = $Data
$PutMsg.CharacterSet = 1047
$PutOptions = $MQSess.AccessPutMessageOptions
$Queue.Put($PutMsg, $PutOptions)

Func _ErrFunc($oError)
   ConsoleWrite($oError.description & @CRLF)
EndFunc   ;==>_ErrFunc
