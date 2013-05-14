#Region Global Declarations
#Include <String.au3>
#Include <IE.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Excel.au3>
HotKeySet("{F1}", "Help")
Global $LogonControl = ObjCreate("SAP.LogonControl.1")
Global $TableControl = ObjCreate("SAP.TableFactory.1")
Global $FunctionControl = ObjCreate("SAP.Functions")
Global $oConnection
Global $tblData
Global $Results
Global $System
Global $oExcel
Global $YESTERDAY = @YEAR & @MON & @MDAY -1

If StringLen($YESTERDAY) = 6 Then
	$YESTERDAY = @YEAR & "0" & @MON & "0" & @MDAY -1
ElseIf StringLen($YESTERDAY) = 7 Then
	$YESTERDAY =  @YEAR & @MON & "0" & @MDAY -1
ElseIf StringLen($YESTERDAY) <> 8 Then
	MsgBox(0, "ERROR!", "Incorrect date format for function call. Please contact the developer.")
EndIf

#EndRegion
#Region GUI

Local $msg
GUICreate("SAP Health Check v2",-1,-1,-1,-1,-1,$WS_EX_TOPMOST)  ; will create a dialog box that when displayed is centered
;GUICtrlCreateGroup("User Information", 10, 10, 380, 200)
;~ GUICtrlCreateTab(10,10,380,380)
;~ GUICtrlCreateTabItem("Main")
GUICtrlCreateGroup("Results", 15, 230, 373, 110)

$GO = GUICtrlCreateButton("GO", 165, 345, 70, 50)

$UserD = GUICtrlCreateInput("", 152,22,230,20)
$PasswordD = GUICtrlCreateInput("", 152,50,230,20,0x0020)
$UserI = GUICtrlCreateInput("", 152,97,230,20)
$PasswordI = GUICtrlCreateInput("", 152,125,230,20,0x0020)
$UserU = GUICtrlCreateInput("", 152,172,230,20)
$PasswordU = GUICtrlCreateInput("", 152,200,230,20,0x0020)

GUICtrlCreateLabel("Username", 60,25,50,20)
GUICtrlCreateLabel("Password", 60,53,50,20)
GUICtrlCreateLabel("Username", 60,100,50,20)
GUICtrlCreateLabel("Password", 60,128,50,20)
GUICtrlCreateLabel("Username", 60,175,50,20)
GUICtrlCreateLabel("Password", 60,203,50,20)

$Results =GUICtrlCreateInput("", 25, 245, 355, 87, 0x0004 + 0x00200000)
GUICtrlCreateGroup("BPD", 15, 10, 373, 65)
GUICtrlCreateGroup("BPI", 15, 85, 373, 65)
GUICtrlCreateGroup("BPU", 15, 160, 373, 65)

GUISetState(@SW_SHOW)

FillInputs($UserD, $PasswordD, $UserI, $PasswordI, $UserU, $PasswordU)
$UserDD = GUICtrlRead($UserD)
$PasswordDD = GUICtrlRead($PasswordD)
$UserID = GUICtrlRead($UserI)
$PasswordID = GUICtrlRead($PasswordI)
$UserUD = GUICtrlRead($UserU)
$PasswordUD = GUICtrlRead($PasswordU)
$sFilePath1 = IniRead("settings.ini","Main","Excel File","BP Environment Monitoring.xlsx")
GUICtrlSetData($Results, "Please be patient while the Excel Spreadsheet loads...")
$sFilePath1 = "C:\TEMP\Monitoring.xlsx"
$oExcel = _ExcelBookOpen($sFilePath1,0)
	For $x = 1 to 100

		$sCellValue = _ExcelReadCell($oExcel, $x, 1)
		If _ExcelReadCell($oExcel, $x, 1) = @YEAR & @Mon & @MDAY & "000000" Then
			$z = "Yes"
			If IniRead("settings.ini","DEV","Active","N") = "Y" Then
				_ExcelWriteCell($oExcel, $z, $x, 11)
				_ExcelWriteCell($oExcel, $z, $x, 13)
			EndIf
			If IniRead("settings.ini","SIT","Active","N") = "Y" Then
				_ExcelWriteCell($oExcel, $z, $x+1, 11)
				_ExcelWriteCell($oExcel, $z, $x+1, 13)
			EndIf
			If IniRead("settings.ini","UAT","Active","N") = "Y" Then	
				_ExcelWriteCell($oExcel, $z, $x+2, 11)
				_ExcelWriteCell($oExcel, $z, $x+2, 13)
			EndIf
			ExitLoop
		EndIf
	Next
