if ErrorLevel
	{
		Tooltip, ERR! @ Line#:  %A_LineNumber%`n %A_LineFile%
		SetTimer, RemoveToolTip, -2000

		Return
	}