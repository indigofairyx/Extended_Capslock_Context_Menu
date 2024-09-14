; !NOTE This Script is not set to run as admin, if you need it to delete the " ; " at the front of the next two lines
 ; If !A_IsAdmin
 ; 	 Run *RunAs "%A_ScriptFullPath%"

#warn  ; enable warning to assist with detecting common errors.
#SingleInstance, Force
#NoEnv
#Persistent ; Keeps a script permanently running (that is, until the user closes it or ExitApp is encountered)
#InstallKeybdHook
#InstallMouseHook
SetBatchLines -1  ; Run the script at maximum speed.
SetWinDelay, -1
CoordMode, Mouse, Screen
SendMode Input

SetWorkingDir,%A_ScriptDir%
filePath := A_ScriptFullPath

FormatTime, A_Time,, Time
FormatTime, A_ShortDate,, ShortDate
FormatTime, A_LongDate,, LongDate
FormatTime, A_YY,, yy
formattime, A_HH,, HH 
formattime, A_tt,, tt
{
    Date := A_Now
    List := DateFormats(Date)
    TextMenuDate(List)
}
StartTime := A_TickCount
ScriptVersion := "v.2024.09.13-2"
ScriptName := "Extended CAPS Context Menu"
url := "https://www.github.com/indigofairyx"
dittourl := "https://github.com/sabrogden/Ditto"
everuthingurl := "https://www.voidtools.com/forum/viewtopic.php?t=9787"
autocorrecturl := "https://github.com/BashTux1/AutoCorrect-AHK-2.0"
textifyurl := "https://ramensoftware.com/textify"
Textgraburl := "https://github.com/TheJoeFin/Text-Grab/"
notepadppurl := "https://github.com/notepad-plus-plus/notepad-plus-plus"


SetCapsLockState, off  ; might be a good idea to run this on script start up
CapsGuiToggle := false

;;;;;;; DARK MODE ;;;;;;; Change the values below to change the color of the menu.
DarkMode := true ; set initial mode to light
MenuDark()
; 0=Default  1=AllowDark  2=ForceDark  3=ForceLight  4=Max

;;;;;;;;;;;;;;;;;;;;;;;;;


MenuDark(Dark:=2) { ;<=--<=CHANGE DEFAULT TO DARK MODE (make it the default)
    ;https://stackoverflow.com/a/58547831/894589
    static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
    static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
    static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")

    DllCall(SetPreferredAppMode, "int", Dark) ; 0=Default  1=AllowDark  2=ForceDark  3=ForceLight  4=Max
    DllCall(FlushMenuThemes)
}

menu, tray, icon, %A_ScriptDir%\Images\keyboard-caps-lock-filled xfav arrow send move_256x256.ico
menu, tray, add, ; line ;------------------------- 
menu, tray, add, View About && Hotkeys, aboutwindow
menu, tray, icon, View About && Hotkeys, %A_ScriptDir%\Images\about_48x48.ico


;;; go capslock menu, go case menu, START  caps menu, capsmenu, go menu, case
; menu, Case, Add


menu, case, add, ; top line ;-------------------------
menu, Case, DeleteAll

Menu Case, Add, CAPSLOCK MENU TOGGLE, ToggleCapsLock
Menu Case, icon, CAPSLOCK MENU TOGGLE, %A_ScriptDir%\Images\keyboard-caps-lock-filled xfav arrow send move_256x256.ico
Menu, Case, Default, CAPSLOCK MENU TOGGLE

menu, case, add, ; top line ;-------------------------
; menu, Case, DeleteAll

menu, Case, Add, UPPERCASE, Upper
menu, Case, Add, lowercase, Lower
menu, Case, Add, Title Case, Title
menu, Case, Add, Sentence case, Sentence
menu, case, add, ; line ;-------------------------

menu, ctxt, add
menu, ctxt, DeleteAll
Menu, ctxt, Add, Capital Case, Capital
menu, ctxt, add, Reverse,  Reverse
Menu, ctxt, Add, iNVERT cASE, Invert
menu, ctxt, add, ; line
menu, ctxt, add, Remove  Extra   Spaces, RemoveExtraS
menu, ctxt, Add, Remove ALL Spaces, RASpace
menu, ctxt, icon, Remove ALL Spaces, %A_ScriptDir%\Images\sc_gluepercent_16x16.ico
Menu, ctxt, add, S p r e a d T e x t, spread ; ccase ; spread case
menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, Add, PascalCase, Pascal
Menu, ctxt, Add, camelCase, camel
Menu, ctxt, Add, aLtErNaTiNg cAsE, Alternating
menu, ctxt, add, ;line ;-------------------------
Menu, ctxt, Add, Space to Dot.Case, Dot
Menu, ctxt, Add, Space to Snake_Case, Snake
Menu, ctxt, Add, Space to Kebab-Case, Kebab
menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, add, Fix Linebreaks, FixLineBreaks

menu, case, add, More Convert Case..., :ctxt
menu, case, icon, More Convert Case..., %A_ScriptDir%\Images\richtext_editor__32x32.ico
menu, Case, Add ; line ;-------------------------
menu, Case, Add, Put in "Quotes", ClipQuote
menu, Case, icon, Put in "Quotes", %A_ScriptDir%\Images\format quote_24x24.ico
menu, Case, add, Put in `{Curly Brackets`}, wrapincbrackets
menu, Case, icon, Put in `{Curly Brackets`}, %A_ScriptDir%\Images\coding code json filetype_24x24.ico


menu, cform, add ; line  ;-------------------------
menu, cform, deleteall
menu, cform, add, Put in `/`* Block Comment `*`/, commentblock
menu, cform, add, Put in (Parentheses), wrapparen
menu, cform, add, Put in [Square Brackets], squbracket
menu, cform, Add, Put in ``Code - `Inline``, CodeLine
menu, cform, Add, Put in ``````Code - Box``````, CodeBox
menu, cform, icon, Put in ``````Code - Box``````, %A_ScriptDir%\Images\selection text code Resources_200_24x24.ico
menu, cform, add, Put in `<`!-- xml Comment --`>, wrapinxmlcomment
menu, cform, add, ; line ;------------------------- '
menu, cform, Add, Add &More Formatting, Addmore
menu, cform, icon, Add &More Formatting, %A_ScriptDir%\Images\notepad++_100.ico
menu, case, add, Code Formatting..., :cform
menu, case, icon, Code Formatting..., %A_ScriptDir%\Images\code spark xfav function_256x256.ico

menu, case, add ; line ;-------------------------