GUICtrlSetData($Results, "")
If @error = 1 Then
	MsgBox(0, "Error!", "Unable to Create the Excel Object")
	Exit
ElseIf @error = 2 Then
	MsgBox(0, "Error!", "Excel File does not exist!")
	Exit
EndIf

;~ _ExcelHide($oExcel)

While 1
	$msg = GUIGetMsg()
	If $msg = $GO Then 
		If $UserD <> "" AND $UserI <> "" AND $UserU <> "" AND $PasswordD <> "" AND $PasswordI <> "" AND $PasswordU <> "" Then
			UpdatePasswordFile($UserD, $PasswordD, $UserI, $PasswordI, $UserU, $PasswordU)
			$UserDD = GUICtrlRead($UserD)
			$PasswordDD = GUICtrlRead($PasswordD)
			$UserID = GUICtrlRead($UserI)
			$PasswordID = GUICtrlRead($PasswordI)
			$UserUD = GUICtrlRead($UserU)
			$PasswordUD = GUICtrlRead($PasswordU)
			RFCCalls($UserDD, $PasswordDD, $UserID, $PasswordID, $UserUD, $PasswordUD)
		Else
			MsgBox(0,"Error!", "Please fill in all of the required fields.")
		EndIf
	EndIf
	If $msg = $GUI_EVENT_CLOSE Then 
		_ExcelBookSave($oExcel, 0) 
		_ExcelBookClose($oExcel)
		ExitLoop
	EndIf
WEnd
GUIDelete()

#EndRegion
#Region SAP RFC Calls
Func RFCCalls(Byref $UserD,Byref $PasswordD,Byref $UserI,Byref $PasswordI,Byref $UserU,Byref $PasswordU)
;===============================================================================================================================================================
;==============================================CONNECTION=======================================================================================================
;===============================================================================================================================================================
	If IniRead("settings.ini","DEV","Active","Y") = "Y" Then
		$System = IniRead("settings.ini","DEV","System","FID")
		$AppServer = IniRead("settings.ini","DEV","AppServer","10.60.17.157")
		$SysNumber = IniRead("settings.ini","DEV","SysNumber","00")
		$Client = IniRead("settings.ini","DEV","Client","100")
		$Language = IniRead("settings.ini","DEV","Language","E")

		$Auth = Connect($System, $AppServer, $SysNumber, $UserD, $PasswordD, $Client, $Language)
		If $Auth = True Then
			Main($System)
		Else 
			MsgBox(0, "Error!", "Username or Password incorrect for " & $System & ".")
		EndIf
		ConsoleWrite(@CRLF)
		GUICtrlSetData($Results,@CRLF,1)
	EndIf
	If IniRead("settings.ini","SIT","Active","N") = "Y" Then
		$System = IniRead("settings.ini","SIT","System","FIQ")
		$AppServer = IniRead("settings.ini","SIT","AppServer","10.60.16.67")
		$SysNumber = IniRead("settings.ini","SIT","SysNumber","01")
		$Client = IniRead("settings.ini","SIT","Client","200")
		$Language = IniRead("settings.ini","SIT","Language","E")

		$Auth = Connect($System, $AppServer, $SysNumber, $UserI, $PasswordI, $Client, $Language)
		If $Auth = True Then
			Main($System)
		Else 
			MsgBox(0, "Error!", "Username or Password incorrect for " & $System & ".")
		EndIf
		ConsoleWrite(@CRLF)
		GUICtrlSetData($Results,@CRLF,1)
	EndIf
	If IniRead("settings.ini","UAT","Active","N") = "Y" Then	
		$System = IniRead("settings.ini","UAT","System","FIP")
		$AppServer = IniRead("settings.ini","UAT","AppServer","10.60.0.100")
		$SysNumber = IniRead("settings.ini","UAT","SysNumber","00")
		$Client = IniRead("settings.ini","UAT","Client","200")
		$Language = IniRead("settings.ini","UAT","Language","E")

		$Auth = Connect($System, $AppServer, $SysNumber, $UserU, $PasswordU, $Client, $Language)
		If $Auth = True Then
			Main($System)
		Else 
			MsgBox(0, "Error!", "Username or Password incorrect for " & $System & ".")
		EndIf
		ConsoleWrite(@CRLF)
	EndIf
	$oConnection.LogOff
