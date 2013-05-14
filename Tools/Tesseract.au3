#include-once
#Include <Array.au3>
#Include <File.au3>
#include <GDIPlus.au3>
#include <ScreenCapture.au3>
#include <WinAPI.au3>
#include <ScrollBarConstants.au3>
#include <WindowsConstants.au3>
#Include <GuiComboBox.au3>
#Include <GuiListBox.au3>
#Region Header
#cs
	Title:   		Tesseract UDF Library for AutoIt3
	Filename:  		Tesseract.au3
	Description: 	A collection of functions for capturing text in applications.
	Author:   		seangriffin
	Version:  		V0.6
	Last Update: 	17/03/09
	Requirements: 	AutoIt3 3.2 or higher,
					Tesseract 2.01.
	Changelog:		---------15/02/09---------- v0.1
					Initial release.
					
					---------15/02/09---------- v0.2
					Changed path to tesseract.exe to @ProgramFilesDir.
					Added scaling as input to _TesseractCapture.
					Fixed indentation.
					Changed CaptureHWNDToTIFF to input window and control IDs.
					
					---------16/02/09---------- v0.3
					Added the parameter $get_last_capture to _TesseractCapture.
					Added the parameter $show_capture to _TesseractCapture.
					
					---------16/02/09---------- v0.4
					Added the function _TesseractFind.
					
					---------21/02/09---------- v0.5
					Updated _TesseractCapture to remove a listbox selection entirely,
						and return it after the text capture is done.
					
					---------17/03/09---------- v0.6
					Split the function "_TesseractCapture" into 3 functions:
						_TesseractScreenCapture
						_TesseractWinCapture
						_TesseractControlCapture
					Split the function "_TesseractFind" into 3 functions:
						_TesseractScreenFind
						_TesseractWinFind
						_TesseractControlFind
					Renamed the function "CaptureHWNDToTIFF" to "CaptureToTIFF",
						and modified it to allow for handling of the screen, windows
						and controls.
					Added the function "_TesseractTempPathSet".
