#include <SAP.au3>

_SAPSessAttach("SAP Easy Access")
_SAPObjValueSet("tbar[0]/okcd","se37")
_SAPVKeysSend("Enter")
_SAPObjValueSet("usr/ctxtRS38L-NAME","Z_ADR_HIDE_UNHIDE")
_SAPVKeysSend("F8")
_SAPVKeysSend("F2")
_SAPVKeysSend("SHIFT+F7")
_SAPObjValueSet("usr/txt[51,10]","0000000001") ;??? Switch to WND[1] from WND[0].