EndFunc
#EndRegion
#Region Excel Spreadsheet
Func Excel(ByRef $Column, Byref $System, ByRef $Value)
	Dim $Row
	
	If $System = "BPD" Then
		$Row = 0
	ElseIf $System = "BPI" Then
		$Row = 1
	ElseIf $System = "BPU" Then
		$Row = 2
	EndIf
	
	For $x = 1 to 100
		$sCellValue = _ExcelReadCell($oExcel, $x, 1)
		If _ExcelReadCell($oExcel, $x, 1) = @YEAR & @Mon & @MDAY & "000000" Then
			_ExcelWriteCell($oExcel, $Value, $x + $Row, $Column)
			ExitLoop
		EndIf
	Next
EndFunc
#EndRegion
#Region SMS
Func SMS()
;Incomplete
EndFunc
#EndRegion
#Region SAP RFCs (Functions)

Func Main(ByRef $System)
	ST22()
	SM58()
	SMQ1()
	SMQ2()
;~ 	SM66()
	DATA_ASYNCH()
	SMW02()
	SCOT()
EndFunc

#Region ST22
;===============================================================================================================================================================
;==============================================ST22=======TESTED_AND_COMPLETELY_FUNCTIONAL======================================================================
;===============================================================================================================================================================
Func ST22()
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "SNAP_BEG"
	$Options =  "DATUM EQ '" & $YESTERDAY & "'"

	$Field = "SEQNO"

	TableRead($Table, $Options, $Field)
	
	If $tblData.RowCount > 0 Then
		For $intRow = 1 To $tblData.RowCount
			IF ($tblData($intRow, 1)) = 000 Then
				$x += 1
			EndIf		
		Next
		ConsoleWrite("ST22: " & $x & " ABAP dumps yesterday on " & $System & @CRLF)
		GUICtrlSetData($Results,"ST22: " & $x & " ABAP dumps yesterday on " & $System & @CRLF,1)
		$z = 3
		Excel($z, $System, $x)
	Else
		$x = 0
		ConsoleWrite ("ST22: " & $x & " ABAP dumps yesterday on " & $System & @CRLF)
		GUICtrlSetData($Results,"ST22: " & $x & " ABAP dumps yesterday on " & $System & @CRLF, 1)
		$z = 3
		Excel($z, $System, $x)
	EndIf
