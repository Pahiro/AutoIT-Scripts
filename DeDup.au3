#cs
    ;#=#INDEX#===================================================#
    ;#  Title .........: Duplicate File Finder.au3
    ;#  Description ...: Finds and deletes duplicate files.
    ;#  Date ..........: 3.12.09
    ;#  Version .......: 1.0
    ;#  AutoIt Version : Written in 3.2.12.1
    ;#                   Tested with 3.3.0.0
    ;#  OS ............: Written and working on XP Pro SP2.
    ;#  Remarks .......: Do never scan and delete any system files !
    ;#                   Use at own risk - No responsibility for damages.
    ;#  Author ........: jennico (jennicoattminusonlinedotde)
    ;#                   ©  2009 by jennico
    ;#===========================================================#
#ce

#include <ListviewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiImageList.au3>
#include <GuiTreeView.au3>
#include <GuiListView.au3>

Opt("GUIOnEventMode", 1)

Global Const $pv = "PendingFileRenameOperations", $pe = "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" 
Global $title = " Duplicate File Finder", $item[1], $items = 0, $popup = 0, $start = 0

$GUI = GUICreate($title & "  ©  2009 by jennico", 800, 500, Default, Default, $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX + $WS_SIZEBOX)
GUISetIcon(@SystemDir & "\shell32.dll", -167)
TraySetIcon(@SystemDir & "\shell32.dll", -167)

GUICtrlSetFont(GUICtrlCreateGroup(" 1. Directories to search ", 2, 3, 681, 94), 8.5, 800)
GUICtrlSetResizing(-1, 550)
$listview = GUICtrlCreateListView("x|x", 5, 18, 600, 75, $LVS_NOCOLUMNHEADER + $LVS_SINGLESEL + $LVS_SHOWSELALWAYS, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES + $LVS_EX_CHECKBOXES)
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 550)

$add = GUICtrlCreateButton("Add", 613, 18, 60, 34)
GUICtrlSetOnEvent(-1, "_Add")
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 804)
GUICtrlSetCursor(-1, 0)

$remove = GUICtrlCreateButton("Remove", 613, 58, 60, 34)
GUICtrlSetOnEvent(-1, "_Remove")
GUICtrlSetResizing(-1, 804)
GUICtrlSetState(-1, 128)
GUICtrlSetCursor(-1, 0)

GUICtrlSetFont(GUICtrlCreateGroup(" 2. Scan ", 700, 3, 88, 94), 8.5, 800)
GUICtrlSetResizing(-1, 804)
$scan = GUICtrlCreateButton("Scan", 711, 22, 65, 65)
GUICtrlSetOnEvent(-1, "_Start")
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 804)
GUICtrlSetState(-1, 128)
GUICtrlSetCursor(-1, 0)

GUICtrlSetFont(GUICtrlCreateGroup(" 3. Report ", 2, 102, 796, 296), 8.5, 800)
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 102)
$hTreeView = _GUICtrlTreeView_Create ($GUI, 5, 118, 789, 276, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES, DllStructGetData($TVS_CHECKBOXES, "")), $WS_EX_DLGMODALFRAME)

GUICtrlSetFont(GUICtrlCreateGroup(" 4. Delete selected ", 2, 403, 140, 75), 8.5, 800)
GUICtrlSetResizing(-1, 834)
$delete = GUICtrlCreateButton("Delete", 10, 442, 124, 29)
GUICtrlSetOnEvent(-1, "_Delete")
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 834)
GUICtrlSetState(-1, 128)
GUICtrlSetCursor(-1, 0)

