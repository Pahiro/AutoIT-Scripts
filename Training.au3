Dim $variable
Dim $x, $y

$x = 200

$variable = _Test($x)

ConsoleWrite($variable)

Func _Test(Byref $Var)
	$Var *= 100
	Return $Var
EndFunc
