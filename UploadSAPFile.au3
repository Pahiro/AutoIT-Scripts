#include <SAP.au3>
#include <File.au3>
#include <Array.au3>

_SAPSessAttach("Program ZBP_ADR_FILE_UPLOAD")
$ARR = _FileListToArray("C:\TEMP\SAP\")
For $x = 1 to $ARR[0]
	_SAPObjValueSet("usr/ctxtP_INFILE", "C:\TEMP\SAP\" & $ARR[$x])
	ToolTip($ARR[$x])
	_SAPObjValueSet("usr/txtP_OUTFIL", "/usr/sap/CDQ/" & $ARR[$x]) 
	_SAPVKeysSend("F8")
	Sleep(1000)
Next

