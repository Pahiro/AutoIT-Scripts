#include <StaticConstants.au3>
#include <EditConstants.au3>
#Include <GuiListView.au3>
#include <Twitter.au3>

Dim $msg, $twitter, $twitter_ctrl
Global $main_gui, $curr_gui, $authentication_gui

; Setup the Main GUI
$main_gui = GUICreate("Twitter Example - Main", 460, 360, -1, -1)

GUICtrlCreateGroup("Authentication", 10, 10, 440, 70)
GUICtrlCreateLabel("Consumer Key:", 20, 30, 80, 20)
$consumer_key_input = GUICtrlCreateInput("WW6MD2bbVwoUHmCgijXog", 105, 30, 120, 20)
GUICtrlCreateLabel("Consumer Secret:", 20, 50, 85, 20)
$consumer_secret_input = GUICtrlCreateInput("fH0zAbhQD5lTBY0HRMKamftUxnWuWoHeblzGKLO2MQ", 105, 50, 120, 20)
$authenticate_button = GUICtrlCreateButton("Authenticate", 230, 50, 80, 20)

GUICtrlCreateGroup("Tweeting", 10, 90, 440, 230)
GUICtrlCreateLabel("Message:", 20, 110, 45, 20)
$message_input = GUICtrlCreateInput("hello world", 105, 110, 80, 20)
GUICtrlCreateLabel("Lat:", 190, 110, 30, 20)
$latitude_input = GUICtrlCreateInput("", 210, 110, 50, 20)
GUICtrlCreateLabel("Long:", 270, 110, 30, 20)
$longitude_input = GUICtrlCreateInput("", 300, 110, 50, 20)
$tweet_button = GUICtrlCreateButton("Tweet", 360, 110, 80, 20)
GUICtrlSetState($tweet_button, $GUI_DISABLE)
GUICtrlCreateLabel("Search Text:", 20, 130, 70, 20)
$search_text_input = GUICtrlCreateInput("hello world", 105, 130, 80, 20)
$search_text_button = GUICtrlCreateButton("Search", 360, 130, 80, 20)
GUICtrlCreateLabel("Result Type:", 20, 150, 90, 20)
$result_type_list = GUICtrlCreateList("", 105, 150, 80, 50, BitOR($WS_BORDER, $WS_VSCROLL))
GUICtrlSetData($result_type_list, "mixed|recent|popular", "mixed")
GUICtrlCreateLabel("Search Results:", 20, 190, 85, 20)
$response_listview = GUICtrlCreateListView("title|author name|published|id", 20, 210, 380, 100)

GUICtrlCreateLabel("Status:", 10, 330, 50, 20)
$status_input = GUICtrlCreateInput("Ready", 50, 330, 300, 20, $ES_READONLY)
$close_button = GUICtrlCreateButton("Close (Esc)", 370, 330, 80, 20)

dim $main_gui_accel[1][2]=[["{ESC}", $close_button]]

; Setup the Authentication GUI
$authentication_gui = GUICreate("Twitter Example - Authenication", 640, 480, -1, -1, BitOR($WS_SIZEBOX, $WS_MAXIMIZEBOX))

$authentication_label1 = GUICtrlCreateLabel("Now accessing Twitter for authentication." & @CRLF & "When prompted, please provide your Twitter username and password.", 10, 10, 630, 50, $SS_CENTER)
GUICtrlSetFont($authentication_label1, 12, 800)
$twitter_ctrl = _GUICtrlTwitter_Create($twitter, 0, 50, 640, 380)
GUICtrlSetState($twitter_ctrl, $GUI_HIDE)
$authentication_label2 = GUICtrlCreateLabel("This window will automatically close when authenication has finished.", 10, 430, 630, 50, $SS_CENTER)
GUICtrlSetFont($authentication_label2, 12, 800)

; Show the Main GUI
$curr_gui = $main_gui
GUISwitch($curr_gui)
GUISetState(@SW_SHOW)
GUISetAccelerators($main_gui_accel)

; The Main Loop
while 1

	if $msg = $authenticate_button Then

		GUICtrlSetData($status_input, "Authentication started ...")
		$curr_gui = $authentication_gui
		GUISwitch($curr_gui)
		GUISetState(@SW_SHOW)
		_GUICtrlTwitter_Authenticate($twitter, $twitter_ctrl, GUICtrlRead($consumer_key_input), GUICtrlRead($consumer_secret_input))
		GUICtrlSetState($tweet_button, $GUI_ENABLE)
		GUISetState(@SW_HIDE)
		$curr_gui = $main_gui
		GUISwitch($curr_gui)
		GUISetState(@SW_ENABLE)
		GUISetState(@SW_RESTORE)
		GUISetAccelerators($main_gui_accel)
		GUICtrlSetData($status_input, "Authentication complete.")
		Sleep(2000)
		GUICtrlSetData($status_input, "Ready")
	EndIf

	if $msg = $tweet_button Then

		GUICtrlSetData($status_input, "Sending tweet ...")
		_GUICtrlTwitter_UpdateStatus($twitter, GUICtrlRead($message_input), GUICtrlRead($latitude_input), GUICtrlRead($longitude_input))
		GUICtrlSetData($status_input, "Tweet sent.")
		Sleep(2000)
		GUICtrlSetData($status_input, "Ready")
	EndIf

	if $msg = $search_text_button Then

		GUICtrlSetData($status_input, "Searching Twitter ...")
		$search_result = _GUICtrlTwitter_Search(GUICtrlRead($search_text_input), GUICtrlRead($result_type_list))

		_GUICtrlListView_BeginUpdate($response_listview)
		_GUICtrlListView_DeleteAllItems($response_listview)

		$entry_num = 1

		while StringLen($search_result.item("entry" & $entry_num & ".id")) > 0

			$listviewitem = $search_result.item("entry" & $entry_num & ".title") & "|" & _
							$search_result.item("entry" & $entry_num & ".name") & "|" & _
							$search_result.item("entry" & $entry_num & ".published") & "|" & _
							$search_result.item("entry" & $entry_num & ".id")

			GUICtrlCreateListViewItem($listviewitem, $response_listview)

			$entry_num = $entry_num + 1
		WEnd

		_GUICtrlListView_SetColumnWidth($response_listview,0,250)
		_GUICtrlListView_SetColumnWidth($response_listview,1,100)
		_GUICtrlListView_SetColumnWidth($response_listview,2,150)
		_GUICtrlListView_SetColumnWidth($response_listview,3,270)

		_GUICtrlListView_EndUpdate($response_listview)

		GUICtrlSetData($status_input, "Search finished.")
		Sleep(2000)
		GUICtrlSetData($status_input, "Ready (" & $entry_num & " results returned)")
	EndIf

	If $msg = $GUI_EVENT_CLOSE or $msg = $close_button Then

		; If the Main GUI was closed, then exit the script
		if $curr_gui = $main_gui Then

			ExitLoop
		Else

			; Other GUIs are disabled, and the Main GUI enabled.
			GUISetState(@SW_HIDE)
			$curr_gui = $main_gui
			GUISwitch($curr_gui)
			GUISetState(@SW_ENABLE)
			GUISetState(@SW_RESTORE)
			GUISetAccelerators($main_gui_accel)
		EndIf
	EndIf

	$msg = GUIGetMsg()
WEnd

GUIDelete()
