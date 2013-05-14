#cs
Author: Bennet van der Gryp
Description: This program pulled meta data from a text file and organized it into a meta file.
#ce
$File = FileOpen("G:\Movies.txt")
Dim $IMDBID, $Plot, $Rating, $Director, $Language, $Runtime, $ReleaseDate
While 1
	$Line = FileReadLine($File)
;~ 	ConsoleWrite($Line & @CRLF)
	If @error = -1 then ExitLoop
	If StringInStr($Line, "Title: ") Then
		$Title = StringReplace($Line, "Title: ","")
		$Title = StringStripWS($Title,7)
	ElseIf StringInStr($Line, "ImdbLink: ") Then
		$IMDBID = StringReplace($Line, "ImdbLink: http://www.imdb.com/title/","")
		$IMDBID = StringLeft($IMDBID, StringLen($IMDBID) - 1)
	ElseIf StringInStr($Line, "Plot: ") Then
		$Plot = StringReplace($Line, "Plot: ","")
	ElseIf StringInStr($Line, "Rating: ") Then
		$Rating = StringReplace($Line, "Rating: ","")
	ElseIf StringInStr($Line, "Director: ") Then
		$Director = StringReplace($Line, "Director: ","")
	ElseIf StringInStr($Line, "Language: ") Then
		$Language = StringReplace($Line, "Language: ","")
	ElseIf StringInStr($Line, "Runtime: ") Then
		$Runtime = StringReplace($Line, "Runtime: ","")
	ElseIf StringInStr($Line, "Genre: ") Then
		$Genre = StringReplace($Line, "Genre: ","")
	ElseIf StringInStr($Line, "Release Date: ") Then
		$ReleaseDate = StringReplace($Line, "Release Date: ","")
		CreateXML($Title, $IMDBID, $Plot, $Rating, $Director, $Language, $Runtime, $Genre, $ReleaseDate)
	ElseIf StringInStr($Line, "Poster: ") Then
		;Do nothing. :)
	EndIf
WEnd

