#Include <String.au3>
Opt("WinTitleMatchMode", 2)
#cs
Updates
2012/10/30 - Added a tooltip that displays in the centre of the screen to inform you of the last episode that you've watched as soon as you open a series.
		   - Added functionality that ensures that going back in the series doesn't update the file. Only the latest one opened will be stored.
#ce
Dim $x = 0
Dim $Hold
While 1
	If WinExists("Episode") Then
		$Title = WinGetTitle("Watch Series")
		If $Hold <> $Title Then
			$Series = _StringBetween($Title, "Watch Online", "Season")
			$Season = _StringBetween($Title, "Season", "Episode")
			$Episode = _StringBetween($Title,"Episode", "-")
			
			$SeriesVar = StringStripWS($Series[0], 3)
			$SeasonVar = StringStripWS($Season[0], 3)
			$EpisodeVar = StringStripWS($Episode[0], 3)
			$SeasonComp = IniRead(@ScriptDir & "\series.ini", $SeriesVar, "Season", 0)
			$EpisodeComp = IniRead(@ScriptDir & "\series.ini", $SeriesVar, "Episode", 0)
			If $SeasonComp <= $SeasonVar Then
				If $EpisodeComp < $EpisodeVar Then
;~ 					MsgBox(0,$EpisodeComp,$EpisodeVar)
					IniWrite(@ScriptDir & "\series.ini", $SeriesVar, "Season", $SeasonVar)
					IniWrite(@ScriptDir & "\series.ini", $SeriesVar, "Episode", $EpisodeVar)
				EndIf
			EndIf
			$Hold = $Title
			ConsoleWrite($Hold)
		EndIf
		ConsoleWrite("1")
	ElseIf WinExists("Serie Online - Watch Series") Then
		$Title = WinGetTitle("Watch Series")
		If $Hold <> $Title Then
			$Series = _StringBetween($Title, "Watch","Serie Online - Watch Series")
			$SeriesVar = StringStripWS($Series[0], 3)
			$SeasonVar = IniRead(@ScriptDir & "\series.ini",$SeriesVar,"Season", "Not yet watched")
			$EpisodeVar = IniRead(@ScriptDir & "\series.ini",$SeriesVar,"Episode", "Not yet watched")
			ToolTip("The last episode you saw was" & @CRLF & "Season " & $SeasonVar & " Episode " & $EpisodeVar)
			Sleep(5000)
			Tooltip("")
			$Hold = $Title
		EndIf	
	EndIf
	Sleep(5000)
WEnd