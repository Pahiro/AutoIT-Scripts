#cs
Author: Bennet van der Gryp
Description:
#ce
#Include <Array.au3>
;This is an attempt to predict trends in the JSE.
;The first step is creating a trenline for each of the indices.
;The seconds step is creating the evolutionary algorithm to analyze these trends
;and try and figure out if the trends have any correlation between eachother
;thereby increasing prediction accuracy with each generation.

;Correlations to consider:
;1. Month of year
;2. Day of week
;3. Categories?
;4. Reactionary Market ***

;Databases: Historic Data
; 			Predictions
;			CurrentStocks

Func BuySell()
	;Take top 10 indices.
	;Compare top 10 indices to previous indices where our money is.
	;If previous index not in top 10
		;Sell stocks.
	;EndIf
	;Determine weight of each of the new indices.
	;Devide money by weights.
	;If stocks are owned in current top10 then only add on or sell from
EndFunc

Func GetData(ByRef $Index)
	;If $Index if Initial go through all indices.
		;For each record in file
			$Prediction = Predict($Index)
			;Export prediction to another column.
		;Next
	;Else
		$Prediction = Predict($Index)
	;Endif
	;Sort indices.
EndFunc

Func Predict(ByRef $Index)
	$1 = MonthOfYear($Index)
	$2 = DayOfWeek($Index)
	$3 = ReactionAnalysis($Index)
	
	$1 = $1 / 100 * 10 ;10% Weight
	$2 = $2 / 100 * 5  ;5% Weight
	$3 = $3 / 100 * 75 ;75% Weight
	
	$LikelyHood = $1 + $2 + $3 ;Likelyhood that index will raise.
	
	Return $LikelyHood
EndFunc

Func MonthOfYear(ByRef $Index)
	;Check history to see what happens in this month every year compared to the preceding one.
	Return $Result
EndFunc

Func DayOfWeek(ByRef $Index)
	;Check history to see what happens on this day of the week compared to preceding days.
	Return $Result
EndFunc

Func ReactionAnalysis(ByRef $Index)
	;If one indice dropped and another rose check if this correlates to history.
	;Find patterns.
	Return $Result
EndFunc