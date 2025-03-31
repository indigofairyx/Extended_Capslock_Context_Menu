Pin := 1 ; IN autoexe
gui, +AlwaysOnTop
gui, add, checkbox, NEEDSPOSHERE gunpin vpin checked, Pin\Unpin to Top
unpin:
gui, submit, nohide
if (pin)
	Gui, +alwaysontop
else
	Gui, -alwaysontop
return