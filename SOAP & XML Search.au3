#include <Array.au3>
Global $oMyError
$XMLFile = "C:\TEMP\1.xml"

#region SOAP Section

$oSOAP = ObjCreate("MSSOAP.SoapClient30")

$oSOAP.mssoapinit("http://www.webservicex.net/stockquote.asmx?WSDL")

$oSOAP.ConnectorProperty("ProxyServer") = "192.168.101.54:80" 
$oSOAP.ConnectorProperty("ProxyUser") = "SBICZA01\a159994" 
$oSOAP.ConnectorProperty("ProxyPassword") = "AA!^16"

$String = $oSOAP.GetQuote("MSFT")

;ConsoleWrite($String)
$oFile = FileOpen($XMLFile,2)
FileWrite($oFile,$String)
FileClose($oFile)
#endregion


#region XML Searching
$objXML = ObjCreate("Msxml2.DOMDocument.6.0")

$objXML.async = False
$objXML.preserveWhiteSpace = True
$objXML.validateOnParse = True
$objXML.Load($XMLFile)
$objXML.setProperty ("SelectionLanguage", "XPath")

$Nodes = $objXML.SelectNodes("/StockQuotes/Stock")

For $Node in $Nodes
    ConsoleWrite($Node.SelectSingleNode("Name").text & @CRLF)
Next


$SearchNodes = $objXML.SelectNodes("/NewDataSet/Table[Name='South Africa']")

For $Node in $SearchNodes
    ConsoleWrite($Node.SelectSingleNode("Name").text & @CRLF)
Next

#endregion
