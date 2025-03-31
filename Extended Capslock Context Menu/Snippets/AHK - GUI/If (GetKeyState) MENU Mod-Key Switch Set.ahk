

if (GetKeyState("Control", "P") && GetKeyState("Shift", "P"))
	{
		tooltip, Not assigned yet...`n%a_linefile%`n @ Line: %A_linenumber%
		SetTimer, RemoveToolTip, -2000 
		return
	}
if (GetKeyState("Lwin", "P") && GetKeyState("Control", "P"))
	{
		tooltip, Not assigned yet...`n%a_linefile%`n @ Line: %A_linenumber%
		SetTimer, RemoveToolTip, -2000 
		return
	}
if (GetKeyState("Lwin", "P") && GetKeyState("Shift", "P"))
	{
		tooltip, Not assigned yet...`n%a_linefile%`n @ Line: %A_linenumber%
		SetTimer, RemoveToolTip, -2000 
		return
	}
if (GetKeyState("Control", "P"))
	{
		tooltip, Not assigned yet...`n%a_linefile%`n @ Line: %A_linenumber%
		SetTimer, RemoveToolTip, -2000 
		return
	}
if (GetKeyState("Shift", "P"))
	{
		tooltip, Not assigned yet...`n%a_linefile%`n @ Line: %A_linenumber%
		SetTimer, RemoveToolTip, -2000 
		return
	}
else ;; normal click
	{

	}