EndFunc
#EndRegion
#Region SM58
;===============================================================================================================================================================
;===============================================SM58========TESTED_AND_COMPLETELY_FUNCTIONAL====================================================================
;===============================================================================================================================================================
Func SM58()
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "ARFCSSTATE"
	$Options =  "ARFCDATUM EQ '" & @YEAR & @MON & @MDAY -1 & "'"
	If StringLen($Options) = 21 Then
		$Options =  "ARFCDATUM EQ '" & @YEAR & "0" & @MON & "0" & @MDAY -1 & "'"
	ElseIf StringLen($Options) = 22 Then
		$Options =  "ARFCDATUM EQ '" & @YEAR & @MON & "0" & @MDAY -1 & "'"
	ElseIf StringLen($Options) <> 23 Then
		MsgBox(0, "ERROR!", "Incorrect date format for function call. Please contact the developer.")
	EndIf
	$Field = "ARFCSTATE"

	TableRead($Table, $Options, $Field)

	If $tblData.RowCount > 0 Then
		For $intRow = 1 To $tblData.RowCount
				If $tblData($intRow, 1) = "SYSFAIL" Then
					$x += 1
				EndIf
			Next
		If $x <> 0 Then
			ConsoleWrite("SM58: " & $x & " errors yesterday on " & $System & @CRLF)
			GUICtrlSetData($Results,"SM58: " & $x & " errors yesterday on " & $System & @CRLF,1)
			$z = 5
			Excel($z, $System, $x)
		Else
			ConsoleWrite ("SM58: " & 0 & " errors yesterday on " & $System & @CRLF)
			GUICtrlSetData($Results,"SM58: " & 0 & " errors yesterday on " & $System & @CRLF,1)
			$z = 5
			$x = 0
			Excel($z, $System, $x)
		EndIf
	Else
		ConsoleWrite ("SM58: " & 0 & " errors yesterday on " & $System & @CRLF)
		GUICtrlSetData($Results,"SM58: " & 0 & " errors yesterday on " & $System & @CRLF,1)
		$z = 5
		$x = 0
		Excel($z, $System, $x)
	EndIf
EndFunc
#EndRegion
#Region SMQ1
;===============================================================================================================================================================
;===============================================SMQ1============TESTED_AND_COMPLETELY_FUNCTIONAL================================================================
;===============================================================================================================================================================
Func SMQ1()
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "TRFCQOUT"
	$Options =  "QSTATE EQ 'SYSFAIL'"
	$Field = "QSTATE"
	
	TableRead($Table, $Options, $Field)

	If $tblData.RowCount > 0 Then
		ConsoleWrite("SMQ1: Outbound Queue blocked on " & $System & @CRLF)
		GUICtrlSetData($Results,"SMQ1: Outbound Queue blocked on " & $System & @CRLF,1)
		$z = 7
		$y = "Blocked"
		Excel($z, $System, $y)
	Else
		ConsoleWrite("SMQ1: Outbound Queues clear on " & $System & @CRLF)
		GUICtrlSetData($Results,"SMQ1: Outbound Queues clear on " & $System & @CRLF,1)
		$z = 7
		$y = "Ok"
		Excel($z, $System, $y)
	EndIf
EndFunc
#EndRegion
#Region SMQ2
;===============================================================================================================================================================
;===============================================SMQ2============TESTED_AND_COMPLETELY_FUNCTIONAL================================================================
;===============================================================================================================================================================
Func SMQ2()
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "TRFCQIN"
	$Options =  "QSTATE EQ 'SYSFAIL'"
	$Field = "QSTATE"
	
	TableRead($Table, $Options, $Field)

	If $tblData.RowCount > 0 Then
		For $intRow = 1 To $tblData.RowCount
			If $tblData($intRow, 1) <> "READY" Then
				ConsoleWrite("SMQ2: Iutbound Queues blocked on " & $System & @CRLF)
				GUICtrlSetData($Results,"SMQ2: Iutbound Queues blocked on " & $System & @CRLF,1)
				$z = 8
				$y = "Blocked"
				Excel($z, $System, $y)
			EndIf
		Next
	Else
		ConsoleWrite("SMQ2: Inbound Queues clear on " & $System & @CRLF)
		GUICtrlSetData($Results,"SMQ2: Inbound Queues clear on " & $System & @CRLF,1)
		$z = 8
		$y = "Ok"
		Excel($z, $System, $y)
	EndIf
