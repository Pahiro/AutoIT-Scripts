#cs
Author: Bennet van der Gryp
Description: I had the rating in the foldername for each of my movies. I decided it to remove that detail.
#ce

$Dir = FileFindFirstFile("G:\Movies\*.*")
While 1
	$sFile = FileFindNextFile($Dir)
	If @error Then ExitLoop
	$Title = StringLeft($sFile,StringLen($sFile)-7)
	DirMove("G:\Movies\" & $sFile, "G:\SrcMovies\" & $Title)
WEnd