; menu, cfind, deleteall
menu, cfind, add, Google This, googlethis
menu, cfind, icon, Google This, %A_ScriptDir%\Images\google_96x96.ico
menu, cfind, add, Youtube This, youtubethis
menu, cfind, icon, Youtube This, %A_ScriptDir%\Images\youtube_64x64.ico
menu, cfind, add, AHK Syntax Search, ahksearch
menu, cfind, icon, AHK Syntax Search, %A_ScriptDir%\Images\www.autohotkey.com website favcon_48x48.ico
menu, cfind, add, Find Locally with Everything, Findwitheverything
menu, cfind, icon, Find Locally with Everything, %A_ScriptDir%\Images\voidtools-15-Everything-1.5.ico
menu, cfind, add, Search in System Index, evindex
menu, cfind, icon, Search in System Index, %A_ScriptDir%\Images\office search find content everything -document-viewer_32x32.ico
menu, cfind, add, Look up on Dictionary.com, Dictionarydotcom
menu, case, add, Search Selected Text..., :cfind
menu, case, icon, Search Selected Text..., %A_ScriptDir%\Images\search find Windows 11 Icon 13_256x256.ico

menu, case, add, ; line ;-------------------------
menu, Case, add, Insert Date..., :dtmenu
menu, Case, icon, Insert Date..., %A_ScriptDir%\Images\clock SHELL32_16771 256x256.ico
Menu, case, Add, Open Emoji Keyboard, OpenEmojiKeyboard
Menu, case, icon, Open Emoji Keyboard, %A_ScriptDir%\Images\emoji-face people_256x256.ico
menu, Case, Add ; line ;-------------------------

; menu, ctools, deleteall
menu, ctools, add, Copy Selection To New Document, newtxtfile
menu, ctools, icon, Copy Selection To New Document, %A_ScriptDir%\Images\document new text txt add FLUENT_colored_454_64x64.ico
menu, ctools, add, Quick Save NewFile.txt, autotxtfile
menu, ctools, icon, Quick Save NewFile.txt, %A_ScriptDir%\Images\lc_savebasicas_26x26.ico
menu, ctools, add, Open Quick Notes Dir, openquick
menu, ctools, icon, Open Quick Notes Dir, C:\Windows\System32\imageres.dll, 265
menu, ctools, add, ; line ;-------------------------
menu, ctools, add, Save Clipboard to New Document, SaveClipboardAsTxt
menu, ctools, icon, Save Clipboard to New Document, C:\xsysicons\Fluent Colored icons\Dopus FLUENT Icon Set\document rename FLUENT_colored_453_64x64.ico
menu, ctools, add, View Clipboard, viewclip
menu, ctools, icon, View Clipboard, %A_ScriptDir%\Images\message Magic Box.ico
menu, ctools, add, Clear Clipboard, clearclip
menu, ctools, icon, Clear Clipboard, %A_ScriptDir%\Images\clean broom sweep icon.ico


menu, ctools, add, ; line ;------------------------- 
Menu, ctools, Add, Dark Mode | Light Mode, DMToggle
Menu, ctools, icon, Dark Mode | Light Mode, %A_ScriptDir%\Images\darkmodetoggleshell32_284_48x48.ico
menu, ctools, add, About, aboutwindow
menu, ctools, icon, About, %A_ScriptDir%\Images\about_48x48.ico
MENU, ctools, add, Debug Lines, lines
menu, ctools, icon, Debug Lines, %A_ScriptDir%\Images\bug report FLUENT_colored_217_64x64.ico
menu, ctools, add, ; line ;-------------------------
MENU, ctools, add, Run AHK Auto Correct, abc
MENU, ctools, icon, Run AHK Auto Correct, %A_ScriptDir%\Images\autocorrect_icon_32x32.ico
menu, ctools, add, ; line ;------------------------- 
menu, ctools, add, Ditto Clipboard, dittobutton
menu, ctools, icon, Ditto Clipboard, %A_ScriptDir%\Images\ditto quote clipboard 128x128.ico
menu, ctools, add, Textify, TextifyButton
menu, ctools, icon, Textify, %A_ScriptDir%\Images\textify 128x128.ico
menu, ctools, add, Text Grab, runtextgrab
menu, ctools, icon, Text Grab, %A_ScriptDir%\Images\text grab v4 128x128.ico
menu, ctools, add, Notepad++, runnotepad
menu, ctools, icon, Notepad++, %A_ScriptDir%\Images\notepad++_100.ico
menu, ctools, add, ; line ;------------------------- 
menu, ctools, add, Exit Script, exitscript
menu, ctools, icon, Exit Script,  C:\Windows\System32\imageres.dll, 94 

menu, case, add, Text Tools && Apps, :ctools
menu, case, icon, Text Tools && Apps, %A_ScriptDir%\Images\Pencil and Ruler__32x32.ico

menu, case, add ; line ;-------------------------
menu, Case, Add, Copy, basiccopy
menu, Case, icon, Copy, %A_ScriptDir%\Images\edit-copy_32x32.ico
menu, case, add, Copy + Add to Clipboard, appendclip
menu, case, icon, Copy + Add to Clipboard, %A_ScriptDir%\Images\clipboard--plus_16x16.ico
Menu, Case, add, Cut, basiccut
menu, case, icon, Cut, %A_ScriptDir%\Images\edit-cut_32x32.ico
menu, case, add, Paste, basicpaste
menu, case, icon, Paste, %A_ScriptDir%\Images\edit-paste_256x256.ico
MENU, case, ADD, Paste As Plain Text, pasteplain

menu, case, add ; line ;-------------------------
menu, case, add, Close This Menu, ExitMenu
menu, case, icon, Close This Menu, %A_ScriptDir%\Images\aero Close_24x24-32b.ico
; menu, Case, DeleteAll



;; Date time menu ( bound to cpaslock\case menu)
TextMenuDate(TextOptions)
{
 StringSplit, MenuItems, TextOptions , |
 Loop %MenuItems0%
  {
    Item := MenuItems%A_Index%
    Menu, dtmenu, add, %Item%, dtMenuAction
    ; Menu, dtmenu, add, %Date%, dtMenuAction ; xadd
  }
 ; menu, dtmenu, add ; line ;-------------------------
 ; Menu, dtMenu, DeleteAll
 ; menu, dtmenu, add, &Exit This Menu, ExitMenu
 ; Menu, dtmenu, icon, &Exit This Menu, %A_ScriptDir%\Images\aero Close_24x24-32b.ico
 ; Menu, dtMenu, Show
;;;; X NOTE - I can add addiional submenu items here
}

DateFormats(Date)
{
local
static
  FormatTime, OutputVar , %Date%, h:mm tt ;12 hour clock
  List := OutputVar
  FormatTime, OutputVar , %Date%, HH:mm tt ;24 hour clock
  List := List . "|" . OutputVar
  FormatTime, OutputVar , %Date%, ShortDate ; 9/5/2015
  List := List . "|" . OutputVar
  FormatTime, OutputVar , %Date%, MM/dd/yy ; 09/05/2015
  List := List . "|" . OutputVar
  FormatTime, OutputVar , %Date%, MMMM d, yyyy ; August 26, 2024
  List := List . "|" . OutputVar
  FormatTime, OutputVar , %Date%, LongDate ; Monday, August 26, 2024
  List := List . "|" . OutputVar
  FormatTime, OutputVar, %Date%, dddd, MMMM d, yyyy, h:mm tt  ; Friday, September 6, 2024, 9:46 PM
  List := List . "|" . OutputVar
  FormatTime, OutputVar, %Date%, dddd, MMMM d, yyyy, hh:mm:ss tt ; Friday, September 6, 2024, 09:46:41 PM
  List := List . "|" . OutputVar
  FormatTime, OutputVar, %Date%, %A_now% ; 20240826165553
  List := List . "|" . OutputVar
   FormatTime, OutputVar, %Date%, dddd ; Monday
  List := List . "|" . OutputVar
   FormatTime, OutputVar, %Date%, MMMM ; August
  List := List . "|" . OutputVar
  Return List
}
;;; end case menu, end capslock  menu, end date menu


