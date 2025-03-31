Run, %A_ThisMenuItem%,,UseErrorLevel
if ErrorLevel
{
	run, C:\Windows\System32\OpenWith.exe "%A_ThisMenuItem%"
	Tooltip, ERR!`n`n Couldn't Run This File!`n @ Line#:  %A_LineNumber%`n %A_LineFile%
	SetTimer, RemoveToolTip, -3000
	; Return
}