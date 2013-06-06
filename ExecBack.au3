HotKeySet("^{RIGHT}", "_ExecBack")

While 1
   Sleep(200)
WEnd

Func _ExecBack()
   Send("{F9}")
   Sleep(1000)
   Send("+{F1}")
   Sleep(1000)
   Send("{Space}")
   Sleep(1000)
   Send("^s")
EndFunc