return


;---------------------- CAPS LOCK BANNER -----------------------------------------------------------
;----------------------------------------------------------------------------------------------------
/***
        ; CCCCCCCCCCCCC               AAA               PPPPPPPPPPPPPPPPP      SSSSSSSSSSSSSSS lllllll                                      kkkkkkkk
     ; CCC↑↑↑↑↑↑↑↑↑↑↑↑C              A↑↑↑A              P↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑P   SS↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑Sl↑↑↑↑↑l                                      k↑↑↑↑↑↑k
   ; CC↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑C             A↑↑↑↑↑A             P↑↑↑↑↑↑PPPPPP↑↑↑↑↑P S↑↑↑↑↑SSSSSS↑↑↑↑↑↑Sl↑↑↑↑↑l                                      k↑↑↑↑↑↑k
  ; C↑↑↑↑↑CCCCCCCC↑↑↑↑C            A↑↑↑↑↑↑↑A            PP↑↑↑↑↑P     P↑↑↑↑↑PS↑↑↑↑↑S     SSSSSSSl↑↑↑↑↑l                                      k↑↑↑↑↑↑k
 ; C↑↑↑↑↑C       CCCCCC           A↑↑↑↑↑↑↑↑↑A             P↑↑↑↑P     P↑↑↑↑↑PS↑↑↑↑↑S             l↑↑↑↑l    ooooooooooo       cccccccccccccccc k↑↑↑↑↑k    kkkkkkk
; C↑↑↑↑↑C                        A↑↑↑↑↑A↑↑↑↑↑A            P↑↑↑↑P     P↑↑↑↑↑PS↑↑↑↑↑S             l↑↑↑↑l  oo↑↑↑↑↑↑↑↑↑↑↑oo   cc↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑c k↑↑↑↑↑k   k↑↑↑↑↑k
; C↑↑↑↑↑C                       A↑↑↑↑↑A A↑↑↑↑↑A           P↑↑↑↑PPPPPP↑↑↑↑↑P  S↑↑↑↑SSSS          l↑↑↑↑l o↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑o c↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑c k↑↑↑↑↑k  k↑↑↑↑↑k
; C↑↑↑↑↑C                      A↑↑↑↑↑A   A↑↑↑↑↑A          P↑↑↑↑↑↑↑↑↑↑↑↑↑PP    SS↑↑↑↑↑↑SSSSS     l↑↑↑↑l o↑↑↑↑↑ooooo↑↑↑↑↑oc↑↑↑↑↑↑↑cccccc↑↑↑↑↑c k↑↑↑↑↑k k↑↑↑↑↑k
; C↑↑↑↑↑C                     A↑↑↑↑↑A     A↑↑↑↑↑A         P↑↑↑↑PPPPPPPPP        SSS↑↑↑↑↑↑↑↑SS   l↑↑↑↑l o↑↑↑↑o     o↑↑↑↑oc↑↑↑↑↑↑c     ccccccc k↑↑↑↑↑↑k↑↑↑↑↑k
; C↑↑↑↑↑C                    A↑↑↑↑↑AAAAAAAAA↑↑↑↑↑A        P↑↑↑↑P                   SSSSSS↑↑↑↑S  l↑↑↑↑l o↑↑↑↑o     o↑↑↑↑oc↑↑↑↑↑c              k↑↑↑↑↑↑↑↑↑↑↑k
; C↑↑↑↑↑C                   A↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑A       P↑↑↑↑P                        S↑↑↑↑↑S l↑↑↑↑l o↑↑↑↑o     o↑↑↑↑oc↑↑↑↑↑c              k↑↑↑↑↑↑↑↑↑↑↑k
 ; C↑↑↑↑↑C       CCCCCC    A↑↑↑↑↑AAAAAAAAAAAAA↑↑↑↑↑A      P↑↑↑↑P                        S↑↑↑↑↑S l↑↑↑↑l o↑↑↑↑o     o↑↑↑↑oc↑↑↑↑↑↑c     ccccccc k↑↑↑↑↑↑k↑↑↑↑↑k
  ; C↑↑↑↑↑CCCCCCCC↑↑↑↑C   A↑↑↑↑↑A             A↑↑↑↑↑A   PP↑↑↑↑↑↑PP          SSSSSSS     S↑↑↑↑↑Sl↑↑↑↑↑↑lo↑↑↑↑↑ooooo↑↑↑↑↑oc↑↑↑↑↑↑↑cccccc↑↑↑↑↑ck↑↑↑↑↑↑k k↑↑↑↑↑k
   ; CC↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑C  A↑↑↑↑↑A               A↑↑↑↑↑A  P↑↑↑↑↑↑↑↑P          S↑↑↑↑↑↑SSSSSS↑↑↑↑↑Sl↑↑↑↑↑↑lo↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑o c↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ck↑↑↑↑↑↑k  k↑↑↑↑↑k
     ; CCC↑↑↑↑↑↑↑↑↑↑↑↑C A↑↑↑↑↑A                 A↑↑↑↑↑A P↑↑↑↑↑↑↑↑P          S↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑SS l↑↑↑↑↑↑l oo↑↑↑↑↑↑↑↑↑↑↑oo   cc↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ck↑↑↑↑↑↑k   k↑↑↑↑↑k
        ; CCCCCCCCCCCCCAAAAAAA                   AAAAAAAPPPPPPPPPP           SSSSSSSSSSSSSSS   llllllll   ooooooooooo       cccccccccccccccckkkkkkkk    kkkkkkk
 */
 
;------------------------- CAPS KEY FUCNCTIONS--------CAPSLOCK-------------------------------------
;------------------------------ capslock menu -----------------------------------------------------




CopyClipboardCLM() ;; function
{
    global ClipSaved  ; Ensure global is used if ClipSaved is accessed elsewhere
    ClipSaved := ClipboardAll  ; Save the current clipboard contents
	sleep 750
    Clipboard := ""  ; Clear the clipboard
    Sleep 200  ; Adjust the sleep time if needed
    Send ^{vk43}  ; Send Ctrl+C
    ClipWait, 1.5  ; Wait for the clipboard to contain data
    if ErrorLevel
    {
        TrayTip, CAPSkey, Copy to clipboard failed!, 4, 18
		Clipboard := ClipSaved  ; Restore the clipboard
        return
    }
}

