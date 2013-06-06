#include <IE.au3>
#Include <Excel.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
$Path = 'C:\TEMP\TZIM.xls'
Global $oExcel = _ExcelBookOpen($Path,0)
Global $aArray = _ExcelReadSheetToArray($oExcel) ;Using Default Parameters

;~ _ArrayDisplay($aArray)
;~ exit
For $x = 81 to 90
   Consolewrite("Attaching to IE" & @CRLF)
   $oIE = _IEAttach("", "instance", 1)
   Consolewrite("Attaching to Form" & @CRLF)
   $oForm = _IEFormGetObjByName ($oIE, "Form1")
   Consolewrite("Attaching to Objects" & @CRLF)
   $oFirstName = _IEFormElementGetObjByName ($oForm, "txtFirstname")
   $oLastName = _IEFormElementGetObjByName ($oForm, "txtSurname")
   $oEmail = _IEFormElementGetObjByName ($oForm, "txtEmail")
   $oSave = _IEFormElementGetObjByName ($oForm, "btnSave")
   Consolewrite("Setting values" & @CRLF)
   _IEFormElementSetValue ($oFirstName, $aArray[$x][1])
   _IEFormElementSetValue ($oLastName, $aArray[$x][2])   
   _IEFormElementSetValue ($oEmail, $aArray[$x][3]) 
;~    Exit
   _IEAction ($oSave, "click")
   _IELoadWait($oIE)
   _IENavigate($oIE, "http://helpdesk.britehouse.co.za/User/UserUpdate.aspx?cMode=Add&nClientNo=293")
   _IELoadWait($oIE)
;~    MsgBox(0,"","")
Next






Func _ArraySize( $aArray )
	SetError( 0 )
	
	$index = 0
	
	Do
		$pop = _ArrayPop( $aArray )
		$index = $index + 1
	Until @error = 1
	
	Return $index - 1
EndFunc