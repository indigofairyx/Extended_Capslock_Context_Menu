Gui, Add, Button, XM vReload gReload , &Reload
GuiControlGet, hwndReload , Hwnd, Reload
DllCall("uxtheme\SetWindowTheme", "ptr", hwndReload , "str", "DarkMode_Explorer", "ptr", 0)
Gui, Add, Button, X+M vedit geditscript , &Edit
GuiControlGet, hwndedit , Hwnd, edit
DllCall("uxtheme\SetWindowTheme", "ptr", hwndedit , "str", "DarkMode_Explorer", "ptr", 0)

reload:
tooltip %A_scriptname%`n  reloading...
sleep 900
tooltip
reload
return
editscript:
run %texteditor% "%A_ScriptFullPath%"
return