GUICtrlSetFont(GUICtrlCreateGroup(" Status ", 156, 403, 466, 75), 8.5, 800)
GUICtrlSetResizing(-1, 582)
$label = GUICtrlCreateLabel("", 170, 422, 450, 54)
GUICtrlSetResizing(-1, 582)
$progress = GUICtrlCreateProgress(170, 425, 200, 12, 1)
GUICtrlSetResizing(-1, 834)
GUICtrlSetState(-1, 32)
$avi = GUICtrlCreateAvi("shell32.dll", 152, 170, 445, 16, 16)
GUICtrlSetResizing(-1, 834)
GUICtrlSetState(-1, 32)
$avi2 = GUICtrlCreateAvi("shell32.dll", 164, 160, 416, 300, 60)
GUICtrlSetResizing(-1, 834)
GUICtrlSetState(-1, 32)
$red = GUICtrlCreateLabel("not duplicate", 538, 416, 76, 16, 513)
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetResizing(-1, 836)
GUICtrlSetState(-1, 160)
$yellow = GUICtrlCreateLabel("90% duplicate", 538, 436, 76, 16, 513)
GUICtrlSetBkColor(-1, 0xFFF000)
GUICtrlSetResizing(-1, 836)
GUICtrlSetState(-1, 160)
$green = GUICtrlCreateLabel("99% duplicate", 538, 456, 76, 16, 513)
GUICtrlSetBkColor(-1, 0x00FF00)
GUICtrlSetResizing(-1, 836)
GUICtrlSetState(-1, 160)

GUICtrlSetFont(GUICtrlCreateGroup(" ©  2009 by jennico ", 647, 403, 138, 62), 8.5, 800)
GUICtrlSetResizing(-1, 836)
GUICtrlSetState(-1, 128)
$new = GUICtrlCreateButton("New", 637, 440, 75, 35)
GUICtrlSetOnEvent(-1, "_New")
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 836)
GUICtrlSetState(-1, 128)
GUICtrlSetCursor(-1, 0)
GUICtrlCreateButton("Exit", 719, 440, 75, 35)
GUICtrlSetOnEvent(-1, "_Exit")
GUICtrlSetFont(-1, 8.5, 800)
GUICtrlSetResizing(-1, 836)
GUICtrlSetCursor(-1, 0)

GUIRegisterMsg($WM_GETMINMAXINFO, "_WM_GETMINMAXINFO")
GUIRegisterMsg($WM_SIZE, "_WM_SIZE")
GUISetOnEvent(-3, "_Exit")
GUISetState()

$context = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
GUICtrlSetState(GUICtrlCreateMenuItem("Play / Open", $context), 512)
GUICtrlSetOnEvent(-1, "_Open")
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Open directory", $context), "_Explorer")
GUICtrlCreateMenuItem("", $context)
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Cut / Move", $context), "_CutCopy")
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Copy", $context), "_CutCopy")
GUICtrlCreateMenuItem("", $context)
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Copy file name to Clipboard", $context), "_Clip")
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Copy path && file name to Clipboard", $context), "_Clip")
GUICtrlCreateMenuItem("", $context)
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Delete", $context), "_DeleteOne")
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Edit / Rename", $context), "_Edit")
GUICtrlCreateMenuItem("", $context)
GUICtrlSetOnEvent(GUICtrlCreateMenuItem("Properties", $context), "_Properties")

$hImage = _GUIImageList_Create ()
_GUIImageList_Add ($hImage, _GUICtrlTreeView_CreateSolidBitMap ($hTreeView, 0xFFFFFF, 16, 16))
_GUIImageList_Add ($hImage, _GUICtrlTreeView_CreateSolidBitMap ($hTreeView, 0xFF0000, 16, 15))
_GUIImageList_Add ($hImage, _GUICtrlTreeView_CreateSolidBitMap ($hTreeView, 0xFFF000, 16, 15))
_GUIImageList_Add ($hImage, _GUICtrlTreeView_CreateSolidBitMap ($hTreeView, 0x00FF00, 16, 15))
_GUICtrlTreeView_SetNormalImageList ($hTreeView, $hImage)

While Sleep(20)
    If GUICtrlRead($listview) And GUICtrlGetState($remove) = 144 Then GUICtrlSetState($remove, 64)
    If GUICtrlRead($listview) = 0 And GUICtrlGetState($remove) = 80 Then GUICtrlSetState($remove, 128)
    If $start = 1 Then
        $start = 0
        $start = _Scan()
    EndIf
    If $popup = 1 Then
        $tmp = _TextSelected()
        If StringInStr($tmp, ":\") And StringLeft($tmp, 1) <> "~"  Then $popup = DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", GUICtrlGetHandle($context), "int", 0, "int", MouseGetPos(0), "int", MouseGetPos(1), "hwnd", $GUI, "ptr", 0)
    EndIf
WEnd