PasteClipboardCLM() ;; function
{
    global ClipSaved ; Use a similar approach as in CopyClipboardCLM
    Send ^v  ; Send Ctrl+V
    Sleep 200  ; Give the system time to paste the clipboard content
    Clipboard := ClipSaved  ; Restore the saved clipboard contents
    ClipSaved := ""  ; Clear the variable
}


PastePlain()
{
local
    ClipSaved := ClipboardAll  ; save original clipboard contents
	sleep 400
    Clipboard := Clipboard  ; remove formatting
	sleep 150
    Send ^v  ; send the Ctrl+V command
    Sleep 100  ; give some time to finish paste (before restoring clipboard)
    Clipboard := ClipSaved  ; restore the original clipboard contents
    ClipSaved := ""  ; clear the variable
}

Upper()
{
    CopyClipboardCLM()
    StringUpper, Clipboard, Clipboard
    PasteClipboardCLM()
}

Lower()
{
    CopyClipboardCLM()
    StringLower, Clipboard, Clipboard
    PasteClipboardCLM()
}
Title()
{
    ExcludeList := ["a", "about", "above", "after", "an", "and", "as", "at", "before", "but", "by", "for", "from", "nor", "of", "or", "so", "the", "to", "via", "with", "within", "without", "yet"]
    ExactExcludeList := ["AutoHotkey", "iPad", "iPhone", "iPod", "OneNote", "USA"]
    CopyClipboardCLM()
    TitleCase := Format("{:T}", Clipboard)
    for _, v in ExcludeList
        TitleCase := RegexReplace(TitleCase, "i)(?<!\. |\? |\! |^)(" v ")(?!\.|\?|\!|$)\b", "$L1")
    for _, v in ExactExcludeList
        TitleCase := RegExReplace(TitleCase, "i)\b" v "\b", v)
    TitleCase := RegexReplace(TitleCase, "im)\b(\d+)(st|nd|rd|th)\b", "$1$L{2}")
    Clipboard := TitleCase
    PasteClipboardCLM()
}
Sentence()
{
    ExactExcludeList := ["AutoHotkey", "iPad", "iPhone", "iPod", "OneNote", "USA"]
    CopyClipboardCLM()
    StringLower, Clipboard, Clipboard
    ; Clipboard := RegExReplace(Clipboard, "(((^|([.!?]\s+))[a-z])| I | I')", "$u1")  ;og line from caps_menu
	Clipboard := RegExReplace(Clipboard, "((?:^|\R|[.!?]\s+)[a-z])|(\bi\b)|(\bi'\b)", "$u1") ; added by gpt not inclding this last one  --> Func("Capitalize"))
    ; Clipboard := RegExReplace(Clipboard, "((?:^|[.!?]\s+)[a-z])", "$u1")  ; fastkeys
    for _, v in ExactExcludeList
        Clipboard := RegExReplace(Clipboard, "i)\b" v "\b", v)
    PasteClipboardCLM()
}

Invert()
{
    CopyClipboardCLM()
    Inv_Char_Out := ""
    Loop % StrLen(Clipboard)
    {
        Inv_Char := SubStr(Clipboard, A_Index, 1)
        if Inv_Char is Upper
            Inv_Char_Out := Inv_Char_Out Chr(Asc(Inv_Char) + 32)
        else if Inv_Char is Lower
            Inv_Char_Out := Inv_Char_Out Chr(Asc(Inv_Char) - 32)
        else
            Inv_Char_Out := Inv_Char_Out Inv_Char
    }
    Clipboard := Inv_Char_Out
    PasteClipboardCLM()
}

camel()
{
    CopyClipboardCLM()
    StringUpper, Clipboard, Clipboard, T
    FirstChar := SubStr(Clipboard, 1, 1)
    StringLower, FirstChar, FirstChar
    camelCase := SubStr(Clipboard, 2)
    camelCase := StrReplace(camelCase, A_Space)
    Clipboard := FirstChar camelCase
    PasteClipboardCLM()
}
Pascal()
{
    CopyClipboardCLM()
    StringUpper, Clipboard, Clipboard, T
    Clipboard := StrReplace(Clipboard, A_Space)
    PasteClipboardCLM()
}

Capital()
{
    ExactExcludeList := ["AutoHotkey", "iPad", "iPhone", "iPod", "OneNote", "USA"]
    CopyClipboardCLM()
    CapitalCase := Format("{:T}", Clipboard)
    for _, v in ExactExcludeList
        CapitalCase := RegExReplace(CapitalCase, "i)\b" v "\b", v)
    Clipboard := CapitalCase
    PasteClipboardCLM()
}

Alternating()
{
    CopyClipboardCLM()
sleep 200
    Inv_Char_Out := ""
    StringLower, Clipboard, Clipboard
    Loop, Parse, Clipboard
    {
        if (Mod(A_Index, 2) = 0)
            Inv_Char_Out .= Format("{1:U}", A_LoopField)
        else
            Inv_Char_Out .= Format("{1:L}", A_LoopField)
    }
    Clipboard := Inv_Char_Out
sleep 175
    PasteClipboardCLM()
}


Dot()
{
    CopyClipboardCLM()
	sleep 300
    if RegExMatch(Clipboard, "\-|\_|\.") != "0"
    {
        Clipboard := RegExReplace(Clipboard, "\-|\_|\.", " ")
		sleep 200
        PasteClipboardCLM()
    }
    else
    {
        Clipboard := StrReplace(Clipboard, A_Space, ".")
		sleep 200
        PasteClipboardCLM()
    }
}

Snake()
{
    CopyClipboardCLM()
	sleep 300
    if RegExMatch(Clipboard, "\-|\_|\.") != "0"
    {
        Clipboard := RegExReplace(Clipboard, "\-|\_|\.", " ")
		sleep 200
        PasteClipboardCLM()
    }
    else
    {
        Clipboard := StrReplace(Clipboard, A_Space, "_")
sleep 200
        PasteClipboardCLM()
    }
}

Kebab()
{
    CopyClipboardCLM()
	sleep 300
    if RegExMatch(Clipboard, "\-|\_|\.") != "0"
    {
        Clipboard := RegExReplace(Clipboard, "\-|\_|\.", " ")
		sleep 200
        PasteClipboardCLM()
    }
    else
    {
        Clipboard := StrReplace(Clipboard, A_Space, "-")
		sleep 200
        PasteClipboardCLM()
    }
}

FixLineBreaks()
{
    CopyClipboardCLM()
	Clipboard := RegExReplace(Clipboard, "\R", "`r`n")
	sleep 300
    PasteClipboardCLM()
}

removeextras()
{
    CopyClipboardCLM()
	Loop
		{
		StringReplace, Clipboard, Clipboard, %A_Space%%A_Space%, %A_Space%, UseErrorLevel
		if ErrorLevel = 0
		    break
		}
    PasteClipboardCLM()
}