#ce
#EndRegion Header
#Region Global Variables and Constants
Global $last_capture
Global $tesseract_temp_path = "C:\"
#EndRegion Global Variables and Constants
#Region Core functions
; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractTempPathSet()
; Description ...:	Sets the location where Tesseract functions temporary store their files.
;						You must have read and write access to this location.
;						The default location is "C:\".
; Syntax.........:	_TesseractTempPathSet($temp_path)
; Parameters ....:	$temp_path	- The path to use for temporary file storage.
;									This path must not contain any spaces (see "Remarks" below).
; Return values .: 	On Success	- Returns 1. 
;                 	On Failure	- Returns 0.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	The current version of Tesseract doesn't support paths with spaces.
; Related .......: 
; Link ..........: 
; Example .......:	No
;
; ;==========================================================================================
func _TesseractTempPathSet($temp_path)

	$tesseract_temp_path = $temp_path
	
	Return 1
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractScreenCapture()
; Description ...:	Captures text from the screen.
; Syntax.........:	_TesseractScreenCapture($get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$get_last_capture	- Retrieve the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not retrieve the last capture (default)
;											1 = retrieve the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be returned if this isn't provided.
;											An array of delimited text will be returned if this is provided.
;											Eg. Use @CRLF to return the items of a listbox as an array.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the screen.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the screen.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the screen.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the screen.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success	- Returns an array of text that was captured. 
;                 	On Failure	- Returns an empty array.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	Use the default values for first time use.  If the text recognition accuracy is low,
;					I suggest setting $show_capture to 1 and rerunning.  If the screenshot of the
;					window or control includes borders or erroneous pixels that may interfere with
;					the text recognition process, then use $left_indent, $top_indent, $right_indent and
;					$bottom_indent to adjust the portion of the screen being captured, to
;					exclude these non-textural elements.
;					If text accuracy is still low, increase the $scale parameter.  In general, the higher
;					the scale the clearer the font and the more accurate the text recognition.
; Related .......: 
; Link ..........: 
; Example .......:	No
;
; ;==========================================================================================
func _TesseractScreenCapture($get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	Local $tInfo
	dim $aArray, $final_ocr[1], $xyPos_old = -1, $capture_scale = 3
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_ALL)

	if $last_capture = "" Then

		$last_capture = ObjCreate("Scripting.Dictionary")
	EndIf

	; if last capture is requested, and one exists.
	if $get_last_capture = 1 and $last_capture.item(0) <> "" Then
		
		return $last_capture.item(0)
	EndIf

	$capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
	$ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)
	$ocr_filename_and_ext = $ocr_filename & ".txt"

	CaptureToTIFF("", "", "", $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent)
	
	ShellExecuteWait(@ProgramFilesDir & "\tesseract\tesseract.exe", $capture_filename & " " & $ocr_filename)

	; If no delimter specified, then return a string
	if StringCompare($delimiter, "") = 0 Then
		
		$final_ocr = FileRead($ocr_filename_and_ext)
	Else
	
		_FileReadToArray($ocr_filename_and_ext, $aArray)
		_ArrayDelete($aArray, 0)

		; Append the recognised text to a final array
		_ArrayConcatenate($final_ocr, $aArray)
	EndIf

	; If the captures are to be displayed
	if $show_capture = 1 Then
	
		GUICreate("Tesseract Screen Capture.  Note: image displayed is not to scale", 640, 480, 0, 0, $WS_SIZEBOX + $WS_SYSMENU)  ; will create a dialog box that when displayed is centered

		GUISetBkColor(0xE0FFFF)

		$Obj1 = ObjCreate("Preview.Preview.1")  
		$Obj1_ctrl = GUICtrlCreateObj($Obj1, 0, 0, 640, 480)
		$Obj1.ShowFile ($capture_filename, 1)

		GUISetState()

		if IsArray($final_ocr) Then
		
			_ArrayDisplay($aArray, "Tesseract Text Capture")
		Else
			
			MsgBox(0, "Tesseract Text Capture", $final_ocr)
		EndIf

		GUIDelete()
	EndIf

	FileDelete($ocr_filename & ".*")

	; Cleanup
	if IsArray($final_ocr) And $cleanup = 1 Then

		; Cleanup the items
		for $final_ocr_num = 1 to (UBound($final_ocr)-1)

			; Remove erroneous characters
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ".", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "'", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ",", "")
			$final_ocr[$final_ocr_num] = StringStripWS($final_ocr[$final_ocr_num], 3)
		Next

		; Remove duplicate and blank items
		for $each in $final_ocr
		
			$found_item = _ArrayFindAll($final_ocr, $each)
			
			; Remove blank items
			if IsArray($found_item) Then
				if StringCompare($final_ocr[$found_item[0]], "") = 0 Then
					
					_ArrayDelete($final_ocr, $found_item[0])
				EndIf
			EndIf

			; Remove duplicate items
			for $found_item_num = 2 to UBound($found_item)
				
				_ArrayDelete($final_ocr, $found_item[$found_item_num-1])
			Next
		Next
	EndIf

	; Store a copy of the capture
	if $last_capture.item(0) = "" Then
			
		$last_capture.item(0) = $final_ocr
	EndIf

	Return $final_ocr
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractWinCapture()
; Description ...:	Captures text from a window.
; Syntax.........:	_TesseractWinCapture($win_title, $win_text = "", $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to capture text from.
;					$win_text			- Optional: The text of the window to capture text from.
;					$get_last_capture	- Retrieve the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not retrieve the last capture (default)
;											1 = retrieve the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be returned if this isn't provided.
;											An array of delimited text will be returned if this is provided.
;											Eg. Use @CRLF to return the items of a listbox as an array.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the window.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the window.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the window.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the window.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success	- Returns an array of text that was captured. 
;                 	On Failure	- Returns an empty array.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	Use the default values for first time use.  If the text recognition accuracy is low,
;					I suggest setting $show_capture to 1 and rerunning.  If the screenshot of the
;					window or control includes borders or erroneous pixels that may interfere with
;					the text recognition process, then use $left_indent, $top_indent, $right_indent and
;					$bottom_indent to adjust the portion of the window being captured, to
;					exclude these non-textural elements.
;					If text accuracy is still low, increase the $scale parameter.  In general, The higher
;					the scale the clearer the font and the more accurate the text recognition.
; Related .......: 
; Link ..........: 
; Example .......:	No
;
; ;==========================================================================================
func _TesseractWinCapture($win_title, $win_text = "", $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	Local $tInfo
	dim $aArray, $final_ocr[1], $xyPos_old = -1, $capture_scale = 3
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_ALL)

	if $last_capture = "" Then

		$last_capture = ObjCreate("Scripting.Dictionary")
	EndIf

	$hwnd = WinGetHandle($win_title, $win_text)

	; if last capture is requested, and one exists.
	if $get_last_capture = 1 and $last_capture.item(Number($hwnd)) <> "" Then
		
		return $last_capture.item(Number($hwnd))
	EndIf

	; Perform the text recognition

	$capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
	$ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)
	$ocr_filename_and_ext = $ocr_filename & ".txt"

	CaptureToTIFF($win_title, $win_text, "", $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent)
	
	ShellExecuteWait(@ProgramFilesDir & "\tesseract\tesseract.exe", $capture_filename & " " & $ocr_filename)

	; If no delimter specified, then return a string
	if StringCompare($delimiter, "") = 0 Then
		
		$final_ocr = FileRead($ocr_filename_and_ext)
	Else
	
		_FileReadToArray($ocr_filename_and_ext, $aArray)
		_ArrayDelete($aArray, 0)

		; Append the recognised text to a final array
		_ArrayConcatenate($final_ocr, $aArray)
	EndIf

	; If the captures are to be displayed
	if $show_capture = 1 Then
	
		GUICreate("Tesseract Screen Capture.  Note: image displayed is not to scale", 640, 480, 0, 0, $WS_SIZEBOX + $WS_SYSMENU)  ; will create a dialog box that when displayed is centered

		GUISetBkColor(0xE0FFFF)

		$Obj1 = ObjCreate("Preview.Preview.1")  
		$Obj1_ctrl = GUICtrlCreateObj($Obj1, 0, 0, 640, 480)
		$Obj1.ShowFile ($capture_filename, 1)

		GUISetState()

		if IsArray($final_ocr) Then
		
			_ArrayDisplay($aArray, "Tesseract Text Capture")
		Else
			
			MsgBox(0, "Tesseract Text Capture", $final_ocr)
		EndIf

		GUIDelete()
	EndIf

	FileDelete($ocr_filename & ".*")

	; Cleanup
	if IsArray($final_ocr) And $cleanup = 1 Then

		; Cleanup the items
		for $final_ocr_num = 1 to (UBound($final_ocr)-1)

			; Remove erroneous characters
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ".", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "'", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ",", "")
			$final_ocr[$final_ocr_num] = StringStripWS($final_ocr[$final_ocr_num], 3)
		Next

		; Remove duplicate and blank items
		for $each in $final_ocr
		
			$found_item = _ArrayFindAll($final_ocr, $each)
			
			; Remove blank items
			if IsArray($found_item) Then
				if StringCompare($final_ocr[$found_item[0]], "") = 0 Then
					
					_ArrayDelete($final_ocr, $found_item[0])
				EndIf
			EndIf

			; Remove duplicate items
			for $found_item_num = 2 to UBound($found_item)
				
				_ArrayDelete($final_ocr, $found_item[$found_item_num-1])
			Next
		Next
	EndIf

	; Store a copy of the capture
	if $last_capture.item(Number($hwnd)) = "" Then
			
		$last_capture.item(Number($hwnd)) = $final_ocr
	EndIf

	Return $final_ocr
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractControlCapture()
; Description ...:	Captures text from a control.
; Syntax.........:	_TesseractControlCapture($win_title, $win_text = "", $ctrl_id = "", $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to capture text from.
;					$win_text			- Optional: The text of the window to capture text from.
;					$ctrl_id			- Optional: The ID of the control to capture text from.
;											The text of the window will be returned if one isn't provided.
;					$get_last_capture	- Retrieve the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not retrieve the last capture (default)
;											1 = retrieve the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be returned if this isn't provided.
;											An array of delimited text will be returned if this is provided.
;											Eg. Use @CRLF to return the items of a listbox as an array.
;					$expand				- Optional: Expand the control before capturing text from it?
;											0 = do not expand the control
;											1 = expand the control (default)
;					$scrolling			- Optional: Scroll the control to capture all it's text?
;											0 = do not scroll the control
;											1 = scroll the control (default)
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$max_scroll_times	- The maximum number of scrolls to capture in a control
;											If a control has a very long scroll bar, the text recognition
;											process will take too long.  Use this value to restrict
;											the amount of text to recognise in a long control.
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the control.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the control.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the control.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the control.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success	- Returns an array of text that was captured. 
;                 	On Failure	- Returns an empty array.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	Use the default values for first time use.  If the text recognition accuracy is low,
;					I suggest setting $show_capture to 1 and rerunning.  If the screenshot of the
;					window or control includes borders or erroneous pixels that may interfere with
;					the text recognition process, then use $left_indent, $top_indent, $right_indent and
;					$bottom_indent to adjust the portion of the control being captured, to
;					exclude these non-textural elements.
;					If text accuracy is still low, increase the $scale parameter.  In general, The higher
;					the scale the clearer the font and the more accurate the text recognition.
; Related .......: 
; Link ..........: 
; Example .......:	Yes
;
; ;==========================================================================================
func _TesseractControlCapture($win_title, $win_text = "", $ctrl_id = "", $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	Local $tInfo
	dim $aArray, $final_ocr[1], $xyPos_old = -1, $capture_scale = 3
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_ALL)

	if $last_capture = "" Then

		$last_capture = ObjCreate("Scripting.Dictionary")
	EndIf

	; if a control ID is specified, then get it's HWND
	if StringCompare($ctrl_id, "") <> 0 Then

		$hwnd = ControlGetHandle($win_title, $win_text, $ctrl_id)

		; if expansion of the control is required.
		if $expand = 1 and StringCompare($delimiter, "") <> 0 Then

			$hwnd2 = $hwnd

			If _GUICtrlComboBox_GetComboBoxInfo($hwnd, $tInfo) Then

				$hwnd = DllStructGetData($tInfo, "hList")
			EndIf
		
			; Expand the control.
			_GUICtrlComboBox_ShowDropDown($hwnd2, True)
		EndIf
	EndIf

	; if last capture is requested, and one exists.
	if $get_last_capture = 1 and $last_capture.item(Number($hwnd)) <> "" Then
		
		return $last_capture.item(Number($hwnd))
	EndIf

	; Text recognition improves alot if the current selection and focus rectangle is removed.
	;	The following code will remove the selection.
	;	After text recognition the selection is returned.
	$sel_index = _GUICtrlListBox_GetCurSel($hwnd)

	; The following two lines should remove the current selection and focus rectangle
	;	in all cases.
	_GUICtrlListBox_SetCurSel($hWnd, -1)
	_GUICtrlListBox_SetCaretIndex($hWnd, -1)

	; Scroll to the top
	DllCall("user32.dll", "int", "SendMessage", "hwnd", $hwnd, "int", $WM_VSCROLL, "int", $SB_TOP, "int", 0)

	for $i = 1 to $max_scroll_times

		if $i > 1 Then
			
			; Scroll the list down one page
			DllCall("user32.dll", "int", "SendMessage", "hwnd", $hwnd, "int", $WM_VSCROLL, "int", $SB_PAGEDOWN, "int", 0)

		EndIf

		; Get the position of the scroll bar
		DllCall("user32.dll", "int", "GetScrollInfo", "hwnd", $hwnd, "int", $SB_VERT, "ptr", DllStructGetPtr($tSCROLLINFO))
		$xyPos = DllStructGetData($tSCROLLINFO, "nPos")
		
		; If the scroll bar hasn't moved, we have finished scrolling
		if $xyPos_old = $xyPos then ExitLoop
		
		$xyPos_old = $xyPos

		; Perform the text recognition
		WinActivate($win_title)

		$capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
		$ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)
		$ocr_filename_and_ext = $ocr_filename & ".txt"

		CaptureToTIFF($win_title, $win_text, $hwnd, $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent)
		
		ShellExecuteWait(@ProgramFilesDir & "\tesseract\tesseract.exe", $capture_filename & " " & $ocr_filename)

		; Return the current selection (if one existed)
		if $sel_index > -1 Then
		
			_GUICtrlListBox_SetCurSel($hwnd, $sel_index)
		EndIf

		; If no delimter specified, then return a string
		if StringCompare($delimiter, "") = 0 Then
			
			$final_ocr = FileRead($ocr_filename_and_ext)
			$i = $max_scroll_times
		Else
		
			_FileReadToArray($ocr_filename_and_ext, $aArray)
			_ArrayDelete($aArray, 0)

			; Append the recognised text to a final array
			_ArrayConcatenate($final_ocr, $aArray)
		EndIf

		; If the captures are to be displayed
		if $show_capture = 1 Then
		
			GUICreate("Tesseract Screen Capture.  Note: image displayed is not to scale", 640, 480, 0, 0, $WS_SIZEBOX + $WS_SYSMENU)  ; will create a dialog box that when displayed is centered

			GUISetBkColor(0xE0FFFF)

			$Obj1 = ObjCreate("Preview.Preview.1")  
			$Obj1_ctrl = GUICtrlCreateObj($Obj1, 0, 0, 640, 480)
			$Obj1.ShowFile ($capture_filename, 1)

			GUISetState()

			if IsArray($final_ocr) Then
			
				_ArrayDisplay($aArray, "Tesseract Text Capture")
			Else
				
				MsgBox(0, "Tesseract Text Capture", $final_ocr)
			EndIf

			GUIDelete()
		EndIf

		FileDelete($ocr_filename & ".*")
	Next

	; Cleanup
	if IsArray($final_ocr) And $cleanup = 1 Then

		; Cleanup the items
		for $final_ocr_num = 1 to (UBound($final_ocr)-1)

			; Remove erroneous characters
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ".", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "'", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ",", "")
			$final_ocr[$final_ocr_num] = StringStripWS($final_ocr[$final_ocr_num], 3)
		Next

		; Remove duplicate and blank items
		for $each in $final_ocr
		
			$found_item = _ArrayFindAll($final_ocr, $each)
			
			; Remove blank items
			if IsArray($found_item) Then
				if StringCompare($final_ocr[$found_item[0]], "") = 0 Then
					
					_ArrayDelete($final_ocr, $found_item[0])
				EndIf
			EndIf

			; Remove duplicate items
			for $found_item_num = 2 to UBound($found_item)
				
				_ArrayDelete($final_ocr, $found_item[$found_item_num-1])
			Next
		Next
	EndIf

	; Store a copy of the capture
	if $last_capture.item(Number($hwnd)) = "" Then
			
		$last_capture.item(Number($hwnd)) = $final_ocr
	EndIf

	Return $final_ocr
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractScreenFind()
; Description ...:	Finds the location of a string within text captured from the screen.
; Syntax.........:	_TesseractScreenFind($find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$find_str			- The text (string) to find.
;					$partial			- Optional: Find the text using a partial match?
;											0 = use a full text match
;											1 = use a partial text match (default)
;					$get_last_capture	- Search within the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not use the last capture (default)
;											1 = use the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be searched if this isn't provided.
;											The index of the item found will be returned if this is provided.
;											Eg. Use @CRLF to find an item in a listbox.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the screen.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the screen.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the screen.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the screen.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success			- Returns the location of the text that was found.
;											If $delimiter is "", then the character position of the text found
;												is returned.
;											If $delimiter is not "", then the element of the array where the
;												text was found is returned.
;                 	On Failure			- Returns an empty array.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	
; Related .......: 
; Link ..........: 
; Example .......:	No
;
; ;==========================================================================================
func _TesseractScreenFind($find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	; Get all the text from the screen
	$recognised_text = _TesseractScreenCapture($get_last_capture, $delimiter, $cleanup, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $show_capture)

	if IsArray($recognised_text) Then
		
		$index_found = _ArraySearch($recognised_text, $find_str, 0, 0, 0, $partial)
	Else
		
		if $partial = 1 Then
			
			$index_found = StringInStr($recognised_text, $find_str)
		Else
			
			if StringCompare($recognised_text, $find_str) = 0 Then
				
				$index_found = 1
			Else
				
				$index_found = 0
			EndIf
		EndIf
	EndIf

	Return $index_found
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractWinFind()
; Description ...:	Finds the location of a string within text captured from a window.
; Syntax.........:	_TesseractWinFind($win_title, $win_text = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to find text in.
;					$win_text			- Optional: The text of the window to find text in.
;					$find_str			- The text (string) to find.
;					$partial			- Optional: Find the text using a partial match?
;											0 = use a full text match
;											1 = use a partial text match (default)
;					$get_last_capture	- Search within the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not use the last capture (default)
;											1 = use the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be searched if this isn't provided.
;											The index of the item found will be returned if this is provided.
;											Eg. Use @CRLF to find an item in a listbox.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the window.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the window.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the window.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the window.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success			- Returns the location of the text that was found.
;											If $delimiter is "", then the character position of the text found
;												is returned.
;											If $delimiter is not "", then the element of the array where the
;												text was found is returned.
;                 	On Failure			- Returns an empty array.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	
; Related .......: 
; Link ..........: 
; Example .......:	No
;
; ;==========================================================================================
func _TesseractWinFind($win_title, $win_text = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	; Get all the text from the window
	$recognised_text = _TesseractWinCapture($win_title, $win_text, $get_last_capture, $delimiter, $cleanup, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $show_capture)

	if IsArray($recognised_text) Then
		
		$index_found = _ArraySearch($recognised_text, $find_str, 0, 0, 0, $partial)
	Else
		
		if $partial = 1 Then
			
			$index_found = StringInStr($recognised_text, $find_str)
		Else
			
			if StringCompare($recognised_text, $find_str) = 0 Then
				
				$index_found = 1
			Else
				
				$index_found = 0
			EndIf
		EndIf
	EndIf

	Return $index_found
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractControlFind()
; Description ...:	Finds the location of a string within text captured from a control.
; Syntax.........:	_TesseractControlFind($win_title, $win_text = "", $ctrl_id = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to find text in.
;					$win_text			- Optional: The text of the window to find text in.
;					$ctrl_id			- Optional: The ID of the control to find text in.
;											The text of the window will be usee if one isn't provided.
;					$find_str			- The text (string) to find.
;					$partial			- Optional: Find the text using a partial match?
;											0 = use a full text match
;											1 = use a partial text match (default)
;					$get_last_capture	- Search within the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not use the last capture (default)
;											1 = use the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be searched if this isn't provided.
;											The index of the item found will be returned if this is provided.
;											Eg. Use @CRLF to find an item in a listbox.
;					$expand				- Optional: Expand the control before searching it?
;											0 = do not expand the control
;											1 = expand the control (default)
;					$scrolling			- Optional: Scroll the control to search all it's text?
;											0 = do not scroll the control
;											1 = scroll the control (default)
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$max_scroll_times	- The maximum number of scrolls to capture in a control
;											If a control has a very long scroll bar, the text recognition
;											process will take too long.  Use this value to restrict
;											the amount of text to recognise in a long control.
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the control.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the control.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the control.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the control.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success			- Returns the location of the text that was found.
;											If $delimiter is "", then the character position of the text found
;												is returned.
;											If $delimiter is not "", then the element of the array where the
;												text was found is returned.
;                 	On Failure			- Returns an empty array.
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	
; Related .......: 
; Link ..........: 
; Example .......:	Yes
;
; ;==========================================================================================
func _TesseractControlFind($win_title, $win_text = "", $ctrl_id = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	; Get all the text from the control
	$recognised_text = _TesseractControlCapture($win_title, $win_text, $ctrl_id, $get_last_capture, $delimiter, $expand, $scrolling, $cleanup, $max_scroll_times, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $show_capture)

	if IsArray($recognised_text) Then
		
		$index_found = _ArraySearch($recognised_text, $find_str, 0, 0, 0, $partial)
	Else
		
		if $partial = 1 Then
			
			$index_found = StringInStr($recognised_text, $find_str)
		Else
			
			if StringCompare($recognised_text, $find_str) = 0 Then
				
				$index_found = 1
			Else
				
				$index_found = 0
			EndIf
		EndIf
	EndIf

	Return $index_found
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........:	CaptureToTIFF()
; Description ...:	Captures an image of the screen, a window or a control, and saves it to a TIFF file.
; Syntax.........:	CaptureToTIFF($win_title = "", $win_text = "", $ctrl_id = "", $sOutImage = "", $scale = 1, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0)
; Parameters ....:	$win_title		- The title of the window to capture an image of.
;					$win_text		- Optional: The text of the window to capture an image of.
;					$ctrl_id		- Optional: The ID of the control to capture an image of.
;										An image of the window will be returned if one isn't provided.
;					$sOutImage		- The filename to store the image in.
;					$scale			- Optional: The scaling factor of the capture.
;					$left_indent	- A number of pixels to indent the screen capture from the
;										left of the window or control.
;					$top_indent		- A number of pixels to indent the screen capture from the
;										top of the window or control.
;					$right_indent	- A number of pixels to indent the screen capture from the
;										right of the window or control.
;					$bottom_indent	- A number of pixels to indent the screen capture from the
;										bottom of the window or control.
; Return values .: 	None
; Author ........:	seangriffin
; Modified.......: 
; Remarks .......:	
; Related .......: 
; Link ..........: 
; Example .......:	No
;
; ;==========================================================================================
Func CaptureToTIFF($win_title = "", $win_text = "", $ctrl_id = "", $sOutImage = "", $scale = 1, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0)

	Local $hWnd, $hwnd2, $hDC, $hBMP, $hImage1, $hGraphic, $CLSID, $tParams, $pParams, $tData, $i = 0, $hImage2, $pos[4]
    Local $Ext = StringUpper(StringMid($sOutImage, StringInStr($sOutImage, ".", 0, -1) + 1))
	Local $giTIFColorDepth = 24
	Local $giTIFCompression = $GDIP_EVTCOMPRESSIONNONE

	; If capturing a control
	if StringCompare($ctrl_id, "") <> 0 Then

		$hwnd2 = ControlGetHandle($win_title, $win_text, $ctrl_id)
		$pos = ControlGetPos($win_title, $win_text, $ctrl_id)
	Else
		
		; If capturing a window
		if StringCompare($win_title, "") <> 0 Then

			$hwnd2 = WinGetHandle($win_title, $win_text)
			$pos = WinGetPos($win_title, $win_text)
		Else
			
			; If capturing the desktop
			$hwnd2 = ""
			$pos[0] = 0
			$pos[1] = 0
			$pos[2] = @DesktopWidth
			$pos[3] = @DesktopHeight
		EndIf
	EndIf
	
	; Capture an image of the window / control
	if IsHWnd($hwnd2) Then
	
		WinActivate($win_title, $win_text)
		$hBitmap2 = _ScreenCapture_CaptureWnd("", $hwnd2, 0, 0, -1, -1, False)
	Else
		
		$hBitmap2 = _ScreenCapture_Capture("", 0, 0, -1, -1, False)
	EndIf

	_GDIPlus_Startup ()
	
	; Convert the image to a bitmap
	$hImage2 = _GDIPlus_BitmapCreateFromHBITMAP ($hBitmap2)

	$hWnd = _WinAPI_GetDesktopWindow()
    $hDC = _WinAPI_GetDC($hWnd)
    $hBMP = _WinAPI_CreateCompatibleBitmap($hDC, ($pos[2] * $scale) - ($right_indent * $scale), ($pos[3] * $scale) - ($bottom_indent * $scale))

	_WinAPI_ReleaseDC($hWnd, $hDC)
    $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP ($hBMP)
    $hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage1)
    _GDIPLus_GraphicsDrawImageRect($hGraphic, $hImage2, 0 - ($left_indent * $scale), 0 - ($top_indent * $scale), ($pos[2] * $scale) + $left_indent, ($pos[3] * $scale) + $top_indent)
	$CLSID = _GDIPlus_EncodersGetCLSID($Ext)

	; Set TIFF parameters
	$tParams = _GDIPlus_ParamInit(2)
	$tData = DllStructCreate("int ColorDepth;int Compression")
	DllStructSetData($tData, "ColorDepth", $giTIFColorDepth)
	DllStructSetData($tData, "Compression", $giTIFCompression)
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOLORDEPTH, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "ColorDepth"))
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOMPRESSION, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "Compression"))
	If IsDllStruct($tParams) Then $pParams = DllStructGetPtr($tParams)

	; Save TIFF and cleanup
	_GDIPlus_ImageSaveToFileEx($hImage1, $sOutImage, $CLSID, $pParams)
    _GDIPlus_ImageDispose($hImage1)
    _GDIPlus_ImageDispose($hImage2)
    _GDIPlus_GraphicsDispose ($hGraphic)
    _WinAPI_DeleteObject($hBMP)
    _GDIPlus_Shutdown()
EndFunc
