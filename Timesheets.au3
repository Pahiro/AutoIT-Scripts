#include <IE.au3>
#Include <Excel.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

$Form1 = GUICreate("Timesheets", 374, 305, 294, 171)
$Button1 = GUICtrlCreateButton("Run", 136, 232, 105, 57, $WS_GROUP)
$Group1 = GUICtrlCreateGroup("User Details", 16, 16, 345, 105)
$Label1 = GUICtrlCreateLabel("Username:", 64, 48, 55, 17)
$Label2 = GUICtrlCreateLabel("Password:", 64, 77, 55, 17)
$Username = GUICtrlCreateInput("bennet.vandergryp@britehouse.co.za", 120, 48, 190, 21)
$Password = GUICtrlCreateInput("", 120, 82, 190, 21,0x0020)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("File Details", 16, 136, 345, 65)
$Path = GUICtrlCreateInput("C:\TEMP\Timesheets.xlsx", 120, 164, 190, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Label3 = GUICtrlCreateLabel("Path:", 63, 165, 29, 17)
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			 Main(GUICtrlRead($Username), GUICtrlRead($Password), GUICtrlRead($Path))
	EndSwitch
WEnd

Func Main(ByRef $Username, ByRef $Password, ByRef $Path)
	$oIE = _IECreate ("http://tms.britehousessd.co.za/tabid/114/Default.aspx")
	$oForm = _IEFormGetObjByName ($oIE, "Form")

	$oEmail = _IEFormElementGetObjByName ($oForm, "dnn:ctr498:MembersLogin:txtEmail")
	$oPass = _IEFormElementGetObjByName ($oForm, "sPwd")
	$oButton = _IEFormElementGetObjByName ($oForm, "dnn:ctr498:MembersLogin:btnLogin")

	_IEFormElementSetValue ($oEmail, $Username)
	_IEFormElementSetValue ($oPass, $Password)
	_IEAction ($oButton, "click")
	_IELoadWait($oIE)
	$oForm = _IEFormGetObjByName ($oIE, "frmNavigate")
	_IELinkClickByText ($oIE, "Projects")
	_IELoadWait($oIE)
	_IELinkClickByText ($oIE, "Timesheets")

	Global $oExcel = _ExcelBookOpen($Path,0)
	Global $aArray = _ExcelReadSheetToArray($oExcel) ;Using Default Parameters
	_ExcelBookClose($oExcel)

	For $x = 1 to $aArray[0][0] step 5
		$oForm = _IEFormGetObjByName ($oIE, "add_Timesheet")
		$oSubmit = _IEFormElementGetCollection ($oForm, 62)
		$Index = $aArray[0][0] - $x
		If $Index > 4 Then
			For $y = 1 to 5
				$Day = $aArray[$x+$y][1]
				$Month = $aArray[$x+$y][2]
				If $Month < 10 Then
					$Month = '0' & $Month
				EndIf
				$Year = $aArray[$x+$y][3]
				$Project = $aArray[$x+$y][4]
				$NonBill = $aArray[$x+$y][5]
				$Bill = $aArray[$x+$y][6]
				$Desc = $aArray[$x+$y][7]
				$CallNr = $aArray[$x+$y][8]
				
				$oDay = _IEFormElementGetObjByName ($oForm, "dtDD_" & $y)
				$oMonth = _IEFormElementGetObjByName ($oForm, "dtMM_" & $y)
				$oYear = _IEFormElementGetObjByName ($oForm, "dtYY_" & $y)
				$oProject = _IEFormElementGetObjByName ($oForm, "selResourceProjectID_" & $y)
				$oBill = _IEFormElementGetObjByName ($oForm, "txtHours_" & $y)
				$oNonBill = _IEFormElementGetObjByName ($oForm, "d_NonBill_Hours_" & $y)
				$oDesc = _IEFormElementGetObjByName ($oForm, "sActivity_" & $y)
				$oCallNr = _IEFormElementGetObjByName ($oForm, "sRFS_" & $y)
				
				_IEFormElementCheckboxSelect ($oForm, $y-1, "chkInclude", 1, "byIndex")
				_IEFormElementSetValue ($oDay, $Day)
				_IEFormElementSetValue ($oMonth, $Month)
				_IEFormElementSetValue ($oYear, $Year)
				_IEFormElementOptionSelect($oProject, $Project, 1, "byText")
				_IEFormElementSetValue ($oBill, $Bill)
				_IEFormElementSetValue ($oNonBill, $NonBill)
				_IEFormElementSetValue ($oDesc, $Desc)
				_IEFormElementSetValue ($oCallNr, $CallNr)
			Next
			
;~ 			MsgBox(0,"","Continue")

			_IEAction($oSubmit, "click")
			
			If WinExists("Message from webpage") Then
				WinActivate("Message from webpage")
				Send("{ENTER}")
			EndIf
				
			_IELoadWait($oIE)
		Else 
			For $y = 1 to $Index
				ConsoleWrite($Index & ":" & $x & ":" & $y & @CRLF)
				$Day = $aArray[$x+$y][1]
				$Month = $aArray[$x+$y][2]
				If $Month < 10 Then
					$Month = '0' & $Month
				EndIf
				$Year = $aArray[$x+$y][3]
				$Project = $aArray[$x+$y][4]
				$NonBill = $aArray[$x+$y][5]
				$Bill = $aArray[$x+$y][6]
				$Desc = $aArray[$x+$y][7]
				$CallNr = $aArray[$x+$y][8]
				
				$oDay = _IEFormElementGetObjByName ($oForm, "dtDD_" & $y)
				$oMonth = _IEFormElementGetObjByName ($oForm, "dtMM_" & $y)
				$oYear = _IEFormElementGetObjByName ($oForm, "dtYY_" & $y)
				$oProject = _IEFormElementGetObjByName ($oForm, "selResourceProjectID_" & $y)
				$oBill = _IEFormElementGetObjByName ($oForm, "txtHours_" & $y)
				$oNonBill = _IEFormElementGetObjByName ($oForm, "d_NonBill_Hours_" & $y)
				$oDesc = _IEFormElementGetObjByName ($oForm, "sActivity_" & $y)
				$oCallNr = _IEFormElementGetObjByName ($oForm, "sRFS_" & $y)
				
				_IEFormElementCheckboxSelect ($oForm, $y-1, "chkInclude", 1, "byIndex")
				_IEFormElementSetValue ($oDay, $Day)
				_IEFormElementSetValue ($oMonth, $Month)
				_IEFormElementSetValue ($oYear, $Year)
				_IEFormElementOptionSelect($oProject, $Project, 1, "byText")
				_IEFormElementSetValue ($oBill, $Bill)
				_IEFormElementSetValue ($oNonBill, $NonBill)
				_IEFormElementSetValue ($oDesc, $Desc)
				_IEFormElementSetValue ($oCallNr, $CallNr)
			Next
			
;~ 			MsgBox(0,"","Continue" & $Index)
			_IEAction($oSubmit, "click")
			
			If WinExists("Message from webpage") Then
				WinActivate("Message from webpage")
				Send("{ENTER}")
			EndIf
			
			_IELoadWait($oIE)
		EndIf
	Next
	_IEQuit($oIE)
	MsgBox(64,"Success", "All of your timesheet data"& @CRLF & "has been successfully uploaded")
EndFunc