wrapparen()
{
    CopyClipboardCLM()
	  Clipboard := RegExReplace(Clipboard, "\s+$")   ;gets rid of whitespace at end
      Clipboard := "(" Clipboard ")"
    PasteClipboardCLM()
}


squbracket()
{
    CopyClipboardCLM()
	  Clipboard := RegExReplace(Clipboard, "\s+$")   ;gets rid of whitespace at end
      Clipboard := "[" Clipboard "]"
    PasteClipboardCLM()
}

Reverse()
{
    CopyClipboardCLM()
	temp2 =
	  StringReplace, Clipboard, Clipboard, `r`n, % Chr(29), All
      Loop Parse, Clipboard
      temp2 := A_LoopField . temp2     ; Temp2
      StringReplace, Clipboard, temp2, % Chr(29), `r`n, All
    PasteClipboardCLM()
}

OpenEmojiKeyboard()
{
    Send {LWin down}.
    Send {LWin up}
}

spread()
{
    CopyClipboardCLM()
	Clipboard := RegExReplace(Clipboard, "(?<=.)(?=.)", " ")
    PasteClipboardCLM()
}




clearclip:
run, cmd /C "echo off | clip"
return

viewclip:
msgbox, %clipboard%
return


basiccopy:
Send ^{vk43} ;Ctrl C ; SendInput, ^c Send {Ctrl down}c{Ctrl up}  ; Send ^{vk43}
return

basiccut:
SendInput, ^x
return

basicpaste:
Send ^{vk56} ;Ctrl V ; SendInput, ^v
return

appendclip:
{
    SavedClip := ClipboardAll ; Save the current clipboard content
    Clipboard := ""  ; Clear the clipboard to capture new content
    Sleep 175  ; Ensure enough time for clipboard to clear
    Send ^c ; Send Ctrl+C to copy the selected text
    ClipWait, 1  ; Wait for clipboard to be filled with new text

    if !ErrorLevel
    {
        NewText := Clipboard  ; Get the copied text ; If text is successfully copied, append it to the clipboard
        Clipboard := SavedClip  ; Restore the original clipboard content
        Clipboard := Clipboard . "`n`n" NewText  ; Append the new text to the existing content
        Sleep 150  ; Allow time for clipboard to update
    }
    else
    {
        Clipboard := SavedClip ; If no text was copied, restore the original clipboard content
    }
    ; MsgBox, Text has been appended to the clipboard! ; Optional: Notify the user that text was appended
    return
}
return

Lines:
listlines
return


wrapincbrackets:
{
SavedClip := ClipboardAll
sleep 300
Clipboard =
sleep 300
Send ^{vk43} ;Ctrl C
ClipWait 1
Tmp:=Clipboard
Tmp = `{`n%Tmp%`n`}
Clipboard =
Sleep 300
Clipboard := Tmp
Send ^{vk56} ;Ctrl V
Sleep 100
Clipboard := SavedClip
sleep 100
return
}
return


commentblock:
{
SavedClip := ClipboardAll
sleep 200
Clipboard =
sleep 300
Send ^{vk43} ;Ctrl C
ClipWait 1
Tmp:=Clipboard
Tmp = `/`*`n`n %Tmp% `n`n`*`/
Clipboard =
Sleep 75
Clipboard := Tmp
Send ^{vk56} ;Ctrl V
Sleep 100
Clipboard := SavedClip
return
}
return

wrapinxmlcomment:
{
SavedClip := ClipboardAll
sleep 200
Clipboard =
sleep 200
Send ^{vk43} ;Ctrl C
ClipWait 1
Tmp:=Clipboard
Tmp = <`!-- %Tmp% -->
Clipboard =
Sleep 20
Clipboard := Tmp
Send ^{vk56} ;Ctrl V
Sleep 100
Clipboard := SavedClip
return
}
return


CodeLine:
{
SavedClip := ClipboardAll
sleep 200
Clipboard =
sleep 200
Send ^{vk43} ;Ctrl C
ClipWait 1
Tmp:=Clipboard
Tmp = ``%Tmp%``
Clipboard =
Sleep 75
Clipboard := Tmp
Send ^{vk56} ;Ctrl V
Sleep 100
Clipboard := SavedClip
return
}
return


CodeBox:
{
SavedClip := ClipboardAll
sleep 200
Clipboard =
sleep 200
Send ^{vk43} ;Ctrl C
ClipWait 1
Tmp := Clipboard
Tmp = ```````n%Tmp%`n``````
Clipboard =
Sleep 20
Clipboard := Tmp
Send ^{vk56} ;Ctrl V
Sleep 100
Clipboard := SavedClip
return
}
return


;-------------------------

Addmore:
{
run, "notepad.exe" "%filePath%" ; "`%1"
; WinWaitActive, Notepad
sleep 2000
send, ^f
sleep 300
send, cform
sleep 200
send {enter}
}
return

RASpace:
SavedClip := ClipboardAll
sleep 200
Clipboard =
sleep 200
Send ^{vk43} ;Ctrl C
ClipWait 1
TempText:=Clipboard
sleep 175
Loop
{
 StringReplace, TempText, TempText, %A_Space%,, UseErrorLevel ;%A_Space%%A_Space%
 if ErrorLevel = 0
   break
}
Clipboard =
Sleep 175
Clipboard := TempText
Send ^{vk56} ;Ctrl V
Sleep 175
Clipboard := SavedClip
Return


googlethis:
{
        OldClipboard := ClipboardAll  ; Save the current clipboard content
        Clipboard := ""  ; Clear the clipboard to prepare for new content
		sleep 175
        Send, ^c
        ClipWait 1 ; Wait for the clipboard to contain data
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := OldClipboard
        }
        Run, http://www.google.com/search?q=%Clipboard%
        Sleep 200
        Clipboard := OldClipboard ; Restore the original clipboard content

}
Return
youtubethis:
{
        OldClipboard := ClipboardAll  ; Save the current clipboard content
        Clipboard := ""  ; Clear the clipboard to prepare for new content
		sleep 175
        Send, ^c
        ClipWait 1 ; Wait for the clipboard to contain data
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := OldClipboard
        }
        Run, http://www.youtube.com/search?q=%Clipboard%
        Sleep 200
        Clipboard := OldClipboard ; Restore the original clipboard content
}
return

ahksearch:
{
; = "https://www.google.com/search?q=site:ahkscript.org+$(Currentselection)"
; = "https://www.google.com/search?q=site:ahkscript.org+$(Currentselection)"
;; run, https://www.autohotkey.com/search/?q=%Find%
        OldClipboard := ClipboardAll  ; Save the current clipboard content
        Clipboard := ""  ; Clear the clipboard to prepare for new content
sleep 175
        Send, ^c
        ClipWait  ; Wait for the clipboard to contain data
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := OldClipboard
        }
        ; Run, https://www.autohotkey.com/search/?q=%Clipboard%
		run, "https://www.google.com/search?q=site:autohotkey.com+%Clipboard%"
        Sleep 200
        Clipboard := OldClipboard ; Restore the original clipboard content

}
return