Func _Add()
    $x = FileSelectFolder("Select directory to search", "", 0, "", $GUI)
    If $x = "" Or StringInStr($x, ":\") = 0 Then Return
    If StringRight($x, 1) = "\"  Then $x = StringTrimRight($x, 1)
    For $j = 1 To $items
        $input = StringSplit(GUICtrlRead($item[$j - 1]), "|")
        If $input[0] > 1 And $x = $input[2] Then Return
    Next
    $items += 1
    ReDim $item[$items]
    GUICtrlSetTip($listview, " Check box to recurse subdirectories" & @CRLF & "(not recommended - use with caution)")
    $item[$items - 1] = GUICtrlCreateListViewItem("|" & $x, $listview)
    GUICtrlSetState($scan, 64)
    GUICtrlSetState($new, 64)
EndFunc   ;==>_Add

Func _Remove()
    $x = GUICtrlRead($listview)
    If $x > 0 Then GUICtrlDelete($x)
    For $j = 1 To $items
        $input = StringSplit(GUICtrlRead($item[$j - 1]), "|")
        If $input[0] = 3 Then Return
    Next
    GUICtrlSetTip($listview, "")
    GUICtrlSetState($scan, 128)
EndFunc   ;==>_Remove

Func _Start()
    $start = 1
EndFunc   ;==>_Start

Func _Scan()
    GUIRegisterMsg($WM_NOTIFY, "")
    GUICtrlSetState($red, 32)
    GUICtrlSetState($yellow, 32)
    GUICtrlSetState($green, 32)
    GUICtrlSetState($avi, 17)
    GUICtrlSetState($progress, 16)
    GUICtrlSetFont($label, 8.5, 600)
    GUICtrlSetData($label, @CRLF & @CRLF & "      Scanning ...")
    GUICtrlSetData($scan, "Abort")
    _GUICtrlTreeView_DeleteAll ($hTreeView)
    GUICtrlSetState($add, 128)
    GUICtrlSetState($remove, 128)
    GUICtrlSetState($new, 128)
    GUICtrlSetState($delete, 128)
    Dim $fname[1], $fsize[1], $ftime[1], $found = 0, $total = 0, $ftotal = 0, $stotal = 0, $z = 0, $s = "", $t = "completed" 
    For $j = 1 To $items
        $input = StringSplit(GUICtrlRead($item[$j - 1]), "|")
        If $input[0] < 3 Then ContinueLoop
        $x = DirGetSize($input[2], 1 + (GUICtrlRead($item[$j - 1], 1) / 2))
        If @error = 0 Then $total += $x[1]
    Next
    For $j = 1 To $items
        $input = StringSplit(GUICtrlRead($item[$j - 1]), "|")
        If $input[0] < 3 Then ContinueLoop
        _Recurse(GUICtrlRead($item[$j - 1], 1), $input[2], $fname, $fsize, $ftime, $found, $total, $ftotal, $stotal)
    Next
    _GUICtrlTreeView_Sort ($hTreeView)
    If $ftotal <> 1 Then $s = "s" 
    If $start = 1 Or $found > 15999999 Then $t = "aborted" 
    _GUICtrlTreeView_BeginUpdate ($hTreeView)
    $hItem = _GUICtrlTreeView_GetFirstItem ($hTreeView)
    While $hItem
        Dim $nsize = "", $size = Number(_GUICtrlTreeView_GetText ($hTreeView, $hItem))
        If $size > 1023 Then $nsize = " - " & StringFormat("%.3f", $size / 1024) & " kB" 
        If $size > 1048575 Then $nsize &= " - " & StringFormat("%.3f", $size / 1048576) & " MB" 
        _GUICtrlTreeView_SetText ($hTreeView, $hItem, $size & " bytes" & $nsize)
        $hchild = _GUICtrlTreeView_GetFirstChild ($hTreeView, $hItem)
        While $hchild
            _GUICtrlTreeView_SetText ($hTreeView, $hchild, StringMid(_GUICtrlTreeView_GetText ($hTreeView, $hchild), 16))
            $hchild = _GUICtrlTreeView_GetNextChild ($hTreeView, $hchild)
        WEnd
        $hItem = _GUICtrlTreeView_GetNextSibling ($hTreeView, $hItem)
    WEnd
    $hItem = _GUICtrlTreeView_Add ($hTreeView, 0, "Scan " & $t & ". Summary:")
    _GUICtrlTreeView_SetBold ($hTreeView, $hItem)
    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hItem, 3)
    $hchild = _GUICtrlTreeView_AddChild ($hTreeView, $hItem, "Found: " & $ftotal & " duplicate" & $s & ".")
    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hchild, 3)
    _GUICtrlTreeView_SetBold ($hTreeView, $hchild)
    $hchild = _GUICtrlTreeView_AddChild ($hTreeView, $hItem, "Wasted space: " & _Bytes($stotal))
    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hchild, 3)
    _GUICtrlTreeView_SetBold ($hTreeView, $hchild)
    _GUICtrlTreeView_EndUpdate ($hTreeView)
    _GUICtrlTreeView_Expand ($hTreeView)
    SoundPlay(@WindowsDir & "\Media\chimes.wav")
    GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
    GUICtrlSetState($progress, 32)
    GUICtrlSetData($progress, 0)
    GUICtrlSetState($avi, 32)
    GUICtrlSetFont($label, 7, 400)
    GUICtrlSetData($label, "")
    If $ftotal Then GUICtrlSetData($label, @CRLF & @CRLF & "Right click items for options." & @CRLF & "Double click to open / play item.")
    GUICtrlSetData($scan, "Scan")
    GUICtrlSetState($add, 64)
    GUICtrlSetState($new, 64)
    GUICtrlSetState($red, 16)
    GUICtrlSetState($yellow, 16)
    GUICtrlSetState($green, 16)
    If $ftotal Then GUICtrlSetState($delete, 64)
