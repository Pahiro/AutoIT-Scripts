#include <Scrape.au3>

$Source = _getSource("http://www.news24.com/")
MsgBox(0,"", $Source)
$Code = _stripHTML($Source)
MsgBox(0,"", $Code)
