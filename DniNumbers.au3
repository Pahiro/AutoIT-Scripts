#include <array.au3>
#include <GuiConstants.au3>

$var = InputBox("Input Number", "Input a number to convert to D'ni Numerals")
$hold = $var
Global $co = 0
$data = convert($var)
$posx = 0
$posy = 0
main($hold, $data, $co)
#Region Main Draw

	Func main(ByRef $hold, ByRef $data, ByRef $co)
		$guiwidth = 100 + (100 * $co)
		$gui = GUICreate("D'ni Numerals", $guiwidth, 200)
		For $x = 0 To $co - 1
			$co100 = $x * 100
			GUICtrlCreateGraphic(50, 50, 750, 200)
			GUICtrlSetGraphic(-1, $gui_gr_pensize, 4)
			GUICtrlSetGraphic(-1, $gui_gr_color, 0)
			GUICtrlSetGraphic(-1, $gui_gr_move, -6 + $co100, 0)
			GUICtrlSetGraphic(-1, $gui_gr_line, 106 + $co100, 0)
			GUICtrlSetGraphic(-1, $gui_gr_color, 0)
			GUICtrlSetGraphic(-1, $gui_gr_move, -6 + $co100, 100)
			GUICtrlSetGraphic(-1, $gui_gr_line, 106 + $co100, 100)
			GUICtrlSetGraphic(-1, $gui_gr_rect, 0 + $co100, 0, 101, 101)
			GUICtrlSetGraphic(-1, $gui_gr_pensize, 2)
			Select
				Case $data[$x][0] = 0
					draw0($co100)
				Case $data[$x][0] = 1
					draw1($co100)
				Case $data[$x][0] = 2
					draw2($co100)
				Case $data[$x][0] = 3
					draw3($co100)
				Case $data[$x][0] = 4
					draw4($co100)
				Case $data[$x][0] = 5
					draw5x1($co100)
				Case $data[$x][0] = 6
					draw5x1($co100)
					draw1($co100)
				Case $data[$x][0] = 7
					draw5x1($co100)
					draw2($co100)
				Case $data[$x][0] = 8
					draw5x1($co100)
					draw3($co100)
				Case $data[$x][0] = 9
					draw5x1($co100)
					draw4($co100)
				Case $data[$x][0] = 10
					draw5x2($co100)
				Case $data[$x][0] = 11
					draw5x2($co100)
					draw1($co100)
				Case $data[$x][0] = 12
					draw5x2($co100)
					draw2($co100)
				Case $data[$x][0] = 13
					draw5x2($co100)
					draw3($co100)
				Case $data[$x][0] = 14
					draw5x2($co100)
					draw4($co100)
				Case $data[$x][0] = 15
					draw5x3($co100)
				Case $data[$x][0] = 16
					draw5x3($co100)
					draw1($co100)
				Case $data[$x][0] = 17
					draw5x3($co100)
					draw2($co100)
				Case $data[$x][0] = 18
					draw5x3($co100)
					draw3($co100)
				Case $data[$x][0] = 19
					draw5x3($co100)
					draw4($co100)
				Case $data[$x][0] = 20
					draw5x4($co100)
				Case $data[$x][0] = 21
					draw5x4($co100)
					draw1($co100)
				Case $data[$x][0] = 22
					draw5x4($co100)
					draw2($co100)
				Case $data[$x][0] = 23
					draw5x4($co100)
					draw3($co100)
				Case $data[$x][0] = 24
					draw5x4($co100)
					draw4($co100)
			EndSelect
			ConsoleWrite($data[$x][0] & ":" & $data[$x][1] & "s" & @CRLF)
		Next
		GUISetState(@SW_SHOW)
		While 1
			$msg = GUIGetMsg()
			If $msg = $gui_event_close Then ExitLoop
		WEnd
	EndFunc

#EndRegion
#Region Convert to Base 25 -> Output Array

	Func convert(ByRef $input)
		Dim $c = 0
		Dim $x = 2
		Dim $div
		Dim $out[20][20]
		While 1
			While $x >= 1
				$c += 1
				$div = 25 ^ $c
				$x = $input / $div
			WEnd
			$c -= 1
			$out[$co][0] = Int($input / (25 ^ $c))
			$out[$co][1] = 25 ^ $c
			$co += 1
			$input -= Int($input / (25 ^ $c)) * Int(25 ^ $c)
			If $c = 0 Then ExitLoop
		WEnd
		Return $out
	EndFunc

#EndRegion
#Region Draw Funcs

	Func draw1(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_move, 50 + $posx, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 50 + $posx, 100)
	EndFunc

	Func draw2(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_move, 0 + $posx, 0)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_bezier, 0 + $posx, 100, 50 + $posx, 50, 0 + $posx, 100)
	EndFunc

	Func draw3(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_move, 50 + $posx, 0)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 0 + $posx, 50)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 50 + $posx, 100)
	EndFunc

	Func draw4(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_move, 100 + $posx, 35)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 50 + $posx, 35)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 50 + $posx, 100)
	EndFunc

	Func draw5x1(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_move, 0 + $posx, 50)
		GUICtrlSetGraphic(-1, $gui_gr_line, 100 + $posx, 50)
	EndFunc

	Func draw5x2(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_move, 0 + $posx, 100)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_bezier, 100 + $posx, 100, 50 + $posx, 50, 100 + $posx, 100)
	EndFunc

	Func draw5x3(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_move, 0 + $posx, 50)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 50 + $posx, 100)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 100 + $posx, 50)
	EndFunc

	Func draw5x4(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_move, 35 + $posx, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 35 + $posx, 50)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_line, 100 + $posx, 50)
	EndFunc

	Func draw0(ByRef $posx)
		GUICtrlSetGraphic(-1, $gui_gr_color, 0)
		GUICtrlSetGraphic(-1, $gui_gr_move, 49 + $posx, 50)
		GUICtrlSetGraphic(-1, $gui_gr_line, 51 + $posx, 50)
		GUICtrlSetGraphic(-1, $gui_gr_line, 51 + $posx, 52)
		GUICtrlSetGraphic(-1, $gui_gr_line, 49 + $posx, 52)
		GUICtrlSetGraphic(-1, $gui_gr_line, 49 + $posx, 50)
	EndFunc

#EndRegion