EndFunc   ;==>_Scan

Func _Recurse($checked, $in, ByRef $fname, ByRef $fsize, ByRef $ftime, ByRef $found, ByRef $total, ByRef $ftotal, ByRef $stotal)
    $x = FileFindFirstFile($in & "\*")
    If $x = -1 Then Return
    While $start = 0
        $y = FileFindNextFile($x)
        If @error Then Return
        If StringInStr(FileGetAttrib($in & "\" & $y), "d") Then
            If $checked = 1 Then _Recurse($checked, $in & "\" & $y, $fname, $fsize, $ftime, $found, $total, $ftotal, $stotal)
            ContinueLoop
        EndIf
        $found += 1
        If $found > 15999999 Then Return 1
        GUICtrlSetData($progress, $found * 100 / $total)
        ReDim $fname[$found], $fsize[$found], $ftime[$found]
        $fname[$found - 1] = $in & "\" & $y
        $fsize[$found - 1] = FileGetSize($fname[$found - 1])
        $ftime[$found - 1] = FileGetTime($fname[$found - 1], 1, 1)
        For $i = 0 To $found - 2
            If $fname[$i] <> $fname[$found - 1] And $fsize[$i] = $fsize[$found - 1] Then
                Dim $equal = 3, $string = StringFormat("%012s", $fsize[$i]), $open1 = FileOpen($fname[$i], 0), $open2 = FileOpen($fname[$found - 1], 0), $a1 = FileRead($open1, 10000), $a2 = FileRead($open2, 10000)
                If StringLeft($a1, 1000) <> StringLeft($a2, 1000) Then $equal = 1 + ($fsize[$i] > 1000 And (StringMid($a1, 1000) = StringMid($a2, 1000)))
                FileClose($open1)
                FileClose($open2)
                _GUICtrlTreeView_BeginUpdate ($hTreeView)
                $hItem = _GUICtrlTreeView_FindItem ($hTreeView, $string)
                If $hItem Then
                    If _GUICtrlTreeView_FindItemEx ($hTreeView, $string & "|" & $ftime[$found - 1] & " " & $fname[$found - 1]) = 0 Then _GUICtrlTreeView_AddChild ($hTreeView, $hItem, $ftime[$found - 1] & " " & $fname[$found - 1], $equal, $equal)
                Else
                    $hItem = _GUICtrlTreeView_Add ($hTreeView, 0, $string)
                    _GUICtrlTreeView_SetBold ($hTreeView, $hItem)
                    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hItem, 3)
                    _GUICtrlTreeView_AddChild ($hTreeView, $hItem, $ftime[$i] & " " & $fname[$i], $equal, $equal)
                    _GUICtrlTreeView_AddChild ($hTreeView, $hItem, $ftime[$found - 1] & " " & $fname[$found - 1], $equal, $equal)
                EndIf
                _GUICtrlTreeView_Expand ($hTreeView, $hItem)
                _GUICtrlTreeView_EndUpdate ($hTreeView)
                $ftotal += 1
                $stotal += $fsize[$i]
            EndIf
        Next
    WEnd
EndFunc   ;==>_Recurse

Func _Delete()
    GUIRegisterMsg($WM_NOTIFY, "")
    GUICtrlSetState($avi2, 17)
    GUICtrlSetFont($label, 8.5, 800)
    GUICtrlSetData($label, @CRLF & @CRLF & @TAB & @TAB & @TAB & @TAB & @TAB & @TAB & " Deleting ...")
    GUICtrlSetState($add, 128)
    GUICtrlSetState($remove, 128)
    GUICtrlSetState($scan, 128)
    GUICtrlSetState($new, 128)
    GUICtrlSetState($delete, 128)
    SoundPlay(@WindowsDir & "\Media\chimes.wav")
    If MsgBox(270372, $title, "Do you want to delete all checked files ?        ", 0, $GUI) = 6 Then
        Dim $x = _GUICtrlTreeView_GetFirstItem ($hTreeView), $count = 0, $fail = 0, $size = 0, $rep = 0, $rdel = 0, $fdel = 0, $s1 = "", $s2 = ""
        While $x
            Dim $txt = _GUICtrlTreeView_GetText ($hTreeView, $x), $y = _GUICtrlTreeView_GetNext ($hTreeView, $x)
            If $txt = "Scan completed. Summary:" Or $txt = "Scan aborted. Summary:" Then ExitLoop
            If StringInStr($txt, ":\") And _GUICtrlTreeView_GetChecked ($hTreeView, $x) Then
                Dim $tot = FileGetSize($txt), $cnt = 0
                If $rep = 0 Then
                    _GUICtrlTreeView_BeginUpdate ($hTreeView)
                    $rep = _GUICtrlTreeView_Add ($hTreeView, 0, "Cleaning Report:")
                    _GUICtrlTreeView_SetBold ($hTreeView, $rep)
                    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $rep, 3)
                    _GUICtrlTreeView_EndUpdate ($hTreeView)
                EndIf
                While FileExists($txt)
                    If $cnt = 10 Then
                        $cnt = 11
                        ExitLoop
                    EndIf
                    FileDelete($txt)
                    $cnt += 1
                WEnd
                _GUICtrlTreeView_BeginUpdate ($hTreeView)
                If $cnt = 11 Then
                    RegWrite($pe, $pv, "REG_MULTI_SZ", "\??\" & FileGetShortName($txt) & @LF & @LF & RegRead($pe, $pv))
                    If $fdel = 0 Then
                        $fdel = _GUICtrlTreeView_AddChild ($hTreeView, $rep, "Failed:")
                        _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $fdel, 3)
                        _GUICtrlTreeView_SetBold ($hTreeView, $fdel)
                        _GUICtrlTreeView_Expand ($hTreeView, $rep)
                    EndIf
                    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, _GUICtrlTreeView_AddChild ($hTreeView, $fdel, $txt), 3)
                    _GUICtrlTreeView_Expand ($hTreeView, $fdel)
                    $fail += 1
                Else
                    SoundPlay(@WindowsDir & "\Media\recycle.wav")
                    _GUICtrlTreeView_Delete ($hTreeView, $x)
                    If $rdel = 0 Then
                        $rdel = _GUICtrlTreeView_AddChild ($hTreeView, $rep, "Deleted:")
                        _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $rdel, 3)
                        _GUICtrlTreeView_SetBold ($hTreeView, $rdel)
                        _GUICtrlTreeView_Expand ($hTreeView, $rep)
                    EndIf
                    _GUICtrlTreeView_SetStateImageIndex ($hTreeView, _GUICtrlTreeView_AddChild ($hTreeView, $rdel, "~ " & $txt & "  (" & StringTrimRight(_Bytes($tot), 1) & ")"), 3)
                    _GUICtrlTreeView_Expand ($hTreeView, $rdel)
                    $count += 1
                    $size += $tot
                EndIf
                _GUICtrlTreeView_EndUpdate ($hTreeView)
            EndIf
            $x = $y
        WEnd
        If $rep <> 0 Then
            If $count > 1 Then $s1 = "s" 
            _GUICtrlTreeView_BeginUpdate ($hTreeView)
            $hItem = _GUICtrlTreeView_Add ($hTreeView, 0, "Cleaning completed. Summary:")
            _GUICtrlTreeView_SetBold ($hTreeView, $hItem)
            _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hItem, 3)
            $hchild = _GUICtrlTreeView_AddChild ($hTreeView, $hItem, "Deleted: " & $count & " duplicate" & $s1 & ".")
            _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hchild, 3)
            _GUICtrlTreeView_SetBold ($hTreeView, $hchild)
            $hchild = _GUICtrlTreeView_AddChild ($hTreeView, $hItem, "Regained space: " & _Bytes($size))
            _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hchild, 3)
            _GUICtrlTreeView_SetBold ($hTreeView, $hchild)
            If $fail > 0 Then
                If $fail > 1 Then $s2 = "s" 
                $hchild = _GUICtrlTreeView_AddChild ($hTreeView, $hItem, "Failed: " & $fail & " duplicate" & $s2 & ".")
                _GUICtrlTreeView_SetStateImageIndex ($hTreeView, $hchild, 3)
                _GUICtrlTreeView_SetBold ($hTreeView, $hchild)
            EndIf
            _GUICtrlTreeView_EndUpdate ($hTreeView)
            _GUICtrlTreeView_Expand ($hTreeView, $hItem)
        EndIf
        If $fail > 0 Then _Reboot()
    EndIf
    GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
    GUICtrlSetData($label, "")
    GUICtrlSetState($add, 64)
    GUICtrlSetState($scan, 64)
    GUICtrlSetState($new, 64)
    GUICtrlSetState($delete, 64)
    GUICtrlSetState($avi2, 32)
