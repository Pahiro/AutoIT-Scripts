#cs
Author: Bennet van der Gryp
Description:
#ce
#include <Pyro.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <INet.au3>
#include <String.au3>
#include <Array.au3>

_LoadUI()

Func _LoadUI()
	Local $msg
	Local $aParts[1] = [-1]
	Local $aText[1] = [""]

	GUICreate("My GUI") ; will create a dialog box that when displayed is centered
	$FFGForm = GUICreate("FanFictionGrabber v5.0", 244, 120, -1, -1)
	$iStoryID = GUICtrlCreateInput("", 88, 16, 129, 21)
	$iDir = GUICtrlCreateInput(@ScriptDir & "\Stories\", 88, 40, 129, 21)
	$lStoryID = GUICtrlCreateLabel("StoryID", 35, 18, 45, 17)
	$lDir = GUICtrlCreateLabel("Directory", 35, 42, 45, 17)
	$bGet = GUICtrlCreateButton("Grab Story", 144, 65, 75, 25, $WS_GROUP)
	$lProgress = GUICtrlCreateLabel("", 64, 80, 4, 4)
	
	$StatusBar = _GUICtrlStatusBar_Create ($FFGForm, $aParts, $aText)
    GUISetState(@SW_SHOW) ; will display an empty dialog box
	Global $Dot = "."
    ; Run the GUI until the dialog is closed
    While 1
        $msg = GUIGetMsg()
		Select
			Case $msg = $bGet
				$StoryID = GUICtrlRead($iStoryID)
				$Dir = GUICtrlRead($iDir)
				If StringRight($Dir, 1) <> "\" Then
					$Dir &= "\"
				EndIf
				If $StoryID <> "" And $Dir <> "" Then
					_Grab($StoryID, $Dir, $StatusBar)
				Else
					MsgBox(48, "Error!", "Please ensure that you have entered" & @CRLF & "a StoryID as well as a directory.")
				EndIf
            Case $msg = $GUI_EVENT_CLOSE 
				ExitLoop
		EndSelect
    WEnd
    GUIDelete()
EndFunc   ;==>_LoadUI

Func _Grab($StoryID, $Dir, $StatusBar)
	$Chap = 1
	$Title = ""
	$Chaps = ""
	While 1
		$Source = _INetGetSource("http://www.fanfiction.net/s/" & $StoryID & "/" & $Chap & "/")
		If StringInStr($Source, "Chapter not found" ) Then ExitLoop ;If the all the chapters have been downloaded, exit the loop
		If StringInStr($Source, "Story Not Found" ) Then 
			MsgBox(48, "Error!", "Story Not Found" & @CRLF & "Unable to locate story with id of " & $StoryID)
			ExitLoop ;If the all the chapters have been downloaded, exit the loop
		EndIf
		
		MsgBox(0,"", $Source)
		If $Chaps = "" Then
			$Chaps = _StringBetween($Source, "var chapters = ", ";")
		EndIf
		If $Title = "" Then 
			$Title = _StringBetween($Source, "http://fanfiction.net/s/6721798/" & $Chap & "/", '">')
		EndIf
		_Status($StatusBar, "Completed downloading... Chapter " & $Chap & " of " & $Chaps[0])
		$File = FileOpen($Dir & $StoryID & "\" & $Chap & ".html",10)
		$Arr = StringSplit($Source, "</div>",1) ;Split the source code at all divisions
		For $x in $Arr
			If StringInStr($x, "<p>") Then ;If one of the splits contains the paragraph tag, write it to the file.
				$x = _AddDropDowns($Chaps[0], $Chap, $x)
				FileWrite($File, $x)
			EndIf
		Next
		FileClose($File)
		$Chap += 1
		
	WEnd
	_Status($StatusBar, "Complete")
EndFunc

Func _Status($StatusBar, $Message)
	_GUICtrlStatusBar_SetText($StatusBar, $Message)
EndFunc

Func _AddDropdowns($Number, $Current, $x) ;Working now
	$String = "<table><tr><td align=right><SELECT title='chapter navigation' Name=chapter onChange=" & '"self.location =this.options[this.selectedIndex].value + ' & "'.html';" & '">'
	$hold = ""
	For $Y = 1 to $Number
		$hold &= "<option  value=" & $Y & " " 
		If $Current = $Y Then
			$hold &= "selected"
		EndIf
		$hold &= ">" & $Y & ". Chapter " & $Y
	Next
	$String &= $hold & "</select> <INPUT TYPE=BUTTON Value='&nbsp;Next &gt;&nbsp;' onClick=" & '"self.location=' & "'" & $Current + 1 & ".html'" & '">' & "</td></tr></table>"
	$x = $String & $x ;Add dropdown and next button at the beginning of the page.
	
    $String = "<table><tr><td align=right><SELECT title='chapter navigation' Name=chapter onChange=" & '"self.location =this.options[this.selectedIndex].value + ' & "'.html';" & '">'
	$hold = ""
	For $Y = 1 to $Number
		$hold &= "<option  value=" & $Y & " " 
		If $Current = $Y Then
			$hold &= "selected"
		EndIf
		$hold &= ">" & $Y & ". Chapter " & $Y
	Next
	$String &= $hold & "</select> <INPUT TYPE=BUTTON Value='&nbsp;Next &gt;&nbsp;' onClick=" & '"self.location=' & "'" & $Current + 1 & ".html'" & '">' & "</td></tr></table>"
 	$x = $x & $String ;Add dropdown and next button at the end of the page.
	
	Return $x
EndFunc