EndFunc
#EndRegion
#Region SM66 - Function TH_WPINFO
;~ ;===============================================================================================================================================================
;~ ;===============================================SM66============================================================================================================
;~ ;===============================================================================================================================================================
Func SM66()
	$FunctionControl.RemoveAll
	$x = 0
	Dim $TF
	Dim $SMCount = 0
	
	$oTable = $TableControl.NewTable ()
	
	$FunctionControl.Connection = $oConnection
	$TH_WPINFO = $FunctionControl.Add ( "TH_WPINFO" )
	
	$oTable = $TH_WPINFO.Tables("WPLIST")
	$TH_WPINFO.Call
	For $x = 1 to 24
		$WP_ELT = $oTable.Value($x,14)
		If $WP_ELT <> "" Then
			If $WP_ELT > 2000 Then
				ConsoleWrite("SM66: Long running transactions on " & $System & " for " & $WP_ELT & " seconds." & @CRLF)
				GUICtrlSetData($Results,"SM66: Long running transactions on " & $System & " for " & $WP_ELT & " seconds." & @CRLF,1)
				$SMCount += 1
			EndIf
		EndIf
	Next
	If $TF <> True Then
		ConsoleWrite("SM66: No long running transaction on " & $System & @CRLF)
		GUICtrlSetData($Results,"SM66: No long running transaction on " & $System & @CRLF,1)
		$z = 9
		Excel($z, $System, $SMCount)
	ElseIf $TF = True Then
		$z = 9
		Excel($z, $System, $SMCount)
		$TF = True
	EndIf
EndFunc
#EndRegion
#Region ZBP_DATA_ASYNC - Function RFC_GET_TABLE_ENTRIES
;~ ;===============================================================================================================================================================
;~ ;===============================================ZBP_DATA_ASYNCH=================================================================================================
;~ ;===============================================================================================================================================================

Func DATA_ASYNCH()
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "ZBP_DATA_ASYNCH"
	
	Dim $DACount = 0
	
	$Check = True
	$oTable = $TableControl.NewTable ()
	
	$FunctionControl.Connection = $oConnection
	$RFC_GET_TABLE_ENTRIES = $FunctionControl.Add ( "RFC_GET_TABLE_ENTRIES" )
	
	$strExport1 = $RFC_GET_TABLE_ENTRIES.Exports("TABLE_NAME")
	$strExport1.Value = $Table
	$oTable = $RFC_GET_TABLE_ENTRIES.Tables("ENTRIES")
	$RFC_GET_TABLE_ENTRIES.Call
	
	For $x = 1 to $oTable.RowCount 
		$String = $oTable.Value($x, 1)
		If StringMid($String,5,8) <> @YEAR & @MON & @MDAY Then
			$DACount += 1
		ElseIf StringMid ($String, 13, 2 )> 15 Then
			$DACount += 1
		EndIf
	Next
	
	If $DACount > 0 Then
		ConsoleWrite("ZBP_DATA_ASYNC: Advises are NOT going through in " & $System & @CRLF)
		GUICtrlSetData($Results,"ZBP_DATA_ASYNC: Advises are NOT going through in " & $System & @CRLF,1)
		$z = 12
		$y = $DACount
		Excel($z, $System, $y)
	Else
		ConsoleWrite("ZBP_DATA_ASYNC: Advises are going through in " & $System & @CRLF)
		GUICtrlSetData($Results,"ZBP_DATA_ASYNC: Advises are going through in " & $System & @CRLF,1)
		$z = 12
		$y = $DACount
		Excel($z, $System, $y)
	EndIf
EndFunc
#EndRegion
#Region SMW02
;~ ;===============================================================================================================================================================
;~ ;===============================================SMW02===========================================================================================================
;~ ;===============================================================================================================================================================