EndFunc   ;==>_Delete

Func _Bytes($x)
    If $x > 1073741823 Then Return StringFormat("%.3f", $x / 1073741824) & " GB !" 
    If $x > 1048575 Then Return StringFormat("%.3f", $x / 1048576) & " MB." 
    If $x > 1023 Then Return StringFormat("%.3f", $x / 1024) & " kB." 
    Return $x & " bytes." 
EndFunc   ;==>_Bytes

Func _New()
    GUIRegisterMsg($WM_NOTIFY, "")
    _GUICtrlTreeView_DeleteAll ($hTreeView)
    _GUICtrlListView_DeleteAllItems ($listview)
    GUICtrlSetTip($listview, "")
    GUICtrlSetData($label, "")
    GUICtrlSetState($red, 32)
    GUICtrlSetState($yellow, 32)
    GUICtrlSetState($green, 32)
    GUICtrlSetState($new, 128)
    GUICtrlSetState($scan, 128)
    GUICtrlSetState($delete, 128)
    Dim $item[1], $items = 0
EndFunc   ;==>_New

Func _WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Dim $tNMHDR = DllStructCreate($tagNMHDR, $ilParam), $iCode = DllStructGetData($tNMHDR, "Code")
    If HWnd(DllStructGetData($tNMHDR, "hWndFrom")) = $hTreeView Then
        If $iCode = $NM_DBLCLK Then Return _Open()
        If $iCode = $NM_RCLICK Then
            $popup = 1
            Return 0
        EndIf
    EndIf
    Return "GUI_RUNDEFMSG" 