^+':: ;paste clipboard text in "Quotes"
	saved := clipboard ; save clipboard contents
	Send, "%clipboard%" ; send clipboard content with your characters around it
	clipboard := saved ; restore clipboard
	saved := () ; clear saved
Return

^':: ;'Put selected text in "Quotes"
ClipQuote:
{
SavedClip := ClipboardAll
sleep 175
Clipboard =
sleep 75
Send ^{vk43} ;Ctrl C
ClipWait 1
Tmp:=Clipboard
Tmp = "%Tmp%"
;;;;;;;; Remove space introduced by WORD
StringReplace, Tmp, Tmp,%A_SPACE%",", All
Clipboard = Tmp
Sleep 20
Clipboard := Tmp
Send ^{vk56} ;Ctrl V
Sleep 100
Clipboard := SavedClip
return
}
return

+CapsLock::    ; Switch between UPPERCASE & lowercase
{
  origClipboard=%clipboard%
  clipboard=
sleep 200
  SendInput, ^{vk43} ;Ctrl C
  ClipWait, 2
  if not ErrorLevel
  {
    allCapsBool=1
    Loop, parse, clipboard
    {
      if A_Loopfield is lower
        allCapsBool = 0
    }
    if allCapsBool
      StringLower, clipboard, clipboard
    else
      StringUpper, clipboard, clipboard
    SendInput, ^{vk56} ;Ctrl V
    Sleep, 350
  }
  clipboard=%origClipboard%
}
return



dtMenuAction:
	; clipboard := ""
	; clipboard := A_ThisMenuItem
	; SendInput %A_ThisMenuItem%{Raw}%A_EndChar%
	SendInput %A_ThisMenuItem%
Return

Dictionarydotcom:  ; added to caps\case menu
SaveClip := ClipboardAll
Clipboard := ""
Send ^{vk43} ;Ctrl C
ClipWait 1
Word := RegExReplace(Clipboard, "[^\w\s]")
Clipboard := SaveClip
SaveClip := ""
Run, http://dictionary.reference.com/browse/%Word%?s=t
return


