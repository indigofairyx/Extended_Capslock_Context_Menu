;;;;; !NOTE! This Script is not set to run as admin, if you'd like it to regularly, delete the " ; " at the front of the next two lines, changing it here will override the toggle in the settings menu.

 ; If !A_IsAdmin
 	 ; Run *RunAs "%A_ScriptFullPath%"

;!!!!!!!!!!!! IMPORTANT! THIS FILE MUST BE ENCODED WITH UTF8+BOM !!!!!!!!!!!!!!;

ScriptVersion := "v.2024.11.06"

ScriptName := "Extended CaplsLock Menu" 

; #warn  ; enable warning to assist with detecting common errors
#warn useenv, off

#Persistent
#SingleInstance, Force
#InstallKeybdHook
#InstallMouseHook


SetBatchLines -1  ; Run the script at maximum speed.
SetWinDelay, -1  ; go quick
CoordMode, Mouse, Screen
SendMode Input
SetWorkingDir,%A_ScriptDir%
filePath := A_ScriptFullPath
inifile := A_ScriptDir "\" A_ScriptName "-SETTINGS.ini"
global inifile
if !FileExist(inifile) {
    ; Retrieve the default settings and write to the INI file
    defaultIniSettings := GetDefaultIniSettings()
    FileAppend, %defaultIniSettings%, %inifile%
    Sleep 750
    ToolTip, Your settings file was not found.`nCreating a new one. One moment please.
    Sleep 2000
    ToolTip
    Sleep 200
}

IniRead, ProgramSection, %inifile%, Programs
if (ProgramSection = "ERROR") {
    MsgBox, Could not read the Programs section from the INI file.
    return
}
Loop, Parse, ProgramSection, `n, `r
{
    ; Each line should be in the format Key=Value
    StringSplit, KeyValue, A_LoopField, =
    ; Use indirect assignment for globals
    ; global
    VarName := KeyValue1  ; Name of the variable from the INI key
    VarValue := KeyValue2 ; Value of the variable from the INI value
    %VarName% := VarValue ; Assign dynamically
}
; MsgBox, % "Path to Notepad++: " notepadpp
; MsgBox, % "Path to Notepad4: " notepad4
; MsgBox, % "Path to Directory Opus: " dopus
; MsgBox, % "Path to Directory rt: " dopusrt

; default to 0 ( false - off ) ; default to 1 ( true - on )
IniRead, DarkMode, %inifile%, DarkMode, key, 1 
IniRead, Beep_enabled, %inifile%, Beep_enabled, key, 1 
IniRead, LiveMenuEnabled, %inifile%, LiveMenuEnabled, key, 0 
IniRead, ShiftedNumRow, %inifile%, ShiftedNumRow, key, 0 
IniRead, ReplaceNPPRightClick, %inifile%, ReplaceNPPRightClick, key, 0 

; DarkMode := DarkMode = 1
; Beep_enabled := Beep_enabled = 1
; LiveMenuEnabled := LiveMenuEnabled = 1 
; ShiftedNumRow := ShiftedNumRow = 1
; ReplaceNPPRightClick := ReplaceNPPRightClick = 1
; tooltip, DarkMode: %DarkMode%`nReplacement: %ReplaceNPPRightClick%`n SHIFTED #: %ShiftedNumRow%`n beeps: %Beep_enabled%`n livemenu: %LiveMenuEnabled%
; sleep 1500
; tooltip
if (DarkMode)
		{
			DarkMode := true
			MenuDark(2) ; Set to ForceDark
		}
		else
		{
			DarkMode := false
			MenuDark(3) ; Set to ForceLight
		}




SetCapsLockState, off

; EnvGet, userprofile, Path ;;//broken
;; todo, figure out which EnvGet's I dont need, clean this list out.
envget, userprofile, userprofile
; msgbox, %userprofile%
; EnvGet, EnvGetVar, Path
; EnvGet, EnvGetVar, envgetvar
; msgbox %envgetvar%
; EnvGet, OutputVar, % A_Is64bitOS ? "ProgramW6432" : "ProgramFiles"
; MsgBox, Program files are in: %OutputVar%
EnvGet, LocalAppData, LocalAppData
; MsgBox, %A_UserName%'s Local directory is located at: %LocalAppData%

Global filename,dir,ext,filestem,drive,folder,lastfolder,filetoclip,highlighted




Global texteditor

global ClipSaved
Global ClipSaved := ""   ; Variable to store saved clipboard content

;sticky note parms
; currentIndex := 1 
pinoff=%A_ScriptDir%\icons\pin-off_26x26.ico
pinon=%A_ScriptDir%\icons\pin-on_26x26.ico
global pinstartpic=1
Global pinstartpic := 1  ; Variable for pin state
Global pin   			; var for sticky notes
Global StickyCount := 0  ; Global counter for sticky notes, GUI item
Global clipcontent       ; Dynamic live menu item
Global stickytext := ""  ; Variable for sticky note text

iconerror = %A_ScriptDir%\icons\view error_192x192.ico

; global toggles
; global ReplaceNPPRightClick
; global CAPSGuiToggle
; global CapsGuiToggle := false
; global LiveMenuEnabled
; global ShiftedNumRow
; global Beep_enabled
; global darkmode

;---------------------------------------------------------------------------
this := "" ; swap at, text func
div := "" ;swap at, text, func
;---------------------------------------------------------------------------


;---------------------------------------------------------------------------
{ ; items for menu, dtmenu,
StartTime := A_TickCount
FormatTime, A_Time,, Time
FormatTime, A_ShortDate,, ShortDate
FormatTime, A_LongDate,, LongDate
FormatTime, A_YY,, yy
formattime, A_HH,, HH
formattime, A_tt,, tt
Date := A_Now
List := DateFormats(Date)
TextMenuDate(List)
} ; items for menu, dtmenu,
;; Date time menu ( bound to capslock\case menu)
TextMenuDate(TextOptions)
{
global
menu, dtmenu, add, --- Insert Date && Time ---, showdtmenu
menu, dtmenu, icon, --- Insert Date && Time ---, %A_ScriptDir%\Icons\ico_alpha_Clock_32x32.ico,,28
menu, dtmenu, default, --- Insert Date && Time ---
menu, dtmenu, add, ; line ;-------------------------
	 StringSplit, MenuItems, TextOptions , |
	 Loop %MenuItems0%
	  {
		Item := MenuItems%A_Index%
		Menu, dtmenu, add, %Item%, dtMenuAction
	  }
 menu, dtmenu, add ; line ;-------------------------
 menu, dtmenu, add, Close This Menu, CloseMenu
 Menu, dtmenu, icon, Close This Menu, %A_ScriptDir%\Icons\aero Close_24x24-32b.ico
}

DateFormats(Date)
{
  global
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
dtmenurefresh() ;; Function
{
global
Menu, dtmenu, DeleteAll
Date := A_Now
List := DateFormats(A_Now)
TextMenuDate(List)
}

;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
menu, ctxt, add, --- Modify Text && Case ---, showctxtmenu
menu, ctxt, icon, --- Modify Text && Case ---, %A_ScriptDir%\Icons\richtext_editor__32x32.ico,,28
menu, ctxt, default, --- Modify Text && Case ---,
menu, ctxt, add, ; line -------------------------
menu, ctxt, Add, UPPERCASE, Upper
menu, ctxt, icon, UPPERCASE, %A_ScriptDir%\Icons\Upper case.ico
menu, ctxt, Add, lowercase, Lower
menu, ctxt, icon, lowercase, %A_ScriptDir%\Icons\Lower case.ico
menu, ctxt, Add, Title Case, Title
menu, ctxt, Add, Sentence case, Sentence
Menu, ctxt, Add, Capital Case, Capital
menu, ctxt, add, ; line ;-------------------------
menu, ctxt, add, Reverse - esreveR,  Reverse
menu, ctxt, icon, Reverse - esreveR,  %A_ScriptDir%\Icons\action-text-direction-rtl_48x48.ico
Menu, ctxt, Add, iNVERT cASE - Invert Case, Invert
menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, Add, PascalCase, Pascal
Menu, ctxt, Add, camelCase, camel
Menu, ctxt, Add, aLtErNaTiNg cAsE, Alternating
menu, ctxt, add, ; line ;-------------------------
menu, ctxt, add, Remove  Extra   Spaces, RemoveExtraS
menu, ctxt, Add, RemoveALL Spaces, RASpace
menu, ctxt, icon, RemoveALL Spaces, %A_ScriptDir%\Icons\sc_gluepercent_16x16.ico
Menu, ctxt, add, S p r e a d T e x t, spread ; ccase ; spread case
menu, ctxt, add, ;line ;-------------------------
Menu, ctxt, Add, Space to Dot.Case, addDot
menu, ctxt, add, Remove.Dot to Space, removedot
Menu, ctxt, Add, Space to Under_Score, addunderscore
menu, ctxt, add, Remove_Underscore to Space, removeunderscore
Menu, ctxt, Add, Space to Dash-Case, adddash
menu, ctxt, add, Remove-Dash to Space, removedash
menu, ctxt, add, ; line ;-------------------------
menu, ctxt, add, Sort `> 0-9`,A-Z, sorttext
menu, ctxt, icon, Sort `> 0-9`,A-Z, %A_ScriptDir%\Icons\sort_descending__32x32.ico
menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, add, Fix Linebreaks, FixLineBreaks
menu, ctxt, add, Remove Illegal Characters && Emojis, removeillegal
menu, ctxt, icon, Remove Illegal Characters && Emojis, %A_ScriptDir%\Icons\error bot flow xfav_48x48.ico
menu, ctxt, add, ; line ;-------------------------
menu, ctxt, add, Swap at Anchor Word, text_swap ;swaptext
menu, ctxt, icon, Swap At Anchor Word, %A_ScriptDir%\Icons\arrow_switch__32x32.ico

;---------------------------------------------------------------------------

menu, cform, add, `/`* Block Comment `*`/, commentblock
menu, cform, add, `{Wrapped}, cbrakectswrapped
menu, cform, add, (Parentheses), wrapparen
menu, cform, add, [Square Brackets], squbracket
menu, cform, icon, [Square Brackets], %A_ScriptDir%\Icons\code text brackets file_type_light_toml_32x32.ico
menu, cform, add, `%PercentVar`%, wrappercent
menu, cform, Add, ``Code - `Inline``, CodeLine
menu, cform, Add, ``````Code - Box``````, CodeBox
menu, cform, icon, ``````Code - Box``````, %A_ScriptDir%\Icons\selection text code Resources_200_24x24.ico
menu, cform, add, [code]Box[/code], forumcodebox
menu, cform, Add, <kbd>`K<`/kbd>, dopusK
menu, cform, icon, <kbd>`K<`/kbd>, %A_ScriptDir%\Icons\xml code_128x128.ico
menu, cform, add, `<`!-- xml Comment --`>, wrapinxmlcomment


;---------------------------------------------------------------------------

menu, cfind, add, --- Web Searches ---, showfindmenu
menu, cfind, icon, --- Web Searches ---, %A_ScriptDir%\Icons\web www internet globe 26 64x64.ico,,27
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, Google This, googlethis
menu, cfind, icon, Google This, %A_ScriptDir%\Icons\google_96x96.ico
menu, cfind, add, Youtube This, youtubethis
menu, cfind, icon, Youtube This, %A_ScriptDir%\Icons\youtube_64x64.ico
menu, cfind, add, Define Word (Google), definethis
menu, cfind, icon, define word (google), %A_ScriptDir%\Icons\Dictionary__32x32.ico
menu, cfind, add, Wikipedia Search, wikipediasearch
menu, cfind, icon, Wikipedia Search, %A_ScriptDir%\Icons\wikipedia.ico

menu, cfind, add, AHK Syntax Search, ahksearchmenu
menu, cfind, icon, AHK Syntax Search, %A_ScriptDir%\Icons\www.autohotkey.com website favcon_48x48.ico
menu, cfind, add, ; line -------------------------
menu, cfind, add, Visit Website [If a URL is selected], gowebsite
menu, cfind, icon, Visit Website [If a URL is Selected], %A_ScriptDir%\Icons\web-browser xfav_24x24.ico
menu, cfind, add, ; line ;-------------------------
menu, Cfind, add, --- Local Searches ---, showfindmenu
menu, Cfind, icon, --- Local Searches ---, %A_ScriptDir%\Icons\computer_48x48.ico,,27
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, Everything`, Find [Selected Text] Locally, Findwitheverything
menu, cfind, icon, Everything`, Find [Selected Text] Locally, %A_ScriptDir%\Icons\voidtools-15-Everything-1.5.ico
menu, cfind, add, System Index`, Find with EveryThing 1.5a, evindex
menu, cfind, icon,System Index`, Find with EveryThing 1.5a, %A_ScriptDir%\Icons\windowsindexingoptions_48x48.ico
; menu, cfind, icon, System Index`, Find with EveryThing 1.5a, %A_ScriptDir%\Icons\office search find content everything -document-viewer_32x32.ico ; alt icon
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, NP++`, Find in Files, findinfilesnpp
menu, cfind, icon, NP++`, Find in Files, %A_ScriptDir%\Icons\Find in Files.ico
menu, cfind, add, NP++`, Find all in this Doc, findalllocalnpp
menu, cfind, icon, NP++`, Find all in this Doc, %A_ScriptDir%\Icons\Find next.ico
menu, cfind, add, Find in Files with AstroGrep, findastro
menu, cfind, icon, Find in Files with AstroGrep, %A_ScriptDir%\Icons\astrogrep find search 256x256.ico
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, Look up on Dictionary.com && Thesaurus.com, Dictionarydotcom

;---------------------------------------------------------------------------

menu, ctools, add, --- Text Tools ---, showtoolsmenu
menu, ctools, icon, --- Text Tools ---, %A_ScriptDir%\Icons\Pencil and Ruler__32x32.ico,,28
menu, ctools, default, --- Text Tools ---
menu, ctools, add, ; line ------------------ -------
menu, ctools, add, Save Selection To New Document, newtxtfile
menu, ctools, icon, Save Selection To New Document, %A_ScriptDir%\Icons\document new add FLUENT_colored_239_64x64.ico
menu, ctools, add, Quick Save Selection to New.txt File, quicktxtfile
menu, ctools, icon, Quick Save Selection to New.txt File, %A_ScriptDir%\Icons\lc_savebasicas_26x26.ico
menu, ctools, add, Copy Selected to New Np++ Document, newnpppdoc
menu, ctools, icon, Copy Selected to New Np++ Document, %A_ScriptDir%\Icons\document edit notepad++ npp duplicate FLUENT_colored_452_64x64.ico
menu, ctools, add, ; line ;-------------------------
menu, ctools, add, Save Clipboard to New Document, SaveClipboardAsTxt
menu, ctools, icon, Save Clipboard to New Document, %A_ScriptDir%\Icons\clipboard save b_xedit_48x48.ico
menu, ctools, add, View Clipboard, viewclip
menu, ctools, icon, View Clipboard, %A_ScriptDir%\Icons\QAP-preview_pane_c_26x26.ico
; menu, ctools, icon, View Clipboard, %A_ScriptDir%\Icons\message Magic Box.ico ; alt icon
menu, ctools, add, Clear Clipboard, clearclip
; menu, ctools, icon, Clear Clipboard, %A_ScriptDir%\Icons\Clean_fluentColored_64x64.ico ; alt icon
menu, ctools, icon, Clear Clipboard, %A_ScriptDir%\Icons\clean_clear_clipboard_empty_xedit3_32x32.ico

menu, ctools, add, ;line ;-------------------------
menu, ctools, add, Grab Location Bar Address (Copy), copylocationbar
menu, ctools, icon, Grab Location Bar Address (Copy), %A_ScriptDir%\Icons\address_bar_red__32x32.ico
menu, ctools, add, Copy Selection to Temp Sticky, CopyToStickyNote
menu, ctools, icon, Copy Selection to Temp Sticky, %A_ScriptDir%\Icons\classicStickyNotes_0_6 48x48.ico
menu, ctools, add, ;line ;-------------------------

menu, ctools, add, Read [*Selected Text*] Out Loud, TextToSpeech
menu, ctools, icon, Read [*Selected Text*] Out Loud, %A_ScriptDir%\Icons\loudspeaker_emoji_64x64.ico
menu, ctools, add, ; line ;-------------------------
menu, ctools, add, --- Software Launchers (?About) ---, aboutsoftwareL
menu, ctools, icon, --- Software Launchers (?About) ---, %A_ScriptDir%\Icons\Apps_software_48x48.ico,,24
menu, ctools, add, ; line ;-------------------------
MENU, ctools, add, Run AHK Auto Correct (Included), abc
MENU, ctools, icon, Run AHK Auto Correct (Included), %A_ScriptDir%\Icons\autocorrect_icon_32x32.ico
menu, ctools, add, Ditto Clipboard, runditto
menu, ctools, icon, Ditto Clipboard, %A_ScriptDir%\Icons\ditto quote clipboard 128x128.ico
menu, ctools, add, Textify, runtextify
menu, ctools, icon, Textify, %A_ScriptDir%\Icons\textify 128x128.ico
menu, ctools, add, Text Grab, runtextgrab
menu, ctools, icon, Text Grab, %A_ScriptDir%\Icons\text grab v4 128x128.ico
menu, ctools, add, Notepad++, runnotepadpp
menu, ctools, icon, Notepad++, %A_ScriptDir%\Icons\notepad++_100.ico

; --------------------------------------------------------------------------


menu, copen, add, -- IF a C:\Directory`, C:\Filepath.txt`, Url`, or RegKey is [*SELECTED*] --, showopenmenu
; if FileExist(dopus)
; if FileExist("C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe")
if FileExist(dopus)
	menu, copen, icon, -- IF a C:\Directory`, C:\Filepath.txt`, Url`, or RegKey is [*SELECTED*] --, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,28
else
	menu, copen, icon, -- IF a C:\Directory`, C:\Filepath.txt`, Url`, or RegKey is [*SELECTED*] --, explorer.exe,,28
; menu, copen, icon, -- IF a C:\Directory`, C:\Filepath.txt`, Url`, or RegKey is [*SELECTED*] --, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,27 ; alt og icon
menu, copen, default, -- IF a C:\Directory`, C:\Filepath.txt`, Url`, or RegKey is [*SELECTED*] --
menu, copen, add, ; line ;-------------------------
menu, copen, add, Open Folder, OpenDIRselection
menu, copen, icon, Open Folder, %A_ScriptDir%\Icons\folder file explorer imageres_5325_256x256.ico
; menu, copen, add, Open Folder v2 simple, openfoldersimple
menu, copen, add, Run\Open File, RUNfromselection
menu, copen, icon, Run\Open File, %A_ScriptDir%\Icons\JLicons_1_64x64.ico
menu, copen, add, Copy File\Folder to Clipboard, COPYfromselection
menu, copen, icon, Copy File\Folder to Clipboard, %A_ScriptDir%\Icons\importClipboard image photo picture _48x48.ico
menu, copen, add, Edit in Text Editor, Edittxtfile
if fileexist(Texteditor)
	menu, copen, icon, Edit in Text Editor, %texteditor%
else
	menu, copen, icon, Edit in Text Editor, notepad.exe
menu, copen, add, ; line ;-------------------------
menu, copen, add, Explore Folder in Everything, EVpath
menu, copen, icon, Explore Folder in Everything, %A_ScriptDir%\Icons\voidtools-15-Everything-1.5.ico
menu, copen, add, Search File in Everything, EVfile
menu, copen, icon, Search File in Everything, %A_ScriptDir%\Icons\voidtools-04-Everything-Green.ico

menu, copen, add, ; line ;-------------------------
menu, copen, add, File Content to Clipboard (Text-Based Files), filetoclipboard
menu, copen, icon, File Content to Clipboard (Text-Based Files), %A_ScriptDir%\Icons\binary text txt copy_48x48.ico
; menu, copen, icon, File Content to Clipboard (Text-Based Files), %A_ScriptDir%\Icons\filetype exe binary text txt copy 20_48x48.ico ;alt icon
menu, copen, add, Copy File Names and Details of Folder to Clipboard, copydetails
menu, copen, icon, Copy File Names and Details of Folder to Clipboard, %A_ScriptDir%\Icons\cmd_48x48.ico
menu, copen, add, ; line ;-------------------------
menu, copen, add, Duplicate File as... "File Name -CopyDup.ext", makedup
menu, copen, icon, Duplicate File as... "File Name -CopyDup.ext", %A_ScriptDir%\Icons\lc_duplicatepage_24x24.ico
menu, copen, add, Put File into a Subfolder (Fold will take Filename), movefiletofolder
menu, copen, icon, Put File into a Subfolder (Fold will take Filename), %A_ScriptDir%\Icons\folder new add FLUENT_colored_165_64x64.ico
menu, copen, add, Move File Up into it's Parent Folder, movefiletoparentfolder
menu, copen, icon, Move File Up into it's Parent Folder, %A_ScriptDir%\Icons\folder arrow up action-brown-open_32x32.ico
menu, copen, add, ; line ;-------------------------

menu, copen, add, Jump to Key in RegEdit, RegJump 
menu, copen, icon, Jump to Key in RegEdit, %A_ScriptDir%\Icons\reg blocks app 256x256.ico
; menu, copen, icon, Jump to Key in RegEdit, regedit.exe
menu, copen, add, ; line ;-------------------------
menu, copen, add, Visit Website [If a URL is Selected], gowebsite
menu, copen, icon, Visit Website [If a URL is Selected], %A_ScriptDir%\Icons\web-browser xfav_24x24.ico
menu, copen, add, ; line ;-------------------------
menu, copen, add, View Explore Folder Menu   **[Experimental]**,expmenu
menu, copen, icon, View Explore Folder Menu   **[Experimental]**, %A_ScriptDir%\Icons\submenu JLicons_42_64x64.ico
menu, copen, add, ; line ------------------------- 
menu, copen, add, If NP++ Switch to Alt Open With Menu, alttxtnppmenu
if fileexist(notepadpp)
	menu, copen, icon, If NP++ Switch to Alt Open With Menu, %notepadpp%
else
	menu, copen, icon, If NP++ Switch to Alt Open With Menu, notepad.exe


; menu, copen, add, ; line ;------------------------- ; todo ↓ ↓ add slide out menus for whats selected
; menu, copen, add, Explore Folder, :folders
; menu, copen, add, %clipboard%, :folders

;---------------------------------------------------------------------------
menu, gui, add, Save As`tCtrl + S, savestickyAS
menu, gui, icon, Save As`tCtrl + S, %A_ScriptDir%\Icons\save as floppy Resources_174_24x24.ico
menu, gui, add, Quick Save as .txt`tCtrl + Shift + S, savestickyquick
menu, gui, icon, Quick Save as .txt`tCtrl + Shift + S, %A_ScriptDir%\Icons\action-save_48x48.ico
menu, gui, add, ; line ;-------------------------
menu, gui, add, Create New Temp Sticky`tCtrl + N, newsticky
menu, gui, icon, Create New Temp Sticky`tCtrl + N, %A_ScriptDir%\Icons\sticky-note--plus_16x16.ico

menu, gui, add, ; line ;-------------------------
menu, gui, add, Open Quick Notes Dir`tCtrl + Shift + O, openquick
menu, gui, icon, Open Quick Notes Dir`tCtrl + Shift + O, %A_ScriptDir%\Icons\folder file explorer imageres_5325_256x256.ico
menu, gui, add, ; line ;------------------------- 
menu, gui, add, Close Temp Sticky`tCtrl + Esc, guidestory
menu, gui, icon, Close Temp Sticky`tCtrl + Esc, %A_ScriptDir%\Icons\application-exit_32x32.ico
menu, gui, add, ; line ;-------------------------
menu, gui, add, Pin \ Unpin to Top`tCtrl + P, pintotop
; if (alwaysontop)
	menu, gui, icon, Pin \ Unpin to Top`tCtrl + P, %pinoff%
; else
	; menu, gui, icon, Pin \ Unpin to Top`tCtrl + P, %pinon%
; menu, gui, icon, Pin to Top, %A_ScriptDir%\Icons\pin-off_26x26.ico ;alt icon
; menu, gui, icon, Pin \ Unpin to Top`tCtrl + P, %pinon%
; Menu, gui, add, %A_GuiX% %A_GuiY%, menureturn ;debug test


; todo, populate menu, gui, add right click to gui, stickys

;---------------------------------------------------------------------------
menu, cset, add, ---  Settings && About  ---, showsettingsmenu
menu, cset, icon, ---  Settings && About  ---, %A_ScriptDir%\Icons\setting edit FLUENT_colored_082_64x64.ico,,28
menu, cset, default, ---  Settings && About  ---
menu, cset, add, ; line ------------------------- 
Menu, cset, add, Toggle Live Preview && Auto Copy, ToggleLiveMenu
if (LiveMenuEnabled)
	Menu, cset, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\eyes_emoji_64x64.ico
else
Menu, cset, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\eye_half__32x32.ico
; Menu, cset, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\settings panel JLicons_33_64x64.ico ; og alt icon


Menu, cset, Add, Dark Mode | Light Mode, DMToggle ; this function is in the setting file
Menu, cset, icon, Dark Mode | Light Mode, %A_ScriptDir%\Icons\darkmodetoggleshell32_284_48x48.ico
menu, cset, add, Mute Sound on Capslock Toggle, togglebeepsetting
if (Beep_enabled)
menu, cset, icon, Mute Sound on Capslock Toggle, %A_ScriptDir%\Icons\sound__32x32.ico
else
	menu, cset, icon, Mute Sound on Capslock Toggle, %A_ScriptDir%\Icons\sound_mute__32x32.ico
; menu, cset, icon, Mute Sound on Capslock Toggle, %A_ScriptDir%\Icons\sound_mute__32x32.ico ; og, alt icon
menu, cset, add, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+, shiftednumrow
IF (ShiftedNumRow)
	{
	menu, cset, togglecheck, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+
}
else
	{
	menu, cset, icon, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+, %A_ScriptDir%\Icons\hashtag! Comment xfav crunchbang_48x48.ico
}
menu, cset, add, Replace the NP++ Right Click Menu, ToggleReplaceNPPRightClick
if (ReplaceNPPRightClick)
	{
	menu, cset, togglecheck, Replace the NP++ Right Click Menu
	}
else
	{
	menu, cset, icon, Replace the NP++ Right Click Menu, %A_ScriptDir%\Icons\context menu icon.ico
	}
menu, cset, add, ; line ;-------------------------
menu, cset, add, Run as Admin, runasadmin
menu, cset, icon, Run as Admin, %A_ScriptDir%\Icons\admin imageres_1028.ico
menu, cset, add, ; line ;-------------------------
menu, cset, add, Open Quick Notes Dir, openquick
menu, cset, icon, Open Quick Notes Dir, %A_ScriptDir%\Icons\folder file explorer imageres_5325_256x256.ico
menu, cset, add, ; line ;-------------------------
menu, cset, add, About Extended Caps Lock Menu, aboutcapswindow
menu, cset, icon, About Extended Caps Lock Menu, %A_ScriptDir%\Icons\about question imageres win7_99_256x256.ico
menu, cset, add, Visit Github Webpage, visitgithub
menu, cset, icon, Visit Github Webpage, %A_ScriptDir%\Icons\github icon 256x256.ico


menu, cset, add, ; line ;-------------------------
MENU, cset, add, Debug Lines, lines
menu, cset, icon, Debug Lines, %A_ScriptDir%\Icons\bug report FLUENT_colored_217_64x64.ico

menu, cset, Add, Edit Main Script, editscript
; menu, cset, icon, Edit Main Script, %A_ScriptDir%\Icons\notepad++_100.ico ; alt icon, old
if FileExist(texteditor)
	menu, cset, icon, Edit Main Script, %texteditor%
else
	menu, cset, icon, Edit Main Script, notepad.exe

; menu, cset, add, Edit Settings.ini File, editsettings
; menu, cset, icon, Edit Settings.ini File, %A_ScriptDir%\Icons\ini alt xfav setting document prefs setupapi_19 256x256.ico
menu, cset, add, Edit " %A_scriptname%-SETTINGS.ini " File, editsettings
menu, cset, icon, Edit " %A_scriptname%-SETTINGS.ini " File, %A_ScriptDir%\Icons\ini alt xfav setting document prefs setupapi_19 256x256.ico
menu, cset, icon, Edit Main Script, %A_ScriptDir%\Icons\notepad++_100.ico
menu, cset, add, ; line ;-------------------------
menu, cset, add, Reload Script          --         Ctrl + Shift + R, reload
menu, cset, icon, Reload Script          --         Ctrl + Shift + R, %A_ScriptDir%\Icons\Refresh reload xfave_128x128.ico
menu, cset, add, View Hotkeys, viewhotkeys
menu, cset, icon, View Hotkeys, %A_ScriptDir%\Icons\preferences-desktop hotkeys-keyboard-shortcuts_48x48.ico

; menu, cset, add, Capslock OSD (On\Off), togglegui ; todo broken fix
menu, cset, add, Suspend Hotkeys, suspendkeys
menu, cset, icon, Suspend Hotkeys, %A_ScriptDir%\Icons\advert-block_64x64.ico
menu, cset, add, ; line ;-------------------------
menu, cset, add, Quit\Exit, exitscript
menu, cset, icon, Quit\Exit, %A_ScriptDir%\Icons\skull n bones emoji111.ico

;---------------------------------------------------------------------------

menu, tray, nostandard
menu, tray, icon, %A_ScriptDir%\Icons\keyboard-caps-lock-filled xfav arrow send move_256x256.ico
menu, tray, add, Show Extended Capslock Menu, Capsmenubutton
menu , tray, icon, Show Extended Capslock Menu, %A_ScriptDir%\Icons\keyboard-caps-lock-filled xfav arrow send move_256x256.ico,,28
menu, tray,  default, Show Extended Capslock Menu
menu, tray, add, ; line ;-------------------------
menu, tray, add, Reload, reload
menu, tray, icon, Reload, %A_ScriptDir%\Icons\Refresh reload xfave_128x128.ico
menu, tray, add, View Hotkeys, viewhotkeys
menu, tray, icon, View Hotkeys, %A_ScriptDir%\Icons\preferences-desktop hotkeys-keyboard-shortcuts_48x48.ico
menu, tray, add, Suspend Hotkeys, suspendkeys
menu, tray, icon, Suspend Hotkeys, %A_ScriptDir%\Icons\advert-block_64x64.ico
MENU, tray, add, ; line ;-------------------------
menu, tray, add, Settings && About, :cset
menu, tray, icon, Settings && About, %A_ScriptDir%\Icons\setting gear cog JLicons_40_64x64.ico
MENU, tray, add, ; line ;-------------------------
menu, tray, add, Quit\Exit, exitscript
menu, tray, icon, Quit\Exit, %A_ScriptDir%\Icons\skull n bones emoji111.ico

; Menu, Tray, MainWindow
; menu, tray, add, ; line ;-------------------------

;--------------------------------------------------------------------------- 
;---------------------------------------------------------------------------
;;; go capslock menu, go case menu, START  caps menu, capsmenu, go menu, case
; menu, Case, Add
; menu, case, add, ; top line ;-------------------------



MenuCaseShow() ;; function
{
    global LiveMenuEnabled
    dtmenurefresh()
    sleep 10
	menu, case, add
    Menu, case, DeleteAll ; Clear and reinitialize the menu
    Menu, Case, Add, EXTENDED CAPSLOCK MENU  (Toggle Caps), ToggleCapsLock
    Menu, Case, icon, EXTENDED CAPSLOCK MENU  (Toggle Caps), %A_ScriptDir%\Icons\keyboard-caps-lock-filled xfav arrow send move_256x256.ico,,27
    Menu, Case, Default, EXTENDED CAPSLOCK MENU  (Toggle Caps)
	Menu, case, add, ; line ------------------------- menu, case, top line
	
    if (LiveMenuEnabled) ; Check if LiveMenu is enabled
    {
        CopyClipboardCLM()  ; Auto Copy - Only when live menu is enabled
		if (Clipboard = "")
		{
		MenuItemName := "Your Clipboard is Empty. Err1"
		Menu, case, Add, %MenuItemName%, viewclip
        Menu, case, icon, %MenuItemName%, %A_ScriptDir%\Icons\error bot flow xfav_48x48.ico
		}
		else
		{
        ClipContent := Clipboard
		; MyClipBoard := Trim(Clipboard, " `t`r`n")
		Clipcontent := RegExReplace(RegExReplace(Clipcontent, "\r?\n"," "), "(^\s+|\s+$)")
		MenuItemName := (StrLen(ClipContent) > 45) ? SubStr(ClipContent, 1, 42) "..." : ClipContent
		}
		if (MenuItemName = "" || RegExMatch(MenuItemName, "^\s*$"))
			{
				MenuItemName := "Auto Copy Failed. Clipboard is Empty. Err2" ; fall back error for copying empty space, aka, there's nothing to show
				Menu, case, Add, %MenuItemName%, viewclip
				Menu, case, icon, %MenuItemName%, %A_ScriptDir%\Icons\error bot flow xfav_48x48.ico
				menu, case, add, ; line ------------------------- 
				restoreclipboard()
			}
    else
    {
        Menu, case, Add, %MenuItemName%, viewclip
        Menu, case, icon, %MenuItemName%, %A_ScriptDir%\Icons\QAP-preview_pane_c_26x26.ico
		menu, case, add, ; line ------------------------- 
		; Menu, case, icon, %MenuItemName%, %A_ScriptDir%\Icons\error bot flow xfav_48x48.ico ;alt icon
		; Menu, case, icon, %MenuItemName%, %A_ScriptDir%\Icons\view error_192x192.ico ;alt icon
    }
}
    else
    {
        MenuItemName := "Live Preview && Auto Copy is Disabled"
        Menu, case, Add, %MenuItemName%, viewclip
        Menu, case, icon, %MenuItemName%, %A_ScriptDir%\Icons\eye_close__32x32.ico
		Menu, case, add, ; line -------------------------
		; this section can be comment out to completely hide this static menu item when its off, it will\\can only appear when turn on
    }



menu, case, add, Text Tools && Apps, :ctools
menu, case, icon, Text Tools && Apps, %A_ScriptDir%\Icons\Pencil and Ruler__32x32.ico
menu, case, add, Find\Search Selected Text..., :cfind
menu, case, icon, Find\Search Selected Text..., %A_ScriptDir%\Icons\search find Windows 11 Icon 13_256x256.ico

; todo, remove for std ed. Dopus ed only, ; todo try to get this work in explorer? Gag
menu, case, add, Open\Run\Explore...     [ Files Menu ], :copen
; menu, case, icon, Open\Run\Explore...   ,
menu, case, icon, Open\Run\Explore...     [ Files Menu ], %A_ScriptDir%\Icons\folder tree FLUENT_colored_051_64x64.ico

menu, Case, Add ; line ;-------------------------
menu, Case, Add, Wrap in "Quotes"                                     Ctrl + `", ClipQuote ; ;10 %A_Space% in menu
menu, Case, icon, Wrap in "Quotes"                                     Ctrl + `", %A_ScriptDir%\Icons\format quote_24x24.ico ; "
menu, Case, add, `{..Curly &Brackets..`}`, On New Lines, wrapincbrackets
menu, Case, icon, `{..Curly &Brackets..`}`, On New Lines, %A_ScriptDir%\Icons\coding code json filetype_24x24.ico
; menu, cform, add ; line  ;-------------------------

menu, case, add, Code Formatting....., :cform
menu, case, icon, Code Formatting....., %A_ScriptDir%\Icons\code spark xfav function_256x256.ico

menu, case, add ; line ;-------------------------
menu, case, add, Modify Text && Case....., :ctxt
menu, case, icon, Modify Text && Case....., %A_ScriptDir%\Icons\richtext_editor__32x32.ico
menu, case, add, ; line ;-------------------------

menu, Case, add, Insert Date && Time, :dtmenu
menu, Case, icon, Insert Date && Time, %A_ScriptDir%\Icons\clock SHELL32_16771 256x256.ico
Menu, case, Add, Emoji Keyboard, OpenEmojiKeyboard
Menu, case, icon, Emoji Keyboard, %A_ScriptDir%\Icons\emoji face smilesvg_36x36.ico
menu, Case, Add ; line ;-------------------------

; menu, case, add ; line ;-------------------------
menu, Case, Add, Copy                                     Single Tap Capslock, basiccopy
menu, Case, icon, Copy                                     Single Tap Capslock, %A_ScriptDir%\Icons\edit-copy_32x32.ico
Menu, case, Add, + Copy (Add to Clipboard), appendclip
; Menu, case, Add, Append\Add (+ Copy) to Clipboard, appendclip
Menu, case, icon,  + Copy (Add to Clipboard), %A_ScriptDir%\Icons\clipboard--plus_16x16.ico
; menu, case, icon, Append\Add (+ Copy) to Clipboard, %A_ScriptDir%\Icons\copySpecial_48x48.ico ; alt icon
menu, case, icon,  + Copy (Add to Clipboard), %A_ScriptDir%\Icons\clipboard--plus_16x16.ico
Menu, Case, add, Cut, basiccut
menu, case, icon, Cut, %A_ScriptDir%\Icons\edit-cut_32x32.ico
menu, case, add, Paste                                   Double Tap Capslock, basicpaste
menu, case, icon, Paste                                   Double Tap Capslock, %A_ScriptDir%\Icons\edit-paste_256x256.ico
MENU, case, ADD, Paste As Plain Text, pasteplain
MENU, case, icon, Paste As Plain Text, %A_ScriptDir%\Icons\plaintextdoc_64x64.ico
; menu, case, add, ; line ;-------------------------
; Menu, case, Add, Ditto Clipboard, runditto
; Menu, case, icon, Ditto Clipboard, %A_ScriptDir%\Icons\ditto quote clipboard 128x128.ico
menu, case, add ; line ;-------------------------
menu, case, add, Setting && About, :cset
menu, case, icon, Setting && About, %A_ScriptDir%\Icons\setting gear cog JLicons_40_64x64.ico
menu, case, add, Close This Menu, CloseMenu
menu, case, icon, Close This Menu, %A_ScriptDir%\Icons\aero Close_24x24-32b.ico

Menu, Case, Show
}

;; end menus

;***************************************************************************
;************************* SOFTWARE LINKS **********************************
;***************************************************************************

url := "https://github.com/indigofairyx/Extended_Capslock_Context_Menu"
astrogrepurl := "https://astrogrep.sourceforge.net/features/"
dittourl := "https://github.com/sabrogden/Ditto"
everythingurl := "https://www.voidtools.com/forum/viewtopic.php?t=9787"
autocorrecturl := "https://github.com/BashTux1/AutoCorrect-AHK-2.0"
textifyurl := "https://ramensoftware.com/textify"
Textgraburl := "https://github.com/TheJoeFin/Text-Grab/"
notepadppurl := "https://github.com/notepad-plus-plus/notepad-plus-plus"
xnviewmpurl := "https://www.xnview.com/en/xnviewmp/"
dopusforumurl := "https://resource.dopus.com/"
doupushomepageurl := "https://www.gpsoft.com.au"
dopusdocsurl := "https://docs.dopus.com/doku.php?id=introduction"

;***************************************************************************
;************************* HOTKEYS *****************************************
;***************************************************************************
; this section is not for editing, it only reference for the message box popup
; changing the keys here won't change them inside the script.

hotkeys = 
(
-----[[[[ HOTKEYS ]]]]-----
Extended CAPSLOCK KEY Functionality Using AutoHotkey:
	+ Capslock, Single Tap, COPY
	+ Capslock, Double Tap, PASTE
	+ Capslock, HOLD, Show Extended Capslock Menu

Middle Mouse Button -- Alt Mouse Hotkey to OPEN MENU
Ctrl + Alt + F3 -- Alt Keyboard Hotkey to OPEN MENU

  Ctrl + Shift + F2 -- New Sticky Filled With Selection
  Ctrl + Alt + F2 -- New Empty Sticky Note
  Ctrl + Shift + R -- Reload Script
-------------------------------------------------- 
Alt + Capslock -- Toggle Capslock
Ctrl + Capslock -- Toggle Caplock
Shift + Capslock -- Switch between UPPERCASE & lowercase
-------------------------------------------------- 
--- Hotkeys for the Sticky Note GUI Windows ---
Alt + M -- Show Sticky GUI Quick Menu
Ctrl + S -- Save Sticky As
Ctrl + Shift + S -- Quick Save As '.txt'
Ctrl + N -- Create New Empty Temp Sticky
Ctrl + P -- Pin Sticky To Top
Ctrl + Shift + O -- Open Quick Notes Folder
Ctrl + ESC -- Close Stick without saving
**************************************************

         -----+++ OTHER HOTKEYS +++-----
Ctrl + Shift + `" -- Paste Clipboard in Quotes
	Ctrl + `" -- Put Quotes Around [*Selected Text*]
Win + H -- Add Auto Correct Hot Strings ...
		 ...(if include Auto Correct script is running)
-------------------------------------------------- 
==+++ SPECIAL IF Notepad++ ACTIVE HOTKEYS +++==
Right Click -- Can replace NP++ menu with this one. (optional)
Ctrl + Space -- Open Live Folder Menu... [*Experimental*]
	if a [* C:\Filepath.txt *] is selected it show's that files folder
	if nothing is selected it will show the folder of the Active file
	+ this can also work in Everything 1.5a on a selected file
	- this menu hotkey is turn off else where
Ctrl + Alt + N -- Open Active File in Alternative Text Editor Menu
**************************************************

TIP -- You can also click that Live Preview menu item at any time to see a message box of the text in your Clipboard, whether or not Live Preview is running.

) 
; "




return
;; First Return, END Auto execute

;---------------------------------------------------------------------------
;;; end case menu, end capslock  menu, end date menu, case, end


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

IfLive() ;; function ;; checks if Auto Copy is running
{
	global ClipSaved
    global LiveMenuEnabled
	; Global filename, dir, ext, filestem, drive
    if (LiveMenuEnabled)
    {
        ; do nothing continue with the Auto Copied clipboard data
    }
    else ; if not live
    {
        CopyClipboardCLM()  ; Copy before continuing
    }
}

CopyClipboardCLM() ;; Function
{
    global ClipSaved  ;Ensure global is used if ClipSaved is accessed elsewhere
	Global filename, dir, ext, filestem, drive, lastfolder
	global ClipSaved := ""
	sleep 100
    ClipSaved := ClipboardAll  ; Save the current clipboard contents
    sleep 200 ; todo broken fix adjust time longer if needed
    Clipboard := ""  ; Clear the clipboard
    Sleep 50  ; Adjust the sleep time if needed
	; WinGet, id, ID, A
    ; WinGetClass, class, ahk_id %id%
    ; if (class ~= "(Cabinet|Explore)WClass|Progman|dopus.lister")
        ; Send {F2}
    Sendinput, ^c ; Sendinput ^{vk43}  ; Send Ctrl+C COPY
    ClipWait, 0.5 
	if (ErrorLevel || Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$"))  ; Check if clipboard is empty, a tab, or just whitespace
    if ErrorLevel
    {
        TrayTip, Extended Caps Menu, Copy Failed!`nOr you did not have text selected.`nYour Previous Clipboard Content is Restored., 2, 18
		sleep 90
		Clipboard := ClipSaved  ; Restore the clipboard
		ClipSaved := ""  ; clear the variable
		sleep 90
        return
    }
}

PasteClipboardCLM() ;; function
{
; sleep 3000
	
    global ClipSaved
	sleep 200
			; WinGet, id, ID, A  ; Get the ID of the active window ; errorlevel checks
			; WinActivate, ahk_id %id%  ; Activate the window
	; WinGet, id, ID, A
    ; WinGetClass, class, ahk_id %id%
    ; if (class ~= "(Cabinet|Explore)WClass|Progman|dopus.lister")
        ; Send {F2}
    send, ^v ; Sendinput, ^{vk43} ;, Sendinput, ^v  ; Send Ctrl+V
    Sleep 800  ; Give the system time to paste the clipboard content
	; RestoreClipboard()
    Clipboard := ClipSaved  ; {Restore the saved clipboard contents}
	sleep 400
    ClipSaved := ""  ; Clear the variable
}

RestoreClipboard() ;; function
{
global Clipsaved
sleep 100
Clipboard := ClipSaved
sleep 500
ClipSaved := ""  ; Clear the variable
; return
}


BackupClipboard() ;; Function
{
Global ClipSaved
Clipsaved := "" ; clear the last ClipSaved
sleep 50
ClipSaved := ClipboardAll ; save the current clipboard to memory 
sleep 400
Clipboard := "" ; empty the clipboard, ready to revive content
sleep 50
}

PastePlain() ;; function
{
	global ClipSaved
    ClipSaved := ClipboardAll  ; save original clipboard contents
	sleep 300
    Clipboard := Clipboard  ; remove formatting
	sleep 150
    Send ^v  ; send the Ctrl+V command
    Sleep 100  ; give some time to finish paste (before restoring clipboard)
    Clipboard := ClipSaved  ; restore the original clipboard contents
    ClipSaved := ""  ; clear the variable
}

basiccopy() ;; function
{
Global ClipSaved
SendInput, ^c ;Send ^{vk43} ;Ctrl C ;  Send {Ctrl down}c{Ctrl up}  ; Send ^{vk43}
; return
}

basiccut() ;; Function
{
Global ClipSaved
SendInput, ^x
; return
}

basicpaste() ;; Function
{
Global ClipSaved
Send ^{vk56} ;Ctrl V ; SendInput, ^v, send, ^v
; return
}

getfileinfo() ;; function 
{
Global ClipSaved, filename, dir, ext, filestem, drive, activefile, lastfolder, highlighted
iflive()
sleep 100
cleanupPATHstring()
sleep 100
; SplitPath, Clipboard, filename, dir, ext, filestem, drive
}

cleanupPATHstring() ;; function ; trims white space, removes single & double quotes, converts ahk dirvar, splits file path into parts, from the selected FILE PATH.
{
Global ClipSaved, filename, dir, ext, filestem, drive, lastfolder, activefile
sleep 90
Clipboard := RegExReplace(RegExReplace(Clipboard, "\r?\n"," "), "(^\s+|\s+$)") ; remove line breaks\returns
sleep 90
Clipboard := RegExReplace(Clipboard, "^(?:'*)|('*$)") ; remove single quotes '' leading - trailing
sleep 90
Clipboard := StrReplace(clipboard,"""") ; remove double quotes "" leading - trailing
sleep 90
If (SubStr(Clipboard, 1, 8) = "file:///") { ;convert file url path to win path
	Clipboard := SubStr(Clipboard, 9) ; Remove the 'file:///' prefix
	Clipboard := StrReplace(Clipboard, "%20", " ") ; Decode spaces
	Clipboard := StrReplace(Clipboard, "/", "\") ; Convert to Windows backslashes
}
If InStr(Clipboard, "`%A_ScriptDir`%") ; expand AHKs var
	{
		clipboard := StrReplace(Clipboard, "%A_ScriptDir%", A_ScriptDir)
		dir := RegexReplace(clipboard, "\\[^\\]*$", "")
	}
if InStr(Clipboard, "%") { ; Expand environment variables if present
Transform, Clipboard, Deref, %Clipboard%
}
SplitPath, Clipboard, filename, dir, ext, filestem, drive
lastfolder := dir ;claude
lastfolder := RegExReplace(lastfolder, ".*\\([^\\]+)\\?$", "$1")
sleep 90

}

cleanupsearchforweb:
cleanupsearchforweb()
return

cleanupsearchforWEB() ;; function
{
global clipsaved
    ; Modify some characters that screw up the URL
    ; RFC 3986 section 2.2 Reserved Characters (January 2005):  !*'();:@&=+$,/?#[]
    StringReplace, Clipboard, Clipboard, `r`n, %A_Space%, All
    StringReplace, Clipboard, Clipboard, #, `%23, All
    StringReplace, Clipboard, Clipboard, &, `%26, All
    StringReplace, Clipboard, Clipboard, +, `%2b, All
    StringReplace, Clipboard, Clipboard, ", `%22, All ; '"

; todo isolate this clean up string move this search line else where ;todo trim the run out of the function
    Run % "https://www.google.com/search?hl=en&q=" . clipboard ; uriEncode(clipboard) ; "
	SLEEP 300
Clipboard := ClipSaved
return
}


/*
basiccopy:
SendInput, ^c ;Send ^{vk43} ;Ctrl C ;  Send {Ctrl down}c{Ctrl up}  ; Send ^{vk43}
return
basiccut:
SendInput, ^x
return
basicpaste:
Send ^{vk56} ;Ctrl V ; SendInput, ^v
return
*/

;***** END ***************CLIPBOARD FUNCTIONS *************** END **********
;*************************************************************************** 

;***************************************************************************
;*************************** MENU, CTXT, FUNCTIONS *************************
;*************************************************************************** 
Upper() ;; function
{
global ClipSaved
	IfLive()
    StringUpper, Clipboard, Clipboard
    PasteClipboardCLM()
}

Lower() ;; function
{
global ClipSaved
	IfLive()
    StringLower, Clipboard, Clipboard
    PasteClipboardCLM()
}
Title() ;; function
{
global ClipSaved
    ExcludeList := ["a", "about", "above", "after", "an", "and", "as", "at", "before", "but", "by", "for", "from", "nor", "of", "or", "so", "the", "to", "via", "with", "within", "without", "yet"]
    ExactExcludeList := ["AutoHotkey", "iPad", "iPhone", "iPod", "OneNote", "USA"]
	IfLive()
    TitleCase := Format("{:T}", Clipboard)
    for _, v in ExcludeList
        TitleCase := RegexReplace(TitleCase, "i)(?<!\. |\? |\! |^)(" v ")(?!\.|\?|\!|$)\b", "$L1")
    for _, v in ExactExcludeList
        TitleCase := RegExReplace(TitleCase, "i)\b" v "\b", v)
    TitleCase := RegexReplace(TitleCase, "im)\b(\d+)(st|nd|rd|th)\b", "$1$L{2}")
    Clipboard := TitleCase
    PasteClipboardCLM()
}
Sentence() ;; Function
{
global ClipSaved
    ExactExcludeList := ["AutoHotkey", "iPad", "iPhone", "iPod", "OneNote", "USA"]
	IfLive()
    StringLower, Clipboard, Clipboard
	; todo, look up & clean up these reg ex lines
    ; Clipboard := RegExReplace(Clipboard, "(((^|([.!?]\s+))[a-z])| I | I')", "$u1")  ;og line from caps_menu
	Clipboard := RegExReplace(Clipboard, "((?:^|\R|[.!?]\s+)[a-z])|(\bi\b)|(\bi'\b)", "$u1") ; added by gpt not inclding this last one  --> Func("Capitalize"))
    ; Clipboard := RegExReplace(Clipboard, "((?:^|[.!?]\s+)[a-z])", "$u1")  ; fastkeys
    for _, v in ExactExcludeList
        Clipboard := RegExReplace(Clipboard, "i)\b" v "\b", v)
    PasteClipboardCLM()
}

Invert() ;; Function
{
global ClipSaved
    IfLive()
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

camel() ;; Function
{
global ClipSaved
    IfLive()
    StringUpper, Clipboard, Clipboard, T
    FirstChar := SubStr(Clipboard, 1, 1)
    StringLower, FirstChar, FirstChar
    camelCase := SubStr(Clipboard, 2)
    camelCase := StrReplace(camelCase, A_Space)
    Clipboard := FirstChar camelCase
    PasteClipboardCLM()
}
Pascal() ;; Function
{
global ClipSaved
    IfLive()
    StringUpper, Clipboard, Clipboard, T
    Clipboard := StrReplace(Clipboard, A_Space)
    PasteClipboardCLM()
}

Capital() ;; Function
{
global ClipSaved
    ExactExcludeList := ["AutoHotkey", "iPad", "iPhone", "iPod", "OneNote", "USA"]
    IfLive()
    CapitalCase := Format("{:T}", Clipboard)
    for _, v in ExactExcludeList
        CapitalCase := RegExReplace(CapitalCase, "i)\b" v "\b", v)
    Clipboard := CapitalCase
    PasteClipboardCLM()
}

Alternating() ;; function
{
global ClipSaved
    IfLive()
	sleep 175
    Inv_Char_Out := ""
    StringLower, Clipboard, Clipboard
	sleep 175
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


addDot() ;; function
{
global ClipSaved
    IfLive()
	sleep 175
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

removedot() ;; function
{
global ClipSaved
    IfLive()
	sleep 300
	StringReplace, Clipboard, Clipboard, ., %A_Space%, All
	sleep 300
    PasteClipboardCLM()
}

addunderscore() ;; function
{
global ClipSaved
    IfLive()
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

removeunderscore() ;; function
{
global ClipSaved
    IfLive()
	sleep 300
	StringReplace, Clipboard, Clipboard, _, %A_Space%, All
	sleep 300
    PasteClipboardCLM()
}

adddash() ;; function
{
global ClipSaved
    IfLive()
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
removedash() ;; function
{
global ClipSaved
    IfLive()
	sleep 300
	StringReplace, Clipboard, Clipboard, -, %A_Space%, All
	sleep 300
    PasteClipboardCLM()
}

FixLineBreaks() ;; function
{
global ClipSaved
    IfLive()
	Clipboard := RegExReplace(Clipboard, "\R", "`r`n")
	sleep 300
    PasteClipboardCLM()
}

removeextras() ;; function
{
global ClipSaved
    IfLive()
	Loop
		{
		StringReplace, Clipboard, Clipboard, %A_Space%%A_Space%, %A_Space%, UseErrorLevel
		if ErrorLevel = 0
		    break
		}
    PasteClipboardCLM()
}
;********* END *********** MENU, CTXT, FUNCTIONS ********** END ************
;***************************************************************************
;************************* MENU, CFORM, FUNCTIONS **************************
;***************************************************************************

wrapparen:
global clipsaved
    IfLive()
	sleep 300
	  Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
      Clipboard := "(" Clipboard ")"
	  sleep 300
    PasteClipboardCLM()
sleep 300
return

squbracket() ;; function
{
global ClipSaved
    IfLive()
	  Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
	  sleep 20
      Clipboard := "[" Clipboard "]"
	  sleep 500
    PasteClipboardCLM()
}

wrappercent() ;;Function
{
global ClipSaved
	IfLive()
	  Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
      Clipboard := "`%" Clipboard "`%"
	PasteClipboardCLM()
}
Reverse() ;; function
{
global ClipSaved
    IfLive()
	temp2 =
	  StringReplace, Clipboard, Clipboard, `r`n, % Chr(29), All
      Loop Parse, Clipboard
      temp2 := A_LoopField . temp2     ; Temp2
      StringReplace, Clipboard, temp2, % Chr(29), `r`n, All
    PasteClipboardCLM()
}

OpenEmojiKeyboard() ;; function
{
    Send {LWin down}.
    Send {LWin up}
}

spread() ;; function
{
global ClipSaved
    IfLive()
	Clipboard := RegExReplace(Clipboard, "(?<=.)(?=.)", " ")
	sleep 750
    PasteClipboardCLM()
}

; sorttext:
sorttext() ;; function
{
Global ClipSaved
    IfLive()
	Sort, Clipboard
	sleep 750
    PasteClipboardCLM()
}

cbrakectswrapped:
IfLive()
Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
Tmp:=Clipboard
sleep 90
Tmp = `{%Tmp%`}
Clipboard =
Sleep 200
Clipboard := Tmp
sleep 90
PasteClipboardCLM()
return

wrapincbrackets:
IfLive()
Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
Tmp:=Clipboard
sleep 90
Tmp = `{`n%Tmp%`n`}
Clipboard =
Sleep 90
Clipboard := Tmp
sleep 90
PasteClipboardCLM()
return

commentblock:
IfLive()
Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
Tmp:=Clipboard
sleep 90
Tmp = `/`*`n`n %Tmp% `n`n`*`/
Clipboard =
Sleep 20
Clipboard := Tmp
sleep 90
PasteClipboardCLM()
return

wrapinxmlcomment:
IfLive()
Tmp:=Clipboard
sleep 90
Tmp = <`!-- %Tmp% -->
Clipboard =
Sleep 30
Clipboard := Tmp
sleep 90
PasteClipboardCLM()
return

dopusK:
IfLive()
Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
sleep 20
Tmp:=Clipboard
sleep 90
Tmp = <kbd>%Tmp%</kbd>
Clipboard =
Sleep 90
Clipboard := Tmp
sleep 90
PasteClipboardCLM()
return

CodeLine:
IfLive()
Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
Tmp:=Clipboard
sleep 100
Tmp = ``%Tmp%``
Clipboard =
Sleep 20
Clipboard := Tmp
sleep 100
PasteClipboardCLM()
return

CodeBox:
IfLive()
Tmp := Clipboard
sleep 90
Tmp = ```````n%Tmp%`n``````
Clipboard =
Sleep 20
Clipboard := Tmp
sleep 90
PasteClipboardCLM()
return

forumcodebox:
IfLive()
tmp := Clipboard
sleep 20
tmp = [code]`n%tmp%`n[/code]
sleep 20
clipboard := tmp
sleep 90
pasteclipboardclm()
return



RASpace:
IfLive()
TempText:=Clipboard
sleep 175
Loop
{
 StringReplace, TempText, TempText, %A_Space%,, UseErrorLevel ;%A_Space%%A_Space%
 if ErrorLevel = 0
   break
}
sleep 90
Clipboard =
Sleep 175
Clipboard := TempText
sleep 90
PasteClipboardCLM()
Return



removeillegal:
Global ClipSaved
IfLive()
; StringLower, clipboard, clipboard
sleep 90
clipboard := RegExReplace(clipboard, "[/\\~?^%*:|<>]", "$u1") ; Remove symbols: /\?%~^*:|<>
sleep 90
clipboard := RegExReplace(clipboard, "\p{C}","") ; Remove control characters
sleep 90
Clipboard := RegExReplace(Clipboard, "\p{So}+", "")  ; Remove emojis and other symbols in Unicode 'Symbols, Other' category
sleep 90
PasteClipboardCLM()
return


;******** END ************ MENU, CFORM, FUNCTIONS ********* END ************
;*************************************************************************** 


;***************************************************************************
;************************* MENU, CTOOLS, FUNCTIONS ************************* 
;***************************************************************************

clearclip:
run, cmd /C "echo off | clip"
return

viewclip:
msgbox, %clipboard%
return

appendclip:
{
    global ClipSaved := ClipboardAll ; Save the current clipboard content
	sleep 350
    Clipboard := ""  ; Clear the clipboard to capture new content
    Sleep 75  ; Ensure enough time for clipboard to clear
    Sendinput, ^c ; Send Ctrl+C to copy the selected text
    ClipWait, 1  ; Wait for clipboard to be filled with new text

    if !ErrorLevel
    {
        NewText := Clipboard  ; Get the copied text ; If text is successfully copied, append it to the clipboard
        Clipboard := ClipSaved  ; Restore the original clipboard content
		sleep 200
        Clipboard := Clipboard . "`n`n" NewText  ; Append the new text to the existing content
        Sleep 350  ; Allow time for clipboard to update
    }
    else
    {
        Clipboard := ClipSaved ; If no text was copied, restore the original clipboard content
		tooltip, Error! Your selection was not`nappend to the Clipboard.`nPrevious Clipboard Restored.
		sleep 2500
		tooltip
    }
    ; MsgBox, Text has been appended to the clipboard! ; Optional: Notify the user that text was appended
    return
}
return

guicaps() ;; function, gui, OSD overlay
{
; gui, caps: hide
	Gui, caps: +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
	Gui, caps: Font, cffb900 s12 bold, WW Digital
	Gui, caps: Color, af001d ; changes background color
	Gui, caps: add, picture, xm w18 h18, %A_ScriptDir%\Icons\keyboard-caps-lock-filled xfav arrow send move_256x256.ico
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
;; sticky gui gui, sticky

CreateStickyNote(FromClipboard := false) {
    Global StickyCount, stickytext, pin, b1
    
    StickyCount++
    if (FromClipboard) {
        stickytext := Clipboard
    } else {
        stickytext := ""
    }
    
    Gui, sticky%StickyCount%:new, +Resize +MinSize250x250 -MaximizeBox
    Gui, sticky%StickyCount%: Margin, 10, 10
    Gui, sticky%StickyCount%: Color, 3D5400, 090909
    Gui, sticky%StickyCount%: Font, s11 cEEEEC9, Consolas
    
    ; Add controls
    Gui, sticky%StickyCount%: Add, picture, x10 y10 h24 w24 vpin gpintotop, %A_ScriptDir%\Icons\pin-off_26x26.ico
    Gui, sticky%StickyCount%: Add, button, x45 y10 h24 w224 vb1 gguimenubutton, Sticky &Menu (Alt + M)
    Gui, sticky%StickyCount%: Add, Edit, wanttab x10 y45 w630 h280 vStickyText, %stickytext%
    
    GuiControl, Focus, stickytext
    Gui, sticky%StickyCount%: show,, AHK Temp Sticky Note #%StickyCount%
    return
}

sticky1GuiSize:
sticky2GuiSize:
sticky3GuiSize:
sticky4GuiSize:
sticky5GuiSize:
sticky6GuiSize:
sticky7GuiSize:
sticky8GuiSize:
sticky9GuiSize:
sticky10GuiSize:
NewWidth := A_GuiWidth - 30
NewHeight := A_GuiHeight - 55
GuiControl, Move, StickyText, w%NewWidth% h%NewHeight%
return


CopyToStickyNote() { ; Call this function from the menu with clipboard content
Global FromClipboard ; xadd
    iflive()  ; Your function to handle clipboard and other conditions
    Sleep, 200
    CreateStickyNote(true)  ; Pass true to indicate clipboard content should be used
	sleep 700
    restoreclipboard()  ; Restore clipboard content after using it
    Sleep 30
}

ahkstickygui() { ; Call this from a hotkey to create an empty sticky note
    CreateStickyNote(false)  ; Pass false for an empty sticky note
}

guimenubutton: ; todo add right click menu to sticky gui
    menu, gui, show
return

;; gui, sticky, hotkeys, gui sticky hotkeys ;*************************
#IfWinActive AHK Temp Sticky Note #
^s:: ; save sticky as doc
savestickyAS()
return

^+s:: ; quick save sticky as .txt
savestickyquick()
return

~rbutton:: ; show capslock menu on stickys
;; Note: Since Edit controls have their own context menu, a right-click in one of them will not launch GuiContextMenu. // workaround 
menucaseshow()
return

^n:: ; new empty stick note
gosub newsticky
return

^+O:: ; open quick notes dir
gosub openquick
return

^esc:: ; close sticky
gosub guidestory
return
^p:: ; pin\unpin sticky to top
global pin, pinoff, pinon, pinstartpic, StickyCount
gui, submit, nohide
gosub pintotop
return
#IfWinActive

savestickyquick() ;; function
{
global stickytext
static stickyname
WinGetTitle, activeWindowTitle, A
if (InStr(activeWindowTitle, "AHK Temp Sticky Note"))
	{
    stickyNum := RegExReplace(activeWindowTitle, ".*#(\d+).*", "$1")

    Gui, sticky%stickyNum%: Submit, NoHide ; Get the text from the active sticky window
    GuiControlGet, stickytext, sticky%stickyNum%:, StickyText

	inputbox, stickyname, Create a File Name, Give your new quick note a name.`n`nNo .ext needed. It will auto-save as a .txt file.`n`nIt will automatically be saved to`n%A_ScriptDir%\Extended Capslock Menu QUICK Notes\`n`nYou can go there quickly from the settings menu., ,  ,300 , ,
	if (stickyName = ""){
		tooltip, Canceled by user`nor Quick Note requires a name.
		sleep 1500
		tooltip
		return
		}
	if errorlevel
		{
		tooltip, CANCELED by User.
		sleep 1000
		tooltip
		return
		}
	FileCreateDir, Extended Capslock Menu QUICK Notes
	sleep 750
	fileappend,%Stickytext%,%A_ScriptDir%\Extended Capslock Menu QUICK Notes\%stickyname%.txt
	sleep 1000
	}
return
}

savestickyAS() ;; function
{
global stickytext
static savepath

WinGetTitle, activeWindowTitle, A ; Get the title of the currently active window

if (InStr(activeWindowTitle, "AHK Temp Sticky Note")) ; Check if the active window is a sticky note by looking for the "AHK Temp Sticky Note" in the title
	{
    stickyNum := RegExReplace(activeWindowTitle, ".*#(\d+).*", "$1") ; Extract the sticky number from the title (assuming the format is "AHK Temp Sticky Note #N")

    Gui, sticky%stickyNum%: Submit, NoHide ; Get the text from the active sticky window
    GuiControlGet, stickytext, sticky%stickyNum%:, StickyText

    FileSelectFile, SavePath, S16, %A_MyDocuments%, Save Selected Text as a New Document, Text Files (*.txt)

    if SavePath =  ; If no savefile was selected\named
    {
        tooltip, File Path Cannot Be Blank`nSave Canceled.
        sleep 1500
        tooltip
        Return
    }
    if !InStr(SavePath, ".")  ; Check if the user provided a file extension, if not..
    {
        SavePath := SavePath . ".txt"  ; Append .txt if .ext left black by user
    }
    sleep 500
    FileAppend, %stickytext%, %SavePath%  ; Append the %stickytext% to the selected file
    sleep 800
	}
return
}

/*
; savestickyAS:
savestickyAS() ;; Function
{
global stickytext
static savepath
gui, submit, nohide
FileSelectFile, SavePath, S16, %A_MyDocuments%, Save Selected Text as a New Document, Text Files (*.txt) ; Prompt for where to save the file
    if SavePath =  ; If no file was selected
        {
		tooltip, File Path Cannot Be Blank`nSave As Canceled.
		sleep 1500
		tooltip
		Return
		}
    if !InStr(SavePath, ".")  ; If no '.' in the file name
	{
		SavePath := SavePath . ".txt"  ; Append .txt
	}
sleep 800
FileAppend, %stickytext%, %SavePath%  ; Append clipboard contents to the selected file
	sleep 1500
return
}
*/



guidestory: 
global activeWindowTitle
global stickyNum
WinGetTitle, activeWindowTitle, A
if (InStr(activeWindowTitle, "AHK Temp Sticky Note"))
	{
    stickyNum := RegExReplace(activeWindowTitle, ".*#(\d+).*", "$1")
    Gui, sticky%stickyNum%: Destroy
	}
return


pintotop:
global pin, pinoff, pinon, pinstartpic, StickyCount
gui, submit, nohide
If pinstartpic = 1
	{
	gui, submit, nohide
	; send, {Blind}{RButton Up}{Esc}#+t ;; requires powertoys
	sleep 10 ;;IGNORE 4 SHARE
	GuiControl,,pin, %pinon%
	pinstartpic=2
	Gui, sticky%StickyCount%: +alwaysontop
	tooltip, Pinned to Top!
	sleep 1000
	tooltip
	menu, gui, icon, Pin \ Unpin to Top`tCtrl + P, %pinon%
	return
	}
If pinstartpic = 2
	{
	gui, submit, nohide
	; send, {Blind}{RButton Up}{Esc}#+t ;; requires powertoys
	sleep 10 ;;IGNORE 4 SHARE
	GuiControl,,pin, %pinoff%
	pinstartpic=1
	Gui, sticky%StickyCount%: -alwaysontop
	tooltip, Unpinned!
	sleep 1000
	tooltip
	menu, gui, icon, Pin \ Unpin to Top`tCtrl + P, %pinoff%
	return
	}
Return

newtxtfile: ;todo, clean up, match iflive() add alt text file .ext, e.g. .ahk, .css, etc
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
	sleep 400
  clipboard=%origClipboard%
  sleep 250
msgbox, 4, Selected Text Saved, Your selected text as been saved to...`n`n%SavePath%`n`nWould you like to Edit this file now?`n`nThis popup will auto-close in 5 seconds., 5
	ifmsgbox yes
		{
		try run "%texteditor%" "%SavePath%"
		catch
		run notepad.exe "%SavePath%"
		}
	ifmsgbox no
		return
	Ifmsgbox timeout
		return
return

quicktxtfile() ;; function
{
Global ClipSaved
  iflive()
  if (Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$"))
		{
        TrayTip, CAPSkey, Your Clipboard is Empty.`nAborted Auto Save., 4, 18
		sleep 500
		restoreclipboard()
        return
		}
  inputbox, notename, Create a File Name, Give your new quick note a name.`n`nNo .ext needed. It will auto-save as a .txt file`nIt will automatically be saved to`n%A_ScriptDir%\Extended Capslock Menu QUICK Notes\`n`nYou can go there quickly from the settings menu., , ,
  if (noteName = ""){
	tooltip, Canceled
	sleep 1500
	tooltip
	restoreclipboard()
	return
	}
FileCreateDir, Extended Capslock Menu QUICK Notes
sleep 750
fileappend,%Clipboard%,%A_ScriptDir%\Extended Capslock Menu QUICK Notes\%notename%.txt
sleep 2500
restoreclipboard()
Sleep 250
return
}

newnpppdoc:
Global ClipSaved 
; copyclipboardclm()
IfLive()
try run, %notepadpp%
if errorlevel
	{
	tooltip, Notepad++ was not found.
	sleep 1500
	tooltip
	restoreclipboard()
	return
	}
WinWaitActive, ahk_exe notepad++.exe,,7
if errorlevel
	{
	tooltip, Notepad++ could not be actived.
	sleep 1500
	tooltip
	restoreclipboard()
	return
	}
sleep 300
sendinput, ^n
sleep 300
pasteclipboardclm()
return
copylocationbar: ; Copy Location Bar
global clipsaved
	backupclipboard()
	sleep 75
	sendinput, ^l
	sleep 100
	sendinput, ^c
	clipwait, 0.5
	if errorlevel
		{
		tooltip, Error Copying The Location Bar`nYour Clipboard is being restored.
		sleep 2000
		tooltip
		sleep 50
		restoreclipboard()
		sleep 200
		return
		}
	else
		{
		send, {esc}
		tooltip, Location Bar Copied
		sleep 1500
		tooltip
		}
return

TextToSpeech:
Global ClipSaved 
	iflive()
    text := Clipboard
	restoreclipboard()
    if (text != "") ; Speak the text if it's not empty
        SpeakText(text)
    else
       {
		tooltip No text selected for Text-to-Speech.
		sleep 2000
		tooltip
		}
Return

SpeakText(Text) { ;; function
    ; Create a COM object for the SAPI.SpVoice TTS engine
    voice := ComObjCreate("SAPI.SpVoice")
    ; Speak the provided text
    voice.Speak(Text)
    ; Release the COM object
    voice := ""
}

SaveClipboardAsTxt:
    FileSelectFile, SavePath, S16, %A_MyDocuments%, Save Clipboard As, Text Files (*.*) ; Prompt for where to save the file
	if SavePath = ; if no savepath was selected
		{
		Tooltip, ERR.`nA valid FileName & Path`nmust be provided.`nSaving Clipboard Canceled.
		Sleep 2500
		Tooltip
        Return
		}
	if !InStr(SavePath, ".")  ; If no '.' in the file name
		{
			SavePath := SavePath . ".txt"  ; Append .txt
			sleep 10
    FileAppend, %Clipboard%, %SavePath%  ; Append clipboard contents to the selected file
		}
	else
		{
		FileAppend, %Clipboard%, %SavePath%  ; Append clipboard contents to the selected file
		}
    ; MsgBox, Clipboard saved to %SavePath%!
	sleep 500
	msgbox, 4, Clipboard Saved, The text in your Clipboard as been saved to...`n`n%SavePath%`n`nWould you like to Edit this file now?`n`nThis popup will auto-close in 5 seconds., 5
	ifmsgbox yes
		{
		try run %texteditor% "%SavePath%"
		catch
		run notepad.exe "%SavePath%"
		}
	ifmsgbox no
		return
	Ifmsgbox timeout
		return
Return


;************************* END, CTOOLS, FUNCTIONS **************************
;*************************************************************************** 



;***************************************************************************
;************************* MENU, WEB, FUNCTIONS ****************************
;************************* MENU, CFIND, FUNCTIONS **************************
;*************************************************************************** 
ahksearchmenu:
{
;; run, https://www.autohotkey.com/search/?q=%Find%
		global ClipSaved
		IfLive()
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := Clipsaved
        }
		; sleep 200
		; try Run, vivaldi.exe "--new-window"
		; sleep 200
		Run "http://www.google.com/search?q=%clipboard%+site:autohotkey.com"
		sleep 200
		; stringreplace, clipboard, clipboard, #,_, all
		; sleep 200
		; run, "https://www.autohotkey.com/docs/v1/lib/%clipboard%.htm"
		; sleep 200
		; stringreplace, clipboard, clipboard, _,,all
		; sleep 200
		; run, "https://www.autohotkey.com/docs/search.htm?q=%clipboard%&m=2"
        ; Sleep 200
		; run, "https://www.autohotkey.com/search/?q=%clipboard%"
        Clipboard := ClipSaved
}
return

Dictionarydotcom:  ; added to caps\ccase menu
IfLive()
Word := RegExReplace(Clipboard, "[^\w\s]")
Run, https://www.dictionary.com/browse/%Word% ;?s=t
Run, https://www.thesaurus.com/browse/%Word%
sleep 40
Clipboard := ClipSaved
ClipSaved := ""
return

; definethis:
definethis() ;; function
{
		global ClipSaved
		IfLive()
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }

		Run, https://www.google.com/search?q=define+%Clipboard%
        Sleep 200
        Clipboard := ClipSaved ; Restore the original clipboard content
return
}


wikipediasearch:
		ClipSaved := ClipboardAll  ; Save the current clipboard content
		sleep 250
        Clipboard := ""  ; Clear the clipboard to prepare for new content
		sleep 175
        Send, ^c
        ClipWait 1 ; Wait for the clipboard to contain data
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }
		Run, https://en.wikipedia.org/wiki/%Clipboard%
        Sleep 200
        Clipboard := ClipSaved ; Restore the original clipboard content
return

googlethis:
        ClipSaved := ClipboardAll  ; Save the current clipboard content
        Clipboard := ""  ; Clear the clipboard to prepare for new content
		sleep 175
        Send, ^c
        ClipWait 1 ; Wait for the clipboard to contain data
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }
        Run, http://www.google.com/search?q=%Clipboard%
        Sleep 200
        Clipboard := ClipSaved ; Restore the original clipboard content
Return

youtubethis() ;; function
{
       IfLive()
	   global ClipSaved
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }
        Run, http://www.youtube.com/search?q=%Clipboard%
        Sleep 200
        Clipboard := ClipSaved ; Restore the original clipboard content
return
}


;; todo clean up this double menu call
ahksearch() ;; function
{
Global ClipSaved
; = "https://www.google.com/search?q=site:ahkscript.org+$(Currentselection)"
; = "https://www.google.com/search?q=site:ahkscript.org+$(Currentselection)"
;; run, https://www.autohotkey.com/search/?q=%Find%
        ClipSaved := ClipboardAll  ; Save the current clipboard content
        Clipboard := ""  ; Clear the clipboard to prepare for new content
sleep 175
        Send, ^c
        ClipWait  ; Wait for the clipboard to contain data
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }
        ; Run, https://www.autohotkey.com/search/?q=%Clipboard%
		run, "https://www.google.com/search?q=site:autohotkey.com+%Clipboard%"
        Sleep 200
        Clipboard := ClipSaved ; Restore the original clipboard content
return
}

;************************* END, MENU, CFIND, FUNCTIONS *********************
;*************************************************************************** 
;; todo, move these to hotkeys or matching menu section


dtMenuAction:
	; clipboard := ""
	; clipboard := A_ThisMenuItem
	SendInput %A_ThisMenuItem%{Raw}%A_EndChar%
	; SendInput %A_ThisMenuItem%
Return

;************************* TEST SWAP START SECTION *************************
; !S:: test swap testing errors
/*
; [ text_swap script info]
; version     = 1.2
; description = swap text at a certain character or word, interactively
; author      = davebrny
; source      = https://gist.github.com/davebrny/8bdbef225aedf6478c2cb6414f4b9bce
*/
text_swap:
repeat_last_swap_interactive:
textswap()
return

textswap() ;; Function case menu
{

global
selected := selected_text()
loop, % strLen(selected) / 1.6
    div .= "- "  ; make divider
mouseGetPos, mx, my
if inStr(a_thisLabel, "repeat_last")
     swapped := swap(selected, this := last_swap)
else swapped := selected
toolTip, % "swap at: """ . this . """`n`n" selected "`n" div "`n" swapped, mx, my+50

loop,
    {
    input, new_input, L1, {enter}{esc}{backspace}
    endkey := strReplace(errorLevel, "EndKey:", "")
    if endkey contains enter,escape
        break
    if (endkey = "backspace")
        stringTrimRight, this, this, 1
    if inStr(selected, new_input)
        this .= new_input

    swapped := swap(selected, this)
    tooltip, % "swap at: """ . this . """`n`n" selected "`n" div "`n" swapped, mx, my+50
    }

tooltip, ; clear
if (this != "") and (endkey = "enter")
    {
    last_swap := this
    clipboard := swapped
    send ^{v}
    sleep 300
    }
clipboard := save_clipboard
this := ""
div  := ""
return
}

repeat_last_swap:
if (last_swap)
    {
    clipboard := swap(selected_text(), last_swap)
    send ^{v}
    sleep 300
    clipboard := save_clipboard
    }
return

selected_text() {
    global save_clipboard
    save_clipboard := clipboardAll
    clipboard := ""
    send ^{c}
    clipWait, 0.3
    if clipboard is space
        return
    if !inStr(clipboard, "`n")
        return clipboard
}

swap(string, at_this) {
    stringGetPos, pos, string, % at_this
    stringMid, left, string, pos, , L
    stringGetPos, pos, string, % at_this
    stringMid, right, string, pos + strLen(at_this) + 1

    stringRight, left_space,  left,  % strLen(left)  - strLen(rTrim(left))
    stringLeft,  right_space, right, % strLen(right) - strLen(lTrim(right))

    return lTrim(right) . left_space . at_this . right_space . rTrim(left)
}
;*************************  END text swap SECTION **************************

;***************************************************************************
;*************************  MENU, COPEN, FUNCTIONS ********TODO*************
;*************************************************************************** 

openfoldersimple() ;; Function ; xnote -not use here for ref
; If the copied text is a valid folder, open it in Windows Explorer
	; Else If ThisMenuItem =&Open Folder...
	{
		Clipboard := StrReplace(clipboard, "/", "\")
		if (FileExist(clipboard))
			; Run explorer.exe /select`,%string%
			Run %clipboard%
		else
		{
			replacement := RegExReplace(clipboard, "[^\\\/]+[\\\/]?$")
			length := StrLen(replacement)
			subString := SubStr(replacement, 1, length - 1)
			; Run %subString%
			Run explorer.exe %subString%
		}
	return
	}

; todo testing, next two functions ;; this works 


; Ctrl+Shift+O to open containing folder in Explorer.
; Ctrl+Shift+E to open folder with current file selected.
; Supports SciTE and Notepad++.
; source; https://www.autohotkey.com/docs/v1/Hotkeys.htm#Function
; ^+o::
; ^+e::
    editor_open_folder() {
        WinGetTitle, path, A
        if RegExMatch(path, "\*?\K(.*)\\[^\\]+(?= [-*] )", path)
            if (FileExist(path) && A_ThisHotkey = "^+e")
                Run explorer.exe /select`,"%path%"
            else
                Run explorer.exe "%path1%"
	return
    }

; ^+o:: ;open path from selection
; copyclipboardCLM()
; sleep 75
; OpenDIRselection()
; return
OpenDIRselection: ;;;;; () ;; Function
Global ClipSaved, filename, dir, ext, filestem, drive, lastfolder
iflive()
sleep 75
cleanuppathstring()
sleep 75

    if (FileExist(Clipboard))  ; Check if it's a file or directory ; //If path exists
    {
        FileGetAttrib, Attributes, %Clipboard%
        if (InStr(Attributes, "D"))  ; If it's a directory
        {
            try Run, %Clipboard%  ; Open folder
			sleep 20
			restoreclipboard()
			Return
        }
        else ; If it's a file
        {
			try Run, %dopusrt% /cmd Go "%Clipboard%" NEWTAB TOFRONT
			catch
			Run explorer.exe /select`,"%clipboard%"
			sleep 20
			restoreclipboard()
			Return
				; Run, %dir%, , , PID ;this works, does not select file from string
				; Optional: Select the file after opening the folder (explorer)
				; Run, explorer.exe /select,"%Clipboard%"  ; todo see if I can get this run with explorer, gag
        }
    }
		else if InStr(Clipboard, "%")  ; If it contains environment variables
		{
			try Run, %dopusrt% /cmd Go "%Clipboard%" NEWTAB TOFRONT
			catch
			try Run explorer.exe /select`,"%clipboard%"
			sleep 20
			restoreclipboard()
			Return
		}
		else ; If the path doesn't exist, show the "Directory Not Found" message
		{
			ToolTip, Directory Not Found
			Sleep, 1500
			ToolTip
		sleep 20
			restoreclipboard()
			sleep 100
		}
return

; ^!o:: ;run selected files, dir , websites
; copyclipboardclm()
; RUNfromselection: ;run
; RUNfromselection()
; return

; RUNfromselection() ;; Function old
RUNfromselection: 
;; this function has been hacked together from 3 different script snippets sources: https://www.autohotkey.com/boards/viewtopic.php?t=64520  https://www.winhelponline.com/blog/open-file-folder-path-clipboard-using-shortcut/   https://www.autohotkey.com/boards/viewtopic.php?t=33822
Global ClipSaved, filename, dir, ext, filestem, drive, lastfolder
iflive()
sleep 75
cleanuppathstring()
sleep 75
dir := clipboard 
FileGetAttrib, Attributes, % dir

;Folders\\Dirs
IfInString, Attributes, D 
		{
		try run, "%clipboard%"
		}
	else If InStr(clipboard, "%") ; env vars
		{
		 try run, %dopusrt% /cmd Go "%clipboard%" NEWTAB TOFRONT 
			catch
		 Run, explorer.exe /select`,"%clipboard%"
		sleep 400
		restoreclipboard()
		sleep 90
		Return
		}
;open\\run files by ext
	if % ext = "ahk"
		{
		try Run %texteditor% "%clipboard%"
		catch
		run notepad.exe "%clipboard%"
		sleep 400
		restoreclipboard()
		sleep 90
		Return
		}
	else if % ext = "ico" 
		{
		try Run %xnviewmp% "%clipboard%"
			catch
		try Run "%clipboard%"
		sleep 400
		restoreclipboard()
		sleep 30
		Return
		}
	else if % ext = "exe" 
		{
		run "%clipboard%",,useerrorlevel  ; Run % "Explorer.exe /select, " Chr(34) clipboard Chr(34) ;; Chr(34) is quote this opens explore with the file selected
		if errorlevel
				{
				LogError(Clipboard)
				Tooltip, ERR! Could not open this File or Dir.`nPlease Check the Path.
				Sleep, 2000
				Tooltip
				}
		sleep 400
		restoreclipboard()
		sleep 30
		return
		}
	else
		{
		run "%clipboard%",, UseErrorLevel
			if errorlevel
				{
				LogError(Clipboard)
				Tooltip, ERR! Could not open this File or Dir.`nPlease Check the Path.
				Sleep, 2000
				Tooltip
				}
		sleep 100
		restoreclipboard()
		sleep 30
		return
		}

	; else ;if nothing above matches, google this selection
		; {
		; run, "http://www.google.com/search?q=%clipboard%"
		; }
	; else ;if nothing above matches, notify
		; {
		; logerror(clipboard)
		; tooltip File Not Found or Selected`nERR. Line#: %A_LineNumber%
		; sleep 2000
		; tooltip
		; }
sleep 200
restoreclipboard()
sleep 30
return



; ^!+O:: ; copy file to clipboard from path selection
; copyclipboardclm()
; sleep 100
COPYfromselection: ; copy file or directory to clipboard from path selection
Global ClipSaved, filename, dir, ext, filestem, drive, lastfolder, activefile, filetoclip
    iflive()
    Sleep 30
    cleanuppathstring()
    Sleep 30
    filetoclip := Clipboard
    Sleep 30
    if (FileExist(filetoclip))
    {
        try
        {
            Run, %dopusrt% /CMD Clipboard COPY FILE "%filetoclip%", , UseErrorLevel
            if (ErrorLevel)
            {
                throw ; poor lambs are not using the DOPE!
            }
            ToolTip, %filetoclip% ...`n... copied to your Clipboard with Directory Opus!`nPaste it anywhere you would normally would paste a File.
            Sleep, 2500
            ToolTip
			return
        }
        catch ; If Directory Opus fails or is not installed, prompt the user to select a destination folder using a COPY TO... popup
        {
            FileSelectFolder, destFolder, , 3, Select destination folder to copy to:
            if (destFolder != "")
            {
                if (InStr(FileExist(filetoclip), "D")) ; Check if selection is a directory
                {
                    SplitPath, dir, , lastFolder  ; Get the name of the directory
					lastfolder := RegExReplace(dir, ".*\\([^\\]+)\\?$", "$1")
					; msgbox, filetoclip:%filetoclip%`n`ndir:%dir%`n`nfilestem:%filestem%`n`nfilename:%filename%`n`next:%ext%`n`nlastfolder:%lastfolder%`n`nLine#: %A_LineNumber%
                    FileCreateDir, %destfolder%\%lastfolder% ; Create the destination directory if it doesn't exist
                    FileCopyDir, %filetoclip%, %destfolder%\%lastfolder%, 1 ; Copy the directory contents to the destination path
                    if (ErrorLevel)
                    {
                        ToolTip, Failed to copy directory:`n%filetoclip% to %destfolder%\%lastfolder%`n`nERR. Line#: %A_LineNumber%
                    }
                    else  
                    {
                        ToolTip, Directory copied to:`n%destfolder%\%lastfolder%
                    }
					sleep 2000
					tooltip
					restoreclipboard()
					return
                }
                else ; a file is selected
                {
                    FileCopy, %filetoclip%, %destFolder%\%filename%, 1 ; Copy file to destFolder
                    if (ErrorLevel)
                    {
                        ToolTip, Failed to copy file: %filetoclip% to`n%destFolder%\%filename%`n`nERR. Line#: %A_LineNumber%
                    }
                    else
                    {
                        ToolTip, File copied to:`n%destFolder%\%filename%
                    }
                }
                Sleep, 2000
                ToolTip
            } 
            else
            {
                ToolTip, Copy canceled by user.
                Sleep, 1500
                ToolTip
            }
			tooltip
            restoreclipboard()
            return
        }
    }
    else
    {
        ToolTip, ERR. File or Directory Not Found:`n@ %filetoclip%
        Sleep, 2000
        ToolTip
        restoreclipboard()
        return
    }
return
Edittxtfile:
iflive()
Sleep, 30
cleanupPATHstring()  
dir := Clipboard
FileGetAttrib, Attributes, %dir%
if FileExist(Clipboard) {
    if InStr(Attributes, "D") { ; Check if it's a directory
        Tooltip, ERR! Line# %A_LineNumber%`nCan't Edit a Folder in a Text Editor
        Sleep, 2000
        Tooltip
        Sleep, 20
        return
    } else { ; it it's a file send to text editor
        try {
            Run, %texteditor% "%Clipboard%"
        } catch {
            Run, notepad.exe "%Clipboard%"
        }
        if ErrorLevel {
            Tooltip, ERR! Line# %A_LineNumber%`nOops! Maybe you can't open that file in a Text Editor?
            Sleep, 1500
            Tooltip
            return
        }
    }
} else {
    Tooltip, ERR! Line# %A_LineNumber%`nFile Does Not Exist!
    Sleep, 1500
    Tooltip
    return
}
RestoreClipboard()
return

gowebsite:
Global ClipSaved
iflive()
sleep 90
;websites//urls
	If SubStr(ClipBoard,1,8)="https://"
		{
		Run, %clipboard%
		}
	else If SubStr(ClipBoard,1,4)="www."
		{
		Run, "https://%Clipboard%"
		}
	else If SubStr(ClipBoard,1,7)="http://"
		{
		Run, %Clipboard%
		}
	else if (RegExMatch(Clipboard, "\.(com|net|org|edu|gov|co\.uk|ca|de|fr|jp|au)$"))
		{
		run, "https://www.%clipboard%"
		}
	else If (SubStr(Clipboard, 1, 4) = "ftp.")
		{
		Run, "ftp://" Clipboard
		}
	else if (RegExMatch(Clipboard, "^\d{1,3}(\.\d{1,3}){3}$"))  ; Matches IP addresses
		{
			Run, "http://" Clipboard
		}
	else
		{
		ToolTip, Err. Incorrect URL Format
		Sleep, 2000
		ToolTip
		}
	 ; RegExMatch(Clipboard, "^(https?://)?(www\.)?[a-zA-Z0-9-]+\.(com|net|org|edu|gov|co\.uk|ca|de|fr|jp|au)") ;Full URL with Optional Protocol and Subdomain
sleep 300
restoreclipboard()
sleep 20
return
LogError(Path) { ;; logerror function
global clipsaved, filename, ext, filestem, dir, lastfolder
    if ErrorLevel
    {
    FileAppend, % "*`n+-=START=-+`nError Info...`nTime: " A_Now "`n@ Line: " A_LineNumber "`nClipboard := " Clipboard "`n`nWhich Hotkey: " A_ThisHotkey "`nThis Label: " A_ThisLabel "`nWhich Menu: " A_ThisMenu "`nWhich Menu Item: " A_ThisMenuItem "`nMenu Pos: " A_ThisMenuItemPos "`nFull Menu text...`nmenu`, " A_thismenu "`, Add`, " A_ThisMenuItem "`, " A_ThisLabel "`n`nVars listed.....`nFilename: " filename "`nExt: " ext "`nFilestem: " filestem "`nDir: " dir "`nParent-LastFolder: " lastfolder "`n`nEvent Info: " A_EventInfo "`nLast Error: " A_LastError "`nThis Func: " A_ThisFunc "`n+-=END=-+`n", %A_ScriptDir%\%A_scriptname%- ERROR LOG.txt
	sleep 500
    Return
    }
}
; OpenREGfromselection:
;Open Regedit and navigate to RegPath.
;RegPath accepts both HKEY_LOCAL_MACHINE and HKLM formats.
; source: https://www.autohotkey.com/board/topic/85751-regjump-jump-to-registry-path-in-regedit/
RegJump(RegPath)
{
global regeditor
global ClipSaved
iflive()
sleep 20
cleanuppathstring()
Clipboard := RegExReplace(clipboard, "^[+-]", "")  ; Matches '-' or '+' at the start of the line
sleep 30
regpath := Clipboard
sleep 30
; sleep 30
; clsid := RegExReplace(RegPath, ".*\\(\{[^\}]+\})$", "$1")  ; Capture the {clsid} as a var
; sleep 30
RegPath := RegExReplace(RegPath, "\\\{[^}]+\}", "")  ;removes the \{clsid} from base key
;if clsid doesn't exist in ones reg it will break the path returning nothing. Same for keys, thou  clsids change more often so I'm cutting them here.
sleep 30
; msgbox, %clsid%
	;NOTE, Must close Regedit so that next time it opens the target key is selected
	; WinClose, Registry Editor ahk_class RegEdit_RegEdit
	if winexist("ahk_class RegEdit_RegEdit")
		{
		WinClose, Registry Editor ahk_class RegEdit_RegEdit
		; Winkill, Registry Editor ahk_class RegEdit_RegEdit
		winwaitclose, Registry Editor ahk_class RegEdit_RegEdit,,7
		}
	If (SubStr(RegPath, 0) = "\") ;remove trailing "\" if present
		RegPath := SubStr(RegPath, 1, -1)
	;Extract RootKey part of supplied registry path
	Loop, Parse, RegPath, \
	{
		RootKey := A_LoopField
		Break
	}
	;Now convert RootKey to standard long format
	If !InStr(RootKey, "HKEY_") ;If short form, convert to long form
	{
		If RootKey = HKCR
			StringReplace, RegPath, RegPath, %RootKey%, HKEY_CLASSES_ROOT
		Else If RootKey = HKCU
			StringReplace, RegPath, RegPath, %RootKey%, HKEY_CURRENT_USER
		Else If RootKey = HKLM
			StringReplace, RegPath, RegPath, %RootKey%, HKEY_LOCAL_MACHINE
		Else If RootKey = HKU
			StringReplace, RegPath, RegPath, %RootKey%, HKEY_USERS
		Else If RootKey = HKCC
			StringReplace, RegPath, RegPath, %RootKey%, HKEY_CURRENT_CONFIG
	}
sleep 150
	;Make target key the last selected key, which is the selected key next time Regedit runs
	RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %RegPath%
	sleep 300
	Run, Regedit.exe
	winwaitactive, ahk_class RegEdit_RegEdit,,7
	if errorlevel
		{
		tooltip, Couldn't run Regedit`nSearch Canceled.
		sleep 2000
		tooltip
		sleep 30
		RestoreClipboard()
		return
		}
	; ControlSend,,^{l} ahk_class RegEdit_RegEdit
	sleep 900
	; sendinput, ^{l}
	; controlfocus, edit1, ahk_class RegEdit_RegEdit ; works
	; sleep 30
	; send, {right}
	; sleep 30
	; sendraw, \%clsid%
	; sendinput, {enter}
	; sleep 200
	restoreclipboard()
	; sleep 30
return
}

copydetails() ;; function ; menu, copen, funtion ; Use CMD to save open folder contents info to clipboard
{
global clipsaved
global dir
		; Else If (ThisMenuItem ="&Copy File Names and Details from Folder to Clipboard...")
		; source into: https://lexikos.github.io/v2/docs/FAQ.htm#output
		iflive()
		sleep 175
		SplitPath, clipboard, , dir
		clipboardTemp := dir . "\clipboard.txt"
		RunWait %comspec% ' "/c dir "%dir%" /a /o /q /t > "%clipboardTemp%" "', , hide
		clipboardFile := FileOpen(clipboardTemp, "rw")
		clipboard := clipboardFile.Read()
		clipboardFile.Close()
		FileDelete, %clipboardTemp%
	return
}

filetoclipboard() ;; Function ; menu, copen, function ; Save file contents to clipboard
	; Else If (ThisMenuItem ="&File to Clipboard...")
{
Global ClipSaved
static file
iflive()
sleep 90
cleanuppathstring()
sleep 100
if (fileexist(clipboard))
	{
		file := FileOpen(Clipboard, "r")
		sleep 100
		clipboard := File.Read()
		sleep 500
		file.Close()
		sleep 350
		tooltip, The content of selected file`nhas been copied into your clipboard.
		sleep 2000
		tooltip
		sleep 75
		return
	}
	else
	{
		tooltip, Err. Copying the content of the selected file failed.`nFile could not be found.
		sleep 2000
		tooltip
		sleep 175
		restoreclipboard()
		sleep 100
		return
	}
return
}

altmakedup: ; todo, if dup already exisit, rename (1), (2) etc, rather than replacing
; msgbox,VAR CHECK - FILE CHECK - SPLITPATH CHECK - ERROR CHECK`nthis script: %A_ScriptName%`nline#: %A_LineNumber%`n`nthis label: %A_ThisLabel%`nthis func: %A_ThisFunc%`n`nActiveFile: %activefile%`nfilename: %filename%`ndir: %dir%`next: %ext%`nfilestem: %filestem%`n`naltogether-dir\fs-ext:`n%dir%\%Filestem%.%ext%`n`nclipboard: %clipboard%`n`nclipsaved: %clipsaved%`ntmp: %tmp%`n`nline#: %A_LineNumber%
if (FileExist(activefile))
	{
		FileCopy, %dir%\%filename%, %dir%\%filestem%-CopyDup.%ext%
		if errorlevel
			{
			MsgBox, 262196, CopyDup Error!, ERROR!`nThe file "%filestem%-CopyDup.%ext%" already exists.`n`nDo you want to Overwrite it?, 7
			IfMsgBox yes
				{
					FileCopy, %dir%\%filename%, %dir%\%filestem%-CopyDup.%ext%,1
					sleep 500
					tooltip, File Overwritten`,`n%dir%\%filestem%-CopyDup.%ext%
					sleep 2000 
					return
				}
			IfMsgBox no
				return
			IfMsgBox timeout
				return
			}
		sleep 500
		tooltip, New File Created`n%dir%\%filestem%-CopyDup.%ext%
		sleep 2000
	}
	else
	{
		Tooltip, ERR. File Does Not Exist!`nOr you have selected a directory.
		Sleep 2000
	}
tooltip
sleep 10
return

makedup: ;; todo, I need to make a dir errorlevel check here
Global ClipSaved,activefile,filename,dir,ext,filestem
iflive()
sleep 30
cleanuppathstring()
SplitPath, Clipboard, filename, dir, ext, filestem, drive
if (FileExist(clipboard))
	; {
	; FileGetAttrib, Attributes, %Clipboard%
        ; if (InStr(Attributes, "D"))  ; If it's a directory
        ; {
            ; msgbox, You're about to Duplicate a Directory`n`ndir: %dir%`n`nClipboard: %clipboard%`n`nContinue?
			; ifmsgbox no
				; {
				; restoreclipboard()
				; return
				; }
			; ifmsgbox yes
				; {
				; continue
				; }
			; sleep 20
			; restoreclipboard()
			; Return
        ; }
	; }
	; if else ; it's a file
	{
	FileCopy, %dir%\%filename%, %dir%\%filestem%-CopyDup.%ext%
		if errorlevel
			{
			MsgBox, 262196, CopyDup Error!, ERROR!`nThe file "%filestem%-CopyDup.%ext%" already exists.`n`nDo you want to Overwrite it?, 7
			IfMsgBox yes
				{
					FileCopy, %dir%\%filename%, %dir%\%filestem%-CopyDup.%ext%,1
					sleep 500
					tooltip, File Overwritten`,`n%dir%\%filestem%-CopyDup.%ext%
					sleep 2000 
					return
				}
			IfMsgBox no
				return
			IfMsgBox timeout
				return
			}
		sleep 500
	tooltip, New File Created`n%dir%\%filestem%-CopyDup.%ext%
	sleep 2000
	}
	else
	{
	Tooltip, ERR. File Does Not Exist!`nOr you have selected a directory.
	Sleep 2000
	}
tooltip
sleep 10
restoreclipboard()
return
movefiletofolder() ;; function , menu, copen, function ; Create a new subfolder, add hightlighted file to it
	; Else If ThisMenuItem =&Add File to Subfolder...
{
Global ClipSaved
iflive()
sleep 90
cleanuppathstring()
sleep 90
SplitPath, clipboard, , dir, , nameNoExt
if FileExist(clipboard)
	{
FileCreateDir, %nameNoExt%
FileMove, %clipboard%, %nameNoExt%
	}
else
	{
	tooltip, Err. File Not Found.
	sleep 1500
	tooltip
	}
sleep 300
restoreclipboard()
return
}

movefiletoparentfolder() ;; function ; menu, copen, function ; Take file out of current folder and add to parent folder
	; Else If ThisMenuItem =&Pull File Out to Parent Folder...
{
Global ClipSaved
global dir
iflive()
sleep 100
cleanuppathstring()
; todo add errorlevel here
SplitPath, clipboard, , dir
SplitPath, dir, , dir2
FileMove, %clipboard%, %dir2%
sleep 400
restoreclipboard()
return
}


;************************* END menu, copen, functions, END *****************
;***************************************************************************


;*************************************************************************** 
;************************** EXTRA SOFTWARE FUNCTIONS ***********************
;************************* MENU, CFIND, FUNCTIONS ************************** todo separte this heading to its own functions
;***************************************************************************





















Findwitheverything: ; label-sub () ;; function ;selected text ;menu, cfind,
; Findwitheverything() ;; function ;selected text
; {
global clipsaved
	iflive()
	sleep 90
	try Run, %everything15a% -new-tab -s "%Clipboard%"
	; try Run, %everything15a% -s "%Clipboard%"
	sleep 800
	restoreclipboard()
	sleep 30
return
	
	/*
	runeverything()
; gosub runeverything
	sleep 100
	; sendinput, ^t ; open new tab
	; sleep 50
	ControlSend, , ^{L} ; activates search bar
	sleep 50
	sendinput, ^a
	sleep 50
	sendraw, %clipboard%
	sleep 200
	restoreclipboard()
	sleep 200
; return
	*/

findastro:
iflive()
sleep 90
try run %astrogrep% /spath="c:" /stext="%clipboard%" /s 
sleep 800
restoreclipboard()
sleep 20
return
; evindex: ;; label-gosub
evindex: ; () ;; function ; todo - broken When ev is not installed?? add errorlevel exit
global clipsaved
Sleep 100
iflive()
sleep 200
; gosub runeverything
; try Run, %everything15a% -s* si:* "%Clipboard%" 
try Run, %everything15a% -new-tab -s* si:* "%Clipboard%" 
; runeverything()
; sleep 300
; sendinput, ^l
; sleep 50
; sendinput, ^a
; sleep 50
; sendraw, si*: "%Clipboard%"
sleep 300
restoreclipboard()
sleep 175
return


EVfile:
	global Clipsaved
	iflive()
	sleep 30
	cleanuppathstring()
	sleep 30
	SplitPath, Clipboard, file, , , , 
	try run %everything15a% -newtab -s "%file%"
	sleep 800
	; runeverything()
	; sendinput, ^l
	; sleep 20
	; sendinput, ^a
	; sleep 200
	; sendraw, %file%
	; sleep 800
	restoreclipboard()
return

/*
 if InStr(Clipboard, "%")  ; If it contains environment variables ; todo, where did I take this out from? put back or oktd
		{
		runeverything()
		; gosub runeverything
		; WinWaitActive , ahk_class EVERYTHING, , 7, ,
		; if errorlevel
			; return
		sendinput, ^l
		sleep 20
		sendinput, ^a
		sleep 200
		sendraw, "%filename%"
		; sendraw, "%dir%"
		}
else
{


}

*/

; EVpath() ;; function
EVpath:
global Clipsaved, filename, dir, ext, filename, drive
iflive()
sleep 20
cleanuppathstring()
sleep 20
; SplitPath, Clipboard, filename, dir, ext, filestem, drive ; Extract parts of the path
	if InStr(Clipboard, "%")  ; If it contains environment variables
		{
		
		try run %everything15a% -newtab -s "%clipboard%"
		sleep 500
		RestoreClipboard()
		return
		}
	if !(FileExist(Clipboard))
		{
        ToolTip, ERR. Directory or File Not Found!`nTrying Parent Dir Instead.
        Sleep, 2000
        ToolTip
		try run %everything15a% -newtab -s """"%dir%""""
		}
	else if (FileExist(clipboard))
	{
		FileGetAttrib, Attributes, %Clipboard%
        if (InStr(Attributes, "D"))  ; If it's a directory
		{
			clipboard := RegExReplace(clipboard, "\\$") ; removed trailing "\" 
			sleep 200
		    ; send, "%Clipboard%"
			try run %everything15a% -newtab -s """"%clipboard%""""
		}
		else ; If it's a file
		{
		sleep 200
		; try run %everything15a% -newtab -s "%dir%"
		try Run, %everything15a% -newtab -s """"%dir%""""
		}

	}
Sleep, 200
restoreclipboard()
sleep 90
return


findalllocalnpp:
WinGetClass, class, A
if (class != "Notepad++")  ; Check if the active window is not Notepad++
    {
	tooltip, This active window is not Notepad++`nSearch Canceled
	sleep 1500
	tooltip
	; restoreclipboard()
	sleep 50
	return
	}
sendinput, ^f
sleep 350
sendinput, !d
return


findinfilesnpp() ;; function
{
Global ClipSaved
IfLive()
runnotepadpp()
; gosub runnotepadpp ;todo check errorlevels
; winwaitactive, ahk_class Notepad++, , 7 ; - Notepad++
; if errorlevel
	; {
	; Tooltip, Could not run Notepad++`nSearch Canceled
	; sleep 1500
	; tooltip
	; restoreclipboard()
	; sleep 250
	; return
	; }
sendinput, ^+f
winactivate, Find in Files
sleep 300
sendraw, %clipboard%
sleep 30
sendinput, {tab}
sleep 30
sendinput, {bs}
sleep 30
sendinput, {tab 4}
; sendinput, {enter}
Sleep 100
Clipboard := ClipSaved
sleep 100
return
}

;************************* END, MENU, CFIND, FUNCTIONS *********************


;*************************************************************************** 
;************************* MENU, APPSKEY ***********************************
;*************************************************************************** 
stop:
return

runeverything() ;; function
{
Global everything15a
if !FileExist(everything15a)    ; Check if the Everything executable exists
    {
        tooltip, %everything15a%`n...could not be FOUND. Err1`nSearch Canceled
        sleep 2000
        tooltip
		sleep 300
        restoreclipboard()
		sleep 175
		; gosub stop
        return  ; Stop execution if file does not exist
    } else {
IfWinExist, ahk_class EVERYTHING  ; Check if Everything is running
    {
        WinActivate, ahk_class EVERYTHING  ; Activate the window if found
    }
   Else
    {
        try Run, %everything15a%
    }
Sleep 300  ; Wait a moment for the program to start
WinWaitActive, ahk_class EVERYTHING, , 7  ; Wait for the window to be active
    if (ErrorLevel)  ; Check if there was an error waiting for the window
    {
        tooltip, %everything15a%`n...could not be ACTIVATED. Err2`nSearch Canceled
        sleep 2000
        tooltip
		sleep 300
        restoreclipboard()
		sleep 175
        return  ; Stop execution if the window did not activate
    }
return
}

}


; ^+E::
runeverything: ;; label
Global everything15a
if !FileExist(everything15a)    ; Check if the Everything executable exists,
    { 
        tooltip, %everything15a%`n...could not be FOUND. Err1`nSearch Canceled
        sleep 2000
        tooltip
		sleep 300
        restoreclipboard()
		sleep 175
		; gosub stop
        return  ; Stop execution if file does not exist
		;  !! TODO !! fix, broken!, add a isinstalled(%3rdpartysoftware%) error level check to run%xxx% function\label(s)
    }
IfWinExist, ahk_class EVERYTHING  ; Check if Everything is running
    {
        WinActivate, ahk_class EVERYTHING  ; Activate the window if found
    }
   Else
    {
        try Run, %everything15a%
    }
Sleep 300  ; Wait a moment for the program to start
WinWaitActive, ahk_class EVERYTHING, , 7  ; Wait for the window to be active
    if (ErrorLevel)  ; Check if there was an error waiting for the window
    {
        tooltip, %everything15a%`n...could not be ACTIVATED. Err2`nSearch Canceled
        sleep 2000
        tooltip
		sleep 300
        restoreclipboard()
		sleep 175
        return  ; Stop execution if the window did not activate
    }
Return


runnotepadpp() ;; function
{
Global notepadpp
    IfWinExist, ahk_class Notepad++ ; ahk_exe notepad++.exe
    {
        WinActivate, ahk_class Notepad++
    }
    Else
    {
        try Run, %notepadpp%
    }
winwaitactive, ahk_class Notepad++, , 7 ; - Notepad++
if errorlevel
	{
	; Tooltip, Could not run Notepad++`nSearch Canceled
	tooltip, %notepadpp%`n...could not be launched`nSearch Canceled.
	sleep 1500
	tooltip
	restoreclipboard()
	sleep 250
	return
	}
; Return
}

; ^+N::
runnotepadpp: ;; label
    Global notepadpp
    IfWinExist, ahk_class Notepad++
    {
        WinActivate, ahk_class Notepad++
    }
    Else
    {
		try Run, %notepadpp%
    }
Return

runDopus() ;; function
{
Global dopus  ; Make sure to declare the VARIABLE as global
    IfWinExist, ahk_class dopus.lister ; ahk_exe dopus.exe
    {
        WinActivate, ahk_class dopus.lister
    }
    Else
    {
        try Run, %dopus%
    }
winwaitactive, ahk_class dopus.lister, , 7 ; - Notepad++
if errorlevel
	{
	; Tooltip, Could not run Notepad++`nSearch Canceled
	tooltip, %dopus%`n...could not be launched`nSearch Canceled.
	sleep 1500
	tooltip
	restoreclipboard()
	sleep 250
	return
	}
; return
}

; ^+D::
runDopus: ;; label
    Global dopus  ; Make sure to declare the VARIABLE as global
    IfWinExist, ahk_class dopus.lister
    {
        WinActivate, ahk_class dopus.lister
    }
    Else
    {
        try Run, %dopus%
    }
return

runtextify: ; label
try run, Textify.exe
; catch
; try run, "C:\Users\%A_UserName%\AppData\Local\Programs\Textify\Textify.exe"
catch
try run, %textify%
; catch
; try run, "%textify%"
return

runtextgrab:
try run, %textgrab%
return

/*
; runtextgrab:
; try run, %textgrab%
; return

 ; ^+E::
; runeverything:
; runeverything()
; return

; runeverything()  Function
; {
; global
 ; SetTitleMatchMode, 2
; IfWinExist, ahk_class EVERYTHING  Everything 1.5
	; {
	; WinActivate, ahk_class EVERYTHING  Everything 1.5
	 ; WinWait, ahk_exe Everything64.exe
	 ; soundbeep, 800,
	 ; Sleep 200
	 ; ControlSend, , ^{L} ;this activates the search bar if its not already selected
	; }
; ifwinnotexist, ahk_class EVERYTHING  ahk_exe Everything64.exe
; {
	; try Run, %everything15a%
	; sleep 300
; }
; }

 ; ^+n::
; runnotepadpp:
; runnotepadpp()
; return

; runnotepadpp()  function
; {
; Global
 ; SetTitleMatchMode, 2
; IfWinExist, ahk_class Notepad++
	; {
	; WinActivate, ahk_class Notepad++
	; } else {
		; try Run, %notepadpp%
	; }
; IfWinnotexist, ahk_class Notepad++
	; try run, %notepadpp%
 ; return
; }

 ; ^+D::
; runDopus:
; runDopus()
; return

; runDopus()  Function
; {
; Global
 ; SetTitleMatchMode, 2
; IfWinExist, ahk_class dopus.lister
	; {
	; WinActivate, ahk_class dopus.lister
	 ; soundbeep, 900,
	; } else {
	; try Run, %dopus%
	; }
; ifwinnotexist, ahk_class dopus.lister
	; try run, %dopus%
  ; return
; }
*/

runditto: ; label
;; todo, dittobutton:
; send, ^!#v
ifwinnotexist, ahk_exe Ditto.exe ; ("ahk_exe Ditto.exe")
{
try run %ditto%
sleep 500
try run, %ditto% /Open ;;1
catch
try run, "%ditto%" "/Open" ;;2
catch
try run, "%ditto%" /Open ;;3
catch
try run, %ditto% "/Open" ;;4
catch
try run, Ditto.exe /Open ; will not work, for port installs
} else {
try run %ditto% /Open
}
return

abc:
try run, %A_ScriptDir%\AutoCorrect\AutoCorrect_2.0.ahk
return
;************************* END, MENU, APPSKEY ******************************

;***************************************************************************

;************************* menu, hotkeys ***********************************
; go hotkeys go to hotkeys
; #If !(WinActive("ahk_exe dopus.exe") || WinActive("ahk_exe notepad.exe") || WinActive("ahk_exe calc.exe")) ;; if not multipule

#If !(WinActive("ahk_exe dopus.exe"))  ; Exclude Directory Opus (dopus.exe) for following hotkeys
    ~MButton::
    menucaseshow()
    return
^+r:: ;Reload Script
reload:
tooltip, %ScriptName%`nis Reloading...
sleep 700
tooltip
SLEEP 30
reload
return
#If  ; End excluding dopus condition
^!f3:: ; alt hotkey
menucaseshow()
RETURN



$CapsLock::
    KeyWait CapsLock, T0.15
    if ErrorLevel
		{
		MenuCaseShow() ; hold, show menu
		}
    else
    {
        KeyWait CapsLock, D T0.15
        if ErrorLevel
            CopyClipboardCLM() ; Single Tap, COPY
        else
            Send ^v ; Double Tap, Paste clipboard content
    }
    KeyWait CapsLock
return

showsettingsmenu:
menu, cset, show
return
showopenmenu:
menu, copen, show
return
showtoolsmenu:
menu, ctools, show
return
showfindmenu:
menu, cfind, show
return
showdtmenu:
menu, dtmenu, show
return
showctxtmenu:
menu, ctxt, show
return
; Toggle CapsLock state via the GUI function
; *~CapsLock::
!Capslock::
^CapsLock::
ToggleCapsLock()
    ; CapsLockey(false, true)
return
^+':: ;paste clipboard text in "Quotes"
	saved := clipboard ; save clipboard contents
	Send, "%clipboard%" ; send clipboard content with your characters around it
	clipboard := saved ; restore clipboard
	saved := () ; clear saved
Return
^':: ;'Put selected text in "Quotes"
ClipQuote:
global clipsaved
copyclipboardclm()
sleep 20
clipboard = "%clipboard%"
StringReplace, clipboard, clipboard,%A_SPACE%",", All ;Remove spaces "introduced" by WORD
Sleep 300
pasteclipboardclm()
sleep 100
return


+CapsLock::    ; Switch between UPPERCASE & lowercase
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
return
^!f2:: ; my own stickies
newsticky:
; ahkstickygui()
; gosub ahkstickygui
CreateStickyNote()
return

^+F2:: ;; new sticky from selection
CopyToStickyNote()
return

Capsmenubutton:
menucaseshow()
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

/*
;; og v1 keep safe
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
    ; currentState := GetKeyState("CapsLock", "T")
    ; if (currentState)
        ; GuiControl,, MyText, CapsLock Status: ON
    ; else
        ; GuiControl,, MyText, CapsLock Status: OFF

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
*/


; og v2 with sound beep options, works, keep safe
 CapsLockey(state := false, toggle := false)
{
    global CAPSGuiToggle, beep_enabled

    ; If toggling, flip the current CapsLock state
    if (toggle)
        state := !GetKeyState("CapsLock", "T")

    ; Set Caps Lock state only if needed (prevents endless toggling)
    currentCapsState := GetKeyState("CapsLock", "T")
    if (state != currentCapsState)
        SetCapsLockState % state

    ; Update GUI text
    ; currentState := GetKeyState("CapsLock", "T")
    ; if (currentState)
        ; GuiControl,, MyText, CapsLock Status: ON
    ; else
        ; GuiControl,, MyText, CapsLock Status: OFF 

    CAPSGuiToggle := !CAPSGuiToggle ; Toggle the GUI visibility 
    if (CAPSGuiToggle)
    {
        if (beep_enabled)  ; Check if beeping is enabled
        {
            SoundBeep, 100, 100
            SoundBeep, 200, 200
        }
        ; Gui, caps: Show, x3370 y2059 NoActivate
        guicaps()
    }
    else
    {
        if (beep_enabled)  ; Check if beeping is enabled
        {
            SoundBeep, 200, 100
            SoundBeep, 100, 200
        }
        Gui, caps: Hide
    }
    return
} 

ToggleBeepSetting:
; global beep_enabled
    beep_enabled := !beep_enabled
	if (beep_enabled)
	{
		menu, cset, icon, Mute Sound on Capslock Toggle, %A_ScriptDir%\Icons\sound__32x32.ico
		tooltip, SoundBeeps on Capslock toggle is ON!
		iniwrite, 1, %inifile%, Beep_Enabled, key
	}
	else
	{
		menu, cset, icon, Mute Sound on Capslock Toggle, %A_ScriptDir%\Icons\sound_mute__32x32.ico
		tooltip, SoundBeeps on Capslock Toggle is OFF - MUTED!
		iniwrite, 0, %inifile%, Beep_Enabled, key
	}
sleep 1500
tooltip
return




#If GetKeyState("CapsLock", "T") && ShiftedNumRow  ; Check the toggle state
    `::+` ; Shifted Capslock
    1::+1 ; Shifted Capslock
    2::+2 ; Shifted Capslock
    3::+3 ; Shifted Capslock
    4::+4 ; Shifted Capslock
    5::+5 ; Shifted Capslock
    6::+6 ; Shifted Capslock
    7::+7 ; Shifted Capslock
    8::+8 ; Shifted Capslock
    9::+9 ; Shifted Capslock
    0::+0 ; Shifted Capslock
    -::+- ; Shifted Capslock
    =::+= ; Shifted Capslock
    [::+[ ; Shifted Capslock
    ]::+] ; Shifted Capslock
    \::+\ ; Shifted Capslock
#If


/*
!g:: ; alt Google Search
copyclipboardclm()
sleep 200
; todo, create function, add this to other web searches ↓
websearch:
global ClipSaved
iflive()
if RegExMatch(Clipboard, "^[^ ]*\.[^ ]*$")
{
	try
		Run %Clipboard%
	catch
		cleanupsearchforweb()


	if errorlevel
		{
		cleanupsearchforweb()
		}
}
else
{
    ; Modify some characters that screw up the URL
    ; RFC 3986 section 2.2 Reserved Characters (January 2005):  !*'();:@&=+$,/?#[]
    StringReplace, Clipboard, Clipboard, `r`n, %A_Space%, All
    StringReplace, Clipboard, Clipboard, #, `%23, All
    StringReplace, Clipboard, Clipboard, &, `%26, All
    StringReplace, Clipboard, Clipboard, +, `%2b, All
    StringReplace, Clipboard, Clipboard, ", `%22, All
    Run % "https://www.google.com/search?hl=en&q=" . clipboard ; uriEncode(clipboard) ; "
}
sleep 200
RestoreClipboard()
sleep 200
return

*/
;******* END ****************** MENU, , FUNCTIONS ********** END *************** 

;***************************************************************************
;************************* MENU, CSET, FUNCTIONS ***************************
;***************************************************************************

Lines:
listlines
return

ListLinesButton() ;; Function
{
listLines
sleep 400
WinMove, A, , 2035, 1281, 1080, 720
return
}

editsettings:
; try run, %texteditor% "%settingsfile%"
if FileExist(inifile)
	{
		try run, %texteditor% "%inifile%"
		catch
		run notepad.exe "%inifile%"
	}
	else
	{
	defaultIniSettings := GetDefaultIniSettings()
    FileAppend, %defaultIniSettings%, %inifile%
    Sleep 750
    ToolTip, Your settings file was not found.`nCreating a new one. One moment please.
    Sleep 2000
    ToolTip
    Sleep 200
	try run, %texteditor% "%inifile%"
		catch
	run notepad.exe "%inifile%"
	}
return


editscript:
try run %texteditor% "%filePath%"
catch
run, notepad.exe "%filePath%" 
return

ToggleGUI: ; todo, broken, fix
    CapsLockey(toggle := true)  ; Call the function to toggle the GUI
Return

ShiftedNumRow:
    ShiftedNumRow := !ShiftedNumRow  ; Toggle the state
    if (ShiftedNumRow)
        {
		ToolTip, Shifted # Row is Enabled`n`~`!`@`#`$`%`^`&`*`(`)`_`+`{`}`|
		menu, cset, togglecheck, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+
		iniwrite, 1, %inifile%, ShiftedNumRow, key
		}
    else
        {
		ToolTip, Shifted # Row is Disabled
		menu, cset, togglecheck, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+
		iniwrite, 0, %inifile%, ShiftedNumRow, key
		}
    Sleep, 1500
    ToolTip  ; Clear the tooltip
Return

ToggleReplaceNPPRightClick: ;() {
    ; global ReplaceNPPRightClick
    ReplaceNPPRightClick := !ReplaceNPPRightClick ; Toggle the setting
	menu, cset, togglecheck, Replace the NP++ Right Click Menu
	if (ReplaceNPPRightClick)
		{
		; menu, cset, togglecheck, Replace the NP++ Right Click Menu
		iniwrite, 1, %inifile%, ReplaceNPPRightClick, key
		tooltip, The Right Click menu of Notepad++`nhas been replaced with Extended Capslock Menu!`n`nUse with Caution`, sometimes NP++'s menu is still triggered.`nIt can cause errors at times.
		sleep 2000
		}
	else
		{
		; menu, cset, togglecheck, Replace the NP++ Right Click Menu
		iniwrite, 0, %inifile%, ReplaceNPPRightClick, key
		Tooltip, Notepad++'s Right Click Menu has been Restored.
		sleep 1000
		}
sleep 1500
tooltip
return
; }
visitgithub:
run https://github.com/indigofairyx/Extended_Capslock_Context_Menu
return

openquick:
	try run, %A_ScriptDir%\Extended Capslock Menu QUICK Notes\
		catch
	msgbox,,Extended Capslock Menu,Your Quick Notes Folder was not found.`n`nTry saving some notes first.,7
return

aboutsoftwareL:
msgbox, A quick note the Software Launchers.`n`nThe AutoHotkey Auto Spelling Correct Script is already included with this download. That will run. -- The others are not included.`n`nThese are great Software Tools for working with text, they are free to download and install. Links are in the about window.`n`nIf you install them anywhere other than their default locations you have to update the PROGRAM PATHS to the .exe files inside of the settings file manually.
return

suspendkeys:
suspend
tooltip, Hotkeys Paused
sleep 2500
tooltip
return



menureturn: ; do nothing donothing
return



exitscript: ; quit script
exitapp
return

aboutwindow:
Aboutcapswindow()
return

CloseMenu:
send, {esc}
return



runasadmin:
 If !A_IsAdmin
 	 Run *RunAs "%A_ScriptFullPath%"
return


GetDefaultIniSettings() {
    return "
    (
[Programs]
Texteditor = C:\Program Files\Notepad++\notepad++.exe

ahkstudio = C:\Program Files Portable\AHK Studio V2\AHK-Studio V2.ahk
astrogrep = C:\Program Files (x86)\AstroGrep\AstroGrep.exe
bcompare = C:\Program Files\Beyond Compare 5\BCompare.exe
ditto = C:\Program Files\Ditto\Ditto.exe 
dopus = C:\Program Files\GPSoftware\Directory Opus\dopus.exe
dopusrt = C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe
everything15a = C:\Program Files\Everything 1.5a\Everything64.exe
excel = C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE
geany = C:\Program Files\Geany\bin\geany.exe
markdownmonster = C:\Program Files\Markdown Monster\MarkdownMonster.exe
notepad4 = C:\Program Files Portable\Notepad4\Notepad4.exe
notepadpp = C:\Program Files\Notepad++\notepad++.exe
obsidian = C:\Users\%A_Username%\AppData\Local\Programs\obsidian\Obsidian.exe
obsidianshell = C:\Program Files Portable\ObsidianShell\ObsidianShell.CLI.exe
scite = C:\Program Files\AutoHotkey\SciTE\SciTE.exe
textgrab = C:\Program Files\Text-Grab\Text-Grab.exe
textify = C:\Users\%A_username%\AppData\Local\Programs\Textify\Textify.exe
vscode = C:\Users\%A_Username%\AppData\Local\Programs\Microsoft VS Code\code.exe
VSCodium = C:\Program Files Portable\vscodium-portable\VSCodium.exe
word = C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE
xnviewmp = C:\Program Files\XnViewMP\xnviewmp.exe

[Beep_Enabled]
key=1
[LiveMenuEnabled]
key=0
[ShiftedNumRow]
key=0
[ReplaceNPPRightClick]
key=0
[DarkMode]
key=1
    )"
}




 Aboutcapswindow() ;; function
{
global
aboutcapswindow := " ;"
(
This Extended Capslock Menu is a expanded context menu, written with AutoHotkey.
It made for working with text.
With this menu, after *[SELECTING SOME TEXT]* and then picking a menu item, the text will be copied to your clipboard (with your previous clipboard item preserved) so you can...
	+ search the web or local computer (using free software),
	+ save selected text to a New Text Document(s),
	+ added some simple & quick code formatting around text (e.g. .md, .xml, .ahk),
	+ modify text & cOnVeRt cAsE,
	+ create temp stickies,
	+ append\add new text to your existing clipboard,
	+ save the text content of your clipboard to a new document,
	+ paste rich text as plane text,
	+ shows a GUI above the system try when your caps lock is toggled on,
	+ run apps,
	+ the basic cut, copy, paste,
	+ insert the date and time,
	+ shift your number row when capslock is ON, e.g. 
		``1234567890-=[]\
		~!@#$`%^&*()_+{}|
From the 'Open\Run\Explore...     [ Files Menu ]' , you can ...
... When a Folder\File Path, Url, or Regkey path is [*SELECTED*] 
e.g. C:\Users\YourUserName\Documents\AutoHotkey\Some Script File.ahk
	- Open a folder
	- Run\Open the file without navigating to it.
	*- Copy the file\folder to your clipboard
		*Requires Directory Opus.
			for windows explorer users it
			opens a 'Copy To..' dialogue.
	- copy the Content of a text-base file to you clipboard without opening it
	- copy directory details via the CMD prompt
	- make a Duplicate File Copy, adding a ' -CopyDup.ext' suffix
	- move a file, into it own sub-folder, or up into its parent folder
	- open RegEdit, to the select key
	- open a website from a none-hyperlinked text
	- open Everything 1.5a, to explore the folder
	- open Everything 1.5a, to search the filename
	*+ open an alternative live folder to peek what else is there
		* this features is a bit Experimental
		* it has it own hotkey as well 'Ctrl' + 'Space'
		* its limited to Notepad++ and Everything
			* in Notepad++, if nothing is selected,
			  it will show the Dir of the active file.
++ Other Features With Toggle Options ++
	- light & dark mode toggle (DARK is default),
	- sound beeps for capslock state change (ON by default)
	- shifted number row, when caps on, (OFF by default)
		``1234567890-=
		~!@#$%^&*()_+
	*+ Replace Notepad++'s Right Click Menu with this one! (OFF by Default)
	*+ Auto Copy & Live Preview Mode
		* See Known Issues warning below.
... And more ... to come ...
************************************************** 
**************************************************
**************************************************
A note about the softwares used by Extended Caplock Menu...
&& Stored Prefs in the 'Edit -SETTINGS.ini File'
**************************************************
You can change a few defaults for the menu. Such as...,
	*- Auto Copy & Live Preview (OFF by default),
	*- Replace the NP++ Right Click Menu (OFF by Default)
	- Change Dark\Light Mode (Dark ON by default),
	- Sound Beeps on Caplock Toggle (ON by default),
	- Caplocks for Number Row (OFF by default),
These toggles are stored in the '.ini' file and will persist after reloading the menu.
**************************************************

**Links most all software referenced are listed below and on the about window**
**Or a Quick google search (from the menu) can help you find the other ones**
All software referenced in Extended Capslock Menu are free with the exception of Directory Opus.
Which I HIGHLY recommended as the most Amazing, Pleasant and Over-Powerful File Manager\Explorer Replacement ever made! Seriously I haven't use windows explorer in over decade because, just, no.
	You can find out more on their...
	- Forums, https://resource.dopus.com/
	- Website, https://www.gpsoft.com.au  and\or
	- Documentation, https://docs.dopus.com/doku.php?id=introduction. 
There is a free 60 day trail you try. Should you enjoy it
 you can use this reference code for 15% off your purchase --> ' CW4D0S289B4K '.
This menu tries to interact directly with the following programs...
	* Everything 1.5a
	* AstroGrep
	* Notepad++
	*$ Directory Opus
This menu will try to launch, but not interact with these other great text tools...
	* Ditto
	* Textify
	* Text Grab
	* Notepad++
	* AHK Auto Correct (already included with this download)
The Alternative Text Editor Menu for Notepad++ will try to open the active file in...
	* Notepad4
	* Geany
	* VS Code or Codium
	* Scite 4 AHK
	* AHK Studio
	* MS Word
	* MS Excel
	* Markdown Monster - $hareware
These are just the ones I use, if you know how, the 'alttxt' menu could be added to include other text editors From the '.ahk' script file.
+!+!+!+!++!+!+!+!++!+!+!+!+
(!IMPORTANT!)
 >>> ASSIGNING YOUR DEFAULT LOCATIONS FOR
 >>> THE OTHER SOFTWARE THIS MENU INTERACTS WITH.
 If you want to that is. The 3rd party software is Optional, more below.
+!+!+!+!++!+!+!+!++!+!+!+!+
The list of software used in the menu are referenced as variables from the '-SETTINGS.ini' file. They have to me updated to suite your system MANUALLY with a simple copy and paste. Use the 'Edit Settings.ini File' from the settings sub-menu as a quick shortcut to the file.
They will try to run from the default install locations, as set in the .ini, IF you have them installed in a different location you NEED update them there. Paste the true path to your .exe's. If not updated or if not installed the 3rd party software menu functions just won't do anything. SO THEY ARE NOT REQUIRED. Thou, don't delete or leave a reference empty as it could cause annoying popup messages box about variables not being assigned from AHK. 
	For example, Ditto (a clipboard manager),
	as custom portable install should be changed to...
		ditto = X:\Portable Program Files\Ditto\ditto.exe 
	rather than the default...
		C:\Program Files\Ditto\ditto.exe
Now anywhere in the script you see Run, %ditto% - it will be run from the file path your have provided here.
You can also set your favorite Default Text Editor here.
If not set text files will try to open with Notepad++.exe.
As I have preset it. If NP++ is not installed (at its default location),
then it defaults windows own Notepad.exe.
Replace...
	Texteditor = C:\Program Files\Notepad++\notepad++.exe
with...
	Texteditor = X:\Your favorite\text\editor.exe



***************************************************
***************************************************
****** KNOWN ISSUES & AUTO COPY MODE WARNING ******
***************************************************
This AutoHotkey menu is meant to be run on *[SELECTED TEXT.]*

It has been modified to show when text is not selected,
therefore, at times, it may not work as expected.

E.G. if no text is selected, in a text editor, and you fire a menu item that want to modify text,
it may copy and format an entire line and paste it back into the editor.

A.k.a., use with Caution!!! Especially when working in file manager!
If you use its copy and paste functions on files, or select a menu item with a file selected, it will copy files to your clipboard expecting text input to send to a search or modify before pasting.

It can me used on file names if you hit F2 (Rename) first to select text in the file name.
Though if window changes focus it will deselect the text causing the file itself to be copied. 

Additionally -------------------------  
When enabled the Live Preview & Auto Copy will automatically send CTRL + C to COPY, to any program you are in, EVERY TIME you open the menu!!!

This auto copy updates the live preview menu item. Otherwise it only send a Copy command after selecting a menu item that requires [SELECTED TEXT] to process, which is most of them.

Its a fun feature though use it with caution, especially in file managers! 

It's turned OFF by default when you start this app.
When toggled from the settings menu it will stay on through a reload, until you turn it off again.

The Menu will open slightly faster when not waiting for the clipboard to update.
Thou, depending on the project auto copy is also helpful.

Furthermore ------------------------- 
Regarding 'Replace Notepad++ Context Menu'.
Its set to OFF my default.
Personally, I love this, have it set ON for myself.

90`% of the time its fine, but, this feature can be a bit buggy.
Sometimes the standard context menu will still be triggered behind the Extended Capslock Menu which block it from receiving mouse click inputs. Its harmless but annoying. Reloading seems to help.
It also doesn't interact well with the Search Results Window.

You can still access NP++ own context menu with a 'Ctrl' + 'Right Click' or the 'AppsKey' on your keyboard.

************************************************** 
************************************************** 

)" 



; " changelog = change log =
changelog := "
(


************************* CHANGELOG ************************* 

------ v.2024.11.06 ---------------------------

-- New Menu Items --
+ added 'Edit in Text Editor' to the Open\Run\Explore [ Files ] Menu, will try your set option first [NP++], then notepad.exe
+ added 'If NP++ Switch to Alt Open With Menu' item to the Open\Run\Explore [ Files ] Menu

+ the text field in temp sticky notes now resize with the window!!

+ added the handling of file urls e.g. 'file:///urls.ext' to the Open\Run\Explore [ Files ] Menu

= fixed an error with the handling of the '.ahk' from the Run\Open File... menu item. // ahk files open in a text editor rather than running. [ if you use ahk you know why ]

+ added errorlevel check to append\add to clipboard function
+ added errorlevel checks to Alt Open With Menu for NP++

+ expanded go to website from text to handle more url types, e.g. IP address, ftp://, and Other web address that don't end in '.com', e.g. .net.org.gov.uk.fr.au etc

+ fixed the clipboard not being restored when using the 'Ctrl' + 'Space' hotkey\menu item for the explore folder popup menu

+ fixed the handling of window `%Environment Vars`% in file paths. e.g. '%systemroot%\notepad.exe' ""`%localappdata`%"" `%userprofile`%\desktop file:///C:/Users/`%username`%/Downloads/

+ a couple icon updates with more dynamic icons to match your textediter = if set in the `-SETTING.ini`

------ v.2024.11.04 ---------------------------

=+ improved explore folder popup menu not showing icons or opening folders. navigating folders in menu now follows the location accurately.

+ added errorlevel check to -CopyDup file function, if duplicate already exist, ask it you want to replace it.
+ fixed all everything 1.5a search to all run with cli parms
+ fixed Explore this dir in everything not sending quotes around dir

+ added Read selected text out loud using TTS to Tools menu

------ v.2024.11.02 ------------------------------- 

+++ Added Ini Settings File for Toggle Items! They Now Stay Set to the User Choice Arcoss Reloads!

+ added and updated settings menu toggle icons
+ a few dynamic icons dopus vs explorer
+ dynamic icons to match %texteditor%
- removed welcome traytip on light\dark toggle.

+ and a copy to options for non Directory Opus users
= fixed copy folder to... Not copying folder but dumping folder content to selected dir.

= tray menu changes
new, double click to open extend capslock menu

+ add option to set a default text editor, default is set as notepad++, can be changed in ini file
+ add errorlevel checks to send missing editors to windows notepad

+ added make duplicate -CopyDup.ext to the open\run\explore\files menu

+ added a errorlog function with useerrorlevel

+ improved searches with everything15a running from cli rather than thru multiples lines of ahk input

+ added search selection in files via astrogrep

+++ Added two special If Notepad++ is active menus triggered by hotkeys
+ add notepad++ menus , open in alttxt editor menu with hotkey ^!N:: `Ctrl` + `Alt` + `N`
+ added ^{space} hotkey to notepad++ for the folder explorer menu
	- also works in Everything 1.5a on a selected file.

+ added toggle to replace notepad++ right click menu with this menu as a default
	- notepad++'s OG context menu can still be access by a mouse-hotkey `Ctrl` + `Right Click`

------ v.2024.10.28 ------------------------------- 

+ added Copy Selection to New Notepad++ Doc to the Tools menu
+ started cleaning up the About Window GUI
+ new cleaned up tray menu, double click icon to open menu, right click for quick settings

------ v.2024.10.23 ------------------------------- 

Fix to Save As on Sticky notes, now auto appends '.txt' to a file if user left the .ext off a name

------ v.2024.10.21 ------------------------------- 

+ Added open Registry keys in RegEdit to the 'Open\Run\Explore...' Menu
+ Added Search File & Explore Folder With Everything to the 'Open\Run\Explore...' Menu
+ Added Copy to Folder option for user who don't have Directory Opus
= Fixed 'Warp in Quotes' not restoring clipboard after function

+ Improved save functions from Sticky GUI
- Removed (extra) buttons from Sticky Notes GUI, Replaced them with a single button containing Save Options
+ Added Tab ability inside of text box Sticky GUI

+ Added Hotkeys to the Sticky Note GUI Windows
	Alt + M = Show Sticky GUI Quick Menu
	Ctrl + S = Save Sticky As
	Ctrl + Shift + S = Quick Save As
	Ctrl + N = Create New Empty Temp Sticky
	Ctrl + Shift + O = Open Quick Notes Folder
	Ctrl + ESC = Close Stick
+++ Found a workaround to AHK not show custom Context Menus in GUI Edit Box
+++ Added Extended Capslock Menu as the Right-Click Menu in the Sticky GUI

+ Added a few Global hotkeys
	Middle Mouse Button = Now shows Extended Capslock Menu (will now show in Directory Opus)
	Ctrl + Shift + F2 = Copies Selected Text to Temp Sticky
	Ctrl + Alt + F2 = New Empty Temp Stick
	Ctrl + Alt + F3 = Alt hot to show Extended Capslock Menu

------ v.2024.10.15 ------
++ BUG FIX - fixed an error in the Restore Clipboard function !!

------ v.2024.10.13 ------ 
+ added Live Preview with Auto Copy when the menu is launched
+ added a Settings sub-menu
+ added a settings file for mapping 3rd party software (when note installed in their default locations) & changing a few default toggle options
++ added a few more options for searching selected text, online and locally (requires Everything 1.5a and Notepad++)

+++ Improvements +++
+ shortened the amount of time it takes for the menu to appear when holding down the capslock to 0.15 seconds
+ improved the functions that handle the clipboard for better speed and consistency
+ added alt menu hotkey Ctrl + Alt + F3
+ added more options to the Modify Text & Case, and Code Formatting sub-menus

++ Add Shifted Number Row Mode!!! +++
Capslock can now also shift your NUMBER ROW, E.G.
	`1234567890-=[]\
	~!@#$%^&*()_+{}|
this option can be toggled on\off	

+++ NEW Sticky Note GUIs!!! +++
+ Added GUI for quick temp sticky notes!!
+ Ctrl + Alt + F2 for a new blank note or from the menu on selected text will automatically copy the text into the note

+ Sound beeps on capslock toggle
+ gui overlay that hovers over the taskbar area when capslock is on

+ added a compiled .exe for easier running. A few script options will be limited from the exe. I still recommend the running .ahk file, especially if you want edit\customize the menu.

++ Special Addition to this DOPUS EDITION ++ 
+ Added an Open\Run\Explore... Menu that works on a selected file address from inside a text document.
(REQUIRES DIRCOTRY OPUS) its not free but its well worth it.
= A few of these menu item should work through file explorer, thou I haven't fully tested them with explorer
	- open folder
	- run\open a file
	- copy file to clipboard, paste them in a file manager! (REQUIRES DIRCOTRY OPUS) 
= works on true file paths, and with system variables e.g.
 '%USERPROFILE%\Documents\AutoHotkey\'
+ copy the content of text-based file into your clipboard
> move files into a sub-folder or up into parent folder

------ v.2024.09.28 ------------------------------- 

+ Updated and Fixed the Insert Date & Time Menu to refresh automatically\dynamically every time the menu is launched.
+ Added a Run as Admin option to the Tools menu

------ v.2024.09.20 ------------------------------- 

= minor icon updates that should allow this menu to run on systems running windows 7 without errors

------ v.2024.09.13 ------------------------------- 

* FIRST PUBLIC RELEASE *
+ added new menu items
	+ copy + append to clipboard
	+ save clipboard to new document
++ improvements ++
+ better save new document options.
+ can now save as other types of text based formats (e.g. .ahk, .css, etc) rather then strictly .txt files
+ added errorlevel escapes to stop the script when copying attempts fail

)"
;"
gui, capsa: color, 171717, 090909

gui, capsa: font, cffb900
gui, capsa: add, button, x+m w1 h1 gcapsclose, Close
gui, capsa: font, s12 
gui, capsa: add, text, xm center w550, %scriptname%
gui, capsa: add, text, xm center w550, Version // Last Update: %scriptversion%
gui, capsa: Add, Link, xm, <a href="https://github.com/indigofairyx/Extended_Capslock_Context_Menu">Extended Capslock Menu Github Page</a>
gui, capsa: Add, text, x+m, <-- Visit for More Info && Updates
gui, capsa: Add, text, xm center w550, ------------------------- Overview, Hotkeys && ChangeLog ------------------------- 

gui, capsa: font, s10  Consolas
gui, capsa: font, cffb900
; gui, capsa: add, text, xm, %aboutcapswindow%
gui, capsa: add, edit, xm w550 r23, %aboutcapswindow%`n`n`n%a_tab%%hotkeys%`n`n`n %changelog%`n`n
gui, capsa: add, picture, xm, %A_ScriptDir%\Icons\Screenshots\menus_caps_464x57.png

gui, capsa: font, cA0BADE
gui, capsa: add, picture, xm w36 h36, %A_ScriptDir%\Icons\code spark xfav function_256x256.ico



gui, capsa: add, text, x+m cA0BADE, There are a few pieces of software I use that built into this menu.`nAll free except one. Links are below.`nIf the link is ***marked with*** it means...`nThe menu interacts with this software for searchers or file operations.`nThe unmarked links are only quick launcher that open software, like the start menu.`n`nHeres a list of links to them if you want some awesome software.

gui, capsa: Add, Link, xm, <a href="https://github.com/sabrogden/Ditto">Ditto - Clipboard Manager</a>

gui, capsa: Add, Link, xm, <a href="https://ramensoftware.com/textify">Textify - Lets you copy text out of message boxes and guis</a>
gui, capsa: Add, Link, xm, <a href="https://github.com/TheJoeFin/Text-Grab/">Text Grab - Amazing OCR tool</a>
gui, capsa: Add, Link, xm, <a href="https://github.com/BashTux1/AutoCorrect-AHK-2.0">An AHK Global Auto Correct Script - This is already included here.</a>
gui, capsa: Add, Link, xm, <a href="https://github.com/notepad-plus-plus/notepad-plus-plus">***Notepad++*** - You never know.</a>
gui, capsa: Add, Link, xm, <a href="https://www.voidtools.com/forum/viewtopic.php?t=9787">***Everything v1.5a*** - Powerful local search tool</a>
gui, capsa: add, link, xm, <a Herf="https://astrogrep.sourceforge.net/features/">***AstroGrep*** - A great tool for searching text inside files.</a>
gui, capsa: Add, Link, xm, <a href="https://www.gpsoft.com.au">***Directory Opus*** - The most  powerful File Explorer Replacement - Alternative.</a>
gui, capsa: add, text, xm, Dirctory Opus is the only Paid $oftware on this menu. Its well Worth IT!
gui, capsa: add, text, xm, (Press Space to Close)
gui, capsa: add, button, x+m gcapsclose, Close
guicontrol, focus, Close

gui, capsa: +Border +Resize -MaximizeBox ; +Dpiscale
gui, capsa: show,, Extended CAPS Menu - About


} 


capsclose:
gui capsa: hide
; gui capsa2: hide
return
close:
gui, hide
return


#IfWinActive Extended CAPS Menu - About
~rbutton::
menucaseshow()
return
#ifwinactive

viewhotkeys:
MsgBox, 64, Extended Capslock Menus Hotkeys, %hotkeys%
return

; admintog := 0

; Hotkey, %Alt_Hotkey%, menucaseshow
; todo

;;;;;;;;;;;;;;;;;;;; Dark Mode Activated GUI Script ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; from Ctrl CapsLock Menu (new, ctrl capslock capslock now - removed ctrl shift capslock).ahk
;;;;;;;;;; dark mode toggle, menu, cset,
; Case "Dark Mode | Light Mode":
DMToggle:
    If (DarkMode)
    {
        DarkMode := false
        MenuDark(3) ; Set to ForceLight
	iniwrite, 0, %inifile%, DarkMode, key
		tooltip Dark Mode OFF!
    }
    else
    {
        DarkMode := true
        MenuDark(2) ; Set to ForceDark
	iniwrite, 1, %inifile%, DarkMode, key
		tooltip Dark Mode ON!
	}
sleep 1500
tooltip
return

MenuDark(Dark:=2) { ;<<==<-CHANGE DEFAULT HERE. Only the # has to be changed.
    static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
    static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
    static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
    DllCall(SetPreferredAppMode, "int", Dark)
    DllCall(FlushMenuThemes)
}

;************************* END DARKMODE TOGGLE TRAY TIPS *************************
ToggleLiveMenu() ;; Function to toggle the live preview with a warning message box
{
    global LiveMenuEnabled
    LiveMenuEnabled := !LiveMenuEnabled  ; Toggle between True and False

    if (LiveMenuEnabled)  ; Only show message box when turning ON
    {
		Menu, cset, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\eyes_emoji_64x64.ico
        Tooltip, Auto Copy when you open`nthe menu is now Turn ON!
		sleep 2000
		tooltip
		iniwrite, 1, %inifile%, LiveMenuEnabled, key
		return

    }
	else
	{
		Menu, cset, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\eye_half__32x32.ico
		tooltip, Live Preview && Auto Copy is Turned OFF!
		sleep 2000
		tooltip
		iniwrite, 0, %inifile%, LiveMenuEnabled, key
		return

	}
}
;***************************************************************************
;********* END *************MENU, CSET, FUNCTION ************ END **********
;***************************************************************************





#IfWinActive ahk_class EVERYTHING
^Space::
gosub expmenu
return
#IfWinActive

#IfWinActive ahk_class Notepad++
^space::
gosub expmenu
return

^!n:: ;np++, open active file in alt editor
gosub alttxtnppmenu
return

rbutton::
if (ReplaceNPPRightClick)
    {
	KeyWait, RButton, T0.5  ; Wait for the button to be released, with a 500ms delay
	menucaseshow() ; Show custom menu
	}
else
    sendinput, {rbutton}
return

^rbutton::
sendinput, {appskey}
return
#IfWinActive


; expmenu: ;todo add context options via approach to label
; Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved
; if (A_ThisHotkey = "^space") ; double clause if (A_ThisHotkey = "^Space" && WinActive("ahk_class EVERYTHING"))
	; {
		; tooltip you used Ctrl + space hotkey
		; sleep 900
		; tooltip
	; }
; if (A_ThisMenuItem = "View Explore Folder Menu   **[Experimental]**")
	; {
		; tooltip you used the context menu to get here
		; sleep 900
		; tooltip
	; }

expmenu:
Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved

; Get current window title
WinGetTitle, filename, A
filename := RegexReplace(filename, "^\*", "")
filename := RegexReplace(filename, " - Notepad\+\+( \[Administrator\])?$", "")
folder := RegexReplace(filename, "\\[^\\]*$", "")


iflive()
sleep 10
cleanuppathstring()

highlighted := clipboard
RestoreClipboard() ; Store clipboard content and restore original clipboard immediately
sleep 75  ; Give time for clipboard to restore

; Process the highlighted path
if FileExist(highlighted) {
    if InStr(FileExist(highlighted), "D") {
        ; It's a directory
        folder := highlighted
    } else {
        ; It's a file
        SplitPath, highlighted, filestem, folder, ext, drive
    }
    
    ; Remove trailing backslash to prevent menu breaks
    folder := RegExReplace(folder, "\\$")
} else {
    ; If highlighted content is not valid, use window title path
    folder := folder ? folder : ""
    folder := RegExReplace(folder, "\\$")
}

; Show the folder menu
sleep 50
Gosub, ShowFolder
Return


ShowFolder:
; restoreclipboard()
Menu, Folders, Add, ; line ;------------------------- 
Menu, Folders, Deleteall
itemCount := 0
Menu, Folders, Add, Open this Folder, openfolder
if FileExist(dopus)
	Menu, Folders, Icon, Open this Folder, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,24
else
	Menu, Folders, Icon, Open this Folder, explorer.exe,,24
Menu, Folders, Default, Open this Folder
menu, folders, add, Copy Path: "%folder%", copyfolderspath
menu, folders, icon, Copy Path: "%folder%", %A_ScriptDir%\Icons\folder_go__32x32.ico
menu, folders, add, ; line ------------------------- 
Menu, Folders, Add, .., FolderClicked 
Menu, Folders, Icon, .., %A_ScriptDir%\Icons\arrow go-up_32x32.ico 
menu, folders, add, ; line -------------------------

; icons set 1
 Loop, %folder%\*, 2
	{
		FileGetAttrib, attributes, %A_LoopFileFullPath%
		if attributes contains H,S  ; Skip hidden and system folders
			continue
		Menu, Folders, Add, %A_LoopFileName%, FolderClicked
		Menu, Folders, Icon, %A_LoopFileName%, % GetFileIcon(A_LoopFileFullPath)
		itemCount++
	} 
menu, folders, add

 Loop, %folder%\*, 0
	{
		FileGetAttrib, attributes, %A_LoopFileFullPath%
		if attributes contains H,S  ; Skip hidden and system folders
			continue
		Menu, Folders, Add, %A_LoopFileName%, FileClicked
		Menu, Folders, Icon, %A_LoopFileName%, % GetFileIcon(A_LoopFileFullPath)
		itemCount++
	} 

if (itemCount = 0) {
    Menu, Folders, Add, No Folders or Files found, DoNothing
}

Menu, Folders, Show, %A_CaretX%, %A_CaretY%
Return

; icon set 1
 GetFileIcon(File) {
 global iconerror
    VarSetCapacity(FileInfo, A_PtrSize + 688)
    Flags := 0x101  ; SHGFI_ICON and SHGFI_SMALLICON
    if DllCall("shell32\SHGetFileInfoW", "WStr", File, "UInt", 0, "Ptr", &FileInfo, "UInt", A_PtrSize + 688, "UInt", Flags) {
        return "HICON:" NumGet(FileInfo, 0, "UPtr")
    }
    return %iconerror% 
    ; return A_AhkPath
} 

DoNothing:
Return

FolderClicked:
    if (A_ThisMenuItem = "..") {  ; Check if ".." was clicked to go up one level
        if InStr(folder, "\") { ; Remove trailing slash if present
            StringTrimRight, folder, folder, 1
        }
        SplitPath, folder, , parentDir ; Update folder to parent directory
        folder := parentDir
    } else {
        folder := folder "\" A_ThisMenuItem ; Update folder to the clicked directory item
    }
    Goto ShowFolder ; Refresh and show the updated folder menu
; return ; ??
FileClicked:
ClipSaved := ClipboardAll
clipboard := folder . "\" . A_ThisMenuItem
gosub RUNFile
Return

openfolder:
run, %folder%
if ErrorLevel {
    Tooltip, Error. Folder not found.
    Sleep 2000
    Tooltip
}
return

copyfolderspath:
clipboard := ""
sleep 20
clipboard := folder
clipwait,1
return

RUNfile:
SplitPath, Clipboard,,, ext
dir := Clipboard
FileGetAttrib, Attributes, %dir%
if InStr(Attributes, "D") {
    Run, "%Clipboard%"
} else if (ext = "ahk") {
    try {
        Run, %texteditor% "%Clipboard%"
    } catch {
        Run, notepad.exe "%Clipboard%"
    }
} else if (ext = "ico") {
    try {
        Run, %xnviewmp% "%Clipboard%"
    } catch {
        Run, "%Clipboard%"
    }
} else if (ext = "exe") {
    try {
        Run, "%Clipboard%",, UseErrorLevel
        if ErrorLevel {
            Tooltip, Error! Could not open this file or directory.
            Sleep 2000
            Tooltip
        }
    } catch {
        Tooltip, Error! Could not open this file or directory.
        Sleep 2000
        Tooltip
    }
} else {
    try {
        Run, "%Clipboard%"
    } catch {
        Tooltip, Error! Could not open this file or directory.
        Sleep 2000
        Tooltip
    }
}
; RestoreClipboard()
sleep 50
Clipboard := ""
sleep 50
Clipboard := ClipSaved
sleep 200
return


alttxtnppmenu:
Global ClipSaved,ActiveFile,filename,dir,ext,filestem,texteditor
WinGetTitle ActiveFile, A
	if RegExMatch(ActiveFile, "^\*new ")
		{
			MsgBox, 4112, New File Error, You cannot open an unsaved file in another editor.`n`nSave it first then try again., 3
			return
		}
	if RegExMatch(ActiveFile, "^\*")
		{
			MsgBox, 35, Open in Alt Editor, Your document has unsaved changes.`n`nDo you want to save it before opening it in an Alt Editor?`n`nYes`, Save and Continue`nNo`, Continue without saving`nCancel`, Stop, 5
			IfMsgBox Cancel
				return
			IfMsgBox Yes
				send, ^s
		}
sleep 40
ActiveFile := RegexReplace(ActiveFile, "^\*", "")
sleep 40
	if (instr(ActiveFile, "[Administrator]"))
		{
		ActiveFile := RegexReplace(ActiveFile, " - Notepad\+\+ \[Administrator\]", "")
		sleep 40
		}
	else 
		{
		ActiveFile := RegexReplace(ActiveFile, " - Notepad\+\+", "")
		}
	sleep 40
; folder := RegexReplace(ActiveFile, "\\[^\\]*$", "")
dir := RegexReplace(ActiveFile, "\\[^\\]*$", "")
	sleep 40
splitpath, ActiveFile, filename,dir,ext,filestem
sleep 30
; backupclipboard()
; sleep 30
; send, ^s
; sleep 400
menu, alttxt, add
menu, alttxt, deleteall

menu, alttxt, add, -Open... " %filename% "  ...With?, altmenualttxtshow
menu, alttxt, icon, -Open... " %filename% "  ...With?, %A_ScriptDir%\Icons\document text edit rename FLUENT_colored_453_64x64.ico,,28

menu, alttxt, default, -Open... " %filename% "  ...With?
menu, alttxt, add, ; line ;------------------------- 
; menu, alttxt, add, Open in Default Text Editor`, If Set [ %texteditor% ], altoidefaulttexteditor
menu, alttxt, add, Open in Default Text Editor`, (If Set`, Otherwise Notepad), altoidefaulttexteditor
if FileExist(texteditor)
    menu, alttxt, icon, Open in Default Text Editor`, (If Set`, Otherwise Notepad), %texteditor%
else
    menu, alttxt, icon, Open in Default Text Editor`, (If Set`, Otherwise Notepad), notepad.exe
menu, alttxt, add, ; line -------------------------
menu, alttxt, add, Notepad++ in new Window, altoinppnewwindow
if FileExist(notepadpp)
	menu, alttxt, icon, Notepad++ in new Window, %notepadpp%
else
menu, alttxt, icon, Notepad++ in new Window, %A_ScriptDir%\Icons\notepad++_100.ico
menu, alttxt, add, Notepad4, altoinotepad4
menu, alttxt, icon, Notepad4, %A_ScriptDir%\Icons\notepad4 256x256.ico
menu, alttxt, add, Scite 4 AHK, altoiscite
menu, alttxt, icon, Scite 4 AHK, %A_ScriptDir%\Icons\SciTE_icon_256x256.png
menu, alttxt, add, AHK Studio, altoiahkstudio
menu, alttxt, icon, AHK Studio, %A_ScriptDir%\Icons\AHKStudio.ico
menu, alttxt, add, VS Code, altoivscode
menu, alttxt, icon, VS Code, %A_ScriptDir%\Icons\codium logo 256x256.ico
; menu, alttxt, icon, VS Code, %A_ScriptDir%\Icons\vscode.ico ; alt icon
menu, alttxt, add, Geany, altoigeany
menu, alttxt, icon, Geany, %A_ScriptDir%\Icons\geanytexteditor256x256.ico
; menu, alttxt, add, Notepad++, altoinpp
; menu, alttxt, icon, Notepad++, %A_ScriptDir%\Icons\notepad++_100.ico

menu, alttxt, add, ; line ;------------------------- 
menu, alttxt, add, Word, altoiword
menu, alttxt, icon, Word, %A_ScriptDir%\Icons\ms-word_64x64.ico
menu, alttxt, add, Excel, altoiexcel
menu, alttxt, icon, Excel, %A_ScriptDir%\Icons\ms-excel_64x64.ico
menu, alttxt, add, ; line ;------------------------- 
; menu, alttxt, add, Obsidian, altoiobsidian
; menu, alttxt, icon, Obsidian, %A_ScriptDir%\Icons\obsidian logo 256x256.ico
menu, alttxt, add, Markdown Monster, altoimarkdownmonster
menu, alttxt, icon, Markdown Monster, %A_ScriptDir%\Icons\MarkdownMonster logo 256x256.ico
menu, alttxt, add, ; line ;------------------------- 
menu, alttxt, add, -- Other Quick File Options -- (Also About), aboutalttxtmenu
menu, alttxt, icon, -- Other Quick File Options -- (Also About), %A_ScriptDir%\Icons\about question imageres win7_99_256x256.ico
menu, alttxt, add, ; line ;-------------------------
menu, alttxt, add, Duplicate File as... " %filestem% -CopyDup.%ext% ", altmakedup
menu, alttxt, icon, Duplicate File as... " %filestem% -CopyDup.%ext% ", %A_ScriptDir%\Icons\lc_duplicatepage_24x24.ico
menu, alttxt, add, Copy Full File Path to Clipboard, altcopypath
menu, alttxt, icon, Copy Full File Path to Clipboard, %A_ScriptDir%\Icons\document copy f filename FLUENT_colored_387_64x64.ico

menu, alttxt, add, Copy File Name to Clipboard, altcopyname
menu, alttxt, icon, Copy File Name to Clipboard, %A_ScriptDir%\Icons\document copy n FLUENT_colored_385_64x64.ico
Menu, alttxt, add, Search this Doc in Everything, altevfile
Menu, alttxt, icon, Search this Doc in Everything, %A_ScriptDir%\Icons\voidtools-04-Everything-Green.ico
menu, alttxt, add, Explore This Folder in Everything, altevexp
menu, alttxt, icon, Explore This Folder in Everything, %A_ScriptDir%\Icons\voidtools-15-Everything-1.5.ico
menu, alttxt, add, ; line ;------------------------- 

menu, alttxt, add, Open Folder, alttxtopenfolderalt2
if FileExist(dopus)
	menu, alttxt, icon, Open Folder, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,28
else
	menu, alttxt, icon, Open Folder, explorer.exe,,28
sleep 30
; sleep 100
; msgbox,VAR CHECK - FILE CHECK - SPLITPATH CHECK - ERROR CHECK`nthis script: %A_ScriptName%`nline#: %A_LineNumber%`n`nthis label: %A_ThisLabel%`nthis func: %A_ThisFunc%`n`nActiveFile: %activefile%`nfilename: %filename%`ndir: %dir%`next: %ext%`nfilestem: %filestem%`n`naltogether-dir\fs-ext:`n%dir%\%Filestem%.%ext%`n`nclipboard: %clipboard%`n`nclipsaved: %clipsaved%`ntmp: %tmp%`n`nline#: %A_LineNumber%
; clipboard = %ActiveFile%
; sleep 50
menu, alttxt, show
; sleep 50
; sleep 300
return
aboutalttxtmenu:
msgbox, This is a custom made open with menu.`nThese are a few of the Text Editors I like to play with.`nThere are many others!`n`nIf you're Familiar with AHK I recommend editing and running the '.ahk' to add you're own favorite editors here.
return

altevexp:
try run %everything15a% -newtab -s """"%dir%""""
return

altEVfile:
try run %everything15a% -new-tab -s "%filename%"
return

alttxtopenfolder:
getfileinfo()
sleep 90
try Run, %dopusrt% /cmd Go "%clipboard%" NEWTAB TOFRONT
catch
Run, explorer.exe /select`, "%clipboard%"
sleep 500
restoreclipboard()
return

alttxtopenfolderalt2:
Global ClipSaved,ActiveFile,filename,dir,ext,filestem,texteditor, lastfolder
try Run, %dopusrt% /cmd Go "%activefile%" NEWTAB TOFRONT
catch
Run, explorer.exe /select`, "%activefile%"
sleep 500
return

oinpp:
getfileinfo()
sleep 90
try run, %notepadpp% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoinpp:
try run, %notepadpp% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 500
return

oinppnewwindow:
getfileinfo()
sleep 90
try run, %notepadpp% -multiInst "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 1000
; send key to close all tabs? Todo or can do
restoreclipboard()
return

altoinppnewwindow:
try run, %notepadpp% -multiInst "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 1000
; send key to close all tabs? Todo or can do
return

oinotepad4:
getfileinfo()
sleep 90
try run, "%notepad4%" "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoinotepad4:
try run, "%notepad4%" "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oiexcel:
getfileinfo()
sleep 90
try run, %excel% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoiexcel:
try run, %excel% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oiword:
getfileinfo()
sleep 90
try run, %word% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoiword:
try run, %word% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oimarkdownmonster:
getfileinfo()
try run, %MarkdownMonster% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoimarkdownmonster:
try run, %MarkdownMonster% "%filename%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oiobsidian:
getfileinfo()
sleep 90
try run, %ObsidianShell% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoiobsidian:
try run, %ObsidianShell% "%filename%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oiahkstudio:
getfileinfo()
sleep 90
try run, %ahkstudio% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoiahkstudio:
try run, %ahkstudio% "%activefile%",, useerrorlevel
	if errorlevel
	return
sleep 100
return

oiscite:
getfileinfo()
sleep 90
try Run, %scite% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoiscite:
try Run, %scite% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oivscode:
getfileinfo()
sleep 90
try run, "%VSCode%" "%clipboard%"
catch
try run, "%VSCodium%" "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoivscode:
try run, "%VSCode%" "%activefile%"
catch
try run, "%VSCodium%" "%activefile%"
sleep 100
return

oigeany:
getfileinfo()
sleep 90
try run, %gean% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoigeany:
try run, %gean% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

oidefaulttexteditor:
getfileinfo()
sleep 90
try run, %texteditor% "%clipboard%"
catch
run, notepad.exe "%clipboard%"
sleep 500
restoreclipboard()
return

altoidefaulttexteditor:
try run, %texteditor% "%activefile%"
catch
run, notepad.exe "%activefile%"
sleep 100
return

altcopypath:
clipboard := ""  ; Clear clipboard first
sleep 20
clipboard = %dir%\%filename%
clipwait,1
return

altcopyname:
clipboard := ""
sleep 20
clipboard = %filename%
clipwait,1
return

menualttxtshow:
menu, alttxtsub, show
return

altmenualttxtshow:
menu, alttxt, show
return