EndFunc   ;==>_WM_NOTIFY

Func _WM_SIZE($hWnd, $iMsg, $iwParam, $ilParam)
    $pos = WinGetClientSize($GUI)
    _GUICtrlListView_SetColumnWidth ($listview, 1, $pos[0] - 248)
    ControlMove($GUI, "", $hTreeView, 5, 118, $pos[0] - 9, $pos[1] - 203)
EndFunc   ;==>_WM_SIZE

Func _WM_GETMINMAXINFO($hWnd, $iMsg, $iwParam, $ilParam)
    If $hWnd = $GUI Then
        $minmaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $ilParam)
        DllStructSetData($minmaxinfo, 7, 431)
        DllStructSetData($minmaxinfo, 8, 270)
    EndIf
    Return 0
EndFunc   ;==>_WM_GETMINMAXINFO

Func _Open()
    $x = _TextSelected()
    If StringInStr($x, ":\") And StringLeft($x, 1) <> "~"  Then ShellExecute($x)
EndFunc   ;==>_Open

Func _Explorer()
    Run("explorer.exe /select," & _TextSelected())
EndFunc   ;==>_Explorer

Func _CutCopy()
    $x = FileSelectFolder("Select destination directory", "", 7, "", $GUI)
    If @error Or StringInStr($x, ":\") = 0 Then Return
    If StringRight($x, 1) = "\"  Then $x = StringTrimRight($x, 1)
    Dim $source = _TextSelected(), $dest = $x & StringMid($source, StringInStr($source, "\", 2, -1))
    If $source = $dest And MsgBox(262448, $title, "Select a destination different from source.        ", 0, $GUI) Then Return _CutCopy()
    If FileExists($dest) And MsgBox(262452, $title, $dest & "        " & @CRLF & @CRLF & "File already exists. Do you want to overwrite it ?        ", 0, $GUI) = 7 Then Return
    If @GUI_CtrlId - $context = 4 Then Return FileMove($source, $dest, 9)
    FileCopy($source, $x & "\", 9)
EndFunc   ;==>_CutCopy

Func _Clip()
    $x = _TextSelected()
    If @GUI_CtrlId - $context = 7 Then $x = StringMid($x, StringInStr($x, "\", 2, -1) + 1)
    ClipPut($x)
EndFunc   ;==>_Clip

Func _DeleteOne()
    Dim $cnt = 0, $x = _TextSelected()
    SoundPlay(@WindowsDir & "\Media\chimes.wav")
    If MsgBox(270372, $title, $x & "        " & @CRLF & @CRLF & "Do you really want to delete this file ?        ", 0, $GUI) = 7 Then Return
    While FileExists($x)
        If $cnt = 10 Then Return _Reboot(RegWrite($pe, $pv, "REG_MULTI_SZ", "\??\" & FileGetShortName($x) & @LF & @LF & RegRead($pe, $pv)))
        FileDelete($x)
        $cnt += 1
    WEnd
    SoundPlay(@WindowsDir & "\Media\recycle.wav")
    _GUICtrlTreeView_Delete ($hTreeView, _GUICtrlTreeView_GetSelection ($hTreeView))
EndFunc   ;==>_DeleteOne

Func _Edit()
    Opt("GUIOnEventMode", 0)
    Dim $name = _TextSelected(), $file = StringMid($name, StringInStr($name, "\", 2, -1) + 1), $txt = $file, $y = MouseGetPos()
    $2nd = GUICreate($title & " - Edit / Rename File", 406, 80, 0, 0, $WS_SYSMENU, -1, $GUI)
    GUISetIcon(@SystemDir & "\shell32.dll", -167)
    $ok = GUICtrlCreateButton("Okay", 238, 30, 75, 22)
    GUICtrlSetResizing(-1, 772)
    GUICtrlSetState(-1, 512)
    $cancel = GUICtrlCreateButton("Cancel", 320, 30, 75, 22)
    GUICtrlSetResizing(-1, 772)
    $edit = GUICtrlCreateInput($file, 5, 5, 390, 21)
    GUICtrlSetResizing(-1, 6)
    Dim $tag_Size = DllStructCreate("int X;int Y"), $hWnd = GUICtrlGetHandle($edit), $hDC = DllCall("User32.dll", "hwnd", "GetDC", "hwnd", $hWnd), $hMsg = DllCall("user32.dll", "lparam", "SendMessage", "hwnd", $hWnd, "int", 49, "wparam", 0, "lparam", 0)
    DllCall("GDI32.dll", "hwnd", "SelectObject", "hwnd", $hDC[0], "hwnd", $hMsg[0])
    DllCall("GDI32.dll", "int", "GetTextExtentPoint32", "hwnd", $hDC[0], "str", $file, "int", StringLen($file), "ptr", DllStructGetPtr($tag_Size))
    DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "hwnd", $hDC[0])
    $x = DllStructGetData($tag_Size, "X")
    If $x < 260 Then $x = 260
    If $x > @DesktopWidth - 100 Then $x = @DesktopWidth - 100
    If $y[0] > @DesktopWidth - $x - 10 Then $y[0] = @DesktopWidth - $x - 10
    WinMove($2nd, "", $y[0] - 30, $y[1] - 65, $x + 25)
    GUISetState()
    Do
        $msg = GUIGetMsg()
        $x = GUICtrlRead($edit)
        If $x <> $txt Then
            For $i = 1 To 9
                $y = StringMid('\/:*?"<>|', $i, 1)
                If StringInStr($x, $y) Then
                    GUICtrlSetData($edit, StringReplace($x, $y, ""))
                    ToolTip("A file name must not contain one of the following chars:" & @CRLF & @TAB & '\ / : * ? " < > |', Default, Default, "", 0, 1)
                    AdlibEnable("_Tooltip", 5000)
                EndIf
            Next
            $txt = GUICtrlRead($edit)
        EndIf
        If $msg = $ok Then
            $new = StringReplace($name, $file, $txt)
            If StringMid($txt, StringInStr($txt, ".", 2, -1)) <> StringMid($file, StringInStr($file, ".", 2, -1)) Then
                If MsgBox(262452, $title, "If you alter the file extension, the file will possibly be damaged.        " & @CRLF & @CRLF & "Do you want to proceed ?", 0, $2nd) = 7 Then $msg = 0 * GUICtrlSetData($edit, $file)
            ElseIf $txt <> $file And FileExists($new) Then
                $msg = 0 * MsgBox(262448, $title, $new & @CRLF & @CRLF & "File already exists. Choose a different name.        ", 0, $2nd)
            EndIf
        EndIf
    Until $msg = -3 Or $msg = $ok Or $msg = $cancel
    GUIDelete()
    Opt("GUIOnEventMode", 1)
    If $msg <> $ok Or $file = $txt Then Return
    FileMove($name, $new)
    _GUICtrlTreeView_SetText ($hTreeView, _GUICtrlTreeView_GetSelection ($hTreeView), $new)
EndFunc   ;==>_Edit

Func _Properties()
    Dim $struINFO = DllStructCreate("long;long;long;ptr;ptr;ptr;ptr;long;long;long;ptr;long;long;long;long"), $struVerb = DllStructCreate("char[15];char"), $struPath = DllStructCreate("char[255];char")
    DllStructSetData($struVerb, 1, "properties")
    DllStructSetData($struPath, 1, _TextSelected())
    DllStructSetData($struINFO, 1, DllStructGetSize($struINFO))
    DllStructSetData($struINFO, 2, 0x44C)
    DllStructSetData($struINFO, 4, DllStructGetPtr($struVerb))
    DllStructSetData($struINFO, 5, DllStructGetPtr($struPath))
    DllCall("shell32.dll", "int", "ShellExecuteEx", "ptr", DllStructGetPtr($struINFO))
EndFunc   ;==>_Properties

Func _TextSelected()
    Return _GUICtrlTreeView_GetText ($hTreeView, _GUICtrlTreeView_GetSelection ($hTreeView))
EndFunc   ;==>_TextSelected

Func _Tooltip()
    ToolTip("")
    AdlibDisable()
EndFunc   ;==>_Tooltip

Func _Reboot($x = 0)
    SoundPlay(@WindowsDir & "\Media\notify.wav")
    If ($x = 0 And MsgBox(262436, $title, "Some files could not be deleted.        " & @CRLF & "They will be deleted on reboot.        " & @CRLF & @CRLF & "Do you wish to reboot now ?        ", 0, $GUI) = 6) Or ($x = 1 And MsgBox(262436, $title, "File could not be deleted.        " & @CRLF & "It will be deleted on reboot.        " & @CRLF & @CRLF & "Do you wish to reboot now ?        ", 0, $GUI) = 6) Then Exit (Shutdown(22))
EndFunc   ;==>_Reboot

Func _Exit()
    If MsgBox(270372, $title, "Do you want to quit ?        ", 0, $GUI) = 6 Then Exit
EndFunc   ;==>_Exit