newtxtfile:
origClipboard=%clipboard%
sleep 150
  clipboard=
  sleep 75
  SendInput, ^{vk43} ;Ctrl C
  ClipWait, 1
  if errorlevel
	 {
        TrayTip, CAPSkey, Copy to clipboard failed.`nAborted Auto Save., 4, 18
		Clipboard := origClipboard  ; Restore the clipboard
        return
    }
   FileSelectFile, SavePath, S16, %A_MyDocuments%, Save Selected Text as a New Document, Text Files (*.txt) ; Prompt for where to save the file
    if SavePath =  ; If no file was selected
        Return
    FileAppend, %Clipboard%, %SavePath%  ; Append clipboard contents to the selected file
	sleep 200
  clipboard=%origClipboard%
msgbox, 4, Selected Text Saved, Your selected text as been saved to...`n`n%SavePath%`n`nWould you like to Edit this file now?`n`nThis popup will auto-close in 5 seconds., 5
	ifmsgbox yes
		run "notepad.exe" "%SavePath%"
	ifmsgbox no
		return
	Ifmsgbox timeout
		return
return

/*
 ; newtxtfile:  ; og newfile, replaced with better options
  ; origClipboard=%clipboard%
  ; clipboard=
  ; SendInput, ^{vk43} ;Ctrl C
  ; ClipWait, 2
  ; inputbox, notename, Create a File Name, Give your new quick note a name.`n`nNo .ext needed. It will be saved as a .txt file, , ,
  ; if (noteName = ""){
	; tooltip, Canceled
	; sleep 1000
	; tooltip
	; return
; }
; fileselectFolder, NoteLocation, *%A_MyDocuments%, 3, Select a folder to Save %notename%.txt in.`n`nIf %notename%.txt already exists, the new content will be appended to the end of the note.
; if (noteLocation = ""){
	; tooltip Canceled - You did not select a valid Location
	; sleep 1000
	; tooltip
	; return
; }
; fileappend,%Clipboard%,%NoteLocation%\%notename%.txt
; msgbox, 4, Edit Now?, Would you like to edit %notename%.txt now?`nThis message box will auto close in 5 seconds., 5
; ifmsgbox, yes
	; run, notepad.exe "%NoteLocation%\%notename%.txt"
; ifmsgbox, no
	; return
; ifmsgbox, timeout
	; return
; sleep 200
  ; clipboard=%origClipboard%
; return 

*/


autotxtfile:
{
  origClipboard=%clipboard%
  sleep 150
  clipboard=
  SendInput, ^{vk43} ;Ctrl C
  ClipWait, 2
  if errorlevel
	 {
        TrayTip, CAPSkey, Copy to clipboard failed.`nAborted Auto Save., 4, 18
		Clipboard := origClipboard  ; Restore the clipboard
        return
    }
  inputbox, notename, Create a File Name, Give your new quick note a name.`n`nNo .ext needed. It will auto-save as a .txt file`nIt will automatically be saved to`n%A_ScriptDir%\Auto Saved Text Notes\, , ,
  if (noteName = ""){
	tooltip, Canceled
	sleep 1000
	tooltip
	return
}
FileCreateDir, Auto Saved Text Notes
sleep 100
fileappend,%Clipboard%,%A_ScriptDir%\Auto Saved Text Notes\%notename%.txt
sleep 300
}
return


openquick:
try run, %A_ScriptDir%\Auto Saved Text Notes\
return

SaveClipboardAsTxt:
    FileSelectFile, SavePath, S16, %A_MyDocuments%, Save Clipboard As, Text Files (*.*) ; Prompt for where to save the file
    if SavePath =  ; If no file was selected
        Return
    
    FileAppend, %Clipboard%, %SavePath%  ; Append clipboard contents to the selected file
    ; MsgBox, Clipboard saved to %SavePath%!
	msgbox, 4, Clipboard Saved, The text in your Clipboard as been saved to...`n`n%SavePath%`n`nWould you like to Edit this file now?`n`nThis popup will auto-close in 5 seconds., 5
	ifmsgbox yes
		run "notepad.exe" "%SavePath%"
	ifmsgbox no
		return
	Ifmsgbox timeout
		return
Return


togglenum:
If (numtoggle := !numtoggle) {
	setnumlockstate, on
	menu, num, togglecheck, Toggle Numlock
	gui, num: hide

	; Menu, case, Rename, Numlock Toggle , Numlock Toggle ON
}
else {
	 setnumlockstate, off
	 menu, num, togglecheck, Toggle Numlock
	 gui, num: Show, x3606 y1572 h405 w185 noactivate
}
return


Capsmenubutton:
; CapsLockMenu()
menu, case, show
return

ToggleCapsLock(){
    return CapsLockey(, true)
}

CapsLockOn(){
    return CapsLockey(true)
}

CapsLockOff(){
    return CapsLockey(false)
}
CapsLockey(state := false, toggle := false)
{
    global CAPSGuiToggle

    ; If toggling, flip the current CapsLock state
    if (toggle)
        state := !GetKeyState("CapsLock", "T")

    ; Set Caps Lock state only if needed (prevents endless toggling)
    currentCapsState := GetKeyState("CapsLock", "T")
    if (state != currentCapsState)
        SetCapsLockState % state

    ; Update GUI text
    currentState := GetKeyState("CapsLock", "T")
    if (currentState)
        GuiControl,, MyText, CapsLock Status: ON
    else
        GuiControl,, MyText, CapsLock Status: OFF

    ; Toggle the GUI visibility
    CAPSGuiToggle := !CAPSGuiToggle
    if (CAPSGuiToggle)
    {
        SoundBeep, 100, 100
        SoundBeep, 200, 200
        ; Gui, caps: Show, x3370 y2059 NoActivate
		guicaps()
    }
    else
    {
        SoundBeep, 200, 100
        SoundBeep, 100, 200
        Gui, caps: Hide
    }
	return
}

; Custom CapsLock handler
$CapsLock::
    KeyWait CapsLock, T0.25
    if ErrorLevel
        Menu, case, Show ; Show a menu on long press
    else
    {
        KeyWait CapsLock, D T0.25
        if ErrorLevel
            CopyClipboardCLM() ; Custom clipboard function
        else
            Send ^v ; Paste clipboard content
    }
    KeyWait CapsLock
return

; Toggle CapsLock state via the GUI function
; *~CapsLock::
!Capslock::
^CapsLock::
ToggleCapsLock()
    ; CapsLockey(false, true)
return




;;;;;;;;;; dark mode toggle
; Case "Dark Mode | Light Mode":
DMToggle:
    If (DarkMode)
    {
        DarkMode := false
        ;Menu, Case, Toggle Mode, Dark Mode
        MenuDark(3) ; Set to ForceLight
	WelcomeTrayTipLight()
    }
    else
    {
        DarkMode := true
        ;Menu, Case, Toggle Mode, Light Mode
        MenuDark(2) ; Set to ForceDark
	WelcomeTrayTipDark()
    }



ExitMenu:
send, {esc}
return

close:
gui, hide
return


;; extra software options ************************************************** 


runtextgrab()
{
try run, Text-Grab.exe
}

Findwitheverything() 
{
			; SavedClip := ClipboardAll
			; Clipboard =
			; Send ^{vk43} ;Ctrl C
			; ClipWait 1
	sleep 200
    Send ^{vk43} ;Ctrl C
    ClipWait 1 ; Wait for the clipboard to contain data
	try Run, C:\Program Files\Everything 1.5a\Everything64.exe
	sleep 500
	send, ^v
return
}


findwitheverything:
Findwitheverything()
return
evindex:
Send ^{vk43} ;Ctrl C
ClipWait 1
runeverything()
winwaitactive, Everything 1.5
sleep 300
send, si*: "%Clipboard%"
return

runeverything() ;; Function

{
SetTitleMatchMode, 2
IfWinExist, Everything 1.5
{
	WinActivate, Everything 1.5
	WinWait, ahk_exe Everything64.exe
	soundbeep, 800,
	Sleep 200
	ControlSend, , ^{L} ;this activates the search bar if its not already selected
}
 else {
	TRY Run, C:\Program Files\Everything 1.5a\Everything64.exe
}
return
}


dittobutton:
try run, Ditto.exe /Open
return

TextifyButton:
try run, Textify.exe
try run, "C:\Users\%A_UserName%\AppData\Local\Programs\Textify\Textify.exe"
return



runnotepad() ;; function
{
SetTitleMatchMode, 2
IfWinExist, Notepad++
{
WinActivate, ahk_class Notepad++

 } else {
	try Run, Notepad++.exe
}
IfWinnotexist, notpad++
	try run, notepad++.exe
	  return
}

abc:
try run, %A_ScriptDir%\AutoCorrect\AutoCorrect_2.0.ahk
return

menureturn:
return

^+r:: ;Reload Script
tooltip, Extended CAPS Menu`nis Reloading...
sleep 500
tooltip 
reload
return

;;;;;;;;;;;;;;;;;;;; Dark Mode Activated GUI Script ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; from Ctrl CapsLock Menu (new, ctrl capslock capslock now - removed ctrl shift capslock).ahk  

WelcomeTrayTipDark() {
    static GuiCreated := 0
    static HwndWelcomeScreen1
    static MonRight, MonBottom
    if !GuiCreated  {
        GuiCreated := 1
        Gui, WelcomeScreen1:New, +AlwaysOnTop -Caption +ToolWindow +HwndHwndWelcomeScreen1 +LastFound -DPIScale +E0x20 ; Clickthrough=E0x20
        Gui, WelcomeScreen1:Margin, 30, 25
        Gui, WelcomeScreen1:Font, s30, Segoe UI
        Gui, WelcomeScreen1:Color, 1A1A1A
        Gui, WelcomeScreen1:Add, Text, y20 clime, Dark Mode Activated   ;, %A_UserName% ; make a text control showing welcome back, (username)
        WinSet, Transparent, 0                              ; set gui transparent
        SysGet, P, MonitorPrimary                           ; get primary monitor number
        SysGet, Mon, MonitorWorkArea, % P                   ; get size of primary monitor
        Gui, WelcomeScreen1:Show, Hide                       ; Show gui
        WinGetPos, X, Y, W, H                               ; get pos of gui
        WinMove, % MonRight - W - 10, % MonBottom - H - 10  ; move gui to bottom right
        WinSet, Region, 0-0 W%W% H%H% R20-20                ; round corners
    }
    Gui, WelcomeScreen1:Show, NA
    bf := Func("AnimateFadeIn").Bind(HwndWelcomeScreen1)
    SetTimer, %bf%, -200
}


WelcomeTrayTipLight() {
    static GuiCreated := 0
    static HwndWelcomeScreen
    static MonRight, MonBottom
    if !GuiCreated  {
        GuiCreated := 1
        Gui, WelcomeScreen:New, +AlwaysOnTop -Caption +ToolWindow +HwndHwndWelcomeScreen +LastFound -DPIScale +E0x20 ; Clickthrough=E0x20
        Gui, WelcomeScreen:Margin, 30, 25
        Gui, WelcomeScreen:Font, s30, Segoe UI
        Gui, WelcomeScreen:Color, white  ;<=--\/---------------COLOR OF BOX / TEXT
        Gui, WelcomeScreen:Add, Text, y20 cBlack, Light Mode Activated   ;, %A_UserName% ; make a text control showing welcome back, (username)
        WinSet, Transparent, 0                              ; set gui transparent
        SysGet, P, MonitorPrimary                           ; get primary monitor number
        SysGet, Mon, MonitorWorkArea, % P                   ; get size of primary monitor
        Gui, WelcomeScreen:Show, Hide                       ; Show gui
        WinGetPos, X, Y, W, H                               ; get pos of gui
        WinMove, % MonRight - W - 10, % MonBottom - H - 10  ; move gui to bottom right
        WinSet, Region, 0-0 W%W% H%H% R20-20                ; round corners
    }
    Gui, WelcomeScreen:Show, NA
    bf := Func("AnimateFadeIn").Bind(HwndWelcomeScreen)
    SetTimer, %bf%, -200
}



AnimateFadeIn(hwnd) {
    static Value := 0
    WinSet, Transparent, % Value+=15, % "ahk_id" hwnd
    if (Value >= 255) {                         ; if gui is fully opaque
        Value := 0                              ; reset transparency value
        bf := Func("AnimateFadeOut").Bind(hwnd) ; make bound function to fade out
        SetTimer, %bf%, -1000     ;<=--------------------------------------------------------CHANGE HOW LONG
    } else {
        bf := Func("AnimateFadeIn").Bind(hwnd)  ; create bound functiion to fade in
        SetTimer, %bf%, -15                     ; rerun bound function until gui is fully opaque
    }
}

AnimateFadeOut(hwnd) {
    static Value := 255
    WinSet, Transparent, % Value-=15, % "ahk_id" hwnd
    if (Value <= 0) {                           ; if gui invisible
        Value := 255                            ; reset transparency value
        Gui, %hwnd%:Hide                        ; hide gui when finished
    } else {
        bf := Func("AnimateFadeOut").Bind(hwnd) ; create bound functiion to fade out
        SetTimer, %bf%, -15                     ; rerun bound function until gui is transparent
    }
}


guicaps()
{
; gui, caps: hide
	Gui, caps: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
	Gui, caps: Font, cffb900 s12 bold, WW Digital
	Gui, caps: Color, af001d ; changes background color
	Gui, caps: add, picture, xm w18 h18, %A_ScriptDir%\Images\keyboard-caps-lock-filled xfav arrow send move_256x256.ico
	Gui, caps: Add, Text, X+M ,CAPS LOCK is ON `~`!`@`#`$`%`^&&*( `)`_`+`{ `}`|
	SysGet, P, MonitorPrimary                           ; get primary monitor number
	SysGet, Mon, MonitorWorkArea, % P                   ; get size of primary monitor
	gui, caps: show, noactivate ;x3370 y2059
	WinSet, TransColor, af001d
	; Gui, WelcomeScreen1:Show, Hide                       ; Show gui
	WinGetPos, X, Y, W, H                               ; get pos of gui
	WinMove, % MonRight - W - 10, % MonBottom - H - 10  ; move gui to bottom right
	WinSet, Region, 0-0 W%W% H%H% R20-20                ; round corners
	
	; gui, caps: show, x3370 y2059 noactivate
	
	; Gui, Show, % "x" . (3430) . "y" . (2061) . " NoActivate"
    ; WinSet, TransColor, af001d
	; gui, caps: hide
}


aboutwindow:
aboutwindow()
return

Aboutwindow()
{
global
aboutwindow := "
(
" ScriptName "
" URL "
Last Update: " ScriptVersion "

This AutoHotkey menu is meant to be run on *[SELECTED TEXT.]*
It has been modified to show when text is not selected,
therefore, at times, it may not work as expected.
E.G. if no text is selected it a text editor and you fire a menu item,
it may copy and format an entire line.
A.k.a., use with Caution!!! Especially when working in file manager.
If you use it copy and paste functions on files,
it will copy the files themselves unless you hit F2 first
to select text in the file name. 

Its been pieced together from about 3 other similar scripts,
with extra functions I created. I adding app launcher,
search the web or local computer from selected text, 
save selected text to a New Text Document,
added some code formatting opitons,
insert date and time,
added light & dark mode toggle (dark is default),
added a GUI that show over the system try when your caps lock is toggled.
etc... And more to come.

The Functions run mostly from the menu, there are some some hotkey too.... 
)"

hotkeys := "
(
Hotkeys!
Extend CapsLock Functionality Using AutoHotkey:
	- Single Tap = Copy aka Ctrl+C
	- Double Tap = Paste aka Ctrl+V
	- Long Press = Show Extended CAPLOCK Menu

Ctrl + Capslock to Toggle CAPSLock
Alt + Capslock to Toggle CAPSLock   and CAPS can be toggled from the menu.
Shift + Capslock to Switch Between UPPERCASE and\or lowercase

Win + O to Search Selected Text in Google
Win + F to Search Selected Text Locally Using Everything 1.5a
Ctrl + ' to Wraps the Selected Text In Quotes
Ctrl + Shift + ' to Paste your clipboard in Quotes
Win + H to Add Auto Correct Hot Strings
Ctrl + Shift + R to Reloads the Script
)"


gui, color, 171717
gui, font, s10
gui, font, cffb900
gui, add, text, xm, %aboutwindow%
gui, add, picture, xm, %A_ScriptDir%\Images\Screenshots\menus_caps_464x57.png

gui, font, cA0BADE
gui, add, picture, xm w36 h36, %A_ScriptDir%\Images\code spark xfav function_256x256.ico
gui, add, text, x+m, %hotkeys%

Gui, Add, Link, xm, <a href="https://www.github.com/indigofairyx">This Scripts Github Page</a> 

gui, add, text, xm cffb900, There are a few pieces of free software I use and built into this menu as a launcher for these tools.`nThe ones that are free I left in the menu.`nHeres a list of links to them if you want some awesome software.

Gui, Add, Link, xm, <a href="https://github.com/sabrogden/Ditto">Ditto - Clipboard Manager</a> 
Gui, Add, Link, xm, <a href="https://www.voidtools.com/forum/viewtopic.php?t=9787">Everything v1.5a - Powerful local search tool</a> 
Gui, Add, Link, xm, <a href="https://ramensoftware.com/textify">Textify - Lets you copy text out of message boxes and guis</a> 
Gui, Add, Link, xm, <a href="https://github.com/TheJoeFin/Text-Grab/">Text Grab - Amazing OCR tool</a> 
Gui, Add, Link, xm, <a href="https://github.com/notepad-plus-plus/notepad-plus-plus">Notepad++ - You never know.</a> 
Gui, Add, Link, xm, <a href="https://github.com/BashTux1/AutoCorrect-AHK-2.0">AHK Global Auto Correct Script - This is already included here.</a> 

gui, add, button, xm gclose, Close

gui, +Border +Resize -MaximizeBox +Dpiscale
gui, show,, Extended CAPS Menu - About
}


exitscript:
exitapp
return


/* image list for this file.... picture list
gui, add, text, xm, Credit and Thanks to these two from whom the main structure of this menu came from.
Gui, Add, Link, xm, <a href="https://github.com/S3rLoG/CapsLock_Menu">S3rLoG - Github Page</a> 
gui, add, text, x+m, `&
Gui, Add, Link, x+m, <a href="https://pastebin.com/g6BzS4A8">MRFace1 - Pastebin</a> 
	

*/







