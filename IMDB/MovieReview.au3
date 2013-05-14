#cs
Author: Bennet van der Gryp
Description: Attempt to add MetaData to VideoFile properties.
#ce
#include <String.au3>
#include <array.au3>
#include <Inet.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <IE.au3>
;Doesn't work with folders! (Removes extention for search)
HotKeySet("{ESC}", "ExitProg")
Global $MovieName
Global $sFile
Global $VS = "Google"
$search = FileFindFirstFile("G:\New Folder\*.*")

;~ If $search = -1 Then
;~ 	MsgBox(0, "Error", "No files/directories matched the search pattern")
;~ 	Exit
;~ EndIf
;~ $sFile = FileFindNextFile($search)
;~ $sFile = FileFindNextFile($search)

;~ $File = FileOpen("movies.txt")
While 1
	$sFile = FileFindNextFile($search)
;~ 	$sFile = FileReadline($File)
	If @error Then ExitLoop
;~ 	$MovieName = StringLeft($sFile,StringLen($sFile)-4)
	$MovieName = $sFile
	$link = _IMDblookup($MovieName)
	ImdbFetch($link)
WEnd
#Region File Properties Resolution
Func Resolution($sFile)
	If StringLeft($sFile,1) <> "[" Then
;~ 			$FileName = "G:\Movies\" & $sFile
		$FileNameShort = FileGetShortName($FileName)
		;~ $Results = _Read_File_Properties($FileName)

		$X = 282
		$sFrameW = _Read_File_Properties($FileNameShort, $X)
		$X = 176
		$sDir = _Read_File_Properties($FileNameShort, $X)
;~ 		$X = 155
;~ 		$sFile = _Read_File_Properties($FileNameShort, $X)

		If $sFrameW <> "" Then
;~ 			FileMove($FileName, $sDir & "\[" & $sFrameW & "] " & $sFile,9)
			ConsoleWrite($sDir & "\[" & $sFrameW & "] " & $sFile & @CRLF)
		EndIf
	EndIf

	FileClose($search)
EndFunc

Func _Read_File_Properties(ByRef $sPassed_File_Name, ByRef $X)

    Local  $iError = 0
    
    Local $sDir_Name = StringRegExpReplace($sPassed_File_Name, "(^.*\\)(.*)", "\1")
    Local $sFile_Name = StringRegExpReplace($sPassed_File_Name, "^.*\\", "")
	Local $sDOS_Dir = FileGetShortName($sDir_Name, 1)
	
	Local $oShellApp = ObjCreate("shell.application")
    
	If IsObj($oShellApp) Then
        Local $oDir = $oShellApp.NameSpace($sDOS_Dir)
        If IsObj($oDir) Then
            Local $oFile = $oDir.Parsename($sFile_Name)
            If IsObj($oFile) Then

                $sFile_Property = $oDir.GetDetailsOf($oFile, $X) ; Insert number for property required
				Return $sFile_Property
            Else
                $iError = 3
				Return $iError
            EndIf
        Else
            $iError = 2
			Return $iError
        EndIf
    Else
        $iError = 1
		Return $iError
    EndIf

    If $iError > 0 Then
        Local $sMsg = "Could not read File Properties" & @CRLF & @CRLF & _
                $iError & @CRLF & @CRLF & $sPassed_File_Name
        MsgBox(0, "Error", $sMsg)
    EndIf

EndFunc
#endregion
#Region IMDB Lookup
Func _IMDblookup($searchstring)
	If $VS = "Google" Then
		$link = _SearchGOOGLE($searchstring)
	ElseIf $VS = "IMDB" Then
		$link = _SearchIMDB($searchstring)
		Return $link
	Endif
EndFunc

Func ImdbFetch($link)
	$SourceforFetch = _INetGetSource("http://www.imdb.com/title/" & $link)