Func SMW02()
	Dim $Red = 0
	Dim $Green = 0
	Dim $Yellow = 0
	Dim $Other = 0
	
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "SMW3_BDOC"
	$Options =  "RCV_DATE EQ '" & $YESTERDAY & "'"
	$Field = "BDOC_STATE"
	
	TableRead($Table, $Options, $Field)	
	
	For $intRow = 1 To $tblData.RowCount
		Select
			Case $tblData($intRow, 1) = "I01"
				$Yellow += 1
			Case $tblData($intRow, 1) = "I02"
				$Yellow += 1
			Case $tblData($intRow, 1) = "I03"
				$Yellow += 1
			Case $tblData($intRow, 1) = "I04"
				$Yellow += 1
			Case $tblData($intRow, 1) = "T01"
				$Red += 1
			Case $tblData($intRow, 1) = "F01"
				$Green += 1
			Case $tblData($intRow, 1) = "F02"
				$Green += 1
			Case $tblData($intRow, 1) = "F03"
				$Green += 1
			Case $tblData($intRow, 1) = "F04"
				$Green += 1
			Case $tblData($intRow, 1) = "F05"
				$Other += 1
			Case $tblData($intRow, 1) = "E01"
				$Red += 1
			Case $tblData($intRow, 1) = "E02"
				$Red += 1
			Case $tblData($intRow, 1) = "E03"
				$Red += 1
			Case $tblData($intRow, 1) = "E04"
				$Red += 1
			Case $tblData($intRow, 1) = "E05"
				$Red += 1
			Case $tblData($intRow, 1) = "E06"
				$Red += 1
			Case $tblData($intRow, 1) = "E07"
				$Red += 1
			Case $tblData($intRow, 1) = "E09"
				$Red += 1
			Case $tblData($intRow, 1) = "O01"
				$Yellow += 1
			Case $tblData($intRow, 1) = "D01"
				$Other += 1
			Case $tblData($intRow, 1) = "R01"
				$Other += 1
		EndSelect
	Next

	If $Red > 0 Then
		ConsoleWrite("SMW02: Please check " & $System & ". " & $Red & " Errors." & @CRLF)
		GUICtrlSetData($Results,"SMW02: Please check " & $System & ". " & $Red & " Errors." & @CRLF,1)
		$z = 14
		$y = "No"
		Excel($z, $System, $y)
	ElseIf $Yellow > 0 Then
		ConsoleWrite("SMW02: Please check " & $System & ". " & $Yellow & " Warnings." & @CRLF)
		GUICtrlSetData($Results,"SMW02: Please check " & $System & ". " & $Yellow & " Warnings." & @CRLF,1)
		$z = 14
		$y = "Partial"
		Excel($z, $System, $y)
	ElseIf $Green > 0 Then
		ConsoleWrite("SMW02:" & $System & ". " & $Green & " Successful." & @CRLF)
		GUICtrlSetData($Results,"SMW02: " & $System & ". " & $Green & " Successful." & @CRLF,1)
		$z = 14
		$y = "Yes"
		Excel($z, $System, $y)
	Else
		ConsoleWrite("SMW02: No data available." & @CRLF)
		GUICtrlSetData($Results,"SMW02: No data available." & @CRLF,1)
		$z = 14
		$y = "Yes"
		Excel($z, $System, $y)		
	EndIf	
EndFunc
#EndRegion
#Region SCOT
;~ ;===============================================================================================================================================================
;~ ;===============================================SCOT============================================================================================================
;~ ;===============================================================================================================================================================

Func SCOT()
	Dim $SCOTCount = 0
	
	$FunctionControl.RemoveAll
	$x = 0

	$Table = "SOES"
	$Options =  "SNDDAT EQ '" & $YESTERDAY & "' AND NODE = 'SMTP'"
	$Field = "MSGTY"
	
	TableRead($Table, $Options, $Field)	
	
	For $intRow = 1 To $tblData.RowCount
		If $tblData($intRow, 1) = "E" Then
			$SCOTCount += 1
		EndIf
	Next
	
	If $SCOTCount > 0 Then
		ConsoleWrite("SCOT: Please check " & $System & ". " & $SCOTCount & " Errors." & @CRLF)
		GUICtrlSetData($Results,"SCOT: Please check " & $System & ". " & $SCOTCount & " Errors." & @CRLF,1)
		$z = 15
		$y = $SCOTCount
		Excel($z, $System, $y)
	Else
		ConsoleWrite("SCOT: No errors in " & $System & "." & @CRLF)
		GUICtrlSetData($Results,"SCOT: No errors in " & $System & "." & @CRLF,1)
		$z = 15
		$y = $SCOTCount
		Excel($z, $System, $y)
	EndIf
	