Func CreateXML(ByRef $Title,ByRef $IMDBID,ByRef $Plot,ByRef $Rating,ByRef $Director,ByRef $Language,ByRef $Runtime,ByRef $Genre,ByRef $ReleaseDate)
	For $x = 1900 to 2100
		If StringInStr($ReleaseDate, $x) Then
			ExitLoop
		EndIf
	Next
	
	If $x = 2101 Then $x = 0
	
	FileCopy("G:\New Folder\" & $Title & "\folder.jpg", "C:\Users\Bennet van der Gryp\AppData\Roaming\Microsoft\eHome\mcm_id__" & $IMDBID & "-.jpg",1)
	
;~ 	$XML =	'<?xml version="1.0"?>' & @CRLF
;~ 	$XML ='<METADATA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' & @CRLF
;~ 	$XML =  '<MDR-DVD>' & @CRLF
;~ 	$XML =    '<version>5.0</version>' & @CRLF
;~ 	$XML =    '<dvdTitle>' & $Title & '</dvdTitle>' & @CRLF
;~ 	$XML =    '<studio></studio>' & @CRLF
;~ 	$XML =    '<leadPerformer></leadPerformer>' & @CRLF
;~ 	$XML =    '<director>' & $Director & '</director>' & @CRLF
;~ 	$XML =    '<MPAARating></MPAARating>' & @CRLF
;~ 	$XML =    '<releaseDate>' & $x & '</releaseDate>' & @CRLF
;~ 	$XML =    '<genre>' & $Genre & '</genre>' & @CRLF
;~ 	$XML =    '<largeCoverParams>mcm_id__' & $IMDBID & '-.jpg</largeCoverParams>' & @CRLF
;~ 	$XML =    '<smallCoverParams>mcm_id__' & $IMDBID & '-.jpg</smallCoverParams>' & @CRLF
;~ 	$XML =    '<dataProvider>AMG</dataProvider>' & @CRLF
;~ 	$XML =    '<duration>' & $Runtime & '</duration>' & @CRLF
;~ 	$XML =    '<title>' & @CRLF
;~ 	$XML =      '<titleNum>1</titleNum>' & @CRLF
;~ 	$XML =      '<titleTitle>' & $Title & '</titleTitle>' & @CRLF
;~ 	$XML =      '<studio></studio>' & @CRLF
;~ 	$XML =      '<director>' & $Director & '</director>' & @CRLF
;~ 	$XML =      '<leadPerformer></leadPerformer>' & @CRLF
;~ 	$XML =      '<MPAARating></MPAARating>' & @CRLF
;~ 	$XML =      '<genre></genre>' & @CRLF
;~ 	$XML =      '<synopsis>' & $Plot & '</synopsis>' & @CRLF
;~ 	$XML =    '</title>' & @CRLF
;~ 	$XML =  '</MDR-DVD>' & @CRLF
;~ 	$XML =  '<DvdId>mcm_id__' & $IMDBID & '-</DvdId>' & @CRLF
;~ 	$XML ='</METADATA>'

	$XML = '<?xml version="1.0" encoding="utf-8"?>' & @CRLF
	$XML &= '<Title xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' & @CRLF
	$XML &= '<LocalTitle></LocalTitle>' & @CRLF
	$XML &= '<OriginalTitle>' & $Title &'</OriginalTitle>' & @CRLF
	$XML &= '<SortTitle>' & $Title &'</SortTitle>' & @CRLF
	$XML &= '<ForcedTitle>' & $Title &'</ForcedTitle>  ' & @CRLF
	$XML &= '<IMDBrating>' & $Rating &'</IMDBrating>' & @CRLF
	$XML &= '<ProductionYear>' & $x &'</ProductionYear>' & @CRLF
	$XML &= '<MPAARating></MPAARating>' & @CRLF
	$XML &= '<Revenue></Revenue>' & @CRLF
	$XML &= '<Budget></Budget>' & @CRLF
	$XML &= '<Added>' & @MDAY & "/" & @MON & "/" & @YEAR &'</Added>' & @CRLF
	$XML &= '<IMDbId>' & $IMDBID &'</IMDbId>' & @CRLF
	$XML &= '<RunningTime>' & $Runtime &'</RunningTime>' & @CRLF
	$XML &= '<TMDbId></TMDbId>' & @CRLF
	$XML &= '<Studios>' & @CRLF
	$XML &= '<Studio></Studio>' & @CRLF
	$XML &= '</Studios>' & @CRLF
	$XML &= '<CDUniverseId></CDUniverseId>' & @CRLF
	$XML &= '<Persons>' & @CRLF
	$XML &= '<Person>' & @CRLF
	$XML &= '<Name>' & $Director & @CRLF
	$XML &= '</Name>' & @CRLF
	$XML &= '<Type>' & "Director" & @CRLF
	$XML &= '</Type>' & @CRLF
	$XML &= '</Person>' & @CRLF
	$XML &= '</Persons>' & @CRLF
	$XML &= '<Genres>' & @CRLF
	$XML &= '<Genre>' & $Genre & '</Genre>' & @CRLF
	$XML &= '</Genres>' & @CRLF
	$XML &= '<Description>' & $Plot &'</Description>' & @CRLF
	$XML &= '<Covers>' & @CRLF
	$XML &= '<Front>folder.jpg</Front>' & @CRLF
	$XML &= '<Back/>' & @CRLF
	$XML &= '</Covers>' & @CRLF
	$XML &= '</Title>'
	
;~ 	$save = FileOpen("C:\Users\Bennet van der Gryp\AppData\Roaming\Microsoft\eHome\mcm_id__" & $IMDBID & "-.dvdid.xml",10)
	$save = FileOpen("G:\New Folder\" & $Title & "\mymovies.xml",10)
	FileWrite($save, $XML)
	FileClose($save)
EndFunc