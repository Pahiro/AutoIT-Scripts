#include <String.au3>
#include <array.au3>
#include <Inet.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#cs
Author: Unknown
Description: this program scans through your film directory and downloads all of the posters and metadata from IMDB.com
#ce
FileInstall("gui.dat", "gui.dat") ; installs background image
FileInstall("FilterWords.txt", "FilterWords.txt") ; installs words to be filtered
#Region ### START Koda GUI section ### Form=
$Form1_1 = GUICreate("Imdb And Poster Grabber v1.3", 421, 174, 257, 356)
GUISetBkColor(0x7fa198)
$Pic1 = GUICtrlCreatePic("gui.dat", 0, 0, 421, 174, 0)
$Button2 = GUICtrlCreateButton("Browse", 360, 22, 49, 21, 0)
$Button1 = GUICtrlCreateButton("Run", 344, 104, 65, 33, 0)
$Button3 = GUICtrlCreateButton("Clean", 376, 144, 35, 25, 0)
$Checkbox1 = GUICtrlCreateCheckbox("Fetch Imdb Info", 8, 48, 127, 25)
$Checkbox2 = GUICtrlCreateCheckbox("Download Poster", 8, 70, 127, 25)
$Checkbox3 = GUICtrlCreateCheckbox("Also Get XL Poster", 135, 78, 145, 17)
$Label1 = GUICtrlCreateLabel("Select the folder", 8, 22, 340, 21, $WS_BORDER, $WS_EX_STATICEDGE)
$Label2 = GUICtrlCreateLabel("Idle", 8, 125, 329, 17, $WS_BORDER, $WS_EX_STATICEDGE)
$PopularMatch = GUICtrlCreateRadio("Popular Match", 8, 104, 105, 17)
GUICtrlSetState($PopularMatch, $GUI_CHECKED)
$ExactMatch = GUICtrlCreateRadio("Exact Match", 122, 104, 105, 17)
$Progress1 = GUICtrlCreateProgress(8, 144, 329, 17, $PBS_SMOOTH)
$Label3 = GUICtrlCreateLabel("", 288, 146, 44, 17)
GUICtrlSetBkColor($Label3, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetTip($Button2, "Browse for folder to be scanned.")
GUICtrlSetTip($Button3, "Remove previously downloaded info and posters.")
GUICtrlSetTip($Button1, "Runs the program.")
GUICtrlSetTip($Checkbox1, "Gets the imdbinfo and stores it in, imdbinfo.nfo located in each movie folder.")
GUICtrlSetTip($Checkbox2, "Downloads a Poster from Impawards and stores it as folder.jpg (HTPC compability) in the moviefolder.")
GUICtrlSetTip($Checkbox3, "Requires that you get the (Default) poster as well, since not every movie has the extra large poster. Stored at moviefolder as folder_XL.jpg")
GUICtrlSetTip($Label2, "Shows what the program is currently doing.")
GUICtrlSetTip($PopularMatch, 'Imdb scan picks first "Popular Title" after search,This is (Default) since its most accurate with well established titles.')
GUICtrlSetTip($ExactMatch, "Imdb scan tries to match movies for exact title, This is useful if your movie/movies shows up as another more popular title after an imdb search," & @CRLF & " Reason why this isnt default is that it could link to videogames and other crap and give false movie matches," & @CRLF & " Require that your foldername/moviename has a year in it for accuracy, If it doesn't it will do a Popular title match")
GUICtrlSetTip($Progress1, "Progress bar for Poster download.")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
While 1
	$nMsg = GUIGetMsg()
	If GUICtrlRead($Checkbox3) = $GUI_CHECKED Then
		GUICtrlSetState($Checkbox2, $GUI_CHECKED)
	EndIf
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $nMsg = BitAND(GUICtrlRead($PopularMatch), $GUI_CHECKED) = $GUI_CHECKED
			GUICtrlSetState($ExactMatch, $GUI_UNCHECKED)
		Case $nMsg = BitAND(GUICtrlRead($ExactMatch), $GUI_CHECKED) = $GUI_CHECKED
			GUICtrlSetState($PopularMatch, $GUI_UNCHECKED)
		Case $Button2
			$Scanfolder = FileSelectFolder("Scan Folder", "")
			If Not $Scanfolder = "" Then
				$ScanTypeQuestion = MsgBox(4, "Choose Scantype:", "Does the folder contain a single movie?")
				If $ScanTypeQuestion = 6 Or $ScanTypeQuestion = 7 Then
					GUICtrlSetData($Label1, $Scanfolder)
				EndIf
			EndIf
		Case $Button3
			$ReadFolderInput = GUICtrlRead($Label1)
			If $ReadFolderInput = "Select the folder" Then
				MsgBox(0, "Hey Dude", "I wont work without a movie folder!")
			Else
				$CleanerQuestion = MsgBox(4, "WARNING!!", "Scan The Folder For Previously Downloaded Content Then REMOVE Them?")
				If $CleanerQuestion = 6 Then
					Cleaner($ReadFolderInput)
					GUICtrlSetData($Label2, "Clean Completed Successfully!")
				EndIf
			EndIf
		Case $Button1
			Dim $MovienameArray[1]
			$ReadFolderInput = GUICtrlRead($Label1)
			If $ReadFolderInput = "Select the folder" Then
				MsgBox(0, "Hey Dude", "I wont work without a movie folder!")
			ElseIf GUICtrlRead($Checkbox1) = $GUI_UNCHECKED And GUICtrlRead($Checkbox2) = $GUI_UNCHECKED Then
				MsgBox(0, "Hey Dude", "You have to select what to do!")
			Else
				GUICtrlSetData($Label2, "Begin Scan For Movies...")
				$WrongScanPath = 0
				ScanFolder($ReadFolderInput)
				$totalmovies = UBound($MovienameArray) - 1
				If $WrongScanPath = 0 Then
					If GUICtrlRead($Checkbox1) = $GUI_CHECKED Or GUICtrlRead($Checkbox2) = $GUI_CHECKED Then
						GUICtrlSetData($Label2, "Begin IMDB And/Or Poster Fetch...")
					EndIf
					For $x = 1 To UBound($MovienameArray) - 1
						$MovienameNotFiltered = $MovienameArray[$x]
						$MovienameFiltered = RlsNameFilter($MovienameArray[$x])
						If StringInStr($MovienameFiltered, "-") Then
							$MovienamerlsGroup = StringSplit($MovienameFiltered, "-")
							$i = UBound($MovienamerlsGroup) - 1
							$MovienamerlsGroup = "-" & $MovienamerlsGroup[$i]
							$MovienameFiltered = StringReplace($MovienameFiltered, $MovienamerlsGroup, "")
						EndIf
						$FindYear = StringRegExp($MovienameFiltered, "([\d]{4,4})", 1)
						If @error = 0 Then
							$MovienameFiltered = StringReplace($MovienameFiltered, $FindYear[0], "(" & $FindYear[0] & ")")
						EndIf
						$MovienameFiltered = StringStripWS($MovienameFiltered, 6)
						$link = _IMDblookup($MovienameFiltered)
						If Not $link = 0 Then
							If GUICtrlRead($Checkbox2) = $GUI_CHECKED Then
								ImpAwardsGrabber()
								GUICtrlSetData($Progress1, 0)
							EndIf
							If FileExists($ReadFolderInput & "\" & $MovienameNotFiltered & "\imdbinfo.nfo") = 0 And GUICtrlRead($Checkbox1) = $GUI_CHECKED Then
								ImdbFetch()
							EndIf
						EndIf
						GUICtrlSetData($Label3, $x & "/" & $totalmovies)
					Next
					If GUICtrlRead($Checkbox1) = $GUI_CHECKED Or GUICtrlRead($Checkbox2) = $GUI_CHECKED Then
						GUICtrlSetData($Label2, "IMDB And/Or Poster Fetch...- Done!")
					EndIf
				EndIf
			EndIf
	EndSwitch
WEnd
Func ScanFolder($SourceFolder)
	Local $Search
	Local $File
	Local $FileAttributes
	Local $FullFilePath
	$Search = FileFindFirstFile($SourceFolder & "\*.*")
	While 1
		If $Search = -1 Or $WrongScanPath = 1 Then
			ExitLoop
		EndIf
		$File = FileFindNextFile($Search)
		If @error Then ExitLoop
		$FullFilePath = $SourceFolder & "\" & $File
		$FileAttributes = FileGetAttrib($FullFilePath)
		If StringInStr($FileAttributes, "D") Then
			ScanFolder($FullFilePath)
		ElseIf StringInStr($FullFilePath, ".avi") Or StringInStr($FullFilePath, ".mkv") Or StringInStr($FullFilePath, ".mp4") Or StringInStr($FullFilePath, ".ts") Or StringInStr($FullFilePath, ".mpg") Or StringInStr($FullFilePath, ".mpeg") Or StringInStr($FullFilePath, ".wmv") Then
			If StringInStr($FullFilePath, "sample") = 0 And StringInStr($FullFilePath, ".jpg") = 0 And StringInStr($FullFilePath, "\CD2\") = 0 Then
				Select
					Case $ScanTypeQuestion = 6
						$Aviname = StringSplit($FullFilePath, "\")
						If $FullFilePath = $ReadFolderInput & "\" & $Aviname[$Aviname[0]] Or $FullFilePath = $ReadFolderInput & "\CD1\" & $Aviname[$Aviname[0]] Then
							If StringInStr($FullFilePath, "CD1") Then
								$ReplacedSinglePath = StringReplace($FullFilePath, 'CD1\', "")
								$ReplacedSinglePath = StringSplit($ReplacedSinglePath, "\")
								$StringForImdb = $ReplacedSinglePath[$ReplacedSinglePath[0] - 1]
								_ArrayAdd($MovienameArray, $StringForImdb)
							Else
								$ReplacedSinglePath = StringSplit($FullFilePath, "\")
								$StringForImdb = $ReplacedSinglePath[$ReplacedSinglePath[0] - 1]
								_ArrayAdd($MovienameArray, $StringForImdb)
							EndIf
						Else
							GUICtrlSetData($Label2, "Bad File Was Detected Last Time Scan Run")
							MsgBox(0, "Bad File Detected!", "You choose the wrong scantype, If you open a folder that contain multiple movie folders you have to choose that Scantype in the question box!")
							$WrongScanPath = 1
						EndIf
					Case $ScanTypeQuestion = 7
						$Aviname = StringSplit($FullFilePath, "\")
						If $FullFilePath = $ReadFolderInput & "\" & $Aviname[$Aviname[0]] Or $FullFilePath = $ReadFolderInput & "\CD1\" & $Aviname[$Aviname[0]] Then
							GUICtrlSetData($Label2, "Bad File Was Detected Last Time Scan Run")
							MsgBox(0, "Bad File Detected!", "There's a file without a folder and/or you choose the wrong scantype, If you open a single movie folder you have to choose that Scantype in the question box!")
							$WrongScanPath = 1
						Else
							$StringForImdb = StringReplace($FullFilePath, $ReadFolderInput, "")
							$StringForImdb = _StringBetween($StringForImdb, "\", "\")
							$StringForImdb = $StringForImdb[0]
							_ArrayAdd($MovienameArray, $StringForImdb)
						EndIf
				EndSelect
			EndIf
		EndIf
		
	WEnd
	FileClose($Search)
EndFunc
Func textfilter($searchstring)
	$searchstring = StringReplace($searchstring, "%", "%25")
	$searchstring = StringReplace($searchstring, "!", "%21")
	$searchstring = StringReplace($searchstring, '"', "%22")
	$searchstring = StringReplace($searchstring, '#', "%23")
	$searchstring = StringReplace($searchstring, '$', "%24")
	$searchstring = StringReplace($searchstring, '&', "%26")
	$searchstring = StringReplace($searchstring, "'", "%27")
	$searchstring = StringReplace($searchstring, "(", "%28")
	$searchstring = StringReplace($searchstring, ")", "%29")
	$searchstring = StringReplace($searchstring, "+", "%2B")
	$searchstring = StringReplace($searchstring, ",", "%2C")
	$searchstring = StringReplace($searchstring, "/", "%2F")
	$searchstring = StringReplace($searchstring, ":", "%3A")
	$searchstring = StringReplace($searchstring, ";", "%3B")
	$searchstring = StringReplace($searchstring, "<", "%3C")
	$searchstring = StringReplace($searchstring, "=", "%3D")
	$searchstring = StringReplace($searchstring, ">", "%3E")
	$searchstring = StringReplace($searchstring, "?", "%3F")
	$searchstring = StringReplace($searchstring, "@", "%40")
	$searchstring = StringReplace($searchstring, '[', "%5B")
	$searchstring = StringReplace($searchstring, '\', "%5C")
	$searchstring = StringReplace($searchstring, ']', "%5D")
	$searchstring = StringReplace($searchstring, '^', "%5E")
	$searchstring = StringReplace($searchstring, "`", "%60")
	$searchstring = StringReplace($searchstring, '{', "%7B")
	$searchstring = StringReplace($searchstring, '|', "%7C")
	$searchstring = StringReplace($searchstring, '}', "%7D")
	$searchstring = StringReplace($searchstring, "~", "%7E")
	$searchstring = StringReplace($searchstring, " ", "+")
	Return $searchstring
EndFunc
Func RlsNameFilter($moviename)
	Local $Line = 1
	While 1
		$Badword = FileReadLine("FilterWords.txt", $Line)
		If $Badword = "" Then
			ExitLoop
		Else
			$moviename = StringReplace($moviename, $Badword, "")
			$Line += 1
		EndIf
	WEnd
	$moviename = StringReplace($moviename, ".", " ")
	Return $moviename
EndFunc
Func _IMDblookup($searchstring)
	If $searchstring = "" Then
		Exit
	EndIf
	$searchstring = textfilter($searchstring)
	$url1 = "http://www.imdb.com/find?s=tt&q="
	$url2 = $searchstring
	$url3 = "&x=0&y=0"
	$source = _INetGetSource($url1 & $url2 & $url3)
	If @error Then
		MsgBox(0, "Error", "Couldn't Connect To IMDb!..Exiting!")
		Exit
	EndIf
	$tstring = _StringBetween($source, '<title>', '</title>')
	If StringInStr($tstring[0], "IMDb") Then
		If StringInStr($source, "<b>No Matches.</b>") Then
			Return @error
		EndIf
		If GUICtrlRead($ExactMatch) = $GUI_CHECKED And Not StringInStr($source, "Titles (Exact Matches)") = 0 And StringRegExp($searchstring, "([\d]{4,4})", 0) = 1 Then
			$source = _StringBetween($source, 'Titles (Exact Matches)', 'onClick=')
			$source = $source[0]
			$link = _StringBetween($source, '<a href="/title/', '"')
		Else
			$link = _StringBetween($source, '<a href="/title/', '"')
		EndIf
	Else
		$link = _StringBetween($source, '/title/', "trailers")
	EndIf
	Return $link[0]
EndFunc
Func ImdbFetch()
	$SourceforFetch = _INetGetSource("http://www.imdb.com/title/" & $link)
	Dim $CollectedInfo[1]
	_ArrayAdd($CollectedInfo, "Title: " & @CRLF & $MovienameFiltered)
	_ArrayAdd($CollectedInfo, "ImdbLink: " & @CRLF & "http://www.imdb.com/title/" & $link)
	$FetchPlot = _StringBetween($SourceforFetch, '<h5>Plot:</h5>', '<')
	If Not @error Then
		_ArrayAdd($CollectedInfo, "Plot: " & $FetchPlot[0])
	Else
		_ArrayAdd($CollectedInfo, "Plot: " & @CRLF & "Could Not Find!")
	EndIf
	$FetchRatingFormat = _StringBetween($SourceforFetch, '<b>User Rating:</b>', ')</small>')
	If Not @error Then
		$Getrating = _StringBetween($FetchRatingFormat[0], '<b>', '</b>')
		$Getrated = _StringBetween($FetchRatingFormat[0], 'ratings">', '</a>')
	EndIf
	If Not @error Then
		_ArrayAdd($CollectedInfo, "Rating: " & @CRLF & $Getrating[0] & " (" & $Getrated[0] & ")")
	EndIf
	$FetchDirector = _StringBetween($SourceforFetch, 'content="Directed by', '.')
	If Not @error Then
		$FetchDirector[0] = StringStripWS($FetchDirector[0], 7)
		_ArrayAdd($CollectedInfo, "Director: " & @CRLF & $FetchDirector[0])
	Else
		_ArrayAdd($CollectedInfo, "Director: " & "Could Not Find!")
	EndIf
	$FetchGenreFormat = _StringBetween($SourceforFetch, '<h5>Genre:</h5>', '<a class=')
	If Not @error Then
		$FetchGenre = _StringBetween($FetchGenreFormat[0], '/">', '</a>')
		$AlltheGenres = _ArrayToString($FetchGenre[0], ' , ')
		If Not @error = 1 Then
			_ArrayAdd($CollectedInfo, "Genre: " & @CRLF & $AlltheGenres)
		Else
			_ArrayAdd($CollectedInfo, "Genre: " & @CRLF & $FetchGenre[0])
		EndIf
	EndIf
	$FetchLanguageFormat = _StringBetween($SourceforFetch, '<h5>Language:</h5>', '/a>')
	If Not @error Then
		$FetchLanguage = _StringBetween($FetchLanguageFormat[0], '">', '<')
		$FetchLanguage[0] = StringStripWS($FetchLanguage[0], 7)
		_ArrayAdd($CollectedInfo, "Language: " & @CRLF & $FetchLanguage[0])
	Else
		_ArrayAdd($CollectedInfo, "Language: " & "Could Not Find!")
	EndIf
	$FetchRuntime = _StringBetween($SourceforFetch, '<h5>Runtime:</h5>', '</div>')
	If Not @error Then
		$FetchRuntime[0] = StringStripWS($FetchRuntime[0], 8)
		$FetchRuntime = StringSplit($FetchRuntime[0], "min", 1)
		_ArrayAdd($CollectedInfo, "Runtime: " & @CRLF & $FetchRuntime[1] & "min")
	Else
		_ArrayAdd($CollectedInfo, "Runtime: " & "Could Not Find!")
	EndIf
	$FetchReleaseDate = _StringBetween($SourceforFetch, 'Release Date:</h5> ', '<a class=')
	If Not @error Then
		_ArrayAdd($CollectedInfo, "Release Date: " & $FetchReleaseDate[0])
	Else
		_ArrayAdd($CollectedInfo, "Release Date: " & "Could Not Find!")
	EndIf
	If $ScanTypeQuestion = 6 Then
		For $x = 1 To UBound($CollectedInfo) - 1
			FileWriteLine($ReadFolderInput & "\" & "imdbinfo.nfo", @CRLF & $CollectedInfo[$x])
		Next
	Else
		For $x = 1 To UBound($CollectedInfo) - 1
			FileWriteLine($ReadFolderInput & "\" & $MovienameNotFiltered & "\imdbinfo.nfo", @CRLF & $CollectedInfo[$x])
		Next
	EndIf
EndFunc
Func ImpAwardsGrabber()
	Local $MotechActive = 0
	Local $GetIMPSource
	$GoPosters = _INetGetSource("http://www.imdb.com/title/" & $link & "posters")
	If Not @error Then
		$GetIMPLink = StringRegExp($GoPosters, '(?i)http://www.impawards.com(/[\d]{4,4}/[\w]*?.html)">', 1)
		If @error Then
			$MotechActive = 1
		Else
			$GetIMPSource = _INetGetSource("http://www.impawards.com" & $GetIMPLink[0])
			If StringInStr($GetIMPSource, '<meta http-equiv="REFRESH"') Then
				$GetIMPLink = _StringBetween($GetIMPSource, 'URL=..', '">')
				$GetIMPSource = _INetGetSource("http://www.impawards.com" & $GetIMPLink[0])
			EndIf
		EndIf
		If StringInStr($GetIMPSource, 'No Movie Posters on This Page') Or $MotechActive = 1 Then
			$MotechPostername = StringReplace($link, "/", "_largeCover.jpg")
			$FetchIMPcover = "http://posters.motechnet.com/covers/" & $MotechPostername
		Else
			$Getposterlink = StringRegExp($GetIMPSource, '(?i)<img SRC="(posters/.*?.jpg)" ALT', 1)
			$Getlaststring = StringSplit($GetIMPLink[0], "/")
			$GetLastSplit = _ArrayMax($Getlaststring)
			$Getrightpiclink = StringReplace($GetIMPLink[0], $GetLastSplit, $Getposterlink[0])
			$FetchIMPcover = "http://www.impawards.com" & $Getrightpiclink
			If Not StringInStr($GetIMPSource, "xlg.html") = 0 And GUICtrlRead($Checkbox3) = $GUI_CHECKED Then
				$GetBigPosterpage = _StringBetween($GetIMPSource, '<a href = ', ' target= _blank>')
				$FetchBIGIMPcover = StringReplace("http://www.impawards.com" & $Getrightpiclink, ".jpg", "_xlg.jpg")
				$iSize = InetGetSize($FetchBIGIMPcover)
				If $ScanTypeQuestion = 6 Then
					If FileExists($ReadFolderInput & "\" & "folder_XL.jpg") = 0 Then
						InetGet($FetchBIGIMPcover, $ReadFolderInput & "\" & "folder_XL.jpg", 1, 1)
					EndIf
				Else
					If FileExists($ReadFolderInput & "\" & $MovienameNotFiltered & "\folder_XL.jpg") = 0 Then
						InetGet($FetchBIGIMPcover, $ReadFolderInput & "\" & $MovienameNotFiltered & "\folder_XL.jpg", 1, 1)
					EndIf
				EndIf
				While @InetGetActive
					$iPercent = Int((@InetGetBytesRead / $iSize) * 100)
					GUICtrlSetData($Progress1, $iPercent)
					Sleep(10)
				WEnd
				GUICtrlSetData($Progress1, 100)
				Sleep(520)
			EndIf
		EndIf
		$iSize = InetGetSize($FetchIMPcover)
		If @error Then
			Return
		EndIf
		If $ScanTypeQuestion = 6 Then
			If FileExists($ReadFolderInput & "\" & "folder.jpg") = 0 Then
				InetGet($FetchIMPcover, $ReadFolderInput & "\" & "folder.jpg", 1, 1)
			EndIf
		Else
			If FileExists($ReadFolderInput & "\" & $MovienameNotFiltered & "\folder.jpg") = 0 Then
				InetGet($FetchIMPcover, $ReadFolderInput & "\" & $MovienameNotFiltered & "\folder.jpg", 1, 1)
			EndIf
		EndIf
		While @InetGetActive
			$iPercent = Int((@InetGetBytesRead / $iSize) * 100)
			GUICtrlSetData($Progress1, $iPercent)
			Sleep(10)
		WEnd
		GUICtrlSetData($Progress1, 100)
		Sleep(520)
	EndIf
EndFunc
Func Cleaner($SourceFolder)
	Local $Search
	Local $File
	Local $FileAttributes
	Local $FullFilePath
	$Search = FileFindFirstFile($SourceFolder & "\*.*")
	While 1
		If $Search = -1 Then
			ExitLoop
		EndIf
		$File = FileFindNextFile($Search)
		If @error Then ExitLoop
		$FullFilePath = $SourceFolder & "\" & $File
		$FileAttributes = FileGetAttrib($FullFilePath)
		If StringInStr($FileAttributes, "D") Then
			Cleaner($FullFilePath)
		ElseIf StringInStr($FullFilePath, "imdbinfo.nfo") Or StringInStr($FullFilePath, "imdbinfo.txt") Or StringInStr($FullFilePath, "Folder.jpg") Or StringInStr($FullFilePath, "Folder_XL.jpg") Then
			FileDelete($FullFilePath)
		EndIf
	WEnd
EndFunc