EndFunc
#EndRegion
#Region RFC_READ_TABLE
Func TableRead(ByRef $Table, ByRef $Options, ByRef $Field)
	$FunctionControl.Connection = $oConnection
	$RFC_READ_TABLE = $FunctionControl.Add ( "RFC_READ_TABLE" )
	
	$strExport1 = $RFC_READ_TABLE.Exports("QUERY_TABLE")
	$strExport2 = $RFC_READ_TABLE.Exports("DELIMITER")
	$tblOptions = $RFC_READ_TABLE.Tables("OPTIONS")
	$tblFields = $RFC_READ_TABLE.Tables("FIELDS")
	$tblData = $RFC_READ_TABLE.Tables("DATA")

	$strExport1.Value = $Table
	$strExport2.Value = ","

	$tblOptions.AppendRow
	$tblOptions(1, "TEXT") = $Options

	$tblFields.AppendRow
	$tblFields(1, "FIELDNAME") = $Field

	$RFC_READ_TABLE.Call
	
EndFunc
#EndRegion
#Region NewConnection
Func Connect(ByRef $System, ByRef $AppServer, ByRef $SysNumber, ByRef $User, ByRef $Password, ByRef $Client, ByRef $Language)
	Dim $LoggedIn = False
	$oConnection = $LogonControl.NewConnection
	$oConnection.System = $System
	$oConnection.ApplicationServer = $AppServer
	$oConnection.SystemNumber = $SysNumber

	$oConnection.User = $User
	$oConnection.Password = $Password
	$oConnection.Client = $Client
	$oConnection.Language = $Language
	$LoggedIn = $oConnection.Logon (0,True)
	Return $LoggedIn
;~ 	If $LoggedIn = True Then
;~ 		MsgBox(0, "", True)
;~ 	Else 
;~ 		MsgBox(0,"",False)
;~ 	EndIf
EndFunc
#EndRegion

#EndRegion

#Region Misc
Func FillInputs(Byref $DU, Byref $DP, Byref $IU, Byref $IP, Byref $UU, Byref $UP)
	GUICtrlSetData($DU, IniRead("settings.ini","DEV","Username","ERROR!"))
	GUICtrlSetData($DP, IniRead("settings.ini","DEV","Password","ERROR!"))
	GUICtrlSetData($IU, IniRead("settings.ini","SIT","Username","ERROR!"))
	GUICtrlSetData($IP, IniRead("settings.ini","DEV","Password","ERROR!"))
	GUICtrlSetData($UU, IniRead("settings.ini","UAT","Username","ERROR!"))
	GUICtrlSetData($UP, IniRead("settings.ini","DEV","Password","ERROR!"))
EndFunc

Func UpdatePasswordFile(Byref $DU, Byref $DP, Byref $IU, Byref $IP, Byref $UU, Byref $UP)
	IniWrite("settings.ini","DEV","Username", GUICtrlRead($UserD))
	IniWrite("settings.ini","DEV","Password",  GUICtrlRead($PasswordD))
	IniWrite("settings.ini","SIT","Username", GUICtrlRead($UserI))
	IniWrite("settings.ini","SIT","Password",  GUICtrlRead($PasswordI))
	IniWrite("settings.ini","UAT","Username",  GUICtrlRead($UserU))
	IniWrite("settings.ini","UAT","Password",  GUICtrlRead($PasswordU))
EndFunc
#EndRegion

Func Help()
	Run(@ProgramFilesDir & "\SAP Health Check.chm")
EndFunc