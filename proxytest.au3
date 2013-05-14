#include <XML.au3>
#include <Array.au3>
#include <String.au3>
#include <Array.au3>
	
Global $X
Opt("WinTitleMatchMode", 2)
dim $aAttName[1],$aAttVal[1]
HotKeySet("{PAUSE}", "PauseProg")
HotKeySet("{HOME}", "ConProg")
$FilePath = "C:\Users\Bennet van der Gryp\My Documents\192.168.xml"

$XML = _XMLFileOpen($FilePath)

$ret = _XMLGetValue("/network-scanner-results/items/item/ip-address")

For $IP in $ret
	;set parameters for using 
	Global $UseIntegratedSecurity = True
	Global $ProxyServer = $IP & ":80"
	Global $ProxyUser = "SBICZA01/a159994" ;if $UseIntegratedSecurity is true (and working), these can be blank
	Global $ProxyPass = "AA!(19"

	;create WinHttpRequest object for downloading config info
	Global $oHttp = ObjCreate ("WinHttp.WinHttpRequest.5.1")
	$oHttp.SetProxy(2,$ProxyServer) ; PRECONFIG = 0 (default), DIRECT = 1, PROXY = 2
	
	$sHTML = httpget("http://www.google.com")
	ConsoleWrite($IP & @CRLF)
Next

Func Auth()
	Send("SBICZA01\a159994")
	Send("{TAB}")
	Send("AA{!}{(}19")
	Send("{Enter}")
	Sleep(2000)
	If WinExists("Authentication Required") Then
		Auth()
	EndIf
EndFunc

Func PauseProg()
	$X = 1
	While $X = 1
		Sleep(200)
	WEnd
EndFunc

Func ConProg()
	$X = 0
EndFunc


func httpget($url)
    $COMerrnotify = false
    
    If $UseIntegratedSecurity Then
        $oHttp.SetAutoLogonPolicy(0) ; Always = 0, OnlyIfBypassProxy = 1, Never = 2
    Else
        $oHttp.SetAutoLogonPolicy(2) ; Always = 0, OnlyIfBypassProxy = 1, Never = 2
    EndIf
    
    $status = $oHttp.Open("GET", $url,false)
    
    If Not $UseIntegratedSecurity Then
        $oHttp.SetCredentials($ProxyUser,$ProxyPass,0) ; HTTPREQUEST_SETCREDENTIALS_FOR_SERVER = 0
    EndIf
    
    
    $oHttp.Send()
    if $oHttp.Status <> "200" then
        $status = $oHttp.Status
        $StatusText = $oHttp.StatusText
        Consolewrite("Status: " & $status & @crlf)
        Consolewrite("StatusText: " & $StatusText & @crlf)
        $COMerrnotify = true
        SetError(1)
        return $status & " - " & $StatusText        
    Else
        $COMerrnotify = true
        SetError(0)
        Consolewrite("Response Headers: " & $oHttp.GetAllResponseHeaders & @crlf)
        return $oHttp.ResponseText
    EndIf
    
EndFunc

;_IEErrorHandlerRegister("ComErrFunc")
$oIEErrorHandler = ObjEvent("AutoIt.Error","ComErrFunc")
global $COMerrnotify = true
Func ComErrFunc()
    If IsObj($oIEErrorHandler) Then
        if $COMerrnotify then
            ConsoleWrite("--> ComErrFunc: COM Error Encountered in " & @ScriptName & @CR)
            ConsoleWrite("----> Scriptline = " & $oIEErrorHandler.scriptline & @CR)
            ConsoleWrite("----> Number Hex = " & Hex($oIEErrorHandler.number, 8) & @CR)
            ConsoleWrite("----> Number = " & $oIEErrorHandler.number & @CR)
            ConsoleWrite("----> Win Description = " & StringStripWS($oIEErrorHandler.WinDescription, 2) & @CR)
            ConsoleWrite("----> Description = " & StringStripWS($oIEErrorHandler.description, 2) & @CR)
            ConsoleWrite("----> Source = " & $oIEErrorHandler.Source & @CR)
            ConsoleWrite("----> Help File = " & $oIEErrorHandler.HelpFile & @CR)
            ConsoleWrite("----> Help Context = " & $oIEErrorHandler.HelpContext & @CR)
            ConsoleWrite("----> Last Dll Error = " & $oIEErrorHandler.LastDllError & @crlf)
        EndIf
        $HexNumber = Hex($oIEErrorHandler.number, 8)
        SetError($HexNumber)
    Else
        SetError(1)
    EndIf
    Return 0
EndFunc