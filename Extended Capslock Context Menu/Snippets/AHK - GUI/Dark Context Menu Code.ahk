contextcolor() ;0=Default ;1=AllowDark ;2=ForceDark ;3=ForceLight ;4=Max
contextcolor(color:=2)
	{
    static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
    static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
    static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
    DllCall(SetPreferredAppMode, "int", color)
    DllCall(FlushMenuThemes)
	}