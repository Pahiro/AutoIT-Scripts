#cs
Author: Bennet van der Gryp
Description: Password change program to keep all SAP systems in synch.
#ce
Global $LogonControl = ObjCreate("SAP.LogonControl.1")
Global $FuncControl = ObjCreate("SAP.Functions")
Global $objFileSystemObject = ObjCreate("Scripting.FileSystemObject")

$nr = 0
$string = ""
$var = ""

$newpass = InputBox("New","Enter new password")

While 1
	$nr += 1
	$sys = IniRead("changepass.ini", "SYS", "Item" & $nr, "")
	$app = IniRead("changepass.ini", "APP", "Item" & $nr, "")
	$sysnr =  IniRead("changepass.ini", "SYSNR", "Item" & $nr, "")
	$client =  IniRead("changepass.ini", "CLIENT", "Item" & $nr, "")
	$lang = IniRead("changepass.ini", "LANG", "Item" & $nr, "")
	$currpass = IniRead("changepass.ini", "PASS", "Item" & $nr, "")
	$newpass = $newpass
	
	If $sys = "" Then
		ExitLoop
	Else 
	    $Return = ChangePassword($sys, $app, $sysnr, $client, $lang, $currpass, $newpass)
	    If $Return = "Success" Then
		   IniWrite("changepass.ini","PASS", "Item" & $nr, $newpass)
		   ConsoleWrite($sys & $client & " : Password changed to " & $newpass & @CRLF)
		Else
		   ConsoleWrite($sys & $client & " : Password change failed" & @CRLF)
	    EndIf
    EndIf   
WEnd

Func ChangePassword(ByRef $sys, ByRef $app, ByRef $sysnr, ByRef $client, ByRef $lang, ByRef $currpass, ByRef $newpass)
	$oConnection = $LogonControl.NewConnection
	$oConnection.System = $sys
	$oConnection.ApplicationServer = $app
	$oConnection.SystemNumber = $sysnr
	$oConnection.Client = $client
	$oConnection.Language = $lang
	$oConnection.user = "A159994"
	$oConnection.Password = $currpass
	
	$LoggedIn = $oConnection.Logon (0,True)
	If $LoggedIn = True Then
		$FuncControl.connection = $oConnection
		
		$CHPASS_FN = $FuncControl.Add("SUSR_USER_CHANGE_PASSWORD_RFC")
		$expPassword = $CHPASS_FN.Exports("PASSWORD")
		$expNewPass = $CHPASS_FN.Exports("NEW_PASSWORD")
		$expFillRet = $CHPASS_FN.Exports("USE_BAPI_RETURN")
		$impReturn = $CHPASS_FN.Imports("RETURN")
		$expPassword.Value = $currpass
		$expNewPass.Value = $newpass
		$expFillRet.Value = "1"
		
		If $CHPASS_FN.Call = True Then
			Return "Success"
		Else
			Return "False"
		EndIf
	Else 
		Return "False"
	EndIf
EndFunc