;~ 	ConsoleWrite($SourceforFetch)
	Dim $CollectedInfo[1]
	_ArrayAdd($CollectedInfo, "Title: " & $MovieName)
	_ArrayAdd($CollectedInfo, "ImdbLink: " & "http://www.imdb.com/title/" & $link)
	$FetchPoster = _StringBetween($SourceforFetch, '<img src="http://ia.media-imdb.com/images/', 'style="max-width:')
	If Not @error Then
		$FetchPoster = $FetchPoster[0]
		$FetchPoster = StringLeft($FetchPoster, StringLen($FetchPoster) - 7)
		$FetchPoster = "http://ia.media-imdb.com/images/" & $FetchPoster
		_ArrayAdd($CollectedInfo, "Poster: " & $FetchPoster)
;~ 		InetGet($FetchPoster, "G:\Movies\" & $MovieName & ".jpg")
	Else
		_ArrayAdd($CollectedInfo, "Poster: " & "Could Not Find!")
	EndIf
	$FetchPlot = _StringBetween($SourceforFetch, "<h2>Storyline</h2>", "<em")
	If Not @error Then
		$sFetchPlot = $FetchPlot[0]
		$sFetchPlot = StringReplace($sFetchPlot, "</div>","")
		$sFetchPlot = StringReplace($sFetchPlot, "<p>","")
		$sFetchPlot = StringStripWS($sFetchPlot, 7)
		$sFetchPlot = StringReplace($sFetchPlot,"&#x27;", "'")
		$sFetchPlot = StringReplace($sFetchPlot,"&#x22;", '"')
		_ArrayAdd($CollectedInfo, "Plot: " & $sFetchPlot)
	Else
		$FetchPlot = _StringBetween($SourceforFetch, "<h2>Storyline</h2>", '<span class="see-more inline">')
		If Not @error Then
			$sFetchPlot = $FetchPlot[0]
			$sFetchPlot = StringReplace($sFetchPlot, "</div>","")
			$sFetchPlot = StringReplace($sFetchPlot, "<p>","")
			$sFetchPlot = StringReplace($sFetchPlot, "</p>","")
			$sFetchPlot = StringStripWS($sFetchPlot, 7)
			$sFetchPlot = StringReplace($sFetchPlot,"&#x27;", "'")
			$sFetchPlot = StringReplace($sFetchPlot,"&#x22;", '"')
			_ArrayAdd($CollectedInfo, "Plot: " & $sFetchPlot)
		Else
			_ArrayAdd($CollectedInfo, "Plot: " & "Could Not Find!")
		EndIf
	EndIf
	$FetchRating = _StringBetween($SourceforFetch, '<span class="rating-rating">', '<span>')
	If Not @error Then
		$Getrating = $FetchRating[0]
	EndIf
	If Not @error Then
		_ArrayAdd($CollectedInfo, "Rating: " & $Getrating)
	EndIf
	$FetchDirector = _StringBetween($SourceforFetch, 'content="Directed by', '.')
	If Not @error Then
		$FetchDirector[0] = StringStripWS($FetchDirector[0], 7)
		_ArrayAdd($CollectedInfo, "Director: " & $FetchDirector[0])
	Else
		_ArrayAdd($CollectedInfo, "Director: " & "Could Not Find!")
	EndIf
	$FetchGenre = _StringBetween($SourceforFetch, 'href="/genre/', '"')
	If Not @error Then
		$FetchGenre = $FetchGenre[0]
		_ArrayAdd($CollectedInfo, "Genre: " & $FetchGenre)
	EndIf
	$FetchLanguageFormat = _StringBetween($SourceforFetch, '<h4 class="inline">Language:</h4>', '/a>')
	If Not @error Then
		$FetchLanguage = _StringBetween($FetchLanguageFormat[0], '">', '<')
		$FetchLanguage[0] = StringStripWS($FetchLanguage[0], 7)
		_ArrayAdd($CollectedInfo, "Language: " & $FetchLanguage[0])
	Else
		_ArrayAdd($CollectedInfo, "Language: " & "Could Not Find!")
	EndIf
	$FetchRuntime = _StringBetween($SourceforFetch, '<h4 class="inline">Runtime:</h4>', '</div>')
	If Not @error Then
		$FetchRuntime[0] = StringStripWS($FetchRuntime[0], 8)
		$FetchRuntime = StringSplit($FetchRuntime[0], "min", 1)
		_ArrayAdd($CollectedInfo, "Runtime: " & $FetchRuntime[1] & "min")
	Else
		_ArrayAdd($CollectedInfo, "Runtime: " & "Could Not Find!")
	EndIf
	$FetchReleaseDate = _StringBetween($SourceforFetch, '<h4 class="inline">Release Date:</h4>', '<span class="see-more inline">')
	If Not @error Then
		$FetchReleaseDate = StringStripWS($FetchReleaseDate[0],8)
		_ArrayAdd($CollectedInfo, "Release Date: " & $FetchReleaseDate)
	Else
		_ArrayAdd($CollectedInfo, "Release Date: " & "Could Not Find!")
	EndIf
	For $x = 1 To UBound($CollectedInfo) - 1
		ConsoleWrite(@CRLF & $CollectedInfo[$x])
		If StringInStr($CollectedInfo[$x], "Rating:") <> 0 Then
			$sRating = $CollectedInfo[$x]
			$sRating = StringReplace($sRating, "Rating:","")
			$sRating = StringStripWS($sRating,8)
			MoveAndAddRating($sRating)
		EndIf
	Next
	ConsoleWrite(@CRLF & @CRLF)
EndFunc
#endregion
#Region Move File
Func MoveAndAddRating($sRating)
	$sDir = "G:\Movies\"
	If $sRating <> "" Then
;~ 		FileMove($sDir & $sFile, $sDir & "Done\[" & $sRating & "] " & $sFile,9)
	EndIf
EndFunc
#endregion
Func ExitProg()
	Exit
EndFunc

Func _SearchIMDB(ByRef $searchstring)
	Local $link[10]
	If $searchstring = "" Then
		MsgBox(0,"Error", "Search string empty")
		Exit
	EndIf
	$url1 = "http://www.imdb.com/find?s=tt&q="
	$url2 = $searchstring
	$url3 = "&x=0&y=0"
	$source = _INetGetSource($url1 & $url2 & $url3)
	If @error Then
		MsgBox(0, "Error", "Couldn't Connect To IMDb!..Exiting!")
		Exit
	EndIf
	$tstring = _StringBetween($source, '<title>', '</title>')
;~ 	If StringInStr($tstring[0], "Search") Then
	If StringInStr($source, "<b>No Matches.</b>") Then
		Return @error
	Else
		$link = _StringBetween($source, '<a href="/title/', '" onClick=')
		If @error = 1 Then
			MsgBox(0,$link,$link)
			$link = _StringBetween($source, 'href="http://www.imdb.com/title/','/" /><meta property=')
		EndIf
	EndIf
;~ 		If StringInStr($source, "Titles (Exact Matches)") Then
;~ 			$source = _StringBetween($source, 'Titles (Exact Matches)', 'onClick=')
;~ 			$source = $source[0]
;~ 			$link = _StringBetween($source, '<a href="/title/', '"')
;~ 		Else



;~ 	EndIf
;~ 	Else
;~ 		$link = _StringBetween($source, '/title/', '?fr=')
;~ 	EndIf
	If IsArray($link) Then
		$link = $link[0]
	EndIf
	If StringInStr($link,"vote") <> 0 Then
		$link = StringLeft($link,StringInStr($link,"vote")-1)
	EndIf
	
	
	Return $link
EndFunc

Func _SearchGOOGLE(ByRef $searchstring)
	Local $link[10]
	If $searchstring = "" Then
		MsgBox(0,"Error", "Search string empty")
		Exit
	EndIf
;~ 	$url1 = "http://www.imdb.com/find?s=tt&q="
	$url1= "http://www.google.com/search?q=inurl:imdb.com+"
	$url2 = $searchstring
;~ 	$url3 = "&x=0&y=0"
	$url3 = "&btnI"
	$oIE = _IECreate($url1 & $url2 & $url3,0,1,0)
	Sleep(3000)
	$URL = _IEPropertyGet($oIE, "locationurl")
	_IEAction($oIE,"quit")
	$link = StringMid($URL,27)
	$link = StringReplace($link, "/", "")	
	
	Return $link
EndFunc