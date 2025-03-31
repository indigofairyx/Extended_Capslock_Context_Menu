
;--------------------------------------------------
;!!!!!!!!!!!! IMPORTANT! THIS FILE MUST BE ENCODED WITH UTF8+BOM !!!!!!!!!!!!!!;
;--------------------------------------------------
/*
#TODO
# GUI overhaul update
# add toggle options panel to gui for some options that can exist outside of the menu.
# made sub menu for File menu, put lesser used into in there, e.g. props, move, cmd stats, etc
# add auto correct about and autostart up options
# change + add middle mouse button live menu option here.
	# make Dynamic fast Find menu for live menu

*/


ScriptVersion := "v.2025.03.30"
ScriptName := "Extended CapsLock Menu" 
global scriptversion
global scriptname

SetWorkingDir %A_ScriptDir%
filePath := A_ScriptFullPath

inifile := A_ScriptDir "\" A_ScriptName "-SETTINGS.ini"
global inifile

if !FileExist(inifile)
	{
		; Creates a new ini file if its not found .
		gosub makeini
		Sleep 1000
		ToolTip, Your settings file was not found.`nCreating a new one. One moment please.
		Sleep 2000
		ToolTip
		Sleep 200
	}
; if fileExist(inifile)
; {
	; fileread, inicheck, %inifile%
	; if (inicheck = "")
		; {
		; gosub makeini
		; sleep 1000
		; ToolTip, Your settings file was not found.`nCreating a new one. One moment please.
		; Sleep 2000
		; ToolTip
		; sleep 200
		; }
	; } 





#Persistent
#SingleInstance, Force
#InstallKeybdHook
#InstallMouseHook
#MaxThreads 255
SetBatchLines -1  ; Run the script at maximum speed.
SetWinDelay, -1  ; go quick
SetKeyDelay, 0, 0 	;Smallest possible delay from directives.ahk test
SetMouseDelay, 0 
Process, Priority,, R ;Runs Script at High process priority for best performance
CoordMode, Mouse, Screen
SendMode Input
FileEncoding, UTF-8

;--------------------------------------------------
snipdir := A_ScriptDir . "\Snippets"
global snipdir
if !fileExist(snipdir)
	FileCreateDir, %snipdir%
aboutsnipsfile := snipdir . "\Open Notepad && Click this file to learn about Snippets!.txt"
global aboutsnipsfile
; if !fileExist(aboutsnipsfile)
	; gosub aboutsnips
	
IconsDir := A_ScriptDir . "\Icons" ; Path to the Icons folder
global iconsdir
clogfile = %A_ScriptDir%\ChangeLog.txt
global clogfile
if (A_Username != "CLOUDEN")
	{
	markiconsdirasreadonly()
	markclogfileasreadonly()
	}
Icons := A_ScriptDir . "\Icons" ; Path to the Icons folder
global icons


global LiveMenuEnabled
global Show_CAPS_OSD
global CAPS_Beep_Enabled
global CAPSGuiToggle
global DarkMode
global Double_Right
global ReplaceNPPRightClick
global ShiftedNumRow

INIReadPrograms()
; INIReadGlobal_Hotkeys()
INIReadToggles()
INIReadHotkeySection("Global_Hotkeys")
totalinicount := 0

;-------------------------------------------------- #F12
global ReadableHotkey, labelname, friendlyname, hotkeyvalue, totalinicount, sectionName, menuitems, HotkeyLabels
global HotkeyLabels := {}  ; Ensure this is declared at the start of the script

menu, k, add,
menu, k, deleteall
; menu, k, add, Live Hotkeys Menu`t⊞ + F12, showlivehotkeymenu
; menu, k, icon, Live Hotkeys Menu`t⊞ + F12, %a_scriptdir%\icons\hotkeys.ico,,28
; menu, k, default, Live Hotkeys Menu`t⊞ + F12
menu, k, add, ECLM Live Hotkey Menu`t%showlivehotkeymenu%, showlivehotkeymenu
menu, k, icon, ECLM Live Hotkey Menu`t%showlivehotkeymenu%, %a_scriptdir%\icons\hotkeys.ico,,28
menu, k, default, ECLM Live Hotkey Menu`t%showlivehotkeymenu%
menu, k, add, ; line ------------------------- 
INIReadHotkeySection("Global_Hotkeys")
menu, k, add, ; line -------------------------
; menu, k, add, Hotkey Help, Hotkeyhelp
; menu, k, icon, Hotkey Help, %icons%\about.ico
menu, k, add, Edit %A_Scriptname%-Settings.ini`tKeys Set: %totaliniCount%, editsettings ;Editini
menu, k, icon, Edit %A_Scriptname%-Settings.ini`tKeys Set: %totaliniCount%, %a_scriptdir%\icons\ini alt xfav setting document prefs setupapi_19 256x256.ico,,24
menu, k, add, ; line -------------------------
menu, k, add, AHK Modifier Key Symbols ..., showlivehotkeymenu
menu, k, icon, AHK Modifier Key Symbols ..., %icons%\about.ico
menu, k, add, Ctrl= ^ `, Alt= ! `, Shift= + `, Win= #, showlivehotkeymenu
;--------------------------------------------------
iniread, MaxClipboardLines, %inifile%, MenuOptions, MaxClipboardLines
global MaxClipboardLines
Global TotalLines := 0
Global NonEmptyLines := 0
Global EmptyLines := 0
; read hotkeys again in simple format to feed main menu
; INIReadHotkeySection("Global_Hotkeys")
;--------------------------------------------------
global StartAsAdmin
if (StartAsAdmin)
	{
	If !A_IsAdmin
		Run *RunAs "%A_ScriptFullPath%"
	}

;--------------------------------------------------
if (SeeErrors)
	{
		#warn
		; msgbox,,, u will be annoyed with warning msgboxs,3
	}
else
	{
		Menu, Tray, UseErrorLevel
		#warn, all, Off
		#warn useenv, off
		; msgbox,,, Error Warnings Are Turn Off!,3
		; guicontrol,errorwarnings,show #todo
	}

if (A_IsCompiled)
	{
		menu, tray, UseErrorLevel
		#warn, all, Off
		#warn useenv, off
	}
;--------------------------------------------------
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

;--------------------------------------------------
if (Double_Right)
	Hotkey, ~RButton, doublerightclick, on
else
	Hotkey, ~RButton, doublerightclick, off
;--------------------------------------------------

;; todo, figure out which EnvGet's I dont need, clean this list out.
; envget, userprofile, userprofile
; EnvGet, LocalAppData, LocalAppData
; EnvGet, OutputVar, % A_Is64bitOS ? "ProgramW6432" : "ProgramFiles"
; msgbox, %userprofile%
; EnvGet, EnvGetVar, Path
; EnvGet, EnvGetVar, envgetvar
; msgbox %envgetvar%
; MsgBox, Program files are in: %OutputVar%
; MsgBox, %A_UserName%'s Local directory is located at: %LocalAppData%

;--------------------------------------------------

GLOBAL idn, pidl, plshellfolder, pidlChild, plContextMenu, pt, pIContextMenu2, pIContextMenu3, WPOld ; for windows shell menu


Global filename,dir,filestem,drive,folder,lastfolder,filetoclip,highlighted,attributes ; used by exp popup menu, alt editor menu, copen menu and EV menu items 
; Attributes := ""

trayicon = %A_ScriptDir%\icons\extended capslock menu icon 256x256.ico
global trayicon
iconerror = %A_ScriptDir%\icons\view error_192x192.ico
global iconerror
startuplink := A_StartUp "\" Scriptname ".lnk"
global startuplink
;;// sticky note parms
; currentIndex := 1 
pinoff=%A_ScriptDir%\icons\pin-off_26x26.ico
pinon=%A_ScriptDir%\icons\pin-on_26x26.ico
Global pinstartpic := 1  ; Variable for pin state
Global pin   			; var for sticky notes
global pinon, pinoff
togNN=%A_ScriptDir%\Icons\toggle on Resources_166_24x24.ico
togFF=%A_ScriptDir%\Icons\toggle off Resources_166_24x24.ico
global togNN
global togFF
Global StickyText := ""  ; Variable for sticky note text
Global StickyCount := 0  ; Global counter for sticky notes, GUI item
;; elements for the about gui
global iniload
; global inicontent := ""
; FileRead, inicontent, %inifile%
OnMessage(0x0201, "WM_LBUTTONDOWNdrag")    ;;∙------∙Gui Drag Pt 1.
;;∙======∙Gui Drag Pt 2∙==========================================∙
WM_LBUTTONDOWNdrag() {
   PostMessage, 0x00A1, 2, 0
}
global TabChange ; elements for the about gui
global currentTab ; elemens for the about gui
global selectedtab ; elements for the about gui
global searchPos := 1 ;; gui search box
Global ClipSaved
Global ClipSaved := ""   ; Variable to store saved clipboard content
Global clipcontent       ; Dynamic live menu item from clipboard

Global TTS_Voice := ""  ; Global variable to hold the TTS COM object

global quicknotesdir
quicknotesdir = %A_ScriptDir%\Extended Capslock Menu QUICK Notes
Global texteditor
; splitpath, texteditor, editorfilename

global control = "" ;; right click over np++
Global ActiveFile ; alt editor menu
unSaved := 0 ;; for F9, menu, alttxt, error check for unsaved files when launched outside of np++, e.g. vscode
global unsaved
notatruefile := 0
global notatruefile
global targetID := "" 
SetCapsLockState, off ;; start with caps lock keep turned off to keep it in sync with Show_CAPS_OSD

;///////////////////////////////////////////////////////////////////////////
 ;; checks for updates via githubs releases page
 GitHubAPI := "https://api.github.com/repos/indigofairyx/Extended_Capslock_Context_Menu/releases/latest"
 GitHubVersionFile := "https://raw.githubusercontent.com/indigofairyx/Extended_Capslock_Context_Menu/refs/heads/main/Extended%20Capslock%20Context%20Menu/version.txt" ; URL to the version file in your GitHub repo
 ; global GitHubVersionFile
 Tempupdatecheck := A_Temp . "\ECLMversion.txt" ; Temporary file to store the downloaded version
 ; global tempupdatecheck
 localversioncheck = %a_scriptdir%\version.txt
 if FileExist(localversioncheck)
	 FileSetAttrib, +H, %localversioncheck%
;///////////////////////////////////////////////////////////////////////////
;---------------------------------------------------------------------------
this := "" ; swap at, text, func
div := "" ; swap at, text, func
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
;; Date time menu
TextMenuDate(TextOptions)
{
global
menu, dtmenu, add, < ----- Insert Date && Time ----- >`t%showdtmenu%, showdtmenu
menu, dtmenu, icon, < ----- Insert Date && Time ----- >`t%showdtmenu%, %A_ScriptDir%\Icons\ico_alpha_Clock_32x32.ico,,28
menu, dtmenu, default, < ----- Insert Date && Time ----- >`t%showdtmenu%
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
		menu, dtmenu, add
		Menu, dtmenu, DeleteAll
		Date := A_Now
		List := DateFormats(A_Now)
		TextMenuDate(List)
	}
;---------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////


;///////////////////////////////////////////////////////////////////////////
;--------------------------------------------------------------------------- 

;---------------------------------------------------------------------------


menu, ctools, add, < ------ Text Tools ------ >`t%showtoolsmenu%, showtoolsmenu
menu, ctools, icon, < ------ Text Tools ------ >`t%showtoolsmenu%, %A_ScriptDir%\Icons\Pencil and Ruler__32x32.ico,,28
menu, ctools, default, < ------ Text Tools ------ >`t%showtoolsmenu%
menu, ctools, add, ; line ------------------ -------
menu, ctools, add, Save Selection To New Document`t%newtxtfile%, newtxtfile
menu, ctools, icon, Save Selection To New Document`t%newtxtfile%, %A_ScriptDir%\Icons\document new add FLUENT_colored_239_64x64.ico
if fileexist(notepadpp)
	{
	menu, ctools, add, Copy Selected to New Np++ Document`t%newnpppdoc%, newnpppdoc 
	menu, ctools, icon, Copy Selected to New Np++ Document`t%newnpppdoc%, %notepadpp%
	menu, ctools, add, ; line -------------------------
	; menu, ctools, icon, Copy Selected to New Np++ Document, %A_ScriptDir%\Icons\document edit notepad++ npp duplicate FLUENT_colored_452_64x64.ico  ;; IGNORE 4 SHARE
	}
menu, ctools, add, Quick Save Selection to New.txt File`t%quicktxtfile%, quicktxtfile
menu, ctools, icon, Quick Save Selection to New.txt File`t%quicktxtfile%, %A_ScriptDir%\Icons\lc_savebasicas_26x26.ico
if (showExtraMenusOnCAPS)
{
if fileExist(quicknotesdir)
	{
	topmenu = %quicknotesdir%
	; msgbox TM:%topmenu% `n QN: %quicknotesdir%
	gosub topmenu  ; build live menu item
	Menu, ctools, add, Quick Notes Dir, :%topmenu%
	Menu, ctools, icon, Quick Notes Dir, %A_ScriptDir%\Icons\folder_go__32x32.ico
	}
}
menu, ctools, add, ; line ;-------------------------
menu, ctools, add, Save Clipboard to New Document`t%SaveClipboardAsTxt%, SaveClipboardAsTxt
menu, ctools, icon, Save Clipboard to New Document`t%SaveClipboardAsTxt%, %A_ScriptDir%\Icons\clipboard save b_xedit_48x48.ico
menu, ctools, add, View Clipboard Text`t%viewclip%, viewclip
menu, ctools, icon, View Clipboard Text`t%viewclip%, %A_ScriptDir%\Icons\QAP-preview_pane_c_26x26.ico
; menu, ctools, icon, View Clipboard Text, %A_ScriptDir%\Icons\message Magic Box.ico ; alt icon
menu, ctools, add, Clear Clipboard`t%clearclip%, clearclip
; menu, ctools, icon, Clear Clipboard, %A_ScriptDir%\Icons\Clean_fluentColored_64x64.ico ; alt icon
menu, ctools, icon, Clear Clipboard`t%clearclip%, %A_ScriptDir%\Icons\clean_clear_clipboard_empty_xedit3_32x32.ico
menu, ctools, add, ; line ;-------------------------
Menu, ctools, Add, + Copy (Add to Clipboard)`t%appendclip%, appendclip
Menu, ctools, icon,  + Copy (Add to Clipboard)`t%appendclip%, %A_ScriptDir%\Icons\clipboard add plus append 64x64.ico
MENU, ctools, ADD, Paste As Plain Text`t%pasteasplaintext%, pasteasplaintext
MENU, ctools, icon, Paste As Plain Text`t%pasteasplaintext%, %A_ScriptDir%\Icons\plaintextdoc_64x64.ico
menu, ctools, Add, Wrap in Selection "&Quotes"`t%ClipQuote%, ClipQuote ; ;10 %A_Space% in menu
menu, ctools, icon, Wrap in Selection "&Quotes"`t%ClipQuote%, %A_ScriptDir%\Icons\format quote_24x24.ico ; "

menu, ctools, add, ;line ;-------------------------
menu, ctools, add, Grab Location Bar Address (Copy)`t%copylocationbar%, copylocationbar
menu, ctools, icon, Grab Location Bar Address (Copy)`t%copylocationbar%, %A_ScriptDir%\Icons\address_bar_red__32x32.ico
menu, ctools, add, Copy Selection to Temp Sticky`t%CopyToStickyNote%, CopyToStickyNote
menu, ctools, icon, Copy Selection to Temp Sticky`t%CopyToStickyNote%, %A_ScriptDir%\Icons\classicStickyNotes_0_6 48x48.ico
menu, ctools, add, ;line ;-------------------------

menu, ctools, add, Text Statistics on Selection`t%TextStatsSelected%, TextStatsSelected
menu, ctools, icon, Text Statistics on Selection`t%TextStatsSelected%, %A_ScriptDir%\Icons\document Info_48x48.ico
menu, ctools, add, Read [*Selected Text*] Out Loud`t%TextToSpeech%, TextToSpeech
menu, ctools, icon, Read [*Selected Text*] Out Loud`t%TextToSpeech%, %A_ScriptDir%\Icons\loudspeaker_emoji_64x64.ico
menu, ctools, add, ; line ;-------------------------
menu, ctools, add, < --- Software Launchers (?About) --- >, aboutsoftwareL
menu, ctools, icon, < --- Software Launchers (?About) --- >, %A_ScriptDir%\Icons\Apps_software_48x48.ico,,24
menu, ctools, add, ; line ;-------------------------
MENU, ctools, add, Run AHK Auto Correct (Included)`t%runabc%, runabc
MENU, ctools, icon, Run AHK Auto Correct (Included)`t%runabc%, %A_ScriptDir%\Icons\autocorrect_icon_32x32.ico
menu, ctools, add, Ditto Clipboard`t%runditto%, runditto
menu, ctools, icon, Ditto Clipboard`t%runditto%, %A_ScriptDir%\Icons\ditto quote clipboard 128x128.ico
if FileExist(qce)
	{
	Menu, ctools, add, Quick Clipboard Editor`t%runQCE%, runQCE
	Menu, ctools, icon, Quick Clipboard Editor`t%runQCE%, %qce%
	}
else
	{
	Menu, ctools, add, Quick Clipboard Editor  -- Not Installed ?`t%runQCE%, runQCE
	Menu, ctools, icon, Quick Clipboard Editor  -- Not Installed ?`t%runQCE%, %A_ScriptDir%\Icons\clipboard JLicons_52_64x64.ico
	}

menu, ctools, add, Textify`t%runtextify%, runtextify
menu, ctools, icon, Textify`t%runtextify%, %A_ScriptDir%\Icons\textify 128x128.ico
menu, ctools, add, Text Grab`t%runtextgrab%, runtextgrab
menu, ctools, icon, Text Grab`t%runtextgrab%, %A_ScriptDir%\Icons\text grab v4 128x128.ico
menu, ctools, add, Notepad++`t%runnotepadpp%, runnotepadpp
menu, ctools, icon, Notepad++`t%runnotepadpp%, %A_ScriptDir%\Icons\notepad++_100.ico

if !FileExist(dopus)
	{
	menu, ctools, add, Directory Opus, rundopus
	menu, ctools, icon, Directory Opus, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico
	}

; -------------------------------------------------------------------------- 
	
menu, cfind, add, < --- Search Selected Text Menu --- >`t%showfindmenu%, showfindmenu
menu, cfind, icon, < --- Search Selected Text Menu --- >`t%showfindmenu%, %A_ScriptDir%\Icons\search find Windows 11 Icon 13_256x256.ico,,28
menu, cfind, default, < --- Search Selected Text Menu --- >`t%showfindmenu%
menu, cfind, add, ; line ;-------------------------
menu, Cfind, add, < ------ Local Searches ------ >`t%showfindmenu%, showfindmenu
menu, Cfind, icon, < ------ Local Searches ------ >`t%showfindmenu%, %Icons%\computer_48x48.ico,,28
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, Everything -Find with EV`t%Findwitheverything%, Findwitheverything
menu, cfind, icon, Everything -Find with EV`t%Findwitheverything%, %Icons%\voidtools-15-Everything-1.5.ico
menu, cfind, add, System Index -via EV 1.5a`t%evindex%, evindex
menu, cfind, icon, System Index -via EV 1.5a`t%evindex%, %Icons%\voidtools-07-Everything-SkyBlue.ico
if fileexist(winfindr)
	{
		menu, cfind, add, Winfindr`t%WinFindrSearch%, WinFindrSearch
		menu, cfind, icon, Winfindr`t%WinFindrSearch%, %winfindr%	
	}
menu, cfind, add, ; line ;-------------------------
if fileexist(notepadpp)
	{
	menu, cfind, add, NP++ -Find in Files`t%findinfilesnpp%, findinfilesnpp
	menu, cfind, icon, NP++ -Find in Files`t%findinfilesnpp%, %Icons%\Find in Files.ico

	; menu, cfind, add, NP++ -Find all in this Doc, findalllocalnpp
	; menu, cfind, icon, NP++ -Find all in this Doc, %A_ScriptDir%\Icons\Find next.ico
	}
if fileExist(astrogrep)
	{
	menu, cfind, add, Find in Files with AstroGrep`t%findastro%, findastro
	menu, cfind, icon, Find in Files with AstroGrep`t%findastro%, %findastro%
	; menu, cfind, icon, Find in Files with AstroGrep, %A_ScriptDir%\Icons\astrogrep find search 256x256.ico
	}


menu, cfind, add, Find in Files with dnGREP`t%finddngrep%, finddngrep
if fileexist(dngrep)
	menu, cfind, icon, Find in Files with dnGREP`t%finddngrep%, %dngrep%
else
	menu, cfind, icon, Find in Files with dnGREP`t%finddngrep%, %Icons%\dnGrep 256x256.ico

menu, cfind, add, ; line -------------------------
menu, cfind, add, AHK Help File ( Local )`t%ahkhelplocal%, ahkhelplocal
menu, cfind, icon, AHK Help File ( Local )`t%ahkhelplocal%, %Icons%\chm help document question find hh_0_2.ico
menu, cfind, add, ; line -------------------------

menu, cfind, add, < ------ Web Searches ------ >`t%showfindmenu%, showfindmenu
menu, cfind, icon, < ------ Web Searches ------ >`t%showfindmenu%, %Icons%\web www internet globe 26 64x64.ico,,28
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, Google This`t%googlethis%, googlethis
menu, cfind, icon, Google This`t%googlethis%, %A_ScriptDir%\Icons\google_96x96.ico
menu, cfind, add, Youtube This`t%youtubethis%, youtubethis
menu, cfind, icon, Youtube This`t%youtubethis%, %Icons%\youtube_64x64.ico
menu, cfind, add, Define Word (Google)`t%definethis%, definethis
menu, cfind, icon, Define Word (Google)`t%definethis%, %Icons%\Dictionary__32x32.ico
menu, cfind, add, Wikipedia Search`t%wikipediasearch%, wikipediasearch
menu, cfind, icon, Wikipedia Search`t%wikipediasearch%, %Icons%\wikipedia.ico

menu, cfind, add, ; line -------------------------
menu, cfind, add, Visit Website [If URL]`t%gowebsite%, gowebsite
menu, cfind, icon, Visit Website [If URL]`t%gowebsite%, %Icons%\web-browser xfav_24x24.ico
menu, cfind, add, ; line ;-------------------------
menu, cfind, add, AHK Site Search via Google`t%ahksearchmenu%, ahksearchmenu
menu, cfind, icon, AHK Site Search via Google`t%ahksearchmenu%, %A_ScriptDir%\Icons\www.autohotkey.com website favcon_48x48.ico
; menu, cfind, add, ; line ;-------------------------
; menu, cfind, add, Look up on Dictionary.com && Thesaurus.com, Dictionarydotcom


; -------------------------------------------------------------------------- 



menu, copen, add, < --- IF Files\Dirs is [*Selected*] Menu --- >`t%showopenmenu%, showopenmenu
if FileExist(dopus)
	menu, copen, icon, < --- IF Files\Dirs is [*Selected*] Menu --- >`t%showopenmenu%, %Icons%\DOpus_Spikes_256x256.ico,,28
else
	menu, copen, icon, < --- IF Files\Dirs is [*Selected*] Menu --- >`t%showopenmenu%, explorer.exe,,28
menu, copen, default,  < --- IF Files\Dirs is [*Selected*] Menu --- >`t%showopenmenu%

menu, copen, add, ; line ;-------------------------
menu, copen, add, Open Folder`t%OpenDIRselection%, OpenDIRselection
menu, copen, icon, Open Folder`t%OpenDIRselection%, %A_ScriptDir%\Icons\folder file explorer imageres_5325_256x256.ico
; menu, copen, add, Open Folder v2 simple, openfoldersimple
menu, copen, add, Run\Open File`n%RUNfromselection%, RUNfromselection
menu, copen, icon, Run\Open File`n%RUNfromselection%, %A_ScriptDir%\Icons\JLicons_1_64x64.ico
if FileExist(dopus)
	{
		menu, copen, add, Copy File\Folder to Clipboard`t%COPYfromselection%, COPYfromselection
		menu, copen, icon, Copy File\Folder to Clipboard`t%COPYfromselection%, %Icons%\importClipboard image photo picture _48x48.ico
	}
else
	{
		menu, copen, add, Copy File\Folder to ..., COPYfromselection
		menu, copen, icon, Copy File\Folder to ..., %Icons%\min_copyTo_32x32.ico
	}
menu, copen, add, ; line ;-------------------------
menu, copen, add, Explore Folder in Everything`t%EVpath%, EVpath
menu, copen, icon, Explore Folder in Everything`t%EVpath%, %everything15a% ; alt, if !fileexist icon, %Icons%\voidtools-15-Everything-1.5.ico
menu, copen, add, Search File in Everything`t%EVfile%, EVfile
menu, copen, icon, Search File in Everything`t%EVfile%, %Icons%\voidtools-04-Everything-Green.ico
Menu, copen, add, Load Path into dnGREP for Searching`t%dngreploadpath%, dngreploadpath
if fileexist(dngrep)
menu, copen, icon, Load Path into dnGREP for Searching`t%dngreploadpath%, %dngrep%
else
menu, copen, icon, Load Path into dnGREP for Searching`t%dngreploadpath%, %Icons%\dnGrep 256x256.ico

menu, copen, add, ; line ;-------------------------

menu, copen, add, Edit in Text Editor`t%Edittxtfile%, Edittxtfile
if fileexist(Texteditor)
	menu, copen, icon, Edit in Text Editor`t%Edittxtfile%, %texteditor%
else
	menu, copen, icon, Edit in Text Editor`t%Edittxtfile%, notepad.exe

menu, copen, add, Duplicate File as... "File Name -CopyDup.ext"`t%makedup%, makedup
menu, copen, icon, Duplicate File as... "File Name -CopyDup.ext"`t%makedup%, %Icons%\lc_duplicatepage_24x24.ico
menu, copen, add, File Content to Clipboard (Text-Based Files)`t%filetoclipboard%, filetoclipboard
menu, copen, icon, File Content to Clipboard (Text-Based Files)`t%filetoclipboard%, %Icons%\binary text txt copy_48x48.ico
; menu, copen, icon, File Content to Clipboard (Text-Based Files), %Icons%\filetype exe binary text txt copy 20_48x48.ico ;alt icon
menu, copen, add, File Stats (Count lines - words - etc..)`t%TextStatsFile%, TextStatsFile
menu, copen, icon, File Stats (Count lines - words - etc..)`t%TextStatsFile%, %Icons%\document Info_48x48.ico

menu, copen, add, ; line ;-------------------------

menu, copen, add, Jump to Key in RegEdit`t%RegJumpmenu%, RegJumpmenu
menu, copen, icon, Jump to Key in RegEdit`t%RegJumpmenu%, %Icons%\reg blocks app 256x256.ico
; menu, copen, icon, Jump to Key in RegEdit, regedit.exe ; alt icon
menu, copen, add, ; line -------------------------
menu, copen, add, Windows Context Menu  ☰`t%wincontextmenu%, wincontextmenu
menu, copen, icon, Windows Context Menu  ☰`t%wincontextmenu%, %Icons%\windows logo xfav 48x48.ico
menu, copen, add, Open With...`t%fileopenwith%, fileopenwith
menu, copen, icon, Open With...`t%fileopenwith%, OpenWith.exe
; menu, copen, icon, Open With..., C:\Windows\SysWOW64\OpenWith.exe ; or C:\Windows\System32\OpenWith.exe
menu, copen, add, View File Properties`t%viewfilepropteries%, viewfilepropteries
menu, copen, icon, View File Properties`t%viewfilepropteries%, C:\Windows\system32\imageres.dll, 307
menu, copen, add, ; line ;-------------------------

menu, copen, add, Visit Website [If URL]`t%gowebsite%, gowebsite
menu, copen, icon, Visit Website [If URL]`t%gowebsite%, %Icons%\web-browser xfav_24x24.ico
menu, copen, add, ; line ;-------------------------
menu, copen, add, View Explore Folder Popup Menu`t%expmenu%, expmenu
menu, copen, icon, View Explore Folder Popup Menu`t%expmenu%, %Icons%\submenu JLicons_42_64x64.ico
menu, copen, add, View Live Folder Menu, livefoldermenu


if fileexist(notepadpp)
	{
	menu, copen, add, If NP++ Switch to Alt Open With Menu`t%alttxtnppmenu%, alttxtnppmenu
	menu, copen, icon, If NP++ Switch to Alt Open With Menu`t%alttxtnppmenu%, %notepadpp%
	}

menu, copen, add, ; line -------------------------
menu, copen, add, Put File into Subfolder (Folder takes Filename), movefiletofolder
menu, copen, icon, Put File into Subfolder (Folder takes Filename), %A_ScriptDir%\Icons\folder new add FLUENT_colored_165_64x64.ico
menu, copen, add, Move File Up into it's Parent Folder, movefiletoparentfolder
menu, copen, icon, Move File Up into it's Parent Folder, %A_ScriptDir%\Icons\folder arrow up action-brown-open_32x32.ico
menu, copen, add, Copy File Names && Details of Folder to Clipboard, copydetails
menu, copen, icon, Copy File Names && Details of Folder to Clipboard, %A_ScriptDir%\Icons\cmd_48x48.ico
menu, copen, add, ; line ;-------------------------
menu, copen, add, Put File into Subfolder (Folder takes Filename)`t%movefiletofolder%, movefiletofolder
menu, copen, icon, Put File into Subfolder (Folder takes Filename)`t%movefiletofolder%, %A_ScriptDir%\Icons\folder new add FLUENT_colored_165_64x64.ico
menu, copen, add, Move File Up into it's Parent Folder`t%movefiletoparentfolder%, movefiletoparentfolder
menu, copen, icon, Move File Up into it's Parent Folder`t%movefiletoparentfolder%, %A_ScriptDir%\Icons\folder arrow up action-brown-open_32x32.ico
menu, copen, add, Copy File Names && Details of Folder to Clipboard`t%copydetails%, copydetails
menu, copen, icon, Copy File Names && Details of Folder to Clipboard`t%copydetails%, %A_ScriptDir%\Icons\cmd_48x48.ico

; -------------------------------------------------------------------------- 

menu, ctxt, add, < ---- Modify Text && Case ---- >`t%showctxtmenu%, showctxtmenu
menu, ctxt, icon, < ---- Modify Text && Case ---- >`t%showctxtmenu%, %Icons%\richtext_editor__32x32.ico,,28
menu, ctxt, default, < ---- Modify Text && Case ---- >`t%showctxtmenu%,
menu, ctxt, add, ; line -------------------------
menu, ctxt, Add, UPPERCASE`t%Upper%, Upper
menu, ctxt, icon, UPPERCASE`t%Upper%, %Icons%\Upper case.ico
menu, ctxt, Add, lowercase`t%Lower%, Lower
menu, ctxt, icon, lowercase`t%Lower%, %Icons%\Lower case.ico
menu, ctxt, Add, Title Case`t%Title%, Title
menu, ctxt, Add, Sentence case`t%Sentence%, Sentence
Menu, ctxt, Add, Capital Case`t%Capital%, Capital
Menu, ctxt, Add, iNVERT cASE - Invert Case`t%Invert%, Invert
menu, ctxt, add, ; line ;-------------------------
menu, ctxt, add, Reverse - esreveR`t%Reverse%,  Reverse
menu, ctxt, icon, Reverse - esreveR`t%Reverse%,  %Icons%\action-text-direction-rtl_48x48.ico
menu, ctxt, add, Convert Numbers<&&>Symbols`, 1@3->!2#`t%convertsymbols%, convertsymbols
menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, Add, PascalCase`t%Pascal%, Pascal
Menu, ctxt, Add, camelCase`t%camel%, camel 
menu, ctxt, add, camelPascalCase to Spaced Words`t%UnPascal%, UnPascal
Menu, ctxt, Add, aLtErNaTiNg cAsE`t%Alternating%, Alternating
menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, add, S p r e a d T e x t`t%spread%, spread ; ccase ; spread case
menu, ctxt, add, Remove  Extra   Spaces`t%RemoveExtraS%, RemoveExtraS
menu, ctxt, Add, RemoveALL Spaces`t%RASpace%, RASpace
menu, ctxt, icon, RemoveALL Spaces`t%RASpace%, %Icons%\sc_gluepercent_16x16.ico
menu, ctxt, add, Add Spaces around {Input Symbol}`t%AddSpacesAroundSeparator%, AddSpacesAroundSeparator
menu, ctxt, add, Remove Spaces around {Input Symbol}`t%RemoveSpacesAroundSeparator%, RemoveSpacesAroundSeparator
menu, ctxt, add, Remove Empty Lines`t%RemoveEmptyLines%, RemoveEmptyLines
menu, ctxt, icon, Remove Empty Lines`t%RemoveEmptyLines%, %icons%\edit-vertical-alignment-middle-white_ShareX_16x16.ico
menu, ctxt, add, ;line ;-------------------------
menu, ctxt, add, Sort `> 0-9`,A-Z`t%sorttext%, sorttext
menu, ctxt, icon, Sort `> 0-9`,A-Z`t%sorttext%, %Icons%\sort a-z accending xfav Resources_222_24x24.ico
; menu, ctxt, icon, Sort `> 0-9`,A-Z`t%sorttext%, %Icons%\sort_descending__32x32.ico
menu, ctxt, add, ;line ;-------------------------
Menu, ctxt, Add, Space to Dot.Case`t%addDot%, addDot
menu, ctxt, add, Remove.Dot to Space`t%removedot%, removedot
Menu, ctxt, Add, Space to Under_Score`t%addunderscore%, addunderscore
menu, ctxt, add, Remove_Underscore to Space`t%removeunderscore%, removeunderscore
Menu, ctxt, Add, Space to Dash-Case`t%adddash%, adddash
menu, ctxt, add, Remove-Dash to Space`t%removedash%, removedash

menu, ctxt, add, ; line ;-------------------------
Menu, ctxt, add, Fix Line Breaks`t%FixLineBreaks%, FixLineBreaks
menu, ctxt, add, Remove Illegal Characters && Emojis`t%removeillegal%, removeillegal
menu, ctxt, icon, Remove Illegal Characters && Emojis`t%removeillegal%, %Icons%\error bot flow xfav_48x48.ico
menu, ctxt, add, ; line ;-------------------------
menu, ctxt, add, Flip at {Input Symbol}`t%FlipTextSeparator%, FlipTextSeparator
menu, ctxt, add, Swap @ Anchor Word or Symbol`t%text_swap%, text_swap ;swaptext
menu, ctxt, icon, Swap @ Anchor Word or Symbol`t%text_swap%, %Icons%\arrow_switch__32x32.ico
menu, ctxt, add, Flip Chars @ Caret`, A2->2A`t%letterswap%, letterswap
menu, ctxt, icon, Flip Chars @ Caret`, A2->2A`t%letterswap%, %Icons%\Sync arrow_fluentColored_64x64.ico

;---------------------------------------------------------------------------
menu, code, add, < --- Code Formatting Menu --- >`t%showcodemenu%, showcodemenu
menu, code, icon,  < --- Code Formatting Menu --- >`t%showcodemenu%, %A_ScriptDir%\Icons\code spark xfav function_256x256.ico,,28
menu, code, default,  < --- Code Formatting Menu --- >`t%showcodemenu%
menu, code, add, ; line -------------------------
menu, code, add, 1 `/`* Block Comment `*`/`t%commentblock%, commentblock
menu, code, icon, 1 `/`* Block Comment `*`/`t%commentblock%, %Icons%\comment code coding com.github.jeremyvaartjes.comgen_64x64.ico
menu, code, add, 2 `{Wrapped}`t %cbrakectswrapped%, cbrakectswrapped
menu, code, icon, 2 `{Wrapped}`t %cbrakectswrapped%, %Icons%\lc_symbolshapes.brace-pair_22x22.ico
menu, code, add, 3 (Parentheses)`t%wrapparen%, wrapparen
menu, code, icon, 3 (Parentheses)`t%wrapparen%, %Icons%\lc_symbolshapes.bracket-pair_26x26.ico
menu, code, add, 4 [Square Brackets]`t%squbracket%, squbracket
menu, code, icon, 4 [Square Brackets]`t%squbracket%, %Icons%\lc_symbolshapes.bracket-pair_22x22.ico
; menu, code ,icon, 4 [Square Brackets], %Icons%\code text brackets file_type_light_toml_32x32.ico ; alt icon
menu, code, add, 5 `%PercentVar`%`t%wrappercent%, wrappercent
menu, code, icon, 5 `%PercentVar`%`t%wrappercent%, %Icons%\code format_percentage__32x32.ico
menu, code, Add, 6 ``Code - `Inline```t%CodeLine%, CodeLine
menu, code, Add, 7 ``````Code - Box```````t%CodeBox%, CodeBox
menu, code, icon, 7 ``````Code - Box```````t%CodeBox%, %Icons%\selection text code Resources_200_24x24.ico
menu, code, add, 8 [code]Box - Forum[/code]`t%forumcodebox%, forumcodebox
menu, code, Add, 9 <kbd>`K<`/kbd>`t%dopusK%, dopusK
menu, code, icon, 9 <kbd>`K<`/kbd>`t%dopusK%, %Icons%\xml code_128x128.ico
menu, code, add, 0 `<`!-- xml Comment --`>`t%wrapinxmlcomment%, wrapinxmlcomment
menu, code, add, A ``nAHK new Line``n`t%ahknewline%, ahknewline
menu, code, icon, A ``nAHK new Line``n`t%ahknewline%, %Icons%\083_key return enter keyboard capt_24x24.ico
menu, code, add, B Expand `%A_ScriptDir`%`t%expandscriptdir%, expandscriptdir
; menu, code,icon, B Expand `%A_ScriptDir`%,
menu, code, add, C Encode XML`t%Encodexml%, Encodexml
; menu, code, icon,
menu, code, add, D Decode XML`t%decodexml%, decodexml
; menu, code, icon,
menu, code, add, E Covert file:\\\url to Std Path`t%convertfileurl%, convertfileurl
; menu, code, icon,
; menu, code, add, AHK Expression to `%var`%`t%DecodeAHKVar%, DecodeAHKVar
; menu, code, icon,
; menu, code, add, AHK `%var`% to Expression`t%EncodeAHKVar%, EncodeAHKVar
; menu, code, icon,
menu, code, Add, F Wrap in "&Quotes"`t%ClipQuote%, ClipQuote ; ;10 %A_Space% in menu
menu, code, icon, F Wrap in "&Quotes"`t%ClipQuote%, %A_ScriptDir%\Icons\format quote_24x24.ico ; "
menu, code, add, G `{..Curly &Brackets..`}`, On New Lines`t%wrapincbrackets%, wrapincbrackets
menu, code, icon, G `{..Curly &Brackets..`}`, On New Lines`t%wrapincbrackets%, %A_ScriptDir%\Icons\coding code json filetype_24x24.ico

;---------------------------------------------------------------------------


;---------------------------------------------------------------------------



;---------------------------------------------------------------------------
menu, gui, add, < - Temp Sticky Menu - >`tAlt + M, guimenubutton
menu, gui, icon, < - Temp Sticky Menu - >`tAlt + M, %A_ScriptDir%\Icons\classicStickyNotes_0_6 48x48.ico,,28
menu, gui, default, < - Temp Sticky Menu - >`tAlt + M
menu, gui, add, ; line -------------------------
menu, gui, add, Save As`tCtrl + S, savestickyAS
menu, gui, icon, Save As`tCtrl + S, %A_ScriptDir%\Icons\save as floppy Resources_174_24x24.ico
menu, gui, add, Quick Save as .txt`tCtrl + Shift + S, savestickyquick
menu, gui, icon, Quick Save as .txt`tCtrl + Shift + S, %A_ScriptDir%\Icons\action-save_48x48.ico
menu, gui, add, ; line ;-------------------------
menu, gui, add, Create New Temp Sticky`tCtrl + N, newsticky
menu, gui, icon, Create New Temp Sticky`tCtrl + N, %A_ScriptDir%\Icons\sticky-note--plus_16x16.ico

menu, gui, add, ; line ;-------------------------
if FileExist(quicknotesdir)
	{
	menu, gui, add, Open Quick Notes Dir`tCtrl + Shift + O, OpenQuickNotesDir
	if FileExist(dopus)
		menu, gui, icon, Open Quick Notes Dir`tCtrl + Shift + O, %dopus%
	else
		menu, gui, icon, Open Quick Notes Dir`tCtrl + Shift + O, %A_ScriptDir%\Icons\folder file explorer imageres_5325_256x256.ico
	
	menu, gui, add, ; line ;-------------------------
	}
else
	{
	; show nothing
	}
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

;---------------------------------------------------------------------------
menu, as, add
menu, as, deleteall

menu, as, Add, Toggle >> Dark Mode | Light Mode`t%DMToggle%, DMToggle 
menu, as, icon, Toggle >> Dark Mode | Light Mode`t%DMToggle%, %A_ScriptDir%\Icons\darkmodetoggleshell32_284_48x48.ico

menu, as, add, Always Run As Admin, togSTARTASADMIN
if (StartAsAdmin)
	{
		menu, as, icon, Always Run As Admin, %togNN%
	}
else
	{
		menu, as, icon, Always Run As Admin, %togFF%
	}


menu, as, add, Check For Updates on Start Up, togUpdatecheckonstartup
menu, as, icon, Check For Updates on Start Up, %A_ScriptDir%\Icons\globe web internet updater arrow xfav 256x256.ico
if (CheckForUpdatesONStartup)
	menu, as, ToggleCheck, Check For Updates on Start Up
	
menu, as, add, Run ECLM at Start Up, togRunonStartUp
menu, as, icon, Run ECLM at Start Up, %A_ScriptDir%\Icons\rocket_emoji_startup_64x64.ico
if (RunonStartUP)
	{
	menu, as, ToggleCheck, Run ECLM at Start Up
	; startuplink := A_StartUp "\" Scriptname ".lnk"
	if !FileExist(startuplink)
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%ScriptName%.lnk,,,Runs Extended Capslock Menu at Startup,%trayicon%,,0
	}
else
	{
	if FileExist(startuplink)
		FileDelete, %startuplink%
	}
menu, as, add, ; line -------------------------
menu, as, add, Toggle Live Preview && Auto Copy`t%ToggleLiveMenu%, ToggleLiveMenu
if (LiveMenuEnabled)
	menu, as, icon, Toggle Live Preview && Auto Copy`t%ToggleLiveMenu%, %A_ScriptDir%\Icons\eyes_emoji_64x64.ico
else
	menu, as, icon, Toggle Live Preview && Auto Copy`t%ToggleLiveMenu%, %A_ScriptDir%\Icons\eye_half__32x32.ico
; menu, s, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\settings panel JLicons_33_64x64.ico ; og alt icon

if !(A_IsCompiled)
{
menu, as, add, ; line -------------------------
if (SeeErrors)
	{ ;; if on
	menu, as, add, Don't Show Error AHK Warnings on Launch, Togglewarnings
	menu, as, icon, Don't Show Error AHK Warnings on Launch, %A_ScriptDir%\Icons\stock_dialog-error_96x96.ico
	}
else
	{ ;; if off
	menu, as, add, Suppressing Error AHK Warnings!, togglewarnings
	menu, as, icon, Suppressing Error AHK Warnings!, %A_ScriptDir%\Icons\error_attention caution delete__32x32.ico
	}
}
; menu, as, add, ; line -------------------------
; menu, as, add, If any Toggle options seem stuck - Reload, reload
;---------------------------------------------------------------------------
menu, s, add, < ------ Settings && About ------ >`t%showsettingsmenu%, showsettingsmenu
menu, s, icon, < ------ Settings && About ------ >`t%showsettingsmenu%, %A_ScriptDir%\Icons\setting edit FLUENT_colored_082_64x64.ico,,28
menu, s, default, < ------ Settings && About ------ >`t%showsettingsmenu%
menu, s, add, ; line -------------------------


menu, s, add, Mute Sound on Capslock Toggle`t%togglebeepsetting%, togglebeepsetting
if (CAPS_Beep_Enabled)
	{
	menu, s, icon, Mute Sound on Capslock Toggle`t%togglebeepsetting%, %A_ScriptDir%\Icons\sound__32x32.ico ;1
	}
else
	{
	menu, s, icon, Mute Sound on Capslock Toggle`t%togglebeepsetting%, %A_ScriptDir%\Icons\sound_mute__32x32.ico ;0
	}
	

menu, s, add, Show O S D for Capslock State, osdtoggle
if (Show_CAPS_OSD)
	{ ;1 , SHOWS osd, ON
	menu, s, togglecheck, Show O S D for Capslock State
	CAPSGuiToggle := false
	}
	else
	{ ;0 , DOES NOT SHOW Show_CAPS_OSD, OFF
	menu, s, icon, Show O S D for Capslock State, %A_ScriptDir%\Icons\monitor_lightning__32x32.ico
	CAPSGuiToggle := true
	; gosub osdtogglereset
	}
menu, s, add, Capslock for Number Row ~!@#`$`%^`&&*`(`)_+, shiftednumrow
IF (ShiftedNumRow)
	{
	menu, s, togglecheck, Capslock for Number Row ~!@#`$`%^`&&*`(`)_+
	}
else
	{
	menu, s, icon, Capslock for Number Row ~!@#`$`%^`&&*`(`)_+, %A_ScriptDir%\Icons\hashtag! Comment xfav crunchbang_48x48.ico
	}
if fileexist(notepadpp)
{
	menu, s, add, Replace the NP++ Right Click Menu, ToggleReplaceNPPRightClick
	if (ReplaceNPPRightClick)
		{
		menu, s, togglecheck, Replace the NP++ Right Click Menu
		}
	else
		{
		menu, s, icon, Replace the NP++ Right Click Menu, %A_ScriptDir%\Icons\context menu icon.ico
		}
}
menu, s, add, Double-Right Click to Show Menu, ToggleDoubleRight
if (Double_Right)
	{
	menu, s, togglecheck, Double-Right Click to Show Menu
	}
else
	{
	; menu, s, icon, Double-Right Click to Show Menu, %A_ScriptDir%\Icons\mouse pointer click main_10_2_32x32.ico
	menu, s, icon, Double-Right Click to Show Menu, %A_ScriptDir%\Icons\settings-mouse-right-click_32x32.ico
	}

menu, s, add, Additonal Settings >>>>, :as
menu, s, icon, Additonal Settings >>>>, %A_ScriptDir%\Icons\settings panel JLicons_33_64x64.ico
menu, s, add, ; line -------------------------
menu, s, add, Live Hotkeys Menu >>>>`t%showlivehotkeymenu%, :k
menu, s, icon, Live Hotkeys Menu >>>>`t%showlivehotkeymenu%, %a_scriptdir%\icons\hotkeys.ico
; menu, s, add, AHK Modifier Key Symbols ..., showsettingsmenu
; menu, s, add, Ctrl= ^ `, Alt= ! `, Shift= + `, Win= #, showsettingsmenu
menu, s, add, ; line ;-------------------------
if !(a_isadmin)
	{
		menu, s, add, Run as Admin`t%runasadmin%, runasadmin
		menu, s, icon, Run as Admin`t%runasadmin%, %A_ScriptDir%\Icons\admin imageres_1028.ico
	}
else
	{
		menu, s, add, Script is Running as ADMIN`t%runasadmin%, runasadmin
		menu, s, icon, Script is Running as ADMIN`t%runasadmin%, %A_ScriptDir%\Icons\admin attention win11 imageres_107.ico
	}
menu, s, add, ; line ;-------------------------
; menu, s, add, ; line ;-------------------------
if FileExist(quicknotesdir)
	{
	menu, s, add, Open Quick Notes Dir`t%OpenQuickNotesDir%, OpenQuickNotesDir
	if FileExist(dopus)
		menu, s, icon, Open Quick Notes Dir`t%OpenQuickNotesDir%, %dopus%
		else
		menu, s, icon, Open Quick Notes Dir`t%OpenQuickNotesDir%, %A_ScriptDir%\Icons\folder file explorer imageres_5325_256x256.ico
	menu, s, add, ; line ;-------------------------
	}

menu, s, add, About Extended Caps Lock Menu`t%aboutcapswindow%, aboutcapswindow
menu, s, icon, About Extended Caps Lock Menu`t%aboutcapswindow%, %A_ScriptDir%\Icons\about.ico
menu, s, add, Visit Github Webpage`t%visitgithub%, visitgithub
menu, s, icon, Visit Github Webpage`t%visitgithub%, %A_ScriptDir%\Icons\github icon 256x256.ico

menu, s, add, ; line -------------------------

if !(A_IsCompiled)
{
menu, s, Add, Edit Main Script, editscript
if FileExist(Texteditor)
	menu, s, icon, Edit Main Script, %Texteditor%
else
	menu, s, icon, Edit Main Script, notepad.exe 
}


menu, s, add, Edit " -SETTINGS.ini " File, editsettings
menu, s, icon, Edit " -SETTINGS.ini " File, %A_ScriptDir%\Icons\ini alt xfav setting document prefs setupapi_19 256x256.ico
menu, s, add, ; line ;-------------------------
menu, s, add, Reload Script`t%reload%, reload
menu, s, icon, Reload Script`t%reload%, %A_ScriptDir%\Icons\Refresh reload xfave_128x128.ico
; menu, s, add, View Hotkeys, viewhotkeys
; menu, s, icon, View Hotkeys, %A_ScriptDir%\Icons\preferences-desktop hotkeys-keyboard-shortcuts_48x48.ico

menu, s, add, Suspend Hotkeys`t%suspendkeys%, suspendkeys
menu, s, icon, Suspend Hotkeys`t%suspendkeys%, %A_ScriptDir%\Icons\advert-block_64x64.ico
; menu, s, add, Debug Lines, lines
; menu, s, icon, Debug Lines, %A_ScriptDir%\Icons\bug report FLUENT_colored_217_64x64.ico
menu, s, add, ; line ;-------------------------
menu, s, add, Quit \ Exit \ Kill`t%exitscript%, exitscript
menu, s, icon, Quit \ Exit \ Kill`t%exitscript%, %A_ScriptDir%\Icons\skull n bones emoji111.ico

;---------------------------------------------------------------------------
trayicon = %A_ScriptDir%\icons\extended capslock menu icon 256x256.ico

menu, tray, nostandard
menu, tray, icon, %trayicon%

menu, tray, add, Show Extended Capslock Menu, Capsmenubutton
menu, tray, icon, Show Extended Capslock Menu, %A_ScriptDir%\Icons\extended capslock menu icon 256x256.ico,,32
menu, tray,  default, Show Extended Capslock Menu
menu, tray, add, ; line ;-------------------------
menu, tray, add, About Extended Caps Lock Menu`t%aboutcapswindow%, aboutcapswindow
menu, tray, icon, About Extended Caps Lock Menu`t%aboutcapswindow%, %A_ScriptDir%\Icons\about.ico
menu, tray, add, ; line ;-------------------------

menu, tray, add, Reload`t%reload%, reload
menu, tray, icon, Reload`t%reload%, %A_ScriptDir%\Icons\Refresh reload xfave_128x128.ico
; menu, tray, add, View Hotkeys, viewhotkeys
; menu, tray, icon, View Hotkeys, %A_ScriptDir%\Icons\preferences-desktop hotkeys-keyboard-shortcuts_48x48.ico
menu, tray, add, Suspend Hotkeys`t%suspendkeys%, suspendkeys
menu, tray, icon, Suspend Hotkeys`t%suspendkeys%, %A_ScriptDir%\Icons\advert-block_64x64.ico
menu, tray, add, ; line ;-------------------------
menu, tray, add, Settings && About, :s
menu, tray, icon, Settings && About, %A_ScriptDir%\Icons\setting gear cog JLicons_40_64x64.ico

Menu, AHK, Standard
Menu, Tray, Add, AH&Ks Tray Menu, :AHK 
Menu, Tray, icon, AH&Ks Tray Menu, %A_ahkpath%
MENU, tray, add, ; line ;-------------------------
menu, tray, add, Quit \ Exit \ Kill`t%exitscript%, exitscript
menu, tray, icon, Quit \ Exit \ Kill`t%exitscript%, %A_ScriptDir%\Icons\skull n bones emoji111.ico

; Menu, Tray, MainWindow
; menu, tray, add, ; line ;-------------------------

;--------------------------------------------------------------------------- 
;---------------------------------------------------------------------------

global ForceLiveMenu := false

;; end menus

;***************************************************************************
;************************* SOFTWARE LINKS **********************************
;***************************************************************************

url := "https://github.com/indigofairyx/Extended_Capslock_Context_Menu"
astrogrepurl := "https://astrogrep.sourceforge.net/features/"
dittourl := "https://github.com/sabrogden/Ditto"
everythingurl := "https://www.voidtools.com/forum/viewtopicvoid.php?t=9787" 
autocorrecturl := "https://github.com/BashTux1/AutoCorrect-AHK-2.0"
textifyurl := "https://ramensoftware.com/textify"
Textgraburl := "https://github.com/TheJoeFin/Text-Grab/"
notepadppurl := "https://github.com/notepad-plus-plus/notepad-plus-plus"
xnviewmpurl := "https://www.xnview.com/en/xnviewmp/"
dopusforumurl := "https://resource.dopus.com/"
doupushomepageurl := "https://www.gpsoft.com.au"
dopusdocsurl := "https://docs.dopus.com/doku.php?id=introduction"
dngrepurl := "https://dngrep.github.io"
regexbuddyurl := "https://www.regexbuddy.com"



; dllcall for dpi scaling per screen with mixed dpi menu fix ; dpi scaling per screen with mixed dpi menu fix
;; this might break the menu working on windows 7 win7
;; https://www.autohotkey.com/docs/v1/misc/DPIScaling.htm#Workarounds
;; forum post: https://www.autohotkey.com/boards/viewtopic.php?style=1&t=135025
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
;-------------------------
;; these semi work, allow you use hotkeys from the script when the menu is open, usually ahk blocks hotkeys when its busy showing a menu.
Menu_SetModeless("case") ; make menu modeless
Menu_SetModeless("copen") ; make menu modeless
Menu_SetModeless("cfind") ; make menu modeless
Menu_SetModeless("ctools") ; make menu modeless
Menu_SetModeless("cset") ; make menu modeless
Menu_SetModeless("cform") ; make menu modeless
Menu_SetModeless("ctxt") ; make menu modeless
Menu_SetModeless("folders") ; make menu modeless
Menu_SetModeless("alttxt") ; make menu modeless
Menu_SetModeless("Mylibmenu") ; make menu modeless
Menu_SetModeless("run") ; make menu modeless
Menu_SetModeless("alttxtsub") ; make menu modeless
Menu_SetModeless("dtmenu") ; make menu modeless
Menu_SetModeless("insert") ; make menu modeless

if (isfirstrun)
	gosub firstrunwelcome
if (CheckForUpdatesONStartup)
	gosub CheckUpdatesStartup
if (ShowAboutonStart)
	Aboutcapswindow()




Return
;; First Return, END Auto execute

;---------------------------------------------------------------------------

 ;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;; go capslock menu, go case menu, START  caps menu, capsmenu, go menu, case
; menu, Case, Add
; menu, case, add, ; top line ;-------------------------

; MenuCaseShow() ;; function
; {
cmenu:
global LiveMenuEnabled, targetID, xinc, mylibmenu, topmenu, double_right, forcelivemenu, sectionname, showExtraMenusonCAPS, FriendlyName, DisplayName, labelname, HotkeyValue, ReadableHotkey, MenuItems, MenuVars, ShowLiveMenus
; WinGetTitle, winTitle, A
; WinGetClass, winClass, A
; targetID := ""
; winget, targetID, ID, A ;; get the active window ID over which the menu is shown, sometimes the window can become deactivited when showing the menu  this can be used to re-activate the window before pastes
winget, aapp, processname, A


menu, case, add
Menu, case, DeleteAll ; Clear and reinitialize the menu

dtmenurefresh()


Menu, Case, Add, Extended CAPSLOCK Menu  (Toggle CAPS), ToggleCapsLock
Menu, Case, icon, Extended CAPSLOCK Menu  (Toggle CAPS), %Icons%\extended capslock menu icon 256x256.ico
Menu, Case, Default, Extended CAPSLOCK Menu  (Toggle CAPS)
Menu, case, add, ; line ------------------------- menu, case, top line

if (LiveMenuEnabled || ForceLiveMenu) ;  (LiveMenuEnabled) ; Check if LiveMenu is enabled
    {
        CopyClipboardCLM()  ; Auto Copy - Only when live menu is enabled
		if (Clipboard = "")
			{
				MenuItemName := "Your Clipboard is Empty. Err1"
				Menu, case, Add, %MenuItemName%, viewclip
				Menu, case, icon, %MenuItemName%, %Icons%\error bot flow xfav_48x48.ico
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
			Menu, case, icon, %MenuItemName%, %Icons%\error bot flow xfav_48x48.ico
			menu, case, add, ; line -------------------------
			restoreclipboard()
		}
    else
 		{
			Menu, case, Add, %MenuItemName%, viewclip
			Menu, case, icon, %MenuItemName%, %Icons%\QAP-preview_pane_c_26x26.ico,,24
			menu, case, add, ; line -------------------------
			; Menu, case, icon, %MenuItemName%, %Icons%\error bot flow xfav_48x48.ico ;alt icon
			; Menu, case, icon, %MenuItemName%, %Icons%\view error_192x192.ico ;alt icon
		}
	}
    else
    {
        ; MenuItemName := "Live Preview && Auto Copy is Disabled"
        ; Menu, case, Add, %MenuItemName%, viewclip
        ; Menu, case, icon, %MenuItemName%, %Icons%\eye_close__32x32.ico
		; Menu, case, add, ; line -------------------------
		; this section can be comment out to completely hide this static menu item when its off, it will\\can only appear when turn on
    }

menu, case, add, Text Tools && Apps.....`t%showtoolsmenu%, :ctools
menu, case, icon, Text Tools && Apps.....`t%showtoolsmenu%, %Icons%\Pencil and Ruler__32x32.ico
menu, case, add, Find\Search Selected Text.....`t%showfindmenu%, :cfind
menu, case, icon, Find\Search Selected Text.....`t%showfindmenu%, %Icons%\search find Windows 11 Icon 13_256x256.ico

menu, case, add, Open\Run\Explore\Files.....`t%showopenmenu%, :copen
; menu, case, icon, Open\Run\Explore...   ,
menu, case, icon, Open\Run\Explore\Files.....`t%showopenmenu%, %Icons%\folder tree FLUENT_colored_051_64x64.ico



menu, case, add ; line ;-------------------------
menu, case, add, Modify Text && Case.....`t%showctxtmenu%, :ctxt
menu, case, icon, Modify Text && Case.....`t%showctxtmenu%, %Icons%\richtext_editor__32x32.ico
menu, case, add, ; line ;-------------------------



; menu, Case, Add, Wrap in "&Quotes"`t%ClipQuote%, ClipQuote ; ;10 %A_Space% in menu
; menu, Case, icon, Wrap in "&Quotes"`t%ClipQuote%, %Icons%\format quote_24x24.ico ; "
; menu, Case, add, `{..Curly &Brackets..`}`, On New Lines`t%wrapincbrackets%, wrapincbrackets
; menu, Case, icon, `{..Curly &Brackets..`}`, On New Lines`t%wrapincbrackets%, %Icons%\coding code json filetype_24x24.ico

menu, case, add, Code Formatting.....`t%showcodemenu%, :code
menu, case, icon, Code Formatting.....`t%showcodemenu%, %Icons%\code spark xfav function_256x256.ico

menu, Case, Add ; line ;-------------------------


menu, Case, Add, Copy     [Single Tap CAPS]`t^C, basiccopy
menu, Case, icon, Copy     [Single Tap CAPS]`t^C, %Icons%\edit-copy_32x32.ico
Menu, case, Add, + Copy     [Add to Clipboard]`t%appendclip%, appendclip
Menu, case, icon, + Copy     [Add to Clipboard]`t%appendclip%, %Icons%\clipboard add plus append 64x64.ico
; menu, case, icon, + Copy (Add to Clipboard), %Icons%\copySpecial_48x48.ico ; alt icon
Menu, Case, add, Cut`t^X, basiccut
menu, case, icon, Cut`t^X, %Icons%\edit-cut_32x32.ico
menu, case, add, Paste     [Double Tap CAPS]`t^V, basicpaste
menu, case, icon, Paste     [Double Tap CAPS]`t^V, %Icons%\edit-paste_256x256.ico



if (showExtraMenusonCAPS)
	{
		
		menu, case, add, ; line -------------------------
		gosub buildClipboardMenu
		menu, case, add, Live Clipboard Menu >>>>`t%showclipboardmenu%, :c
		menu, case, icon, Live Clipboard Menu >>>>`t%showclipboardmenu%, %icons%\checkclipboard.ico
		if FileExist(snipdir)
			gosub BuildSnippetFolderMenu
		gosub buildinsertmenu
		menu, case, add, Insert >>>>`t%showinsertmenu%, :i
		menu, case, icon, Insert >>>>`t%showinsertmenu%, %Icons%\lc_insertdocumentaddarrow_26x26.ico
		menu, case, add, ; line ;-------------------------

	}

if (showExtraMenusonCAPS)
	{
		menu, case, add, Quick Save Selection to Note.txt`t%quicktxtfile%, quicktxtfile
		menu, case, icon, Quick Save Selection to Note.txt`t%quicktxtfile%, %A_ScriptDir%\Icons\lc_savebasicas_26x26.ico
		if fileExist(quicknotesdir)
			{
				topmenu = %quicknotesdir%
				; msgbox TM:%topmenu% `n QN: %quicknotesdir%
				gosub topmenu  ; build live menu item
				Menu, case, add, Quick Notes Dir`t%OpenQuickNotesDir%, :%topmenu%
				Menu, case, icon, Quick Notes Dir`t%OpenQuickNotesDir%, %A_ScriptDir%\Icons\folder_go__32x32.ico
				menu, case, add, ; line -------------------------
			}
		else
			menu, case, add, ; line ----------------------
			
		if (aapp = "notepad++.exe") && if FileExist(notepadpp)
			{
				gosub alttxtnppmenu
				menu, case, add, NP++ Open in Alt Editor Menu >>>`t%alttxtnppmenu%, :alttxt
				; menu, case, icon, NP++ Open in Alt Editor Menu >>>`t%alttxtnppmenu%, %A_ScriptDir%\Icons\document text edit rename FLUENT_colored_453_64x64.ico
				menu, case, icon, NP++ Open in Alt Editor Menu >>>`t%alttxtnppmenu%, %notepadpp%
				menu, case, add, ; line -------------------------
			}

		; menu, case, add, ; line -------------------------
		menu, case, add, Live Hotkeys Menu >>>>`t%showlivehotkeymenu%, :k
		menu, case, icon, Live Hotkeys Menu >>>>`t%showlivehotkeymenu%, %icons%\hotkeys.ico

		menu, case, add, Settings >>>>`t%showsettingsmenu%, :s
		menu, case, icon, Settings >>>>`t%showsettingsmenu%, %Icons%\setting gear cog JLicons_40_64x64.ico
		menu, case, add, Showing Live Menus`t%togaddtionalmenus%, togaddtionalmenus
		menu, case, icon, Showing Live Menus`t%togaddtionalmenus%, %togNN%

		menu, case, add, ; line -------------------------
		menu, case, add, Close This Menu`tEsc, CloseMenu
		menu, case, icon, Close This Menu`tEsc, %Icons%\aero Close_24x24-32b.ico
}

;---------------------------------------------------------------------------
if !(showExtraMenusonCAPS)
	{
	menu, case, add, ; line -------------------------
	menu, case, add, Settings >>>>`t%showsettingsmenu%, :s
	menu, case, icon, Settings >>>>`t%showsettingsmenu%, %Icons%\setting gear cog JLicons_40_64x64.ico
	menu, case, add, Show Additional Live Menus`t%togaddtionalmenus%, togaddtionalmenus
	menu, case, icon, Show Additional Live Menus`t%togaddtionalmenus%, %togff%
	}
return


togaddtionalmenus:
showExtraMenusOnCAPS := !showExtraMenusOnCAPS
if (showExtraMenusOnCAPS)
	{
	IniWrite, 1, %inifile%, Toggles, showExtraMenusOnCAPS
	sleep 300
	; reload
	;; i don't this this reload is need here? as least no on SHARE, this is need to repopulate live folders menus, which I'm not putting in SHARE excpt the one QUICKNOTESDIR, I'm onlly using the below toggle for the (ShowLiveMenus) for my EDIT menu mainly.
	}
else
	{
	IniWrite, 0, %inifile%, Toggles, showExtraMenusOnCAPS
	sleep 300
	}
return


toglivemenus: ;; not being used?? its not actually part of the case menu, its attached to my xahkm main menu, its loads my live folders on the the EDIT menu 
ShowLiveMenus := ! ShowLiveMenus
if (ShowLiveMenus)
	{
		IniWrite, 1, %inifile%, Toggles, ShowLiveMenus
		sleep 300
		reload
	}
else
	{
		IniWrite, 0, %inifile%, Toggles, ShowLiveMenus
		sleep 300
		Reload
	}
return




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
Global filename, dir, ext, filestem, drive, lastfolder, highlighted, selected
	global ClipSaved := ""
sleep 20
	ClipSaved := ClipboardAll  ; Save the current clipboard contents
sleep getdelaytime() * 1000
sleep 50
; sleep 369 ; todo broken fix adjust time longer if needed
	Clipboard := ""  ; Clear the clipboard
	Sleep 50  ; Adjust the sleep time if needed
	; WinGet, id, ID, A
	; WinGetClass, class, ahk_id %id%
	; if (class ~= "(Cabinet|Explore)WClass|Progman|dopus.lister")
		; Send {F2}
	Sendinput, ^c ; Sendinput ^{vk43}  ; Send Ctrl+C COPY
	ClipWait, 0.5
  ; Check if clipboard is empty, a tab, or just whitespace
if (ErrorLevel || Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$"))
	; if ErrorLevel
	{
		Tooltip Copy failed! or you didn't have text selected.`n - Extended Capslock Menu -
		SetTimer, RemoveToolTip, -2000
		Clipboard := ClipSaved  ; Restore the clipboard
		sleep 300
		ClipSaved := ""  ; clear the variable
		sleep 30
		return
	}
}

PasteClipboardCLM() ;; function
{
    global ClipSaved
	sleep 200
			; WinGet, id, ID, A  ; Get the ID of the active window ; errorlevel checks
			; WinActivate, ahk_id %id%  ; Activate the window
	; WinGet, id, ID, A
    ; WinGetClass, class, ahk_id %id%
    ; if (class ~= "(Cabinet|Explore)WClass|Progman|dopus.lister")
        ; Send {F2}
    send, ^v ; Sendinput, ^{vk43} ; send, ^v, ; Sendinput, ^{vk43} ; Sendinput, ^v  ; Send Paste
	sleep getdelaytime() * 1000
	sleep 200
    ; Sleep 500  ; Give the system time to paste the clipboard content
    Clipboard := ClipSaved  ; {Restore the saved clipboard contents}
	sleep 400
    ClipSaved := ""  ; Clear the variable
    sleep 50
}

RestoreClipboard() ;; function
{
global Clipsaved
clipboard := ""
sleep 100
Clipboard := ClipSaved
sleep getdelaytime() * 1000
; sleep 1000
sleep 300
ClipSaved := ""  ; Clear the variable
sleep 50
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

pasteasplaintext() ;; function
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

cleanupPATHstring() ;; function
{
;; new function from claude 01-31-2025, 5th fix for windows enviVars, seems likes its fixed, old fucntion is OKTD
    Global ClipSaved, filename, dir, ext, filestem, drive, lastfolder, activefile, highlighted, match, match1
    ; Basic cleanup
    Clipboard := RegExReplace(RegExReplace(Clipboard, "\r?\n"," "), "(^\s+|\s+$)")  ; remove line breaks\returns
    Clipboard := RegExReplace(Clipboard, "^(?:'*)|('*$)")  ; remove single quotes
    Clipboard := StrReplace(clipboard,"""")  ; remove double quotes
    Clipboard := RegExReplace(Clipboard, ",\s*$")  ; Remove trailing comma and spaces
    
    If (SubStr(Clipboard, 1, 8) = "file:///") { ; Handle file:/// URLs
        decodeURLpath(clipboard)
        goto split
    }
    If InStr(Clipboard, "%A_ScriptDir%") { ; Handle AHK variables
        clipboard := StrReplace(Clipboard, "%A_ScriptDir%", A_ScriptDir)
        dir := RegexReplace(clipboard, "\\[^\\]*$", "")
    }
    Loop { ; Handle environment variables
        ; Match any %variable% pattern
        if RegExMatch(Clipboard, "i)%(\w+)%", match) {
            ; Get the environment variable value
            EnvGet, envValue, %match1%
            if (envValue != "") {
                ; Replace the %variable% with its value
                Clipboard := StrReplace(Clipboard, match, envValue)
                continue
            } else {
                tooltip, ERR! @Line#:  %A_linenumber%`nEnvironment variable %match1% not found
                SetTimer, RemoveToolTip, -1500
                break
            }
        }
        break
    }
    
split:
    SplitPath, Clipboard, filename, dir, ext, filestem, drive
    lastfolder := dir
    lastfolder := RegExReplace(lastfolder, ".*\\([^\\]+)\\?$", "$1")
    sleep 90
}
RemoveToolTip() {
    ToolTip
}


/*
; decodeURLpath(inputpath) ;; usage Examples decodeurlpath() ;; function
; myPath := "file:///C:/Some%20Folder/file.txt"
; decodedPath := decodeURLpath(myPath)
; Example 1: Using a variable that already exists
filename := "myfile.txt"                   ; Create a variable first
decodedPath := decodeURLpath(filename)     ; Send that variable to the function

; Example 2: Using a string directly 
decodedPath := decodeURLpath("myfile.txt") ; Send a string directly

; Example 3: Variable can come from anywhere
InputBox, userFile, Enter filename         ; Get filename from user input
decodedPath := decodeURLpath(userFile)     ; Send that input to function

; Example 4: Could be from another function
getSelectedFile() {
    return "selected.txt"
}
decodedPath := decodeURLpath(getSelectedFile())
*/

decodeURLpath(inputpath) {
Global filename, dir, ext, filestem, drive, lastfolder, activefile, highlighted
    If (SubStr(Clipboard, 1, 8) = "file:///") { ; Handle file:/// URLs
        Clipboard := SubStr(Clipboard, 9)
    }
	;;; Special characters allowed in Windows filenames and their URL encodings
    ;;; Decode all URL-encoded special characters
    Clipboard := StrReplace(Clipboard, "%20", " ")   ; Space
    Clipboard := StrReplace(Clipboard, "%21", "!")   ; Exclamation mark
    Clipboard := StrReplace(Clipboard, "%23", "#")   ; Hash/pound
    Clipboard := StrReplace(Clipboard, "%24", "$")   ; Dollar sign
    Clipboard := StrReplace(Clipboard, "%25", "%")   ; Percent
    Clipboard := StrReplace(Clipboard, "%26", "&")   ; Ampersand
    Clipboard := StrReplace(Clipboard, "%27", "'")   ; Single quote
    Clipboard := StrReplace(Clipboard, "%28", "(")   ; Opening parenthesis
    Clipboard := StrReplace(Clipboard, "%29", ")")   ; Closing parenthesis
    Clipboard := StrReplace(Clipboard, "%2B", "+")   ; Plus sign
    Clipboard := StrReplace(Clipboard, "%2C", ",")   ; Comma
    Clipboard := StrReplace(Clipboard, "%2D", "-")   ; Hyphen/minus
    Clipboard := StrReplace(Clipboard, "%2E", ".")   ; Period
    Clipboard := StrReplace(Clipboard, "%3D", "=")   ; Equals sign
    Clipboard := StrReplace(Clipboard, "%40", "@")   ; At symbol
    Clipboard := StrReplace(Clipboard, "%5B", "[")   ; Opening square bracket
    Clipboard := StrReplace(Clipboard, "%5D", "]")   ; Closing square bracket
    Clipboard := StrReplace(Clipboard, "%5E", "^")   ; Caret
    Clipboard := StrReplace(Clipboard, "%60", "`")   ; Backtick ;"
    Clipboard := StrReplace(Clipboard, "%7B", "{")   ; Opening curly brace
    Clipboard := StrReplace(Clipboard, "%7D", "}")   ; Closing curly brace
    Clipboard := StrReplace(Clipboard, "%7E", "~")   ; Tilde
	Clipboard := StrReplace(Clipboard, "%C2%A6", "¦")   ; Vertical bar symbol
	Clipboard := StrReplace(Clipboard, "%2F", "/")   ; Forward slash
	Clipboard := StrReplace(Clipboard, "%5F", "_")   ; Underscore
	Clipboard := StrReplace(Clipboard, "%3B", ";")   ; Semicolon
	Clipboard := StrReplace(Clipboard, "%3A", ":")   ; Colon
	Clipboard := StrReplace(Clipboard, "%3F", "?")   ; Question mark
	Clipboard := StrReplace(Clipboard, "%3C", "<")   ; Less than
	Clipboard := StrReplace(Clipboard, "%3E", ">")   ; Greater than
	Clipboard := StrReplace(Clipboard, "%7C", "|")   ; Pipe
    Clipboard := StrReplace(Clipboard, "/", "\") 	; Convert forward slashes to backslashes
    return Clipboard
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
UnPascal() ;; Function
{
    global ClipSaved
    IfLive()
    Clipboard := RegExReplace(Clipboard, "([a-z])([A-Z])", "$1 $2")  ; Insert space before uppercase letters
    Clipboard := RegExReplace(Clipboard, "([A-Z])([A-Z][a-z])", "$1 $2")  ; Handle acronyms followed by normal words
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
spread() ;; function
{
global ClipSaved
    IfLive()
	Clipboard := RegExReplace(Clipboard, "(?<=.)(?=.)", " ")
	sleep 750
    PasteClipboardCLM()
}

; sort text:
sorttext() ;; function
{
Global ClipSaved
    IfLive()
	Sort, Clipboard
	sleep 750
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

/*
AutoHotkey V1.1
This letter swap routine works by placing the cursor between two characters and 
hitting the Hotkey combination ALT+R. The letters reverse position.
You can find a discussion of this routine (plus other word swapping routines)
in "Chapter Nine: AutoHotkey Windows Clipboard Techniques for Swapping Letters"
in the section  "Eliminating the Requirement for Pre-Selected Text"
of the book "AutoHotkey Hotkeys: Tips, Tricks, Techniques, and Best Practices"
https://www.computoredgebooks.com/AutoHotkey-Hotkey-Techniques-All-File-Formats_c41.htm?sourceCode=FreeAppsPage
https://www.computoredge.com/AutoHotkey/Downloads/LetterSwap.ahk
*/

; $!r::
letterswap:
 OldClipboard := ClipboardAll
 sleep 300
  Clipboard = 
  SendInput {Left}+{Right 2}
  SendInput, ^c
  ClipWait 0 ;pause for Clipboard data
if (ErrorLevel || Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$") || StrLen(Clipboard) !== 2)
    {
        Tooltip, ERR! Your Clipboard is empty.
        Sleep 1500
        Tooltip
        Clipboard := OldClipboard  ; Restore the original clipboard
		sleep 800
        return
    }
  SwappedLetters := SubStr(Clipboard,2) . SubStr(Clipboard,1,1)
  SendInput, %SwappedLetters%
  SendInput {Left}
 Clipboard := OldClipboard
Return

RemoveEmptyLines() {
    ClipSaved := ClipboardAll
    Clipboard := "" ; Clear clipboard
    Send, ^c
    ClipWait, 2
    if ErrorLevel {
        MsgBox, Failed to copy text.
        return
    }

    ; Remove multiple blank lines
    Clipboard := RegExReplace(Clipboard, "(\r\n)\s*(?=\r\n)", "")
    
    ; Remove leading and trailing whitespace from each line
    Clipboard := RegExReplace(Clipboard, "^\s+|\s+$", "", "", true)
    
    ; Remove lines that are completely empty or just whitespace
    Clipboard := RegExReplace(Clipboard, "(\r\n){2,}", "`r`n")
    
    ; Trim multiple spaces within lines
    Loop {
        TempClip := RegExReplace(Clipboard, "  ", " ")
        if (TempClip = Clipboard)
            break
        Clipboard := TempClip
    }

    ; Send the modified text
    Send, ^v
    
    ; Restore original clipboard
    Sleep, 100
    Clipboard := ClipSaved
}

;---------------------------------------------------------------------------
;********* END *********** MENU, CTXT, FUNCTIONS ********** END ************

;***************************************************************************
;************************* menu, code, FUNCTIONS **************************
;***************************************************************************

wrapparen:
global clipsaved
    IfLive()
	sleep 300
	  Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
	  sleep 150
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
Global ClipSaved 
IfLive()
sleep 100
Clipboard := RegExReplace(Clipboard, "^\s+|\s+$")
Tmp:=Clipboard
sleep 150
Tmp = `{`n%Tmp%`n`}
Clipboard =
Sleep 200
Clipboard := Tmp
sleep 150
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

ahknewline:
IfLive()
tmp := Clipboard
sleep 20
tmp = ``n%tmp%``n
sleep 20
clipboard := tmp
sleep 200
pasteclipboardclm()
return

expandscriptdir:
IfLive()
clipboard := StrReplace(Clipboard, "%A_ScriptDir%", A_ScriptDir)
sleep 100
pasteclipboardclm()
sleep 800
return
; 1:: ;; testing
decodexml:
iflive()
; XMLDecode(clipboard)
XMLDecode()
sleep 400
pasteclipboardclm()
sleep 750

return

; 2:: ;; testing
encodexml:
iflive()
XMLEncode()
; XMLEncode(clipboard)
sleep 400
PasteClipboardCLM()
sleep 750
return

; 3:: ;; testing
convertfileurl:
iflive()
decodeURLpath(clipboard)
sleep 400
PasteClipboardCLM()
sleep 750
return

convertsymbols:
    ClipSaved := ClipboardAll
	sleep 350
    Clipboard := ""
    Send, ^c
    ClipWait, 1
    if (ErrorLevel) {
        MsgBox,,, Failed to copy text. Please select some text and try again.,3
		Clipboard := ClipSaved
        return
    }

    ; Map of unshifted to shifted keys
    Unshifted := "``1234567890-=[]\;',./"
    Shifted :=   "~!@#$%^&*()_+{}|:""<>?"
    Text := Clipboard
    NewText := "" ; Conversion logic
    Loop, Parse, Text
    {
        
        Pos := InStr(Unshifted, A_LoopField) ; Check if the character is in the unshifted map
        if Pos
            NewText .= SubStr(Shifted, Pos, 1) ; Get corresponding shifted character
        else {
            Pos := InStr(Shifted, A_LoopField) ; Check if the character is in the shifted map
            if Pos
                NewText .= SubStr(Unshifted, Pos, 1) ; Get corresponding unshifted character
            else
                NewText .= A_LoopField ; Leave unchanged
        }
    }
    Clipboard := NewText
    ClipWait, 1
    Send, ^v
    Sleep, 100
    Clipboard := ClipSaved
	sleep 800
return


;******** END ************ menu, code, FUNCTIONS ********* END ************
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
		tooltip, ERR! @ line#  %A_LineNumber%`nYour selection was not`nappend to the Clipboard.`nPrevious Clipboard Restored.
		sleep 2500
		tooltip
    }
    ; MsgBox, Text has been appended to the clipboard! ; Optional: Notify the user that text was appended
    return
}
return

guicaps() ;; function, gui, Show_CAPS_OSD overlay
{
if (Show_CAPS_OSD)
	{
		GUI, CAPS: new
	Gui, caps: +AlwaysOnTop +ToolWindow -sysmenu -Caption +LastFound
	Gui, caps: Font, cffb900 s12 bold , Consolas
	Gui, caps: Color, af001d ; changes background color
	Gui, caps: add, picture, xm w18 h18, %A_ScriptDir%\Icons\extended capslock menu icon 256x256.ico
	Gui, caps: Add, Text, X+M ,CAPS LOCK is ON	
	IF (CAPS_Beep_Enabled)
		Gui, Caps: Add, picture, x+m w18 h18, %A_ScriptDir%\Icons\sound__32x32.ico
	else
		Gui, Caps: Add, picture, x+m w18 h18, %A_ScriptDir%\Icons\sound_mute__32x32.ico
	if (ShiftedNumRow)
		{
			gui, caps: add, picture, xm w18 h18, %A_ScriptDir%\Icons\hashtag! Comment xfav crunchbang_48x48.ico
			Gui, caps: Add, Text, X+M , `~`!`@`#`$`%`^&&*( `)`_`+`{ `}`|
		}
	IF (Double_Right)
		{
			gui, caps: add, picture, x+m w18 h18, %A_ScriptDir%\Icons\settings-mouse-right-click_32x32.ico
		}
	if (ReplaceNPPRightClick)
		gui, caps: add, picture, x+m w18 h18, %A_ScriptDir%\Icons\context menu icon.ico
	if (A_IsAdmin)
		gui, caps: add, picture, w18 h18 x+m, %A_ScriptDir%\Icons\admin attention win11 imageres_107.ico
	SysGet, P, MonitorPrimary                           ; get primary monitor number
	SysGet, Mon, MonitorWorkArea, % P                   ; get size of primary monitor
	gui, caps: show, noactivate ;x3370 y2059
	WinSet, TransColor, af001d ; makes set background color transparent
	WinGetPos, X, Y, W, H                               ; get pos of gui
	WinMove, % MonRight - W - 10, % MonBottom - H - 10  ; move gui to bottom right
	WinSet, Region, 0-0 W%W% H%H% R20-20                ; round corners
	; gui, caps: show, x3370 y2059 noactivate
	; Gui, Show, % "x" . (3430) . "y" . (2061) . " NoActivate"
	}
else
	{
		gui, caps: hide
	}
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
    Gui, sticky%StickyCount%: Add, Edit, x10 y45 w630 h280 vStickyText +wanttab, %stickytext%
    
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

guimenubutton: 
coordmode, menu, client
    menu, gui, show, 10,10
return







savestickyquick() ;; function
{
global stickytext
static stickyname
global quicknotesdir
WinGetTitle, activeWindowTitle, A
if (InStr(activeWindowTitle, "AHK Temp Sticky Note"))
	{
    stickyNum := RegExReplace(activeWindowTitle, ".*#(\d+).*", "$1")

    Gui, sticky%stickyNum%: Submit, NoHide ; Get the text from the active sticky window
    GuiControlGet, stickytext, sticky%stickyNum%:, StickyText


	inputbox, stickyname, Create a File Name, Give your new quick note a name.`n`nNo .ext needed. It will auto-save as a .txt file.`n`nIt will automatically be saved to`n%quicknotesdir%`n`nYou can go there quickly from the settings menu., ,  ,300 , ,
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
	if !FileExist(quicknotesdir)
		FileCreateDir, %quicknotesdir%
	sleep 750
	fileappend,%Stickytext%,%quicknotesdir%\%stickyname%.txt,UTF-8
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
    FileAppend, %stickytext%, %SavePath%, UTF-8  ; Append the %stickytext% to the selected file
    sleep 800
	}
return
}

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

		tooltip, Copy Failed!`nOperation Canceled.
		SetTimer, RemoveToolTip, -2000
		Clipboard := origClipboard  ; Restore the clipboard
		sleep 750
        return
    }
   FileSelectFile, SavePath, S16, %A_MyDocuments%, Save Selected Text as a New Document, Text Files (*.txt) ; Prompt for where to save the file
    if SavePath =  ; If no file was selected
		{
			tooltip, File Path Cannot Be Blank`nSave Canceled.
			SetTimer, RemoveToolTip, -2000
			Clipboard := origClipboard 
        Return
		}
	if !InStr(SavePath, ".")  ; Check if the user provided a file extension, if not..
    {
        SavePath := SavePath . ".txt"  ; Append .txt if .ext left black by user
    }
	sleep 250
    FileAppend, %Clipboard%, %SavePath%, UTF-8  ; Append clipboard contents to the selected file
	sleep 400
  clipboard=%origClipboard%
  sleep 1000
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
Global ClipSaved, quicknotesdir
  iflive()
  if (Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$"))
		{
        TrayTip, CAPSkey, Your Clipboard is Empty.`nAborted Auto Save., 4, 18
		tooltip, Copy Failed!`nSaving new quick text canecled.
		SetTimer, RemoveToolTip, -2000
		restoreclipboard()
        return
		}
  inputbox, notename, Create a File Name, Give your new quick note a name.`n`nNo .ext needed. It will auto-save as a .txt file`nIt will automatically be saved to`n%quicknotesdir%`n`nYou can go there quickly from the settings menu., , ,
  if (noteName = ""){
	tooltip, Canceled by User.
	SetTimer, RemoveToolTip, -1500
	restoreclipboard()
	return
	}
; FileCreateDir, Extended Capslock Menu QUICK Notes
if !FileExist(quicknotesdir)
	FileCreateDir, %quicknotesdir%
sleep 750
fileappend,%Clipboard%,%quicknotesdir%\%notename%.txt,UTF-8
sleep 1000
restoreclipboard()
Sleep 400
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
	SetTimer, RemoveToolTip, -2000
	restoreclipboard()
	return
	}
WinWaitActive, ahk_exe notepad++.exe,,7
if errorlevel
	{
	SetTimer, RemoveToolTip, -2000
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
		tooltip, Error Copying The Location Bar`nYour Clipboard is being restored.`nERR! @ Line#  %A_LineNumber%
		sleep 2000
		tooltip
		sleep 50
		restoreclipboard()
		sleep 800
		return
		}
	else
		{
		send, {esc}
		tooltip, Location Bar Copied
		SetTimer, RemoveToolTip, -800
		}
return

TextToSpeech: ; Start Text-to-Speech
    Global ClipSaved, TTS_Voice
    iflive()
    text := Clipboard
    sleep 300
    restoreclipboard()
    if (text != "") {
		tooltip, Reading Selected Text Aloud`nPress ESC to Stop Speaking.
		sleep 1500
		tooltip
        ; Create or reuse the TTS COM object
        if !IsObject(TTS_Voice)
            TTS_Voice := ComObjCreate("SAPI.SpVoice")
        ; Speak asynchronously
        TTS_Voice.Speak(text, 1)  ; The 1 flag means speak asynchronously
    } else {
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

StopSpeaking: ; Stop the TTS
    Global TTS_Voice
    if IsObject(TTS_Voice) {
        TTS_Voice.Pause()  ; Pause speaking
        TTS_Voice := ""    ; Release the COM object
    }
Return



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
			FileAppend, %Clipboard%, %SavePath%, UTF-8  ; Append clipboard contents to the selected file
		}
	else
		{
		FileAppend, %Clipboard%, %SavePath%, UTF-8  ; Append clipboard contents to the selected file
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
TextStatsSelected:
TextStatsSelected()
Return
TextStatsSelected()
{
static word := ""
static index := ""
    ClipSaved := ClipboardAll
    Clipboard := ""
    Send, ^c
    ClipWait, 2
    
    ; Word Count (more robust)
    WordCount := 0
    WordArray := StrSplit(Clipboard, [" ", "`t", "`n", "`r"])
    for index, word in WordArray {
        if (RegExMatch(word, "\w+"))
            WordCount++
    }
    
    ; Character Counts
    CharCount := StrLen(Clipboard)
    CharNoSpaceCount := StrReplace(Clipboard, " ", "")
    CharNoSpaceCount := StrLen(StrReplace(CharNoSpaceCount, "`n", ""))
    CharNoSpaceCount := StrLen(StrReplace(clipboard, "`n", ""))
    CharNoWhitespaceCount := RegExReplace(Clipboard, "\s", "")
    
    ; Line Count
    LineCount := 0
    Loop, Parse, Clipboard, `n, `r
    {
        if (Trim(A_LoopField) != "")
            LineCount++
    }
    
    ; Paragraph Count
    ParagraphCount := 0
    Loop, Parse, Clipboard, `n, `r
    {
        if (Trim(A_LoopField) != "")
            ParagraphCount++
    }
    
    ; Estimated Reading Time
    AverageReadingSpeed := 200  ; words per minute
    EstReadTimeMin := Ceil(WordCount / AverageReadingSpeed)
    
    ; Complexity Metrics
    SentenceCount := 0
    LongWordCount := 0
    TotalWordLength := 0
    
    ; Split into sentences (basic approach)
    SentenceSplitRegex := "[.!?]+"
    Loop, Parse, Clipboard, %A_Space%
    {
        ; Count sentences
        if (RegExMatch(A_LoopField, SentenceSplitRegex))
            SentenceCount++
        
        ; Identify long words and calculate average word length
        if (StrLen(A_LoopField) > 6)
            LongWordCount++
        
        TotalWordLength += StrLen(A_LoopField)
    }
    ; Restore clipboard
    Clipboard := ClipSaved
    
    AverageWordLength := TotalWordLength / WordCount
    ComplexityScore := (LongWordCount / WordCount) * 100
    
    ; Prepare message
    StatMessage := "Text Statistics:`n`n"
    StatMessage .= "Line Count: " . LineCount . "`n"
    StatMessage .= "Word Count: " . WordCount . "`n"
    StatMessage .= "Character Count: " . CharCount . "`n"
    StatMessage .= "  (without spaces): " . CharNoSpaceCount . "`n`n"
    ; StatMessage .= "  (no whitespace): " . CharNoWhitespaceCount . "`n"
    ; StatMessage .= "Advanced Metrics:`n"
    StatMessage .= "Sentences: " . SentenceCount . "`n"
    StatMessage .= "Paragraph Count: " . ParagraphCount . "`n"
    StatMessage .= "Average Word Length: " . Round(AverageWordLength, 2) . " chars`n`n"
    StatMessage .= "Estimated Reading Time: " . EstReadTimeMin . " minutes`n"
    StatMessage .= "Complexity Score: " . Round(ComplexityScore, 2) . "%`n"
    
    ; Optional: Logging to a file
    ; FileAppend, %A_Now% - Text Statistics`n%StatMessage%`n---`n, TextStats.log
    
    MsgBox, 262148, , %StatMessage%`n`nWould you like to copy to your clipboard? 
	IfMsgBox no
		return
	IfMsgBox yes	
		{
			; copystatsselected:
			clipboard := ""
			clipboard = %statmessage%
			sleep 50
			return
		}
	return
}


;************************* END, MENU, CTOOLS, FUNCTIONS ********************
;***************************************************************************



;***************************************************************************
;************************* MENU, WEB, FUNCTIONS ****************************
;************************* MENU, CFIND, FUNCTIONS **************************
;*************************************************************************** 
ahksearchmenu:
		global ClipSaved
		IfLive()
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := Clipsaved
        }

		Run "http://www.google.com/search?q=%clipboard%+site:autohotkey.com"
		sleep 200
		run, "https://www.autohotkey.com/search/?q=%clipboard%"
		sleep 200
        ; Clipboard := ClipSaved
		; sleep 200
		restoreclipboard()
		sleep 50
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
        if (Clipboard = "")
		{ ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }

		Run, https://www.google.com/search?q=define+%Clipboard%
        Sleep 100
        Clipboard := ClipSaved ; Restore the original clipboard content
		sleep 300
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
        Sleep 100
        Clipboard := ClipSaved ; Restore the original clipboard content
		sleep 750
Return

youtubethis() ;; function
{
       IfLive()
	   global ClipSaved
        if (Clipboard = "") { ; If the clipboard is empty, use the old clipboard content
            Clipboard := ClipSaved
        }
        Run, http://www.youtube.com/search?q=%Clipboard%
        Sleep 100
        Clipboard := ClipSaved ; Restore the original clipboard content
		sleep 750
return
}


;--------------------------------------------------
; HELPFILES := {"AutoHotkey.chm": "C:\\Program Files\\AutoHotkey\\AutoHotkey.chm"}
; C:\Program Files\AutoHotkey\AutoHotkey.chm
; For k, v in HELPFILES
; {
;     Label := Func("GetHelp").Bind(v, StrReplace(A_Args[1], "#", "_"))
;     Menu, Help, Add, % k, % Label
;     Menu, Help, Icon, % k, %A_WinDir%\hh.exe
; }
; Menu, Help, Show

ahkhelplocal:
Global ClipSaved
iflive()
sleep 30
; keyword := Clipboard
; sleep 30
; RestoreClipboard()
; sleep 30

; GetHelp(GetHelpFile(), clipboard:=A_Args[1])
GetHelp(GetHelpFile())
; Return

GetHelpFile() {
    SplitPath, A_AhkPath, , OutDir
    Return OutDir "\AutoHotkey.chm"
}

GetHelp(HelpFile) {
    ; Run, %HelpFile%, , Max, ID
	; Run, %HelpFile%, , , ID
	IfWinExist, AutoHotkey Help
		{
		WinActivate, AutoHotkey Help
		}
	else
		{
		Run, %HelpFile%, , , ID
		WinActivate, % "ahk_id " ID
		}
    Sleep, 200
    Send, !s
	sleep 20
	Send, ^a
    SendInput, {Raw}%clipboard%
    Sleep, 100
    Send, {Enter}
    Send, {Enter}
}

sleep 100
restoreclipboard()
sleep 750
return
;--------------------------------------------------
;************************* END, MENU, CFIND, FUNCTIONS *********************
;*************************************************************************** 

dtMenuAction:
	; clipboard := ""
	; clipboard := A_ThisMenuItem
	SendInput %A_ThisMenuItem%{Raw}%A_EndChar%
	; SendInput %A_ThisMenuItem%
Return
;***************************************************************************
;************************* TEXT SWAP START SECTION *************************
/*
; [ text_swap script info]
; version     = 1.2
; description = at a certain character or word, interactively text swap
; description = at a certain character or word, swap text interactively
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
CoordMode, Caret, Screen
CoordMode, ToolTip, Screen
selected := selected_text()
loop, % strLen(selected) / 1.6
    div .= "- "  ; make divider
mouseGetPos, mx, my
if inStr(a_thisLabel, "repeat_last")
     swapped := swap(selected, this := last_swap)
else swapped := selected
toolTip, % "Swap at: """ . this . """`nPress {Enter} to Apply, {Esc} to Cancel`n`n" selected "`n" div "`n" swapped, mx, my+50

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
	toolTip, % "Swap at: """ . this . """`nPress {Enter} to Apply, {Esc} to Cancel`n`n" selected "`n" div "`n" swapped, mx, my+50
    ; tooltip, % "Swap at: """ . this . """`n`n" selected "`n" div "`n" swapped, mx, my+50
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
    stringGetPos, swappos, string, % at_this
    stringMid, left, string, swappos, , L
    stringGetPos, swappos, string, % at_this
    stringMid, right, string, swappos + strLen(at_this) + 1

    stringRight, left_space,  left,  % strLen(left)  - strLen(rTrim(left))
    stringLeft,  right_space, right, % strLen(right) - strLen(lTrim(right))

    return lTrim(right) . left_space . at_this . right_space . rTrim(left)
}
;*************************  END text swap SECTION **************************
;***************************************************************************
 FlipTextSeparator()
{
    global ClipSaved
    IfLive()

    ; Ask for the separator character
    InputBox, sep, Separator, Enter the character to flip text around:
    if (ErrorLevel || sep = "")
        return ; Exit if canceled or empty input

    ; Escape special characters for RegEx
    escSep := RegExReplace(sep, "([\\\.\*\+\?\^\$\(\)\{\}\[\]\|])", "\$1")

    ; Process each line separately
    newText := ""
    Loop, Parse, Clipboard, `n, `r
    {
        if (RegExMatch(A_LoopField, "^(.*?)" . escSep . "(.*)$", match))
            newText .= match2 . sep . match1 "`r`n"
        else
            newText .= A_LoopField "`r`n" ; Keep unchanged if no separator
    }

    ; Trim and update clipboard
    Clipboard := RTrim(newText, "`r`n")
    PasteClipboardCLM()
}

AddSpacesAroundSeparator()
{
    global ClipSaved
    IfLive()

    ; Ask for the separator character
    InputBox, sep, Separator, Enter the character to add spaces around:
    if (ErrorLevel || sep = "")
        return ; Exit if canceled or empty input

    ; Escape special characters for RegEx
    escSep := RegExReplace(sep, "([\\\.\*\+\?\^\$\(\)\{\}\[\]\|])", "\$1")

    ; Process each line separately
    newText := ""
    Loop, Parse, Clipboard, `n, `r
    {
        newText .= RegExReplace(A_LoopField, "\s*" . escSep . "\s*", " " . sep . " ") "`r`n"
    }

    ; Trim and update clipboard
    Clipboard := RTrim(newText, "`r`n")
    PasteClipboardCLM()
}


RemoveSpacesAroundSeparator()
{
    global ClipSaved
    IfLive()

    ; Ask for the separator character
    InputBox, sep, Separator, Enter the character to remove spaces around:
    if (ErrorLevel || sep = "")
        return ; Exit if canceled or empty input

    ; Escape special characters for RegEx
    escSep := RegExReplace(sep, "([\\\.\*\+\?\^\$\(\)\{\}\[\]\|])", "\$1")

    ; Process each line separately
    newText := ""
    Loop, Parse, Clipboard, `n, `r
    {
        newText .= RegExReplace(A_LoopField, "\s*" . escSep . "\s*", sep) "`r`n"
    }

    ; Trim and update clipboard
    Clipboard := RTrim(newText, "`r`n")
    PasteClipboardCLM()
}


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

;--------------------------------------------------
; todo testing, next two functions ;; this works 


; Supports SciTE and Notepad++.
; source: https://www.autohotkey.com/docs/v1/Hotkeys.htm#Function
; ^+o:: ;; Ctrl+Shift+O to open containing folder in Explorer.
; ^+e:: ;; Ctrl+Shift+E to open folder with current file selected.
    ; editor_open_folder() {
        ; WinGetTitle, path, A
        ; if RegExMatch(path, "\*?\K(.*)\\[^\\]+(?= [-*] )", path)
            ; if (FileExist(path) && A_ThisHotkey = "^+e")
                ; Run explorer.exe /select`,"%path%"
            ; else
                ; Run explorer.exe "%path1%"
;return
    ; }
;--------------------------------------------------



OpenDIRselection: 
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



RUNfromselection: 
;; this function has been hacked together from 3 different script snippets sources: https://www.autohotkey.com/boards/viewtopic.php?t=64520  https://www.winhelponline.com/blog/open-file-folder-path-clipboard-using-shortcut/   https://www.autohotkey.com/boards/viewtopic.php?t=33822
Global ClipSaved, filename, dir, ext, filestem, drive, lastfolder
iflive()
sleep 75
cleanuppathstring()
sleep 75
; dir := clipboard
; FileGetAttrib, Attributes, % dir
FileGetAttrib, Attributes, %clipboard%
; MsgBox, 4160, dugbug check, clipboard:  %clipboard%`n`nFN: %filename%`nDir: %dir%`next: %ext%`nFs: %filestem%`nDv: %drive%\`nLF: %lastfolder%`n`nAF: %Activefile%`n`nHL: %highlighted%`n`nSN: %A_scriptname%`nLine: %a_linenumber%, 30
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
		sleep 300
		Return
		}
IfInString, clipboard, "shell:::"
	{
	gosub runshell
	sleep 800
	restoreclipboard()
		Return
		}
;open\\run files by ext
	; if % ext = "ahk"
	if (ext = "ahk")
		{
		try Run %texteditor% "%clipboard%"
		catch
		run notepad.exe "%clipboard%"
		sleep 400
		restoreclipboard()
		sleep 300
		Return
		}
	; else if % ext = "ico"
	else if (ext = "ico")
		{
		try Run %xnviewmp% "%clipboard%"
			catch
		try Run "%clipboard%"
		sleep 400
		restoreclipboard()
		sleep 300
		Return
		}
	else if (ext = "exe")
		{
		run "%clipboard%",,useerrorlevel  ; Run % "Explorer.exe /select, " Chr(34) clipboard Chr(34) ;; Chr(34) is quote this opens explore with the file selected
		if errorlevel
				{
				LogError(Clipboard)
				Tooltip, ERR! @ Line: %a_linenumber%`nCould not open this File or Dir.`nPlease Check the Path.
				Sleep, 2500
				Tooltip
				}
		sleep 400
		restoreclipboard()
		sleep 300
		return
		}
	else
		{
		try run "%clipboard%",, UseErrorLevel
			if errorlevel
				{
				LogError(Clipboard)
				Tooltip, ERR! @ Line: %A_linenumber%`nCould not open this File or Dir.`nPlease Check the Path.
				Sleep, 2000
				Tooltip
				}
		sleep 100
		restoreclipboard()
		sleep 800
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
sleep 750
return

runshell:
run, %clipboard%
return


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
                        ToolTip, Failed to copy file: %filetoclip% to`n%destFolder%\%filename%`n`nERR! @ Line#: %A_LineNumber%
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
		sleep 100
        restoreclipboard()
		sleep 300
        return
    }
return

Edittxtfile:
Global ClipSaved 
iflive()
Sleep, 30
cleanupPATHstring()  
dir := Clipboard
FileGetAttrib, Attributes, %dir%
if FileExist(Clipboard) {
    if InStr(Attributes, "D") { ; Check if it's a directory 
		{
        Tooltip, ERR! Line# %A_LineNumber%`nA Folder cannot be edited in a Text Editor
        Sleep, 2000
        Tooltip
        Sleep, 20
        }
    } else { ; it's a file send to text editor
        try {
            Run, %texteditor% "%Clipboard%"
        } catch {
            Run, notepad.exe "%Clipboard%"
        }
        if ErrorLevel {
            Tooltip, ERR! Line# %A_LineNumber%`nOops! Maybe you can't open that file in a Text Editor?
            Sleep, 1500
            Tooltip
        }
    }
} else {
    Tooltip, ERR! Line# %A_LineNumber%`nFile Does Not Exist!
    Sleep, 1500
    Tooltip
}
RestoreClipboard()
sleep 20
return

gowebsite:
Global ClipSaved
iflive()
sleep 90
Clipboard := RegExReplace(RegExReplace(Clipboard, "\r?\n"," "), "(^\s+|\s+$)")
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
		ToolTip, Err. Incorrect URL Format`nSending to google as is...
		Sleep, 2000
		ToolTip
		run, http://www.google.com/search?q=%Clipboard%
		}
	 ; RegExMatch(Clipboard, "^(https?://)?(www\.)?[a-zA-Z0-9-]+\.(com|net|org|edu|gov|co\.uk|ca|de|fr|jp|au)") ;Full URL with Optional Protocol and Subdomain
sleep 300
restoreclipboard()
sleep 20
return

regjumpmenu:
iflive()
sleep 20
cleanuppathstring()
Clipboard := RegExReplace(Clipboard, "^\[|\]$")
; Clipboard := RegExReplace(Clipboard, "^\[+|\]+$") ;; If there are cases where multiple brackets exist (e.g., [[text]]), and you want to remove all [[text]]
Clipboard := RegExReplace(clipboard, "^[+-]", "")  ; Matches '-' or '+' at the start of the line
; sleep 30
ClipWait, 1  ; Wait up to 1 second for clipboard to be set
regpath := Clipboard
RestoreClipboard()
sleep 30
; msgbox clipboard:%clipboard%`n`nRegpath:%regpath%
	If InStr(regpath, "HKEY_")
		RegJump( regpath ) ;Go to Registry path
	else
		{
		Tooltip ERR!  - This Doesn't seem to be`nformatted as a RegKey.
		sleep 1500
		tooltip
		return
		}
; RegJump(RegPath)
return

; OpenREGfromselection:
;Open Regedit and navigate to RegPath.
;RegPath accepts both HKEY_LOCAL_MACHINE and HKLM formats.
; RegJump() essentially does the same as Microsoft's [RegJump](https://learn.microsoft.com/en-us/sysinternals/downloads/regjump), the only advantage being an AHK function it does not rely on a third-party executable to work.
; source: https://www.autohotkey.com/board/topic/85751-regjump-jump-to-registry-path-in-regedit/
RegJump(RegPath)
{
global regeditor
global ClipSaved

if winexist("ahk_class RegEdit_RegEdit")
	{
	; WinClose, Registry Editor ahk_class RegEdit_RegEdit
	; winwaitclose, Registry Editor ahk_class RegEdit_RegEdit,,7
	; Winkill, Registry Editor ahk_class RegEdit_RegEdit
	PostMessage, 0x112, 0xF060,,, ahk_class RegEdit_RegEdit  ; Close using WM_CLOSE
	WinWaitClose, ahk_class RegEdit_RegEdit,,5
	sleep 200
	}
If (SubStr(RegPath, 0) = "\") ;remove trailing "\" if present
	RegPath := SubStr(RegPath, 1, -1)

Loop, Parse, RegPath, \ ;Extract RootKey part of supplied registry path
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

;Make target key the last selected key, which is the selected key next time Regedit runs
RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %RegPath%
sleep 750 ;; adjust time as need so that the key gets written into the registry,
Run, Regedit.exe ;; run regeidt, it will now open to the key written two lines about
winwaitactive, ahk_class RegEdit_RegEdit,,7
if errorlevel
	{
	tooltip, ERR! @ Line#  %A_LineNumber%`nCouldn't run Regedit`nSearch Canceled.
	sleep 2000
	tooltip
	sleep 30
	; RestoreClipboard()
	return
	}
return
}
;; END RegJump
;---------------------------------------------------------------------------

viewfilepropteries:
fileprop := ""
iflive()
cleanupPATHstring()
fileprop = %clipboard%
; clipboard = fileprop
; msgbox clip:   %clipboard%`n`nfileprop:   %fileprop%
restoreclipboard()
sleep 100
if fileexist(fileprop)
	if FileExist(dopusrt)
		run, %dopusrt% /cmd Properties "%fileprop%"
	else
		run, Properties "%fileprop%"
else
	{
		Tooltip, ERR! @ Line#:  %A_LineNumber%`nThe file from your selection could not be found.
		Sleep 2000
		Tooltip
	}
return

fileopenwith:
fileopenw := ""
iflive()
cleanupPATHstring()
fileopenw = %clipboard%
restoreclipboard()
if fileexist(fileopenw)
	; run, C:\Windows\SysWOW64\OpenWith.exe "%fileopenw%" ;; both work, system32 is more basic so...
	run, C:\Windows\System32\OpenWith.exe "%fileopenw%"
else
	{
		Tooltip, ERR! @ Line#:  %A_LineNumber%`nThe file from your selection could not be found.
		Sleep 2000
		Tooltip
	}
return
;---------------------------------------------------------------------------
copydetails() ;; function ; menu, copen, funtion ; Use CMD to save open folder contents info to clipboard, not used
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
		tooltip, Err. @ line# %A_LineNumber%`nCopying the content of the selected file failed.`nFile could not be found or read.
		sleep 2000
		tooltip
		sleep 175
		restoreclipboard()
		sleep 100
		return
	}
return
}


makedup: ;; todo, I need to make a dir errorlevel check here
Global ClipSaved,activefile,filename,dir,ext,filestem,drive
iflive()
sleep 30
cleanuppathstring()

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
					tooltip
					goto finishdup
				}
			IfMsgBox no
				goto finishdup
			IfMsgBox timeout
				goto finishdup
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
finishdup:

sleep 500
restoreclipboard()
sleep 200
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
SplitPath, clipboard, , dir
if fileExist(clipboard)
	{
SplitPath, dir, , dir2
FileMove, %clipboard%, %dir2%
sleep 400
restoreclipboard()
		sleep 300
		return
	}
else
	{
		Tooltip, ERR! @ Line#:  %A_LineNumber%`nFile not found.
		Sleep 2000
		Tooltip
		sleep 300
		restoreclipboard()
		sleep 300
		Return
	}
return
}



TextStatsFile:
iflive()
cleanupPATHstring()
filepath := Clipboard
RestoreClipBoard()
if !FileExist(filepath)
	{
		tooltip, ERR! That file doesn't exist.
		sleep  1500
		tooltip
		return
	}
FileGetAttrib, Attributes, %filepath%
if (InStr(Attributes, "D"))  ; If it's a directory
	{
		tooltip, This tool cannot analyze a Directory.`nTry again with a file.
		sleep 2500
		tooltip
		return
	}
filetextstats(filepath)
return


FileTextStats(FilePath := "") {
    static index := ""
    static word := ""
    
    IfNotExist, %FilePath%
    {
        ToolTip, File does not exist: %FilePath%
        sleep 1500
        tooltip
        return
    }
    
    FileRead, FileContent, %FilePath%
    if (ErrorLevel) {
        ToolTip, ERR! Could not read file: %FilePath%
        sleep 1500
        tooltip
        return
    }
    
    ; Count total lines, non-empty lines, and empty lines
    TotalLines := 0
    NonEmptyLines := 0
    EmptyLines := 0
    Loop, Parse, FileContent, `n, `r
    {
        TotalLines++
        if (Trim(A_LoopField) != "")
            NonEmptyLines++
        else
            EmptyLines++
    }
    
    ; Rest of the counting logic
    WordCount := 0
    WordArray := StrSplit(FileContent, [" ", "`t", "`n", "`r"])
    for index, word in WordArray {
        if (RegExMatch(word, "\w+"))
            WordCount++
    }
    
    CharCount := StrLen(FileContent)
    CharNoSpaceCount := StrReplace(FileContent, " ", "")
    CharNoSpaceCount := StrLen(StrReplace(CharNoSpaceCount, "`n", ""))
    CharNoWhitespaceCount := RegExReplace(FileContent, "\s", "")
    
    ParagraphCount := 0
    Loop, Parse, FileContent, `n, `r
    {
        if (Trim(A_LoopField) != "")
            ParagraphCount++
    }
    
    AverageReadingSpeed := 200
    EstReadTimeMin := Ceil(WordCount / AverageReadingSpeed)
    
    SentenceCount := 0
    LongWordCount := 0
    TotalWordLength := 0
    SentenceSplitRegex := "[.!?]+"
    Loop, Parse, FileContent, %A_Space%
    {
        if (RegExMatch(A_LoopField, SentenceSplitRegex))
            SentenceCount++
        
        if (StrLen(A_LoopField) > 6)
            LongWordCount++
        
        TotalWordLength += StrLen(A_LoopField)
    }
    
    AverageWordLength := TotalWordLength / WordCount
    ComplexityScore := (LongWordCount / WordCount) * 100
    FileGetSize, FileSize, %FilePath%, K
    SplitPath, FilePath, FileName, FileDir, FileExt, FileNameNoExt, FileDrive
    
    ; Reorganized message with new line counts
    StatMessage := "File Statistics:`n`n"
    StatMessage .= "Filename: " . FileName . "`n"
    StatMessage .= "Location: " . FileDir . "`n"
    StatMessage .= "File Size: " . FileSize . " KB`n`n"
    
    StatMessage .= "Line Statistics:`n"
    StatMessage .= "Total Lines: " . TotalLines . "`n"
    StatMessage .= "Non-Empty Lines: " . NonEmptyLines . "`n"
    StatMessage .= "Empty Lines: " . EmptyLines . "`n`n"
    
    StatMessage .= "Content Statistics:`n"
    StatMessage .= "Word Count: " . WordCount . "`n"
    StatMessage .= "Character Count: " . CharCount . "`n"
    StatMessage .= "  (without spaces): " . CharNoSpaceCount . "`n"
    StatMessage .= "Sentences: " . SentenceCount . "`n"
    StatMessage .= "Paragraphs: " . ParagraphCount . "`n"
    StatMessage .= "Average Word Length: " . Round(AverageWordLength, 2) . " chars`n"
    StatMessage .= "Estimated Reading Time: " . EstReadTimeMin . " minutes`n"
    StatMessage .= "Complexity Score: " . Round(ComplexityScore, 2) . "%"
    
    MsgBox, 262148, , %StatMessage%`n`nWould you like to copy to your clipboard?
    IfMsgBox no
        return
    IfMsgBox yes
    {
        clipboard := ""
        clipboard := StatMessage
        sleep 50
    }
    return
}

;************************* END menu, copen, functions, END *****************
;***************************************************************************


;*************************************************************************** 
;************************** EXTRA SOFTWARE FUNCTIONS ***********************
;************************* MENU, CFIND, FUNCTIONS ************************** todo separte this heading to its own functions
;***************************************************************************

evnotinstalled:
if !FileExist(everything15a)
	{
	MsgBox, 262209, ECLM - App Launcher, Everything 1.5a cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, %everythingurl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		return
	}
return



Findwitheverything:
if !FileExist(everything15a)
	goto evnotinstalled
global clipsaved
	iflive()
	sleep 90
	try Run, %everything15a% -newtab -s "%Clipboard%"
	sleep 800
	restoreclipboard()
	sleep 30
return
WinFindrSearch:
iflive()
; clipboard = winfindterm
winfindrterm = %clipboard%
restoreclipboard()
sleep 200

winfindersearchC = "
(
C:\`r
HKEY_CLASSES_ROOT\`r
HKEY_LOCAL_MACHINE\`r
HKEY_CURRENT_USER\`r
)"

; winfindr = C:\Program Files Portable\WinFindr\WinFindr.exe
; WinFindr.exe "search term one|term two|etc" ["ignore term one|term two|etc"] /K|E|F|D [/From:path1|path2|etc] [/Size:>10MB] [/Not:path1|path2|etc] [/In:zip|rar|doc|etc] [/A|AND] [/NOSTART]
if WinExist("ahk_exe WinFindr.exe")
	{
		winkill
		sleep 800
	}
	
run %winfindr%  "%winfindrterm%" /kedf /from:%winfindersearchC%
return
findastro:
if !FileExist(astrogrep)
	{
	MsgBox, 262209, ECLM - App Launcher, Astrogrep cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, %astrogrepurl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		return
	}
Global ClipSaved 

iflive()
sleep 100
try run "%astrogrep%" /spath="%userprofile%\Documents" /stext="%clipboard%" /s
sleep 1000

restoreclipboard()
sleep 20
return


finddngrep:
if !FileExist(dngrep)
	{
	MsgBox, 262209, ECLM - App Launcher, dnGrep cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, %dngrepurl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		return
	}
Global ClipSaved 
iflive()
sleep 100
try run %dngrep% /f "%userprofile%\Documents" /s "%clipboard%" /st PlainText
sleep 1000

sleep 500
restoreclipboard()
sleep 200
return

dngreploadpath:
if !FileExist(dngrep)
	{
	MsgBox, 262209, ECLM - App Launcher, dnGrep cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, %dngrepurl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		return
	}
Global ClipSaved 
iflive()
sleep 30
cleanupPATHstring()
sleep 30
try run %dngrep% "%dir%" ; "%clipboard%"
sleep 1000
RestoreClipboard()
sleep 200
return

evindex: 
if !FileExist(everything15a)
	goto evnotinstalled
global clipsaved
Sleep 100
iflive()
sleep 200
try Run, %everything15a% -newtab -s* si*: "%Clipboard%"
sleep 300
restoreclipboard()
sleep 175
return


EVfile:
if !FileExist(everything15a)
	goto evnotinstalled
	
	global Clipsaved
	iflive()
	sleep 30
	cleanuppathstring()
	sleep 30
	SplitPath, Clipboard, file, , , , 
	try run %everything15a% -newtab -s "%file%"
	sleep 800
	restoreclipboard()
return


EVpath:
if !FileExist(everything15a)
	goto evnotinstalled
	
global Clipsaved, filename, dir, ext, filename, drive
iflive()
sleep 20
cleanuppathstring()
sleep 20
	; if InStr(Clipboard, "%")  ; If it contains environment variables
		; {
		
		; try run %everything15a% -newtab -s "%clipboard%"
		; sleep 500
		; RestoreClipboard()
		; return
		; }
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
			clipboard := RegExReplace(clipboard, "\\$") ; removes trailing "\" 
			sleep 200
			try run %everything15a% -newtab -s """"%clipboard%""""
		}
		else ; If it's a file
		{
		sleep 200
		try Run, %everything15a% -newtab -s """"%dir%""""
		}

	}
Sleep 300
restoreclipboard()
sleep 750
return


findalllocalnpp:
WinGetClass, class, A
if (class != "Notepad++")  ; Check if the active window is not Notepad++
    {
	tooltip, This active window is not Notepad++`nSearch Canceled
	sleep 1500
	tooltip
	sleep 50
	return
	}
sleep 50
sendinput, ^f
sleep 400
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
if !FileExist(notepadpp)
	{
	MsgBox, 262209, ECLM - App Launcher, Notepad++ cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, https://github.com/notepad-plus-plus/notepad-plus-plus
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		Return
	}
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

; runDopus() ;; function
; {
; Global dopus  ; Make sure to declare the VARIABLE as global
    ; IfWinExist, ahk_class dopus.lister ; ahk_exe dopus.exe
    ; {
        ; WinActivate, ahk_class dopus.lister
    ; }
    ; Else
    ; {
        ; try Run, %dopus%
    ; }
; winwaitactive, ahk_class dopus.lister, , 7 ; - Notepad++
; if errorlevel
	; {
	; tooltip, %dopus%`n...could not be launched`nSearch Canceled.
	; sleep 1500
	; tooltip
	; restoreclipboard()
	; sleep 250
	; return
	; }
; }

; ^+D::
runDopus:
if !FileExist(dopus)
		{
		MsgBox, 262209, ECLM - App Launcher, Directory Opus cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it.`n`nDopus is the only paid software featured on this menu. It's a wonderful over-powered customizable file manager replacement.`nIt has a Free Trail. if you like it you can us this promo code for a 15`% off... ' CW4D0S289B4K ', 30
		IfMsgBox Ok
			run, %doupushomepageurl%
		IfMsgBox timeout
			Return
		IfMsgBox Cancel
			Return
		}
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

runtextify:

if !FileExist(textify)
	{
	MsgBox, 262209, ECLM - App Launcher, Texifty cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, %textifyurl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		Return
	}
try run, %textify%
catch
try run, Textify.exe
catch
try run, "C:\Users\%A_UserName%\AppData\Local\Programs\Textify\Textify.exe"
return

runtextgrab:
if !FileExist(textgrab)
	{
	MsgBox, 262209, ECLM - App Launcher, Text Grab cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, %textgraburl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		Return
	}
try run, %textgrab%
return

runditto:
;; todo, dittobutton:
; send, ^!#v
if !FileExist(ditto)
	{
	MsgBox, 262209, ECLM - App Launcher, Ditto.exe cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, https://ditto-cp.sourceforge.io ;%dittourl%
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		Return
	}
ifwinnotexist, ahk_exe Ditto.exe ; ("ahk_exe Ditto.exe")
{
try run %ditto%
sleep 1000
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

runQCE:
if !fileexist(qce)
	{
	MsgBox, 262209, ECLM - App Launcher, Qucik Clipboard Editor cannot be found.`n`nIf you have it installed try updating it location in the -SETTINGS.ini file.`n`nOr click OK to go its webpage where you can download it., 30
	IfMsgBox Ok
		run, https://clipboard.quickaccesspopup.com/
	IfMsgBox timeout
		Return
	IfMsgBox Cancel
		Return
	}
try run %qce%
return
runabc:
try run, %A_ScriptDir%\AutoCorrect\AutoCorrect_2.0_ECLM.ahk
return
;************************* END, MENU, APPSKEY ******************************

;***************************************************************************
; ~MButton::
; showQucikLiveMenu:
showQuickLiveMenu:
showQuickLiveMenu2:
ForceLiveMenu := true
; MenuCaseShow()
gosub cmenu
menu, case, show
ForceLiveMenu := false
return

;************************* global hotkeys ***********************************
; go hotkeys go to hotkeys
; #If !(WinActive("ahk_exe dopus.exe") || WinActive("ahk_exe notepad.exe") || WinActive("ahk_exe calc.exe")) ;; if not multipule

#If !(WinActive("ahk_exe dopus.exe"))  ; Exclude Directory Opus (dopus.exe) for following hotkeys

; ~MButton::
ShowTheMainMenu:
; menucaseshow()
gosub cmenu
menu, case, show
return

; ^space::
; gosub expmenu
; return
#If  ;;///////////////////////// End excluding dopus condition


~Esc:: ;; Escape to stop speaking
    Gosub StopSpeaking
Return

; ^+r:: ;; Reload Script
reload:
tooltip, %A_ScriptName%`nis Reloading...
sleep 700
tooltip
sleep 30
reload
return




$CapsLock:: ;; show Extended CapsLock Menu!!!
    KeyWait CapsLock, T0.15
    if ErrorLevel
		{
		; MenuCaseShow() ; hold, show menu
		gosub cmenu
		menu, case, show
		}
    else
		{
			KeyWait CapsLock, D T0.15
			if ErrorLevel
				Send ^c ; Single Tap, COPY ; CopyClipboardCLM() ; Single Tap, COPY
			else
				Send ^v ; Double Tap, Paste clipboard content
		}
    KeyWait CapsLock
return


doublerightclick:
if (A_PriorHotkey != "~rbutton" or A_TimeSincePriorHotkey > 300)
	{
		KeyWait, rbutton, u ; Too much time between presses, so this isn't a double-press.
		return
	}
else
	{
		sleep 20
		; menucaseshow() 
		gosub cmenu
		menu, case, show
	}
return
ToggleDoubleRight:
Double_Right := !Double_Right
menu, s, ToggleCheck, Double-Right Click to Show Menu
if (Double_Right)
	{
	IniWrite, 1, %inifile%, Toggles, Double_right
	sleep 100
	Hotkey, ~RButton, doublerightclick, on
	}
else
	{
	iniwrite, 0, %inifile%, Toggles, Double_Right
	; menu, s, icon, Double-Right Click to Show Menu, %A_ScriptDir%\Icons\mouse pointer click main_10_2_32x32.ico
	menu, s, icon, Double-Right Click to Show Menu, %A_ScriptDir%\Icons\settings-mouse-right-click_32x32.ico
	sleep 100
	Hotkey, ~RButton, doublerightclick, off
	}
return

;///////////////////////////////////////////////////////////////////////////

;; gui, sticky, hotkeys, gui sticky hotkeys, gui hotkeys *************************
#IfWinActive AHK Temp Sticky Note #
^s:: ;; save sticky as doc
savestickyAS()
return
^+s:: ;; quick save sticky as .txt
savestickyquick()
return
~rbutton:: ;; show capslock menu on stickys
;; Note: Since Edit controls have their own context menu, a right-click in one of them will not launch GuiContextMenu. // workaround
; menucaseshow()
gosub cmenu
menu, case, show
return
^n:: ;; new empty stick note
gosub newsticky
return
^+O:: ;; open quick notes dir
gosub OpenQuickNotesDir
return
^esc:: ;; close sticky
gosub guidestory
return
^p:: ;; pin\unpin sticky to top
global pin, pinoff, pinon, pinstartpic, StickyCount
gui, submit, nohide
gosub pintotop
return
#IfWinActive

;///////////////////////////////////////////////////////////////////////////

#If GetKeyState("CapsLock", "T") && ShiftedNumRow  ; Check the toggle state // shifted number row hotkeys with toggle
    `::+` ;;  Shifted Capslock
    1::+1 ;;  Shifted Capslock
    2::+2 ;;  Shifted Capslock
    3::+3 ;;  Shifted Capslock
    4::+4 ;;  Shifted Capslock
    5::+5 ;;  Shifted Capslock
    6::+6 ;;  Shifted Capslock
    7::+7 ;;  Shifted Capslock
    8::+8 ;;  Shifted Capslock
    9::+9 ;;  Shifted Capslock
    0::+0 ;;  Shifted Capslock
    -::+- ;;  Shifted Capslock
    =::+= ;;  Shifted Capslock
    [::+[ ;;  Shifted Capslock
    ]::+] ;;  Shifted Capslock
    \::+\ ;;  Shifted Capslock
#If
;///////////////////////////////////////////////////////////////////////////
;------------------------- SHOW MENUS COMMANDS
showsettingsmenu:
menu, s, show
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
showcodemenu:
menu, code, show
return
showdtmenu:
Menu, dtmenu, DeleteAll ;new ;refreshes time menu from click
Date := A_Now
List := DateFormats(A_now)
TextMenuDate(List)
menu, dtmenu, show
return
showctxtmenu:
menu, ctxt, show
return
showcformmenu:
menu, code, show
return

ShowTheMainMenuALTHK:
showmainmenualtkey:
showcapsmenu:
Capsmenubutton:
; menucaseshow()
gosub cmenu
menu, case, show
return
;///////////////////////////////////////////////////////////////////////////

pasteclipboardinquotes:
	saved := clipboard ; save clipboard contents
	Sendraw, "%clipboard%" ; send clipboard content with your characters around it
	clipboard := saved ; restore clipboard
	saved := () ; clear saved
Return

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


switchCASE:
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
    Sleep, 400
  }
  clipboard=%origClipboard%
  sleep 400
return

newsticky:
CreateStickyNote()
return

copytostickynote:
CopyToStickyNote()
return




Togglecapslock:
ToggleCapsLock()
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
; og v2 with sound beep options, works, keep safe
CapsLockey(state := false, toggle := false)
{
    global CAPSGuiToggle, CAPS_Beep_Enabled

    ; If toggling, flip the current CapsLock state
    if (toggle)
        state := !GetKeyState("CapsLock", "T")

    ; Set Caps Lock state only if needed (prevents endless toggling)
    currentCapsState := GetKeyState("CapsLock", "T")
    if (state != currentCapsState)
        SetCapsLockState % state


    CAPSGuiToggle := !CAPSGuiToggle ; Toggle the GUI visibility 
    if (CAPSGuiToggle)
    {
		guicaps()
        if (CAPS_Beep_Enabled)  ; Check if beeping is enabled
        {
            SoundBeep, 100, 100
            SoundBeep, 200, 200
        }
		else
		{
		
		}
    }
    else
    {
        Gui, caps: Hide
        if (CAPS_Beep_Enabled)  ; Check if beeping is enabled
        {
            SoundBeep, 200, 100
            SoundBeep, 100, 200
        }
		else
		{

		}
    }
    return
} 

osdtoggle:
Show_CAPS_OSD := !Show_CAPS_OSD
if (Show_CAPS_OSD)
	{ ;0 , DOES NOT SHOW Show_CAPS_OSD, OFF
	menu, s, togglecheck, Show O S D for Capslock State
	GLOBAL CAPSGuiToggle := FALSE
	IniWrite, 1, %inifile%, Toggles, Show_CAPS_OSD
	SLEEP 400
	gui, caps: hide
	SetCapsLockState, off
	tooltip, On Screen Display`nfor Caplock is ON
	sleep 2000
	tooltip
	}
else
	{ ;1 , SHOWS osd, ON
	menu, s, icon, Show O S D for Capslock State, %A_ScriptDir%\Icons\monitor_lightning__32x32.ico
	GLOBAL CAPSGuiToggle := TRUE
	IniWrite, 0, %inifile%, Toggles, Show_CAPS_OSD
	SLEEP 400
	gui, caps: hide
	SetCapsLockState, off
	tooltip, On Screen Display`nfor Caplock is OFF
	sleep 2000
	tooltip
	}
Return

osdtogglereset:
gui, caps: hide
SetCapsLockState, off
return

ToggleBeepSetting:
; global CAPS_Beep_Enabled
    CAPS_Beep_Enabled := !CAPS_Beep_Enabled
	if (CAPS_Beep_Enabled)
	{
		menu, s, icon, Mute Sound on Capslock Toggle`t%togglebeepsetting%, %A_ScriptDir%\Icons\sound__32x32.ico
		tooltip, SoundBeeps on Capslock toggle is ON!
		iniwrite, 1, %inifile%, Toggles,CAPS_Beep_Enabled
	}
	else
	{
		menu, s, icon, Mute Sound on Capslock Toggle`t%togglebeepsetting%, %A_ScriptDir%\Icons\sound_mute__32x32.ico
		tooltip, SoundBeeps on Capslock Toggle is OFF - MUTED!
		iniwrite, 0, %inifile%, Toggles, CAPS_Beep_Enabled
	}
sleep 1500
tooltip
return




/*
; !g:: ;; alt Google Search ;; todo
googlethis2: ;; todo
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
;************************* menu, s, FUNCTIONS ***************************
;***************************************************************************

Lines:
listlines
return

ListLinesButton() ;; Function
{
listLines
sleep 500
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
		return
	}
	else
	{

	gosub makeini
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
if (A_IsCompiled != 1)
	{
		try run %texteditor% "%filePath%"
		catch
		run, notepad.exe "%filePath%" 
		return
	}
if !FileExist(A_ScriptDir . "\" . "Extended Capslock Menu.ahk")
	{
		tooltip ERR!The source code file could not be found!
		sleep 2000
		tooltip
		return	
	}

MsgBox, 4145, Edit ECLM Script, You are currently running the Compiled.EXE of Extented Capslock Menu which cannot be edited.`n`nThe soucre code is included alongside the '.exe'. That will open open in a text editor instead.`n`nAny changes made in the '.ahk' will not be seen by the '.exe' unless you Re-Compile the script first and run the new '.exe' rather than this one.,60
IfMsgBox Ok
	{
	try run %texteditor% "%A_ScriptDir%\Extended Capslock Menu.ahk"
	catch
	run, notepad.exe "%A_ScriptDir%\Extended Capslock Menu.ahk"
	}
IfMsgBox Cancel
	Return
IfMsgBox timeout
	Return
return

ShiftedNumRow:
    ShiftedNumRow := !ShiftedNumRow  ; Toggle the state
    if (ShiftedNumRow)
        {
		ToolTip, Shifted # Row is Enabled`n`~`!`@`#`$`%`^`&`*`(`)`_`+`{`}`|
		menu, s, togglecheck, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+
		iniwrite, 1, %inifile%, Toggles, ShiftedNumRow
		}
    else
        {
		ToolTip, Shifted # Row is Disabled
		menu, s, togglecheck, Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+
		iniwrite, 0, %inifile%, Toggles, ShiftedNumRow
		}
    Sleep, 1500
    ToolTip
Return

ToggleReplaceNPPRightClick: 
    ReplaceNPPRightClick := !ReplaceNPPRightClick ; Toggle the setting
	menu, s, togglecheck, Replace the NP++ Right Click Menu
	if (ReplaceNPPRightClick)
		{
		iniwrite, 1, %inifile%, Toggles, ReplaceNPPRightClick
		; menu, s, togglecheck, Replace the NP++ Right Click Menu
		tooltip, The Right Click menu of Notepad++`nhas been replaced with Extended Capslock Menu!`n`nUse with Caution`, sometimes NP++'s menu is still triggered.`nIt can cause errors at times.
		sleep 1000
		}
	else
		{
		iniwrite, 0, %inifile%, Toggles, ReplaceNPPRightClick
		menu, s, icon, Replace the NP++ Right Click Menu, %A_ScriptDir%\Icons\context menu icon.ico
		Tooltip, Notepad++'s Right Click Menu has been Restored.
		sleep 500
		}
sleep 1500
tooltip
return

visitgithub:
run https://github.com/indigofairyx/Extended_Capslock_Context_Menu
return

OpenQuickNotesDir:
	try run, %quicknotesdir%
		catch
	msgbox,,Extended Capslock Menu,Your Quick Notes Folder was not found.`n`nTry saving some notes first.,7
return

aboutsoftwareL:
msgbox, 262144, A quick note the Software Launchers.`n`nThe AutoHotkey Auto Spelling Correct Script is already included with this download. That will run. -- The others are not included.`n`nThese are great Software Tools for working with text, they are free to download and install. Links are in the about window.`n`nIf you install them anywhere other than their default locations you have to update the PROGRAM PATHS to the .exe files inside of the settings file manually.
return

suspendkeys:
suspend
menu, s, ToggleCheck, Suspend Hotkeys
menu, tray, ToggleCheck, Suspend Hotkeys
tooltip, Hotkeys Paused
sleep 2500
tooltip
return

menureturn: ; do nothing donothing
return

; ^!esc:: ;; exit ECLM
exitscript: ; quit script
exitapp
return

aboutwindow:
Aboutcapswindow()
return

CloseMenu:
send, {esc}
return


togSTARTASADMIN:
startasadmin := !startasadmin
if (startasadmin)
	{
		iniwrite, 1, %inifile%, Toggles, StartAsAdmin
		menu, as, icon, Always Run As Admin, %togNN%
	}
else
	{
		iniwrite, 0, %inifile%, Toggles, StartAsAdmin
		menu, as, icon, Always Run As Admin, %togFF%
	}
; gosub runasadmin
return

runasadmin:
If !A_IsAdmin {
    Run *RunAs "%A_ScriptFullPath%" ; Relaunch script as admin
} else {
		MsgBox, 4420, Running As Admin, If you don't want this script running as Admin any longer you must Exit it completely and Re-Run it.`n`nWould you like to EXIT\QUIT now?`n`nYou have to Restart it Manually afterward.`nThis will also toggle StartAsAdmin to Off.`n`nYES = KILL`nNO = Continue as Admin, 30
		IfMsgBox Yes
			{
				; iniwrite, 1, %inifile%, Toggles, ExitAdmin
				iniwrite, 0, %inifile%, Toggles, StartAsAdmin
				sleep 750
				exitapp
			}
		IfMsgBox No
			return
		IfMsgBox timeout
			return
}
return

Togglewarnings:
SeeErrors := !SeeErrors
if (SeeErrors)
	iniwrite, 1, %inifile%, Toggles, SeeErrors
else
	iniwrite, 0, %inifile%, Toggles, SeeErrors
sleep 750
reload
return

togUpdatecheckonstartup:
CheckForUpdatesONStartup := !CheckForUpdatesONStartup
if (CheckForUpdatesONStartup)
	{
	IniWrite, 1, %inifile%, Toggles, CheckForUpdatesONStartup
	menu, as, ToggleCheck, Check For Updates on Start Up
	}
else
	{
	IniWrite, 0, %inifile%, Toggles, CheckForUpdatesONStartup
	menu, as, ToggleCheck, Check For Updates on Start Up
	}
sleep 400
return



togRunonStartUp:
RunonStartUP := !RunonStartUP
if (RunonStartUP) ;; if run on startup create a .lnk in %appdatae%\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
{
			;; examples from ahkhelp
			; SYNTAX 4 -- FileCreateShortcut, Target, LinkFile [, WorkingDir, Args, Description, IconFile, ShortcutKey, IconNumber, RunState]
			; SYNTAX EXAMPLE 4 -- FileCreateShortcut, Notepad.exe, %A_Desktop%\My Shortcut.lnk, C:\, "%A_ScriptFullPath%", My Description, C:\My Icon.ico, i
	IniWrite, 1, %inifile%, Toggles, RunonStartUP
	FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%ScriptName%.lnk,,,Runs Extended Capslock Menu at Startup,%trayicon%,,0
	menu, as, togglecheck, Run ECLM at Start Up

}
else ; if dont run on startup, delete the .lnk from %appdatae%\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
{
	IniWrite, 0, %inifile%, Toggles, RunonStartUP
	FileDelete, %A_StartUp%\%ScriptName%.lnk
	menu, as, togglecheck, Run ECLM at Start Up
}
sleep 400
return

makeini:
fileappend,
(
;; You should always reload the app\menu after save any changes made in this settings file.
[Toggles]
LiveMenuEnabled=0
ModelessMenusTOG=0
StartAsAdmin=0
CAPS_Beep_Enabled=1
Show_CAPS_OSD=1
ShiftedNumRow=0
ReplaceNPPRightClick=1
DarkMode=0
Double_Right=1
ShowAboutonStart=0
isfirstrun=1
SeeErrors=0
CheckForUpdatesONStartup=1
RunonStartUP=0

[MenuOptions]
MaxClipboardLines= 50
;; number of lines to show in the live clipboard menu.
;; 50 is default, lower this number if the menu is too big for your screen.



[Programs]
Texteditor = C:\Program Files\Notepad++\notepad++.exe

adventure = C:\Program Files\Adventure\Adventure.exe
ahkstudio = C:\Program Files\AutoHotkey\AHK Studio\AHK-Studio.exe
astrogrep = C:\Program Files (x86)\AstroGrep\AstroGrep.exe
bcompare = C:\Program Files\Beyond Compare 5\BCompare.exe
ditto = C:\Program Files\Ditto\Ditto.exe
dngrep = C:\Program Files\dnGrep\dnGREP.exe
dopus = C:\Program Files\GPSoftware\Directory Opus\dopus.exe
dopusrt = C:\Program Files\GPSoftware\Directory Opus\dopusrt.exe
everything15a = C:\Program Files\Everything 1.5a\Everything64.exe
excel = C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE
geany = C:\Program Files\Geany\bin\geany.exe
markdownmonster = C:\Program Files\Markdown Monster\MarkdownMonster.exe
notepad4 = C:\Program Files\Notepad4\Notepad4.exe
notepadpp = C:\Program Files\Notepad++\notepad++.exe
obsidian = C:\Users\%A_Username%\AppData\Local\Programs\obsidian\Obsidian.exe
obsidianshell = C:\Program Files Portable\ObsidianShell\ObsidianShell.CLI.exe
QCE = C:\Program Files\Quick Clipboard Editor\QuickClipboardEditor.exe
QCEm = C:\Program Files\Quick Clipboard Editor\QCEmessenger.exe
scite = C:\Program Files\AutoHotkey\SciTE\SciTE.exe
sharex = C:\Program Files\ShareX\ShareX.exe
SublimeText = C:\Program Files\Sublime Text\sublime_text.exe
textgrab = C:\Program Files\Text-Grab\Text-Grab.exe
textify = C:\Users\%A_Username%\AppData\Local\Programs\Textify\Textify.exe
vscode = C:\Users\%A_Username%\AppData\Local\Programs\Microsoft VS Code\code.exe
VSCodium = C:\Users\%A_Username%\AppData\Local\Programs\VSCodium\VSCodium.exe
winfindr = C:\Program Files\WinFindr\WinFindr.exe
word = C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE
xnviewmp = C:\Program Files\XnViewMP\xnviewmp.exe


[Global_Hotkeys]
;; change your hotkeys here, more info in the about window

; ** hotkey layout...
; Labelname=  <-- DO NOT CHANGE anything before the "="
; Set, or remove, the hotkey between the = & |
; labelname= (set your hotkey here) | Description for the live hotkey menu 


Togglecapslock=!Capslock|Toggle Capslock
; ** - Toggle the CAPSLOCK key state - Ctrl + Capslock is hard coded in the script you can set another one here.

;; alternative keys form showing the main menu.
; * Holding Capslock is hardcoded, alternative key and mouse combos can be set here.
ShowTheMainMenuALTHK= ^!F3 | Show Extended Capslock Menu
showmainmenualtkey= | Show Extended Capslock Menu
Capsmenubutton= | Show Extended Capslock Menu
showcapsmenu= | Show Extended Capslock Menu

showQuickLiveMenu= ^MButton | Show Main Menu - with Auto Copy && Preview

editsettings=  | Edit Extended Capslock Menu-SETTINGS.ini

;; each sub-menu can also be shown by itself, independent from the main menu.

showlivehotkeymenu= #F1 | Show Menu - ECLM's Live Hotkey
showtoolsmenu=  | Show Menu - Text Tools 
showfindmenu=  | Show Menu - Search Selected Text 
showopenmenu=  | Show Menu - IF Files\Dirs is [*Selected*] 
showcodemenu= | Show Menu - Code Formatting 
showctxtmenu=  | Show Menu - Modify Text && Case 
showinsertmenu= | Show Menu - Insert Text
showdtmenu=  | Show Menu - Insert Date && Time 
ShowSnippetFolderMenu= ^Insert | Show Menu - Insert Live Snippets Folder
ShowClipboardMenu= | Show Menu - Live Clipboard
showinsertsymbolsmenu= | Show Menu - Insert Symbols 
showsettingsmenu= #Capslock | Show Menu - Settings && About 


;; Additional (semi-hidden) menus ***  meant to be used in NP++ or simialier editors
;; This one below only works when NP++ is the Active App
showalttxtnppmenu=   |  Show Menu - NP++`s Open With Alt Editor
;; These live menus work on a selected folder\file paths e.g... %userprofile%
;; *$$ Known Issues with the live folder menus blow...
;; *If a folder is large, with 1000+ files, it can cause ECLM to slow down or crash.
;; Unfortunately this is a windows OS limitation with building live menus. there's no fix. just use with caution &  reload the app if needed.
expmenu=  | Show Menu - Explore Folder Popup Menu
livefoldermenu=  | Show Menu - Live Folder Menu 

; Items Listed by the menu they appear on. items with no menus at the bottom
;--------------------------------------------------
; items on the < ------ Text Tools ------ > Menu
newtxtfile=  | Save Selection To New Document
quicktxtfile=  | Quick Save Selection to New.txt File
SaveClipboardAsTxt=  | Save Clipboard to New Document
viewclip=  | View Clipboard Text
clearclip=  | Clear Clipboard
appendclip= ^+C | Copy (Add to Clipboard)
pasteasplaintext=  | Paste As Plain Text
ClipQuote= ^' | Wrap Selection in "Quotes"
copylocationbar=  | Grab Location Bar Address (Copy)
CopyToStickyNote= ^+F2 | Copy Selection to Temp Sticky
TextStatsSelected=  | Text Statistics on Selection
TextStatsFile=  | Text Statistics on Seleted File Path
TextToSpeech=  | Read [*Selected Text*] Out Loud

; aboutsoftwareL=  | < --- Software Launchers (?About) --- >
runabc=  | Run AHK Auto Correct (Included)
runditto=  | Run Ditto Clipboard
runQCE=  | Run Quick Clipboard Editor
runtextify=  | Run Textify
runtextgrab=  | Run Text Grab
runnotepadpp=  | Run Notepad++
OpenEmojiKeyboard=  | Emoji Keyboard

; items on the < --- Search Selected Text Menu --- > Menu
;  | < ------ Local Searches ------ >
Findwitheverything=  | Everything -Find via EV 1.5a
evindex=  | System Index -via EveryThing 1.5a
findastro=  | Find in Files with AstroGrep
finddngrep=  | Find in Files with dnGREP
ahkhelplocal=  | Search in AHK Help File (Local)
;  | < ------ Web Searches ------ >
googlethis=  | Google This
youtubethis=  | Youtube This
definethis=  | Define Word (Google)
wikipediasearch=  | Wikipedia Search
ahksearchmenu=  | AHK Site Search via Google
gowebsite= !#U | Visit Website [If URL is Selected]

; Items on the < --- IF Files\Dirs is [*Selected*] Menu --- >
OpenDIRselection=  | Open Folder from Selection
RUNfromselection=  | Run\Open File from Selection
EVpath=  | Explore Folder in Everything
EVfile=  | Search File in Everything
dngreploadpath=  | Load Path into dnGREP for Searching
Edittxtfile=  | Edit in Text Editor
makedup=  | Duplicate File as... "File Name -CopyDup.ext"
filetoclipboard=  | File Content to Clipboard (Text-Based Files)
TextStatsFile=  | File Stats on Selected File Path
RegJump= #J | Jump to Key in RegEdit
wincontextmenu=  | Windows Context Menu ☰ from Selection
fileopenwith=  | Open With... from Selection
viewfilepropteries=  | View File Properties
movefiletofolder=  | Put File into Subfolder (Folder takes Filename)
movefiletoparentfolder=  | Move File Up into it's Parent Folder
copydetails=  | Copy File Names && Details of Folder to Clipboard


; items on the < --- Code Formatting Menu --- >
commentblock= ^+; | AHK - /* Block Comment */ on New Lines
cbrakectswrapped=  | Wrap Selection in {Curly Brackets}
wrapparen= !0 | Wrap Selection in (Parentheses)
squbracket= !] | Wrap Selection in [Square Brackets]
wrappercent= !5 | Wrap Selection in `%PercentSigns`%
CodeLine=  | `Code - Inline` .MD
CodeBox=  | ```Code - Box``` .MD
forumcodebox=  | [code]Box - Forum[/code] 
dopusK=  | <kbd>`K<`/kbd> from Selection
wrapinxmlcomment=  | <!-- xml Comment --> from Selection
ahknewline=  | `nAHK new Line`n
expandscriptdir=  | Expand `%A_ScriptDir`%
Encodexml=  | Encode XML
decodexml=  | Decode XML
convertfileurl=  | Covert file:\\\url to Std Path
wrapincbrackets= !{ | Wrap in {..Curly Brackets..} on New Lines

; items on the <-- Modify Text && Case Menu -->
Upper=  | UPPERCASE
Lower=  | lowercase
Title=  | Title Case
Sentence=  | Sentence case
Capital=  | Capital Case
Reverse=  | Reverse - esreveR
Invert=  | iNVERT cASE - Invert Case
convertsymbols=  | Convert Numbers<&&>Symbols
Pascal=  | PascalCase
camel=  | camelCase
Alternating=  | aLtErNaTiNg cAsE
spread=  | S p r e a d T e x t
RemoveExtraS=  | Remove  Extra   Spaces
RASpace=  | RemoveALL Spaces
RemoveEmptyLines=  | Remove Empty Lines
sorttext=  | Sort Selection... 0-9, A-Z 
addDot=  | Space to Dot.Case
removedot=  | Remove.Dot to Space
addunderscore=  | Space to Under_Score
removeunderscore=  | Remove_Underscore to Space
adddash=  | Space to Dash-Case
removedash=  | Remove-Dash to Space
FixLineBreaks=  | Fix Line Breaks
removeillegal=  | Remove Illegal Characters && Emojis
text_swap=  | Swap @ Anchor Word or Symbol
letterswap= !R  | Flip Chars @ Caret



; items on the  < ------ Settings && About ------ > Menu
togglebeepsetting=  | Mute Sound on Capslock Toggle
osdtoggle=  | Show O S D for Capslock State
shiftednumrow=  | Capslock for Number Row (On\Off) ~!@#`$`%^`&&*`(`)_+
ToggleDoubleRight=  | Double-Right Click to Show Menu
aboutcapswindow=  | About Extended Caps Lock Menu
visitgithub=  | Visit Github Webpage
editscript=  | Edit Main Script
suspendkeys=  | Suspend Hotkeys
exitscript=^!ESC  | Quit \ Exit \ Kill ECLM
reload= ^+R | Reload ECLM
DMToggle=  | Toggle > Dark | Light Menus
togSTARTASADMIN=  | Always Run As Admin
togUpdatecheckonstartup=  | Check For Updates on Start Up
togRunonStartUp=  | Run ECLM at Start Up
ToggleLiveMenu=  | Toggle Live Preview && Auto Copy


; items on the NP++ Open in alt Editor Menu
; ** this menu is fairly fairy specific to be being used with Notepad++ at the moment.
ALTOIdefaulttexteditor=  | Default Text Editor ( `%texteditfilename`% )
altoinppp=  | Notepad++
altoinotepad4=  | Notepad4
altoiscite=  | Scite 4 AHK
altoivscode=  | VS Code
altoigeany=  | Geany
altoiword=  | Word
altoiexcel=  | Excel
altoimarkdownmonster=  | Markdown Monster
aboutalttxtmenu=  | -- Other Quick File Options -- (Also About)
altmakedup=  | Duplicate File as... " `%filestem`% -CopyDup.`%ext`% "
altcopypath=  | Copy Full Path to Clipboard
altcopyname=  | Copy File Name to Clipboard
altevfile=  | Search this Doc in Everything
altevexp=  | Explore This Folder in Everything
alttxtopenfolderalt2=  | Open Folder
closemenu=  | Close This Menu

;; labels that do not have menu items attracted to them...
pasteclipboardinquotes= ^+' | Paste Clipboard in "Quotes"
OpenQuickNotesDir=  | Open ECLM Quick Docs Folder
switchCASE= +Capslock | Switch > UPPER && lower Case
addsnip= | Copy Selection to New Snippet
opensnipfolder= | Open the Live Snippets Dir

)
, %inifile%
return






Aboutcapswindow() ;; function GUI
{
; guiname := "Extended Capslock Menu - About"
global CurrentTab, scriptname, scriptversion, inifile, iniload, inicontent, overview


overview := "
(

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
	
From the 'Open\Run\Explore\Files...     [ Files Menu ]' , you can ...
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
- open the Windows Context Menu
*+ open an alternative live folder to peek what else is there
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
*+ Double Right-Click to show the menu in any application
*+ Auto Copy & Live Preview Mode
	* See Known Issues warning below.
		
++++ ADDITONAL MENUS ++++

A custom built Open With\In Alternative Text Editor Menu that works in NP++ (on the active file viewing) and in Everything 1.5a (when a file is selected).
The Hotkey for this Menu is {F9}

There's a handful of light-weight text editors that I play with... This menu can be made to work in other applications... 
If you're an AHK enthusiast I recommend editing the script manually to add your own editors. 
 
... And more ...



)"
knownissues := " ;" more notes
(

***************************************************
****** KNOWN ISSUES & AUTO COPY MODE WARNING ******
***************************************************

++++++++++++++++++++++++++++++++++++++++++++++++++

Regarding the Double-Right Click Menu Setting. (Off by Defualt) This is another I always leave on all the time.

It's a global mouse-key that will show the Menu in ANY application! 

This one can be more buggy than the Replace NP++ option. sometime both right click menus end up show overtop of each.

Again this harmless but annoying that you have to hit Esc to cancel the right click menus. Occasionally one or the other menus, trying to override each other, get stuck, ignore the ESC key, then you have to click around to closes the menus and then try again.

++++++++++++++++++++++++++++++++++++++++++++++++++

Regarding 'Replace Notepad++ Context Menu' Option.
Its set to OFF by default.

Personally, I love this! I have it set ON, all the time for months with very few issues.

95`% of the time its fine, but, this feature can be a bit buggy.

Sometimes the standard context menu will still be triggered behind the Extended Capslock Menu which block it from receiving mouse click inputs.

Its harmless but annoying. Reloading seems to help. It also doesn't interact well with the Search Results Window.

You can still access NP++ own context menu with a 'Ctrl' + 'Right Click' or the 'AppsKey' on your keyboard.

++++++++++++++++++++++++++++++++++++++++++++++++++

Regarding the Live Preview & Auto Copy Menu Option

Its a fun feature though use it with caution, especially in file managers!


When enabled the Live Preview & Auto Copy will automatically send CTRL + C to COPY, to any program you are in, EVERY TIME you open the menu!!!
This Auto Copy Mode is meant to be run on [*SELECTED TEXT*]

This Auto Copy updates the Live Preview Menu Item. Otherwise it only send a Copy command after selecting a menu item that requires [*SELECTED TEXT*] to process, which is most of them.

It's turned OFF by default when you start this app. When toggled On from the settings menu it will stay on through a reload, until you turn it off again.

It has been modified to show when text is not selected, therefore, at times, it may not work as expected. E.G. if no text is selected, in a text editor, and you fire a menu item that want to modify text, it may copy and format an entire line and paste it back into the editor.

A.k.a., use with Caution!!! Especially when working in file manager!

If you use its copy and paste functions on files, or select a menu item with a file selected, it will copy files to your clipboard expecting text input to send to a search or modify before pasting.

It can be used on file names if you hit F2 (Rename) first to select text in the file name.
Though if window changes focus it will deselect the text causing the file itself to be copied. 

The Menu will open slightly faster when not waiting for the clipboard to update.

This menu options is mostly for fun, it's not really ment to be use regularly, thou, depending on the project auto copy is also helpful.

++++++++++++++++++++++++++++++++++++++++++++++++++
)" 

aboutsoftware := "
(
**************************************************
A note about the softwares used by Extended Caplock Menu...
&& Stored Prefs in the 'Edit -SETTINGS.ini File' +!+!+
**************************************************

There are a few pieces of software I use that built into this menu.`nAll free except one. Links are below.`nIf the link is ***marked with*** it means...`nThe menu interacts with this software for searchers or file operations.`nThe unmarked links are only quick launcher that open software, like the start menu.`n`nHeres a list of links to them if you want some awesome software.

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
	* dnGrep
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
	* VS Code or VS Codium
	* Scite 4 AHK
	* AHK Studio
	* MS Word
	* MS Excel
	* Markdown Monster - $hareware
These are just the ones I use, if you know how, the 'alttxt' menu could be edited to include other text editors From the '.ahk' script file.

**************************************************
+!+!+!+!++!+!+!+!++!+!+!+!+
(!IMPORTANT!)
 >>> ASSIGNING YOUR DEFAULT LOCATIONS FOR
 >>> THE OTHER SOFTWARE THIS MENU INTERACTS WITH.
 If you want to that is. The 3rd party software(s) are Optional, info on the settings tab.
+!+!+!+!++!+!+!+!++!+!+!+!+
**************************************************


)"

; aboutini := "
aboutini = 
(
★ ALWAYS Click the Save & Reload button when making any changes you want to save to the -settings.ini file. They will be lost if you just close this window. There's no nag check that will ask you if you want to save.

**************************************************
** ABOUT [Toggles] ************************
**************************************************
These items are toggled on Setting & About Menu.
These toggles are stored in the '.ini' file and will persist after reloading the menu.

	- Auto Copy & Live Preview (OFF by default),
	- Replace the NP++ Right Click Menu (OFF by Default)
	- Change Dark\Light Mode (Dark OFF by default),
	- Sound Beeps on Caplock Toggle (ON by default),
	- Show an Show_CAPS_OSD when Capslock is Toggled (ON by Default)
	- Caplocks for Number Row (OFF by default),


** There might a few extra toggles used in development which do not have menu items, I'll leave them here for those you whom want to edit and run the .ahk script

**************************************************
** ABOUT [PROGRAMS] ******************************
**************************************************

The list of software used in the menu are referenced as variables from the '-SETTINGS.ini' file. They have to be updated to suite your system MANUALLY with a simple copy and paste. You can make changes to in the box above or Use the 'Edit --Settings.ini File' from the settings sub-menu to edit the file in a text editor.

They will try to run from the default install locations, as set in the .ini, IF you have them installed in a different location you NEED update them there. Paste the true path to your .exe's, without quotes.

If not updated ornot installed the 3rd party software menu functions just won't do anything. So they are not required. Thou, don't delete or leave a reference empty as it could cause annoying popup messages box about variables not being assigned from AHK.


For example...
Ditto is a great a clipboard manager & tool.
as custom portable install should be changed to...

ditto `= X:\Portable Program Files\Ditto\ditto.exe
	rather than the default...
C:\Program Files\Ditto\ditto.exe

Now anywhere in the script you see Run, `%ditto`% - it will be run from the file path your have provided here.

You can also set your favorite Default Text Editor.

If not set text files will try to open with Notepad++.exe.
As I have preset it. If NP++ is not installed (at its default location),
then it will try windows own Notepad.exe.
Replace...
	Texteditor `= C:\Program Files\Notepad++\notepad++.exe
with...
	Texteditor `= X:\Your favorite\text\editor.exe





***************************************************
** ABOUT [GLOBAL_HOTKEYS] *************************
***************************************************

A handful global hotkeys are already set, you can change them here.

A few others are hard coded in the script which cannot or should not be set to avoid conflicts with system keys, you won't see those in this list.

Any hotkeys set inside of the  -SETTINGS.ini file will be GLOBAL, they will work in every application!

To make them Context Sensitive for Program Specific they should not be set here, but rather inside the .ahk file within #IfWinActive directives ¢ 

**************************************************

Each " Menu Item Name " is listed below in the follwing layout...

Labelname= (hotkey in AHK Syntax) | Disription of Menu Action or Menu Item Name Itself

to set your own hotkey for the menu items you use most of enter the hotkey between the "=" and "|" . Examples below...

¢ DO NOT change the " Labelname= " this will cause the hotkey to break!
You can the description after the "|" if you want, which is what displays on the Live Hotkeys Menu.

There are a lot of menu items labels and toggles here (around 200). You can change them on the fly in this tab, save & Reload. The Menus and Items are organized\grouped, some what, together by the menu they appear on, nearly in order here.

Thou it might be easier to open the -SETTINGS.ini file in a text editor so you can search key words from the menu items you want to change. There's a button above that will give you options to which editor to open the .ini.

-------------------------

Examples ... 
for... " Google This " on the Find Menu
googlethis=#+o | Search Selection on Google
the hotkey would be... Win + Shift + O

for... " Open Folder " on the Files Menu
OpenDIRselection = !#o | Open Directory from Selection
the hotkey would be... Alt + Win + O

for... " 1 `/`* Block Comment `*`/ " on the Code Formatting Menu
commentblock= ^NumpadDiv | AHK Block Comment
the hotkey would be... Ctrl + / -- on the NumberPad --

for... + Copy [Add to Clipboard] on the Text Tools Menu
appendclip = ^!C | Copy, Append to Clipboard
the hotkey would be Ctrl + Shift + C

;-------------------------

AutoHotkey's Modifier Symbols are...

Ctrl = ^
Shift = +
Win = #
Alt = !
;-------------------------

¢ For a full list of {Special_KeyNames} such as ESC, Home, Mouse Buttons, Space etc... and their uses 
visit the Docs page for reference.

You can use the menu to get you there. Select this web address and choose " Visit Website [If a URL is Selected] " from the Find Menu -OR- use the hotkey " Alt + Win + U "

 https://www.autohotkey.com/docs/v1/KeyList.htm 

;-------------------------


)



/*
;***************************************************************************
;************************* HOTKEYS *****************************************
;***************************************************************************
; this section is not for editing, it only reference for the message box popup
; changing the keys here won't change them inside the script.
*/
global hotkeys
hotkeys =
(

** This hotkey list is a bit out of date! After changing that hotkeys are stored in a .ini file you can now change them to your liking. Working on having user set hotkeys appear on all the menu items. Will leave this here for the moment as an old reference. 

** This tab will be changing soon....


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
  Ctrl + Alt + Esc -- Quit \ Exit Script
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
	Ctrl + `" -- Put Quotes Around [`"Selected Text"]
Win + H -- Add Auto Correct Hot Strings ...
		 ...(if include Auto Correct script is running)
--------------------------------------------------

==+++ SPECIAL IF Notepad++ ACTIVE HOTKEYS +++==
Right Click -- Can replace NP++ menu with this one. (optional)
Ctrl + Space -- Open Live Folder Menu...
	if a [* C:\Filepath.txt *] is selected it show's that files folder
	if nothing is selected it will show the folder of the Active file
	+ this can also work in Everything 1.5a on a selected file, it will show that files folder
	- this menu hotkey is turn off else where
Ctrl + Alt + N or F9 -- Open Active File in Alternative Text Editor Menu
**************************************************
)
; "


;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;; start about gui
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
Gui, capsa: New
Gui, capsa: Margin, 5, 5
gui, capsa: color, 171717, 090909
gui, capsa: font, cffb900, Consolas
; gui, capsa: color, 171717,
gui, capsa: font, , Consolas
; Create Tabs
; gui, capsa: add, Tab2, xm w550 h630 vSelectedTab gTabChange, Overview|More Notes|ChangeLog|Software Links|Hotkeys && Settings ; vSelectedTab gTabChange ;; the V & G labels hre are casing warnings from gpt so
; gui, capsa: add, Tab2, buttons xm w550 h630 -Theme , Overview|More Notes|ChangeLog|Software Links|Hotkeys && Settings

gui, capsa: add, Tab3,  xm w550 h650 -Theme , Overview|INI Settings|Hotkeys|ChangeLog|Software Info|Known Issues ;|Tab 6


gui, capsa: Tab, 1
  ; ; Overview Tab

gui, capsa: font, cffb900, Consolas
gui, capsa: font, s11
; gui, capsa: add, text, center  w520, %scriptname%
gui, capsa: add, text,  center w520, Version // Last Update: %scriptversion%

gui, capsa: add, Text, w520, This Extended Capslock Menu is a expanded context menu, written with AutoHotkey. Its made codeing\working\playing with text.`n`nWith this menu, after *[SELECTING SOME TEXT]* and then picking a menu item, the text will be copied to your clipboard (with your previous clipboard item preserved) so you can...`n
gui, capsa: font, s10
gui, capsa: add, edit, w520 r15, %overview%
gui, capsa: font, s09
gui, capsa: Add, text, center w520, ** This Overview Text is Live. You can use the menu here to test && play with the menu. It will reset when you reload this window.
gui, capsa: Add, text, center w520, --------------------------------------------------
gui, capsa: font, s10
gui, capsa: Add, Link, center w520, <a href="https://github.com/indigofairyx/Extended_Capslock_Context_Menu">Extended Capslock Menu Github Page</a>

GUI, CAPSA: add, picture, border hwndhOSD gToggleCapsLock, %A_ScriptDir%\Screenshots\OSD overlay_362x79.png
tip=
	(ltrim
	This On Screen Display appears over the Task Try whey CAPSlock is ON.`nThe Icons update depending on which optional Toggle Settings you have Enabled.`nThis Overlay can also be Toggle OFF if you don't want to see it.`nClick here to Toggle your Capslock to view the dispay
	)
addtooltip(hOSD,tip)


;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
gui, capsa: Tab, 2
;;  ini settings tab
gui, capsa: font, s09, Consolas

gui, capsa: add, text, section, Edit the settings in the .ini file here and\or Settings Menus Options ↓ ★ 

gui, capsa: add, picture, section w28 h28 hwndhshowsettingstip gshowsettingsmenu, %A_ScriptDir%\Icons\setting edit FLUENT_colored_082_64x64.ico
AddTooltip(hshowsettingstip,"Quick Settings Menu")
gui, capsa: add, picture, ys W28 h28 hwndhcodespark gpreviewalttxtmenu, %A_ScriptDir%\Icons\code spark xfav function_256x256.ico
AddToolTip(hcodespark, "Edit .INI Options")
gui, capsa: add, picture, ys, w28 h28 hwndhaset gshowasetmenu, %A_ScriptDir%\Icons\settings panel JLicons_33_64x64.ico
addtooltip(haset, "Additional Settings Menu")

gui, capsa: font, cDCDCDC s10, Consolas
gui, capsa: add, text, hWndhedinginifile gdonothing ys, %A_space%%A_scriptname%-SETTINGS.ini%A_space%%A_space%
AddTooltip(hedinginifile,"This .ini file is loaded in the box below.`n★ Save & Reload to use changes.")

Gui, Add, Button, disabled vallowsave gsaveini h12 x+s, &Save .ini && Reload
GuiControlGet, hwndallowsave , Hwnd, allowsave
DllCall("uxtheme\SetWindowTheme", "ptr", hwndallowsave , "str", "DarkMode_Explorer", "ptr", 0)

; if (darkmode)
	; gui, add, picture, w28 h28 ys hwndhdarkmenu vmenumodeset gDMToggle, %menuLT%
; else
	; gui, add, picture, w28 h28 ys hwndhdarkmenu vmenumodeset gDMToggle, %menuDK%

gui, capsa: font, cDCDCDC s11, Consolas
global inicontent := ""
global iniedit 
global allowsave
FileRead, inicontent, %inifile%
GuiControl,, iniedit, %inicontent%
gui, capsa: add, edit, xs w520 r20 gonchange viniEdit, %inicontent% ; Edit box for INI content


gui, capsa: font, cffb900 s09, Consolas
gui, capsa: add, text, , AHK Modifier Key Symbols .. Ctrl = ^ `, Alt = ! `, Shift = + `, Windows Key = #
; gui, capsa: Add, Link, , <a href="https://www.autohotkey.com/docs/v1/KeyList.htm">Click here to view the Full KeyList page on AutoHotkey.com</a>

gui, capsa: add, text, , Read Me - About Changing Stored Settings...
gui, capsa: font, cFFE9AC s10, Consolas
gui, capsa: add, edit, w520 r9, %aboutini%



;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
gui, capsa: Tab, 3
gui, capsa: add, picture,w24 h24 section, %A_ScriptDir%\Icons\preferences-desktop hotkeys-keyboard-shortcuts_48x48.ico
gui, capsa: add, text, x+10+s , Hotkeys - Tab 3 - Coming soon...
; gui, capsa: add, text,,

gui, capsa: add, edit,w520 r27 xs,%hotkeys%

;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
gui, capsa: Tab, 4
 ; Changelog Tab
; gui, capsa: font, s11,  Consolas
; gui, capsa: font, cffb900
gui, capsa: add, text,center w520, *************************************************************`n************************* CHANGELOG *************************`n*************************************************************
; gui, capsa: add, edit,  w520 r27, %changelog%

; clogfile = %A_ScriptDir%\ChangeLog.txt
global logtext := ""
fileread, logtext, %clogfile% ; %a_scriptdir%\xlib\changelog.txt
; global logtext
global logedit
global sclog
; msgbox %log%

guicontrol,, logedit, %logtext%
if (A_Username != "CLOUDEN")
	gui, capsa: add, edit, vlogedit w520 r27 +ReadOnly, %logtext% ; %changelog%
Else
	gui, capsa: add, edit, gonlogchange vlogedit w520 r27 +wanttab, %logtext% ; %changelog%
	

;gui, capsa: add, text, cyellow, Legend: (+) NEW|ADDED, (*) CHANGED, (!) FIXED, (-) REMOVED, (#) TODO
gui, capsa: add, text, cyellow section, + NEW|ADDED, - REMOVED, ! FIXED,`n* CHANGED, # TODO, $ ISSUE|BROKEN

if (A_Username = "CLOUDEN")
	{
	Gui, capsa: Add, Button,  x+15s+y  h20 disabled vsclog gsavelog , &Save ChangeLog
	GuiControlGet, hwndsclog , Hwnd, sclog
	DllCall("uxtheme\SetWindowTheme", "ptr", hwndsclog , "str", "DarkMode_Explorer", "ptr", 0)

	Gui, capsa: Add, Button, X+s10 h20 veclnp geditchangeloginnpp , Edit in &NP++
	global eclnp
	GuiControlGet, hwndeclnp , Hwnd, eclnp
	DllCall("uxtheme\SetWindowTheme", "ptr", hwndeclnp , "str", "DarkMode_Explorer", "ptr", 0)
	}


;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
gui, capsa: Tab, 5
;; software & links
gui, capsa: font, cFFE9AC s9, Consolas
; gui, capsa: font, cffb900, Consolas
gui, capsa: add, edit, x+m cA0BADE w520 r13 +readonly, %aboutsoftware% 
gui, capsa: font, s9,  Consolas

gui, capsa: Add, Link, section , <a href="https://github.com/notepad-plus-plus/notepad-plus-plus">***Notepad++*** - The Best all-purpose, lite-weight replacement for`n Windows Notepad.</a> <a href="https://www.binaryfortress.com/NotepadReplacer/">Install with Notepad Replacer.</a> 

; gui, capsa: Add, Link, xs, <a href="https://www.binaryfortress.com/NotepadReplacer/">Notepad Replacer - Install with this.</a> 

gui, capsa: Add, Link, , <a href="https://www.voidtools.com/forum2/viewtopic.php?t=9787">***Everything v1.5a*** - Powerful local search tool</a>

gui, capsa: add, link, , <a href="https://dngrep.github.io">***dnGrep*** - A top of the line tool for searching text inside files.</a>

gui, capsa: add, link, , <a href="https://astrogrep.sourceforge.net/features/">***AstroGrep*** - A good tool for searching text inside files.</a>

gui, capsa: Add, Link,hwndhdopelink , <a href="https://www.gpsoft.com.au">***Directory Opus*** - The best and most over powered File Manager.`n A Replacement, Alternative for Windows File Explorer.</a>
AddToolTip(hdopelink, "Dirctory Opus is the only Paid $oftware on this menu I wrote into this menu. Its well Worth IT!`nTheres a free trail to try. If you like it you can get `%15 off your purchase with this code...`nCW4D0S289B4K" )

gui, capsa: Add, Link, , <a href="https://github.com/sabrogden/Ditto">Ditto - Clipboard Manager</a>

gui, capsa: Add, Link, , <a href="https://clipboard.quickaccesspopup.com">Quick Clipboard Editor - A Clipborad editor with advanced`n text & code formatting options built.</a>

gui, capsa: Add, Link, , <a href="https://ramensoftware.com/textify">Textify - Lets you copy text out of message boxes and guis</a>

gui, capsa: Add, Link, , <a href="https://github.com/TheJoeFin/Text-Grab/">Text Grab - An Amazing OCR tool</a>

gui, capsa: Add, Link, , <a href="https://github.com/BashTux1/AutoCorrect-AHK-2.0">An AHK Global Auto Correct Script - This is already included here.</a>

gui, capsa: Add, Link, hwndhahkcom , <a href="https://autohotkey.com">AutoHotkey.com</a>
AddToolTip(hahkcom, "The coding language this menu was written with.")
; gui, capsa: Add,Link,hWndhLink,This is a <a href="https://autohotkey.com">example tooltip hover link</a>.
; Tip=
   ; (ltrim
    ; Tooltip for the Link control.  Click on me to go to AutoHotkey.com.
   ; )
; AddToolTip(hLink,Tip)


;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
gui, capsa: tab, 6
; known issues Tab
gui, capsa: font, cffb900
gui, capsa: font, s09,  Consolas
gui, capsa: add, edit, w520 r15 +readonly, %knownissues%

gui, capsa: font, cFFE9AC s10,  Consolas
gui, capsa: add, text, w520, `nAll in all I'm a N00B at code\programming [just a computer geek really], this AutoHotkey Menu project has been an exercise of learning and fun mostly. I love this menu and have been using it daily on my machine for months. Overall what's happening in the background of the menu is pretty simple and I've tried to break most menu items, looking for bugs, before I've shared it here. It's fairly stable. That being said if you discover any issues or know how to code with AHK, and have recommendations, please report an issue on the github page.
gui, capsa: add, link,,<a href="https://github.com/indigofairyx/Extended_Capslock_Context_Menu/issues">%scriptname% Issues Page</a>

; gui, capsa: font, cFFE9AC s10, Consolas
gui, capsa: font, cffb900
gui, capsa: add, text, gdonothing, For reference, This AHK Menu was Written && Tested on
gui, capsa: add, text,  hwndhwin7 gdonothing, Windows 10
addtooltip(hwin7, "It should also run on Win7 for you die hards,`nthou few menu items might now work.`nand... uhhh Never11")
gui, capsa: add, text, x+10, using
gui, capsa: add, text, x+10 gdonothing hwndhahkv2, AutoHotkey v1.1.37.02
addtooltip(hahkv2, "`And no, I won't updating\converting this AHK v2.`nIt only copies and searches\runs text.`nThere's no need fix what isn't broken.")
gui, capsa: add, text, w520,

;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
; gui, capsa: tab, 7
; gui, capsa: add, text, , Tab 7 - Coming soon...

;---------------------------------------------------------------------------


; Return to the main layout
gui, capsa: Tab 


gui, capsa: font, cA0BADE, Consolas
; gui, capsa: add, text, xm , (Press Space to Close)
gui, capsa: add, picture, xm w36 h36, %A_ScriptDir%\icons\extended capslock menu icon 256x256.ico
gui, capsa: add, picture, x+m w36 h36 hwndhvisitgit gVisitgithub, %A_ScriptDir%\Icons\github icon 256x256.ico
AddToolTip(hvisitgit, "Visit ECLM Repo on Github")


gui, capsa: add, picture, x+m w36 h36 hwndhcheckupdate gCheckUpdatesmanual, %A_ScriptDir%\Icons\globe web internet updater arrow xfav 256x256.ico
AddToolTip(hcheckupdate, "Check for Updates")
gui, capsa: add, picture, x+m w36 h36 hwndhreload greload, %A_ScriptDir%\Icons\Refresh reload xfave_128x128.ico
AddToolTip(hreload,"Reload")

; gui, capsa: add, picture, x+m W36 h36 hwndhcodespark gpreviewalttxtmenu, %A_ScriptDir%\Icons\code spark xfav function_256x256.ico
; AddToolTip(hcodespark, "Just here for fun flair.")


; gui, capsa: add, button, x+m gCheckUpdatesmanual, Check for &Updates
; gui, capsa: add, button, x+m gcapsclose, &Close
static closebut
Gui, Add, Button, X+M vclosebut gcapsclose , &Close
GuiControlGet, hwndclosebut , Hwnd, closebut
DllCall("uxtheme\SetWindowTheme", "ptr", hwndclosebut , "str", "DarkMode_Explorer", "ptr", 0)
;---------------------------------------------------------------------------

; gui, capsa: show,, Extended CAPS Menu - About
gui, capsa: +Border +Resize -MaximizeBox ; +Dpiscale ; +hwndidDisplayWin
gui, capsa: show,, Extended Capslock Menu - About 
winwaitactive Extended Capslock Menu - About 
; sleep 300
; sendinput ^{Home}

; return
;; end about caps gui
; sleep 300
guicontrol, focus, closebut ; darkbutton1 ; Close ;; this needs to be the controls Var, not logical name
} 

showasetmenu:
menu, as, show
return

previewalttxtmenu:
activefile = %inifile%
gosub alttxtuseclip
menu, alttxt, show
return
capsclose:
gui capsa: Destroy
return
close:
gui capsa: Destroy
return
OnChange: ; Triggered when the content of the edit box changes
Gui, capsa: Submit, NoHide
If (iniEdit != iniContent)
    GuiControl, capsa: Enable, allowsave
Else ; Disable the button if the edit box is not changed
    GuiControl, capsa: Disable, allowsave
Return

saveini:
; MsgBox, 4132, , This will save the edits you made in this window to the .ini file and reload the menu. `n`n Continue?`n`n
; IfMsgBox no
	; return
tooltip Saving %A_scriptname%-SETTINGS.ini ...

filecopy, %inifile%, %inifile%.BAK	; make a backup of current .ini
FileSetAttrib, +H, %inifile%.BAK  	;  and hide it.
GuiControlGet, inicontent, , iniEdit ; Get the text from the edit box
FileDelete, %inifile%                ; Delete the existing file to avoid appending
FileAppend, %inicontent%, %inifile%  ; Write the new content to the INI file
sleep 1500 ; give time for file to be written
gosub reload	; reload the script to apply changes
return

inibox:
msgbox %inicontent%
return
/*
TabChange:
; This label will trigger when a user switches tabs.
gui, capsa: submit, nohide
if (SelectedTab = "1") {
    ; Code for the Overview Tab (if needed)
} else if (SelectedTab = "2") {
    ; Code for the Hotkeys Tab (if needed)
} else if (SelectedTab = "3") {
    ; Code for the Changelog Tab (if needed)
} else if (SelectedTab = "4") {
    ; Code for the Links Tab (if needed)
}
else if (SelectedTab = "5")
 {
    ; Code for the Links Tab (if needed)
fileread, inicontent, %inifile%
guicontrol,,iniload, %inicontent%
}
return 

*/

OnlogChange: ; Triggered when the content of the edit box changes
Gui, capsa: Submit, NoHide
If (logEdit != logtext)
    GuiControl, capsa: Enable, sclog
Else ; Disable the button if the edit box is not changed
    GuiControl, capsa: Disable, sclog
Return

savelog:
GuiControl, capsa: Disable, sclog
filecopy, %clogfile%, %a_scriptdir%\myHistory\changelogECLMBU.BAK, 1
sleep 400
GuiControlGet, logtext, , logedit ; Get the text from the edit box
FileDelete, %clogfile%                ; Delete the existing file to avoid appending
FileAppend, %logedit%, %clogfile%  ; Write the new content 
sleep 800
return
editchangeloginnpp:
run notepad++.exe "%clogfile%"
return



#IfWinActive Extended Capslock Menu - About
~rbutton::
; menucaseshow()
gosub cmenu
menu, case, show
return
#ifwinactive

;---------------------------------------------------------------------------
viewhotkeys:
MsgBox, 262208, Extended Capslock Menus Hotkeys, %hotkeys%
return

; admintog := 0

; Hotkey, %Alt_Hotkey%, menucaseshow
; todo

;;;;;;;;;;;;;;;;;;;; Dark Mode Activated GUI Script ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; from Ctrl CapsLock Menu (new, ctrl capslock capslock now - removed ctrl shift capslock).ahk
;;;;;;;;;; dark mode toggle, menu, s,
; Case "Dark Mode | Light Mode":
DMToggle:
    If (DarkMode)
    {
        DarkMode := false
        MenuDark(3) ; Set to ForceLight
		iniwrite, 0, %inifile%, Toggles, DarkMode
		tooltip Dark Mode OFF!
    }
    else
    {
        DarkMode := true
        MenuDark(2) ; Set to ForceDark
		iniwrite, 1, %inifile%, Toggles, DarkMode
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
		menu, as, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\eyes_emoji_64x64.ico
        Tooltip, Auto Copy when you open`nthe menu is now Turn ON!
		sleep 2000
		tooltip
		iniwrite, 1, %inifile%, Toggles, LiveMenuEnabled
		return

    }
	else
	{
		menu, as, icon, Toggle Live Preview && Auto Copy, %A_ScriptDir%\Icons\eye_half__32x32.ico
		tooltip, Live Preview && Auto Copy is Turned OFF!
		sleep 2000
		tooltip
		iniwrite, 0, %inifile%, Toggles, LiveMenuEnabled
		return

	}
sleep 400
}

firstrunwelcome:
IniWrite, 0,  %inifile%, Toggles, isfirstrun
Aboutcapswindow()
MsgBox, 4160, %scriptname%, Thank for checking out Extended Capslock Menu!`n`nIt looks like this is your first time running it.`n`nGive the about window a quick glance.`n`nFrom here you can read the Overview, Edit your INI settings, Find links to free softwares that this menu utilizes, scan the Changelog and Known Issues, Check for Updates, etc...`n`nTo see this about window again you can get to it from the Settings & About Menu.
return

;***************************************************************************
;********* END *************menu, s, FUNCTION ************ END **********
;***************************************************************************

;///////////////////////////////////////////////////////////////////////////
; #if hotkeys ififif

; #IfWinActive ahk_exe Notepad4.exe
; ^space::
; gosub expmenu
; return

; f9::
; ^!n:: ;; np++, open active file in alt editor
; gosub alttxtnppmenu
; return

; rbutton::
; if (ReplaceNPPRightClick)
    ; {
	; KeyWait, RButton, T0.5  ; Wait for the button to be released, with a 500ms delay
	; menucaseshow() ; Show custom menu
	; }
; else
    ; sendinput, {rbutton}
; return

; ^rbutton::
; sendinput, {appskey}
; return
; #ifwinactive ;; END notepad4


#IfWinActive ahk_exe Everything64.exe
/*
; the old quick & easy way to feed the exp menu, this medotd was broken by an update from EV when they started using this hot for as a default action in the edit1 box, which is great addition to EV. created a new work around below...
; ^Space::
; if (LiveMenuEnabled)
	; CopyClipboardCLM()
	
; CopyClipboardCLM()
; gosub expmenu
; return
;; so this has been driving me crazy and I figured out that when in thumbnails view with tooltip in list view they always show and when a tooltip is visible it breaks getting the hidden text from the selected\highlighted item. when I mouse away, so the tooltip is gone ad hit the hotkey again it will see the hidden text and capture the path.  12-19-2024 update: I went to post about this issue on EVs forum... And now this issue seems to be fixed. For now.
*/

^Space::
Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved, texteditor, activefile

ControlGetFocus, ActiveControl, ahk_exe Everything64.exe

; WinGet, activecontrol, ControlList , ahk_exe Everything64.exe
; msgbox, %activecontrol%
; if (Activecontrol = "SysListView321") ;; was using this before, and it works unless there's a tooltip showing, KEEP this, can hopefully use it again

if (ActiveControl = "Edit1")
	{
		send, ^{space}
	; msgbox, u in sub1
		return
	}
else if (Activecontrol = "SysListView321")
	{
	/*
		CopyClipboardCLM()
		highlighted := Clipboard
		sleep 20
		restoreclipboard()
		msgbox, u in sub2`n hl: %highlighted% `n`n // the clipboard was used here.
		goto expmenuuseclip
		*/

; evgetselected:
DetectHiddenText, on 
WinGetText, highlighted, ahk_exe everything64.exe
RegExMatch(highlighted, "m)^(.*)$", highlighted) ;; match first line of captured string

sleep 200
if !RegExMatch(highlighted, ".*\\([^\\]+)\\?$", "$1") ; match a file path in captured hidden text, if no file is seen try coping the file to extract the path instead, this is a work around method for when EVs tooltip cause errors by obscuring the hidden text this menu id searching for.
	{
		; tooltip Everything is running thou nothing is highlighted.
		; sleep 1500
		; tooltip
		Global ClipSaved 
		CopyClipboardCLM()
		highlighted := Clipboard
		SplitPath, highlighted, , folder, , , 
		sleep 20
		restoreclipboard()
		sleep 555
		; msgbox, u in sub4 %highlighted% `n folder: %folder%`n`n// the clipboard was used here
		goto expmenuuseclip
	}
sleep 50
SplitPath, highlighted, , folder, , , 
		; msgbox, u in sub3 %highlighted% `n folder: %folder%`n`n//the clipboard is not being used here 
gosub expmenuuseclip
}
return

; F9:: ;;alt hotkey for open in alt editor npp menu & Everything1.5a
; copyclipboardCLM()
; Activefile := Clipboard
; restoreclipboard()
; gosub alttxtuseclip
; return
#IfWinActive ;; END everything
;///////////////////////////////////////////////////////////////////////////

;///////////////////////////////////////////////////////////////////////////
; if notepad
; #IfWinActive ahk_class Notepad++
#IfWinActive ahk_exe Notepad++.exe
^space::
if (LiveMenuEnabled)
	CopyClipboardCLM()
gosub expmenu
return

f9:: ;;alt hotkey for open in alt editor npp menu
^!n:: ;;np++, open active file in alt editor

; gosub alttxtnppmenu
gosub showalttxtnppmenu
return

rbutton:: ;; if NP++, replace context menu with ECLM
if ReplaceNPPRightClick && MouseIsOver("ahk_exe notepad++.exe") && (Control = "Scintilla1") || (Control = "Scintilla2") || (Control = "Scintilla3") || (Control = "Scintilla4")
    {
	KeyWait, RButton, T0.5  ; Wait for the button to be released, with a 500ms delay
	; menucaseshow() ; Show custom menu
	gosub cmenu
	menu, case, show
	}
else
    sendinput, {rbutton}
return 

; ^rbutton::
; sendinput, {appskey}
; return
#IfWinActive  ;; END NOTEPAD++ KEYS
;///////////////////////////////////////////////////////////////////////////


MouseIsOver(WinTitle) {  ;; Function
global
    MouseGetPos,,,Win,Control
    return WinExist(WinTitle . " ahk_id " . Win . Control)
}

;///////////////////////////////////////////////////////////////////////////

livefoldermenu:
iflive()
cleanupPATHstring()
if !fileexist(clipboard)
	{
	if !fileexist(dir) ; if file isn't found check if the dir exist
		{
			Tooltip, ERR! That Dirctory cannont be found.
			sleep 1500
			tooltip
			restoreclipboard()
			sleep 300
			return
		}
	}
if FileExist(clipboard)
	{
	FileGetAttrib, attributes, %clipboard%
		if (InStr(Attributes, "D"))  ; If it's a directory
			topmenu = %clipboard%
		else ; if it's a file
			topmenu = %dir%
	}
; msgbox, dir: %dir%`nlastfolder: %lastfolder%`nclip: %clipboard%`nfilename:  %filename%`n`n`ntopM: %topmenu%
restoreclipboard()
sleep 100
gosub livefolderpopup
; gosub topmenu
menu, %topmenu%, show
return
; %a_scriptdir%\icons
;; MENU, EXP, START
; expmenu: ;todo add context options via approach to label
; Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved
; if (A_ThisHotkey = "^space") ; double clause if (A_ThisHotkey = "^Space" && WinActive("ahk_class EVERYTHING"))
	; {
	 ; WinGetClass, class, A
		; tooltip you used Ctrl + space hotkey`n`nActive Window class =  %class%
		; sleep 1500
		; tooltip
	; }
; if (A_ThisMenuItem = "View Explore Folder Menu   **[Experimental]**")
	; {
		; tooltip you used the context menu to get here
		; sleep 900
		; tooltip
	; }
	
;---------------------------------------------------------------------------


expmenu:
Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved

WinGetTitle, filename, A ; Get current window title, extract doc name from it
filename := RegexReplace(filename, "^\*", "")
filename := RegexReplace(filename, " - Notepad\+\+( \[Administrator\])?$", "")
folder := RegexReplace(filename, "\\[^\\]*$", "")
; folder := RegExReplace(folder, "\\$") ; removed trailing " \ "
;; check if copied text contains a folder path.
iflive()
; CopyClipboardCLM()
sleep 10
cleanuppathstring()
highlighted := clipboard
sleep 100
RestoreClipboard() ; Store clipboard content and restore original clipboard immediately
sleep 555  ; Give time for clipboard to restore

expmenuuseclip:
; Process the highlighted path
if FileExist(highlighted) {
    if InStr(FileExist(highlighted), "D") { ; It's a directory
        folder := highlighted
    } else { ; It's a file
        SplitPath, highlighted, filestem, folder, ext, drive
    }
folder := RegExReplace(folder, "\\$") ; Remove trailing backslash to prevent menu errors
} else {
    folder := folder ? folder : "" ; If highlighted content is not valid, use window title path
    folder := RegExReplace(folder, "\\$")
}
if !FileExist(folder)
	{
	tooltip Directory Not Found!`n%folder%`n`nExplore Popup Menu Canceled`nERR! Line#  %A_LineNumber%`n`n
	sleep 2500
	tooltip
	return
	}
sleep 50
Gosub, ShowFolder ; Show the folder menu
Return

ShowFolder:

	; if InStr(folder, "&") ; todo...
			; folder := RegExReplace(folder, "&", "&&")

Menu, Folders, Add, ; start building menu.
Menu, Folders, Deleteall
itemCount := 0

Menu, Folders, Add, Open this Folder, openfolder
if FileExist(dopus)
	Menu, Folders, Icon, Open this Folder, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,24
else
	Menu, Folders, Icon, Open this Folder, explorer.exe,,24
Menu, Folders, Default, Open this Folder
menu, folders, add, Copy Path:  %folder%, copyfolderspath
menu, folders, icon, Copy Path:  %folder%, %A_ScriptDir%\Icons\Clipboard_64x64.ico
menu, folders, add, ; line ------------------------- 
Menu, Folders, Add, .. Go Up .., FolderClicked
Menu, Folders, Icon, .. Go Up .., %A_ScriptDir%\Icons\arrow go-up_32x32.ico
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
	
menu, folders, add, ; line ;------------------------- 

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


/*
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
*/
GetFileIcon(File) {
    global iconerror
    VarSetCapacity(FileInfo, A_PtrSize + 688, 0)
    Flags := 0x101  ; SHGFI_ICON and SHGFI_SMALLICON
    if DllCall("shell32\SHGetFileInfoW", "WStr", File, "UInt", 0, "Ptr", &FileInfo, "UInt", A_PtrSize + 688, "UInt", Flags) {
        hIcon := NumGet(FileInfo, 0, "UPtr")
        if hIcon != 0
            return "HICON:" hIcon
    }
    ; Fallback if icon retrieval fails
    return iconerror ? iconerror : A_AhkPath
} 

DoNothing:
Return

FolderClicked:
    if (A_ThisMenuItem = ".. Go Up ..") {  ; Check if ".." was clicked to go up one level
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
    Tooltip, ERR! @ Line# %A_LineNumber%`nFolder not found.
    Sleep 2000
    Tooltip
}
return

copyfolderspath:
clipboard := ""
sleep 40
clipboard := folder
clipwait,0.5
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
;; MENU, EXP, END
;--------------------------------------------------------------------------- 
;***************************************************************************
;---------------------------------------------------------------------------

;--------------------------------------------------------------------------- 
; MENU, ALTTXT, START
alttxtnppmenu:
menu, alttxt, add
menu, alttxt, deleteall
Global ClipSaved,ActiveFile,filename,dir,ext,filestem,texteditor,highlighted, quicknotesdir,topmenu, aapp, unsaved
winget, aapp, ProcessName, A
WinGetTitle ActiveFile, A
	if RegExMatch(ActiveFile, "^\*new ")
		{
			; MsgBox, 4112, New File Error, You cannot open an unsaved file in another editor.`n`nSave it first then try again., 3 
			; return ;;; ##todo!! fix this on share, i d on myine it was confusing
			unsaved := 1
			notatruefile := 1
		}
	if RegExMatch(ActiveFile, "^\*")
		{
			; MsgBox, 35, Open in Alt Editor, Your document has unsaved changes.`n`nDo you want to save it before opening it in an Alt Editor?`n`nYes`, Save and Continue`nNo`, Continue without saving`nCancel`, Stop, 5
			; IfMsgBox Cancel
				; return
			; IfMsgBox Yes
				; {
				; sleep 250
				; send, ^s
				; }
			unsaved := 1
			if (winactive("ahk_exe VSCodium.exe"))
				unSaved := 0
			if (winactive("ahk_exe code.exe"))
				unSaved := 0
		}
ActiveFile := RegexReplace(ActiveFile, "^\*", "")
	if (instr(ActiveFile, "[Administrator]"))
		{
		ActiveFile := RegexReplace(ActiveFile, " - Notepad\+\+ \[Administrator\]", "")
		sleep 20
		}
	else 
		{
		ActiveFile := RegexReplace(ActiveFile, " - Notepad\+\+", "")
		}

; folder := RegexReplace(ActiveFile, "\\[^\\]*$", "")
alttxtuseclip:
winget, aapp, ProcessName, A

dir := RegexReplace(ActiveFile, "\\[^\\]*$", "")

splitpath, ActiveFile, filename,dir,ext,filestem,drive
splitpath, texteditor, texteditfilename

FileGetAttrib, Attributes, %Activefile%
if (InStr(Attributes, "D"))  ; If it's a directory, show a the folder menu layout
{
	menu, alttxt, add
	menu, alttxt, deleteall

	menu, alttxt, add, -Open... " %filename% "  ...With?, altmenualttxtshow
	menu, alttxt, icon, -Open... " %filename% "  ...With?, %A_ScriptDir%\Icons\document text edit rename FLUENT_colored_453_64x64.ico,,28

	menu, alttxt, default, -Open... " %filename% "  ...With?
	menu, alttxt, add, ; line ;-------------------------
	menu, alttxt, add, This menu cannot open a folder in a text editor, altmenualttxtshow
	menu, alttxt, icon ,  This menu cannot open a folder in a text editor, %A_ScriptDir%\Icons\attention_warning_60x60.ico,,28
	menu, alttxt, add, ; line -------------------------
	if fileexist(vscode)
		{
			menu, alttxt, add, Open Folder in VS Code, sendfoldertocode
			menu, alttxt, icon, Open Folder in VS Code, %vscode%
		}

	
	menu, alttxt, add, ; line -------------------------
	menu, alttxt, add, Copy Folder Path to Clipboard, altcopypath
	menu, alttxt, icon, Copy Folder Path to Clipboard, %A_ScriptDir%\Icons\document copy f filename FLUENT_colored_387_64x64.ico

	menu, alttxt, add, Copy Folder Name to Clipboard, altcopyname
	menu, alttxt, icon, Copy Folder Name to Clipboard, %A_ScriptDir%\Icons\document copy n FLUENT_colored_385_64x64.ico
	menu, alttxt, add, ; line ------------------------- 
	Menu, alttxt, add, Search this Name in Everything, altevfile
	Menu, alttxt, icon, Search this Name in Everything, %A_ScriptDir%\Icons\voidtools-04-Everything-Green.ico
	menu, alttxt, add, Explore This Folder in Everything, altevexp
	menu, alttxt, icon, Explore This Folder in Everything, %A_ScriptDir%\Icons\voidtools-15-Everything-1.5.ico
	menu, alttxt, add, ; line -------------------------

	if FileExist(dopus)
		{
		menu, alttxt, add, Open Folder in Dopus, alttxtopenfolderalt2
		menu, alttxt, icon, Open Folder in Dopus, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,28
		}
	else
		{
		menu, alttxt, Add, Open Folder in Explorer, explorer.exe,,28
		menu, alttxt, icon, Open Folder in Explorer, explorer.exe,,28
		}
		
	menu, alttxt, show
return
}
;---------------------------------------------------------------------------
; END ALTTXT FOLDER MENU
;---------------------------------------------------------------------------

FileGetSize, FS, %ActiveFile%, M

; menu, alttxt, add
; menu, alttxt, deleteall

menu, alttxt, add, -Open... " %filename% "  ...With?, altmenualttxtshow
menu, alttxt, icon, -Open... " %filename% "  ...With?, %A_ScriptDir%\Icons\document text edit rename FLUENT_colored_453_64x64.ico,,28
menu, alttxt, default, -Open... " %filename% "  ...With?
menu, alttxt, add, ; line -------------------------
if (unsaved = 1)
	{
		menu, alttxt, add, * This Doc has Unsaved Changes! ~Click to Save~, savefilereopenmenu
		menu, alttxt, icon, * This Doc has Unsaved Changes! ~Click to Save~,  %A_ScriptDir%\Icons\attention_warning_60x60.ico,,28
		menu, alttxt, add, ; line -------------------------
	}
if (FS > 50)
	{
		menu, alttxt, add, ATTENTION!!!  --  This file is large! > %fs% MB., altmenualttxtshow
		menu, alttxt, icon ,  ATTENTION!!!  --  This file is large! > %fs% MB., %A_ScriptDir%\Icons\attention_warning_60x60.ico,,32
		menu, alttxt, add, ; line -------------------------
	}
;---------------------------------------------------------------------------
if (texteditfilename != aapp)
	{
		; menu, alttxt, add, ; line ;-------------------------
		menu, alttxt, add, Default Text Editor ( %texteditfilename% ), ALTOIdefaulttexteditor
		if FileExist(texteditor)
			menu, alttxt, icon, Default Text Editor ( %texteditfilename% ), %texteditor%
		else
			menu, alttxt, icon, Default Text Editor ( %texteditfilename% ), notepad.exe
	}

if (ext = "ahk")
	{
	menu, alttxt, add, Run...  " %filename% ", runahkfile
	if fileExist("C:\Program Files\AutoHotkey\AutoHotkey.exe")
		menu, alttxt, icon, Run...  " %filename% ", C:\Program Files\AutoHotkey\AutoHotkey.exe   ;%A_ahkpath%	
	menu, alttxt, add, ; line -------------------------
	}
if (aapp != "notepad++.exe")
	{
	menu, alttxt, add, Notepad++, ALTOInpp
	if FileExist(notepadpp)
		menu, alttxt, icon, Notepad++ , %notepadpp%
	else
		menu, alttxt, icon, Notepad++, %A_ScriptDir%\Icons\notepad++_100.ico
	}
; if (aapp = "notepad++.exe")
	; {
	
	; }
; else
	; {
	
	
	; }

menu, alttxt, add, Notepad4, altoinotepad4
if FileExist(notepad4)
	menu, alttxt, icon, Notepad4, %notepad4%
else
	menu, alttxt, icon, Notepad4, %A_ScriptDir%\Icons\notepad4 256x256.ico

menu, alttxt, add, Scite 4 AHK, altoiscite
if fileexist(scite)
	menu, alttxt, icon, Scite 4 AHK, %scite%	
else
	menu, alttxt, icon, Scite 4 AHK, %A_ScriptDir%\Icons\SciTE_icon_256x256.png
	
if FileExist(ahkstudio)
	{
	menu, alttxt, add, AHK Studio, altoiahkstudio
	menu, alttxt, icon, AHK Studio, %A_ScriptDir%\Icons\AHKStudio.ico
	}
	
menu, alttxt, add, VS Code, altoivscode
if FileExist(vscode)
	menu, alttxt, icon, VS Code, %vscode%
else
	menu, alttxt, icon, VS Code, %A_ScriptDir%\Icons\vscode.ico
	
; menu, alttxt, icon, VS Code, %A_ScriptDir%\Icons\codium logo 256x256.ico ; alt icon
; menu, alttxt, icon, VS Code, %A_ScriptDir%\Icons\vscode.ico ; alt icon

if fileexist(sublimetext)
	{
	menu, alttxt, add, Sublime Text, ALTOIsublimetxt
	menu, alttxt, icon, Sublime Text, %sublimetext%
	}

menu, alttxt, add, Geany, altoigeany
if fileexist(geany)
	menu, alttxt, icon, Geany, %geany%
else
	menu, alttxt, icon, Geany, %A_ScriptDir%\Icons\geanytexteditor256x256.ico

; menu, alttxt, add, Notepad++, altoinpp
; menu, alttxt, icon, Notepad++, %A_ScriptDir%\Icons\notepad++_100.ico

menu, alttxt, add, ; line ;-------------------------

menu, alttxt, add, Word, altoiword
if FileExist(word)
	menu, alttxt, icon, Word, %word%
else
	menu, alttxt, icon, Word, %A_ScriptDir%\Icons\ms-word_64x64.ico

menu, alttxt, add, Excel, altoiexcel
if fileexist(excel)
	menu, alttxt, icon, Excel, %excel%
else
	menu, alttxt, icon, Excel, %A_ScriptDir%\Icons\ms-excel_64x64.ico
	
menu, alttxt, add, ; line ;-------------------------

; menu, alttxt, add, Obsidian, altoiobsidian ;;IGNORE 4 SHARE
; menu, alttxt, icon, Obsidian, %A_ScriptDir%\Icons\obsidian logo 256x256.ico ;;IGNORE 4 SHARE

menu, alttxt, add, Markdown Monster, altoimarkdownmonster
menu, alttxt, icon, Markdown Monster, %A_ScriptDir%\Icons\MarkdownMonster logo 256x256.ico

menu, alttxt, add, ; line ;-------------------------
menu, alttxt, add, -- Other Quick File Options -- (Also About), aboutalttxtmenu
menu, alttxt, icon, -- Other Quick File Options -- (Also About), %A_ScriptDir%\Icons\about.ico
menu, alttxt, add, ; line ;-------------------------
menu, alttxt, add, Duplicate File as... " %filestem% -CopyDup.%ext% ", altmakedup
menu, alttxt, icon, Duplicate File as... " %filestem% -CopyDup.%ext% ", %A_ScriptDir%\Icons\lc_duplicatepage_24x24.ico
menu, alttxt, add, Copy Full Path to Clipboard, altcopypath
menu, alttxt, icon, Copy Full Path to Clipboard, %A_ScriptDir%\Icons\document copy f filename FLUENT_colored_387_64x64.ico

menu, alttxt, add, Copy File Name to Clipboard, altcopyname
menu, alttxt, icon, Copy File Name to Clipboard, %A_ScriptDir%\Icons\document copy n FLUENT_colored_385_64x64.ico
menu, alttxt, add, ; line ------------------------- 
Menu, alttxt, add, Search this Doc in Everything, altevfile
Menu, alttxt, icon, Search this Doc in Everything, %A_ScriptDir%\Icons\voidtools-04-Everything-Green.ico
menu, alttxt, add, Explore This Folder in Everything, altevexp
menu, alttxt, icon, Explore This Folder in Everything, %A_ScriptDir%\Icons\voidtools-15-Everything-1.5.ico
menu, alttxt, add, ; line -------------------------

if FileExist(quicknotesdir)
	{
	topmenu = %quicknotesdir%
	; msgbox TM:%topmenu% `n QN: %quicknotesdir%
	gosub topmenu  ; build live menu item
	Menu, alttxt, add, Quick Notes Dir, :%topmenu%
	Menu, alttxt, icon, Quick Notes Dir, %A_ScriptDir%\Icons\folder_go__32x32.ico
	menu, alttxt, add, ; line ;-------------------------
	}


menu, alttxt, add, Open Folder, alttxtopenfolderalt2
if FileExist(dopus)
	menu, alttxt, icon, Open Folder, %A_ScriptDir%\Icons\DOpus_Spikes_256x256.ico,,28
else
	menu, alttxt, icon, Open Folder, explorer.exe,,28
sleep 30
menu, alttxt, add, ; line -------------------------
menu, alttxt, add, Close This Menu, closemenu
menu, alttxt, icon, Close This Menu, %A_ScriptDir%\Icons\aero Close_24x24-32b.ico
; menu, alttxt, show
return

showalttxtnppmenu:

gosub alttxtnppmenu
menu, alttxt, show
return
aboutalttxtmenu:
msgbox,262144,, This is a custom made open with menu.`nThese are a few of the Text Editors I like to play with.`nThere are many others!`n`nIf you're Familiar with AHK I recommend editing and running the '.ahk' to add you're own favorite editors here.
return



savefilereopenmenu:  
sleep 500
send, ^s
sleep 500
unsaved := 0
gosub alttxtnppmenu
return

altevexp:
if !FileExist(everything15a)
	goto evnotinstalled
try run %everything15a% -newtab -s """"%dir%""""
return

altEVfile:
if !FileExist(everything15a)
	goto evnotinstalled
try run %everything15a% -newtab -s "%filename%"
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

; oinpp:
; getfileinfo()
; sleep 90
; try run, %notepadpp% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoinpp:
try run, %notepadpp% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 500
return

; oinppnewwindow:
; getfileinfo()
; sleep 90
; try run, %notepadpp% -multiInst "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 1000 ; send key to close all tabs? Todo or can do
; restoreclipboard()
; return

altoinppp:
; try run, %notepadpp% -multiInst "%activefile%",, useerrorlevel
try run, %notepadpp% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 1000
; send key to close all tabs? Todo or can do
return

; oinotepad4:
; getfileinfo()
; sleep 90
; try run, "%notepad4%" "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoinotepad4:
try run, "%notepad4%" "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

; oiexcel:
; getfileinfo()
; sleep 90
; try run, %excel% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoiexcel:
try run, %excel% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

; oiword:
; getfileinfo()
; sleep 90
; try run, %word% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoiword:
try run, %word% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

; oimarkdownmonster:
; getfileinfo()
; try run, %MarkdownMonster% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoimarkdownmonster:
try run, %MarkdownMonster% "%filename%",, useerrorlevel
if errorlevel
	return
sleep 100
return

; oiobsidian:
; getfileinfo()
; sleep 90
; try run, %ObsidianShell% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoiobsidian:
try run, %ObsidianShell% "%filename%",, useerrorlevel
if errorlevel
	return
sleep 100
return

; oiahkstudio:
; getfileinfo()
; sleep 90
; try run, %ahkstudio% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoiahkstudio:
try run, %ahkstudio% "%activefile%",, useerrorlevel
	if errorlevel
	return
sleep 100
return

; oiscite:
; getfileinfo()
; sleep 90
; try Run, %scite% "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoiscite:
try Run, %scite% "%activefile%",, useerrorlevel
if errorlevel
	return
sleep 100
return

; oivscode:
; getfileinfo()
; sleep 90
; try run, "%VSCode%" "%clipboard%"
; catch
; try run, "%VSCodium%" "%clipboard%",, useerrorlevel
; if errorlevel
	; return
; sleep 500
; restoreclipboard()
; return

altoivscode:
try run, "%VSCode%" "%activefile%"
catch
try run, "%VSCodium%" "%activefile%"
sleep 100
return

oigeany:
getfileinfo()
sleep 90
try run, %geany% "%clipboard%",, useerrorlevel
if errorlevel
	return
sleep 500
restoreclipboard()
return

altoigeany:
try run, %geany% "%activefile%",, useerrorlevel
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

sendfoldertocode:
run, %vscode% "%activefile%"
; run, %notepadpp% "%activefile%" ;; so I can send a folder to notepad++, but it will open every file inside it.
return


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

runahkfile:
run, "%activefile%"
return

;///////////////////////////////////////////////////////////////////////////
;; START LIVE QUICK NOTES DIR SUBMENU
/*
topmenu:
; topmenu = %A_ScriptDir%\Extended Capslock Menu QUICK Notes
topmenu = %quicknotesdir%
if !FileExist(topmenu)
	return
; if !FileExist(topmenu)
	; {
		; tooltip ERR! This folder cannot be found.`n@ Line#:  %A_LineNumber%
		; sleep 2000
		; tooltip
		; return
	; }
Menu, %TopMenu%, Add
Menu, %TopMenu%, deleteall
Menu, %TopMenu%, Add, Open Quick Docs Folder, OpenQuickNotesDir
if FileExist(dopus)
	Menu, %TopMenu%, icon, Open Quick Docs Folder, %dopus%
else
	Menu, %TopMenu%, icon, Open Quick Docs Folder, explorer.exe

Menu, %TopMenu%, Add, ;line ;------------------------- 

LastMenu := TopMenu
Loop Files, %TopMenu%\*.*, DFR  ; Recurse into subfolders.
{
    If InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "S")
        Continue ; Skip any file that is H or S (System).

    Menu, %A_LoopFileDir%, Add, %A_LoopFileName% , quicksubAction
	
	IconPath := GetFileIcon(A_LoopFileFullPath)
	Menu, %A_LoopFileDir%, Icon, %A_LoopFileName%, %IconPath%
	
    If (A_LoopFileDir != LastMenu) and (LastMenu != TopMenu)
    {
	; MsgBox %TopMenu% %LastMenu% ; debug
        AddMenu(LastMenu)
    }
    ; Save menu name
    LastMenu := A_LoopFileDir
}

AddMenu(LastMenu)
; Menu, %TopMenu%, Show  ; Don't need to show the menu here as its being built as a submenu
Return
*/
; Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved

; topmenu = %quicknotesdir%

; if !FileExist(topmenu)
	; {
		; tooltip ERR! This folder cannot be found.`n@ Line#:  %A_LineNumber%
		; sleep 2000
		; tooltip TM: %topmenu%`n`nQND: %quicknotesdir%
		; sleep 3000
		; MsgBox TM: %topmenu%`n`nQND: %quicknotesdir%`n `n%ActiveFile%`n, `n%filename%`n,`n%dir%`n,`n%ext%`n,`n%filestem%`n,`n%drive%`n
		; tooltip
		; return
	; }
topmenu:
livefolderpopup:
Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved, quicknotesdir, topmenu
Menu, %topmenu%, Add,
Menu, %topmenu%, deleteall

; if (a_thislabel = "Livefolderpopup")
	; {
	; Menu, %Mylibmenu%, Add, Open - %Lastfolder% - Folder, openLIVE
	; if fileexist(dopus)
		; Menu, %Mylibmenu%, icon, Open - %lastfolder% - Folder, %dopus%
	; else
		; Menu, %Mylibmenu%, icon, Open - %lastfolder% - Folder, explorer.exe
	; }

; if (A_ThisMenuItem = "topmenu")
	; {
	menu, %topmenu%, add, Open Quick Notes Folder`t%OpenQuickNotesDir%, opentopmenu
	menu, %topmenu%, default, Open Quick Notes Folder`t%OpenQuickNotesDir%
	if FileExist(dopus)
		Menu, %topmenu%, icon, Open Quick Notes Folder`t%OpenQuickNotesDir%, %dopus%,,24
	else
		Menu, %topmenu%, icon, Open Quick Notes Folder`t%OpenQuickNotesDir%, explorer.exe,,24
	; }
Menu, %topmenu%, Add, ;line ;------------------------- 
LastMenu := topmenu

Loop, %topmenu%\*.*, 2,1	; add folders first, Recurse into subfolders.
{
If InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "S")
	Continue 

StringGetPos, pos, A_LoopFileLongPath, \, R
if (pos <> -1) ; it has a parent
	StringLeft, ParentFolderDirectory, A_LoopFileLongPath, %pos%
if (pos = -1) ; it has no parent 
	ParentFolderDirectory := rootdir

Menu, %A_LoopFileLongPath%, add
Menu, %A_LoopFileLongPath%, deleteall
Menu, %A_LoopFileLongPath%, add, Open - %A_LoopFileName% - Folder, OpenFolderHeadinglibmenu
IconPath := GetFileIcon(A_LoopFileFullPath)
Menu, %A_LoopFileLongPath%, icon, Open - %A_LoopFileName% - Folder, %iconpath%
if (iconpath = "")
	Menu, %A_LoopFileLongPath%, icon, Open - %A_LoopFileName% - Folder, %dopus%
	
Menu, %A_LoopFileLongPath%, add, ; line -------------------------

Menu, %A_LoopFileDir%, Add, %A_LoopFileName% , Actiontopmenu
IconPath := GetFileIcon(A_LoopFileFullPath)
Menu, %A_LoopFileDir%, Icon, %A_LoopFileName%, %IconPath%

If (A_LoopFileDir != LastMenu) and (LastMenu != topmenu)
	{ 
		; MsgBox %topmenu% %LastMenu%
		AddMenu(LastMenu)
	}
LastMenu := A_LoopFileDir ; Save menu namen
}
menu, %topmenu%, add, ; line -------------------------

Loop, %topmenu%\*.*, 0,1	; add files below folders.
{
	If InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "S") ; or InStr(A_LoopFileExt, "exe") or InStr(A_LoopFileExt, "ico") or InStr(A_LoopFileExt, "png") or InStr(A_LoopFileExt, "psd") or InStr(A_LoopFileExt, "old")	or InStr(A_LoopFileExt, "jpeg") or InStr(A_LoopFileExt, "bak")
		Continue 
	
	; menuname := strreplace(A_LoopFileName, "&", "&&") ;todo
	Menu, %A_LoopFileDir%, Add, %A_LoopFileName% , Actiontopmenu
	
	IconPath := GetFileIcon(A_LoopFileFullPath)
	Menu, %A_LoopFileDir%, Icon, %A_LoopFileName%, %IconPath%
	
	If (A_LoopFileDir != LastMenu) and (LastMenu != topmenu)
	{
		; MsgBox %topmenu% %LastMenu%
		AddMenu(LastMenu)
	}
	LastMenu := A_LoopFileDir ; Save menu name
}

AddMenu(LastMenu)
; Menu, %topmenu%, Show
Return
;---------------------------------------------------------------------------
opentopmenu:
run %topmenu%
return
OpenFolderHeadinglibmenu:
run %A_ThisMenu%
return
Actiontopmenu:
Global filename, dir, ext, filestem, drive, folder, lastfolder, filetoclip, highlighted, ClipSaved, texteditor
file := A_thismenuitem
splitpath, file,,,ext
try run, "%A_thismenu%\%A_ThisMenuItem%"
return
/*

 ; msgbox, you are here!`next: %ext%`nLine#: %a_linenumber%
if (ext = "ahk")
	{
	try Run %texteditor% "%A_thismenu%\%A_ThisMenuItem%"
	catch
	run notepad.exe "%A_thismenu%\%A_ThisMenuItem%"
	sleep 30
	Return
	}
else if (ext = "ico")
	{
	try Run %xnviewmp% "%A_thismenu%\%A_ThisMenuItem%"
		catch
	try Run "%A_thismenu%\%A_ThisMenuItem%"
	sleep 30
	Return
	}
else if (ext = "code-workspace")
	{
	try run, %vscode% "%A_scriptdir%"
	sleep 30
	Return
	}
else if (file = "AutoHotkey X BUE.sps")
	{
		run %syncbackpro% "AutoHotkey X BUE" -n ; -i
		Return
		; gosub AHKBUE
	}
else
	{
	try run, %texteditor% "%A_thismenu%\%A_ThisMenuItem%"
	catch
	try run, nopepad.exe "%A_thismenu%\%A_ThisMenuItem%"
	catch
	try run, "%A_thismenu%\%A_ThisMenuItem%"
	}
Return 

*/

quicksubAction:
; Run, % A_ThisMenu . "\" . A_ThisMenuItem
if % ext = "ahk"
	{
	try Run %texteditor% "%A_thismenu%\%A_ThisMenuItem%"
	catch
	run notepad.exe "%A_thismenu%\%A_ThisMenuItem%"
	sleep 30
	Return
	}
else if % ext = "ico"
	{
	try Run %xnviewmp% "%A_thismenu%\%A_ThisMenuItem%"
		catch
	try Run "%A_thismenu%\%A_ThisMenuItem%"
	sleep 30
	Return
	}
else
	try run, "%A_thismenu%\%A_ThisMenuItem%"
	catch
	try run, %texteditor% "%A_thismenu%\%A_ThisMenuItem%"
	catch
	run, nopepad.exe "%A_thismenu%\%A_ThisMenuItem%"
Return

AddMenu(MenuName) ;; function for building live topmenu
{
    SplitPath, MenuName , DirName, OutDir, OutExtension, OutNameNoExt, OutDrive
    Menu, %OutDir%, Add, %DirName%, :%MenuName%
}
;///////////////////////////////////////////////////////////////////////////
;---------------------------------------------------------------------------
LogError(Path) { ;; logerror function
global clipsaved, filename, ext, filestem, dir, lastfolder
    if ErrorLevel
    {
    FileAppend, % "*`n+-=START=-+`nError Info...`nTime: " A_Now "`n@ Line: " A_LineNumber "`nClipboard := " Clipboard "`n`nWhich Hotkey: " A_ThisHotkey "`nThis Label: " A_ThisLabel "`nWhich Menu: " A_ThisMenu "`nWhich Menu Item: " A_ThisMenuItem "`nMenu Pos: " A_ThisMenuItemPos "`nFull Menu text...`nmenu`, " A_thismenu "`, Add`, " A_ThisMenuItem "`, " A_ThisLabel "`n`nVars listed.....`nFilename: " filename "`nExt: " ext "`nFilestem: " filestem "`nDir: " dir "`nParent-LastFolder: " lastfolder "`n`nEvent Info: " A_EventInfo "`nLast Error: " A_LastError "`nThis Func: " A_ThisFunc "`n+-=END=-+`n", %A_ScriptDir%\%A_scriptname%- ERROR LOG.txt,UTF-8
	sleep 500
    Return
    }
}
;---------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////
wincontextmenu:
iflive()
sleep 20
cleanupPATHstring()
path = %clipboard% 
sleep 20
restoreclipboard()
sleep 400
if FileExist(path)
	ShellContextMenu(Path)
else
	{
		Tooltip, ERR! @ Line#:  %A_LineNumber%`nCannot open Windows Context Menu here.`nPath or file was not found.
		Sleep 2500
		Tooltip
		Return
	}
return

;; https://autohotkey.com/board/topic/20376-invoking-directly-contextmenu-of-files-and-folders/
;; source: https://autohotkey.com/board/topic/89281-ahk-l-shell-context-menu/
; global idn, pidl, plshellfolder, pidlChild, plContextMenu, pt, pIContextMenu2, pIContextMenu3, WPOld ;; for heading

ShellContextMenu( sPath, win_hwnd = 0, pidl = 0, pIShellFolder = 0, pidlChild = 0, pt = 0, pIContextMenu = 0 )
{
   if ( !sPath  )
      return
   if !win_hwnd
   {
		win_hwnd := DllCall( "User32.dll\FindWindow", "Str", "AutoHotkey", "Str", A_ScriptFullPath ( A_IsCompiled ? "" : " - AutoHotkey v" A_AhkVersion ))
      Gui,SHELL_CONTEXT:New, +hwndwin_hwnd
      Gui,Show
   }
   
   If sPath Is Not Integer
      DllCall("shell32\SHParseDisplayName", "Wstr", sPath, "Ptr", 0, "Ptr*", pidl, "Uint", 0, "Uint*", 0)
      ;  // This function is the preferred method to convert a string to a pointer to an item identifier list (PIDL).
   else
      DllCall("shell32\SHGetFolderLocation", "Ptr", 0, "int", sPath, "Ptr", 0, "Uint", 0, "Ptr*", pidl)
   DllCall("shell32\SHBindToParent", "Ptr", pidl, "Ptr", GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}"), "Ptr*", pIShellFolder, "Ptr*", pidlChild)
   ;IShellFolder->GetUIObjectOf
   DllCall(VTable(pIShellFolder, 10), "Ptr", pIShellFolder, "Ptr", 0, "Uint", 1, "Ptr*", pidlChild, "Ptr", GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"), "Ptr", 0, "Ptr*", pIContextMenu)
   ObjRelease(pIShellFolder)
   CoTaskMemFree(pidl)
   
   hMenu := DllCall("CreatePopupMenu")
   ;IContextMenu->QueryContextMenu
   ; // http://msdn.microsoft.com/en-us/library/bb776097%28v=VS.85%29.aspx
   DllCall(VTable(pIContextMenu, 3), "Ptr", pIContextMenu, "Ptr", hMenu, "Uint", 0, "Uint", 3, "Uint", 0x7FFF, "Uint", 0x100)   ;CMF_EXTENDEDVERBS
   ComObjError(0)
      global pIContextMenu2 := ComObjQuery(pIContextMenu, IID_IContextMenu2:="{000214F4-0000-0000-C000-000000000046}")
      global pIContextMenu3 := ComObjQuery(pIContextMenu, IID_IContextMenu3:="{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}")
   e := A_LastError ;GetLastError()
   ComObjError(1)
   if (e != 0)
      goTo, StopContextMenu
   Global   WPOld:= DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int",-4, "Ptr",RegisterCallback("WindowProc"),"UPtr")
   DllCall("GetCursorPos", "int64*", pt)
   DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x800, "Ptr", 2, "Ptr", 0) ; topline
   DllCall("InsertMenu", "Ptr", hMenu, "Uint", 0, "Uint", 0x0400|0x002, "Ptr", 1, "Ptr", &sPath) ; displays filepath at top of menu

   idn := DllCall("TrackPopupMenuEx", "Ptr", hMenu, "Uint", 0x0100|0x0001, "int", pt << 32 >> 32, "int", pt >> 32, "Ptr", win_hwnd, "Uint", 0)

		; typedef struct _CMINVOKECOMMANDINFOEX {
		   ; DWORD   cbSize;          0
		   ; DWORD   fMask;           4
		   ; HWND    hwnd;            8
		   ; LPCSTR  lpVerb;          8+A_PtrSize
		   ; LPCSTR  lpParameters;    8+2*A_PtrSize
		   ; LPCSTR  lpDirectory;     8+3*A_PtrSize
		   ; int     nShow;           8+4*A_PtrSize
		   ; DWORD   dwHotKey;        12+4*A_PtrSize
		   ; HANDLE  hIcon;           16+4*A_PtrSize
		   ; LPCSTR  lpTitle;         16+5*A_PtrSize
		   ; LPCWSTR lpVerbW;         16+6*A_PtrSize
		   ; LPCWSTR lpParametersW;   16+7*A_PtrSize
		   ; LPCWSTR lpDirectoryW;    16+8*A_PtrSize
		   ; LPCWSTR lpTitleW;        16+9*A_PtrSize
		   ; POINT   ptInvoke;        16+10*A_PtrSize
		   ; } CMINVOKECOMMANDINFOEX, *LPCMINVOKECOMMANDINFOEX;
		   ; http://msdn.microsoft.com/en-us/library/bb773217%28v=VS.85%29.aspx

   struct_size  :=  16+11*A_PtrSize
   
   VarSetCapacity(pici,struct_size,0)
   NumPut(struct_size,pici,0,"Uint")         ;cbSize
   NumPut(0x4000|0x20000000|0x00100000,pici,4,"Uint")   ;fMask
   NumPut(win_hwnd,pici,8,"UPtr")       ;hwnd
   NumPut(1,pici,8+4*A_PtrSize,"Uint")       ;nShow
   NumPut(idn-3,pici,8+A_PtrSize,"UPtr")     ;lpVerb
   NumPut(idn-3,pici,16+6*A_PtrSize,"UPtr")  ;lpVerbW
   NumPut(pt,pici,16+10*A_PtrSize,"Uptr")    ;ptInvoke
   
   DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &pici)   ; InvokeCommand

   DllCall("GlobalFree", "Ptr", DllCall("SetWindowLongPtr", "Ptr", win_hwnd, "int", -4, "Ptr", WPOld,"UPtr"))
   DllCall("DestroyMenu", "Ptr", hMenu)
StopContextMenu:
   ObjRelease(pIContextMenu3)
   ObjRelease(pIContextMenu2)
   ObjRelease(pIContextMenu)
   pIContextMenu2:=pIContextMenu3:=WPOld:=0
   Gui,SHELL_CONTEXT:Destroy
   return idn
}

WindowProc(hWnd, nMsg, wParam, lParam)
{
   Global   pIContextMenu2, pIContextMenu3, WPOld
   ; If   pIContextMenu3
   ; {    ;IContextMenu3->HandleMenuMsg2
      ; If   !DllCall(VTable(pIContextMenu3, 7), "Ptr", pIContextMenu3, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)
         ; Return   lResult
   ; }
   ; Else 
   
   ; If   pIContextMenu2
   {    ;IContextMenu2->HandleMenuMsg
      If   !DllCall(VTable(pIContextMenu2, 6), "Ptr", pIContextMenu2, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
         Return   0
   }
   Return   DllCall("user32.dll\CallWindowProcW", "Ptr", WPOld, "Ptr", hWnd, "Uint", nMsg, "Ptr", wParam, "Ptr", lParam)
}

VTable(ppv, idx)
{
   Return   NumGet(NumGet(1*ppv)+A_PtrSize*idx)
}
GUID4String(ByRef CLSID, String)
{
   VarSetCapacity(CLSID, 16,0)
   return DllCall("ole32\CLSIDFromString", "wstr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}
CoTaskMemFree(pv)
{
   Return   DllCall("ole32\CoTaskMemFree", "Ptr", pv)
}
;///////////////////////////////////////////////////////////////////////////
;///////////////////////// END WIN CONTEXT MENU ////////////////////////////
;///////////////////////////////////////////////////////////////////////////


; source:  https://www.reddit.com/r/AutoHotkey/comments/193wdki/hotkeys_are_dont_work_when_a_menu_is_being_shown/
; This function self initializes. No need to call it manually.
; When the user clicks away to close the menu, the message WM_ACTIVATEAPP is sent.
; Calling EndMenu on WM_ACTIVATEAPP fixes the bug that causes a modeless menu to show in the previous position.
; this function allows hotkeys to be triggred when a menu is visiable, usually ahk blocks hotkeys when its busy displaying a menu.
ModelessMenuEnd(wParam) {
    static _ := OnMessage(0x0000001C, "ModelessMenuEnd") ; WM_ACTIVATEAPP
    if !wParam
        DllCall("EndMenu")
}

Menu_SetModeless(menuNameOrHandle)
{
    if menuNameOrHandle is Not Integer
        hMenu := MenuGetHandle(menuNameOrHandle)
    else
        hMenu := menuNameOrHandle

    if !hMenu
        return

    size := 16+3*A_PtrSize
    VarSetCapacity(MenuInfo, size, 0)
    NumPut(size, MenuInfo, 0) ;cbsize

    MIM_STYLE := 0x10
    MNS_MODELESS := 0x40000000
    NumPut(MIM_STYLE, MenuInfo, 4) ;fmask
    DllCall("GetMenuInfo", "ptr", hMenu, "ptr", &MenuInfo)
    style := NumGet(MenuInfo, 8, "uint") ; check dwStyle
    if !(style & MNS_MODELESS) ; If dwStyle not modeless
    {
        ; Set MNS_MODELESS style
        NumPut(style|MNS_MODELESS, MenuInfo, 8)
        DllCall("SetMenuInfo", "uint", hMenu, "uint", &MenuInfo)
    }
}
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

; Decodes XML numeric character references and predefined entities directly on the clipboard content.
XMLDecode() {
    ; Initialize variables
    local prev := 1, result := "", regexNeedle := "S)&(?:" ; Regex to match XML entities
        . "amp|lt|gt|apos|quot|"                         ; Predefined entities
        . "#(?:\d+|x[[:xdigit:]]+)"                      ; Numeric entities (decimal and hex)
        . ");"
    
    ; Process the clipboard content
    ClipSaved := ClipboardAll ; Backup the clipboard
    value := Clipboard        ; Get the current clipboard content
    while (cur := RegExMatch(value, regexNeedle, m, prev)) {
        ; Append text before the match to the result
        result .= SubStr(value, prev, cur - prev)
        ; Decode matched XML entities
        switch m {
            case "&amp;":  result .= "&"               ; Decode `&amp;` to `&`
            case "&lt;":   result .= "<"               ; Decode `&lt;` to `<`
            case "&gt;":   result .= ">"               ; Decode `&gt;` to `>`
            case "&apos;": result .= "'"               ; Decode `&apos;` to `'`
            case "&quot;": result .= """"              ; Decode `&quot;` to `"`
            default:
                ; Handle numeric entities (`&#...;` or `&#x...;`)
                num := SubStr(m, 3)
                result .= Chr(SubStr(num, 1, 1) == "x" ? "0x" SubStr(num, 2) : num)
        }
        prev := cur + StrLen(m) ; Move past the current match
    }
    ; Append the remaining text
    result .= SubStr(value, prev)
    Clipboard := result       ; Update clipboard with the decoded result
    return                    ; End function
}

; Encodes all potentially dangerous characters in the clipboard content so that
; the resulting string can be safely inserted into an XML element or attribute.
; `quotesEncoded` determines if single ('') and double ("") quotes are encoded.
XMLEncode(quotesEncoded := false) {
    ; Initialize variables
    local prev := 1, result := "", regexNeedle := "S)[" ; Regex for dangerous XML characters
        . "&<>" (quotesEncoded ? "'""" : "") "]|"       ; Match &, <, >, ' (optional), and "
        . "[^ -~]"                                      ; Match non-printable/control characters
    
    ; Process the clipboard content
    ; ClipSaved := ClipboardAll ; Backup the clipboard
    value := Clipboard        ; Get the current clipboard content
    while (cur := RegExMatch(value, regexNeedle, m, prev)) {
        ; Append text before the match to the result
        result .= SubStr(value, prev, cur - prev)
        ; Encode dangerous characters
        switch m {
            case "&": result .= "&amp;" ; Encode `&` as `&amp;`
            case "<": result .= "&lt;"  ; Encode `<` as `&lt;`
            case ">": result .= "&gt;"  ; Encode `>` as `&gt;`
            case """": result .= "&quot;" ; Encode `"` as `&quot;` if `quotesEncoded` is true
            case "'": result .= "&apos;" ; Encode `'` as `&apos;` if `quotesEncoded` is true
            default:
                ; Encode control characters or non-printables as numeric entities
                result .= "&#" Ord(m) ";"
        }
        prev := cur + StrLen(m) ; Move past the current match
    }
    ; Append the remaining text
    result .= SubStr(value, prev)
    Clipboard := result ; Update clipboard with the encoded result
    return              ; End function
}


;///////////////////////////////////////////////////////////////////////////
;; get delay time function
; numpadadd::
; freq := ""
; CounterBefore := ""
; CounterAfter := ""
; delaytime()
;-------------------------

;///////////////////////////////////////////////////////////////////////////
;; get delay time fuction for dynamic sleeps
viewdelaytime:
getdelaytime()
msgbox D_t: %delay_time%`ndelaytick: %delaytick% ;`n freq: %freq%
return
/*
;;; raw code from forum, below is edit by AUTOHOTKEY Gurus
; delaytime()
; {
; global
; DllCall("QueryPerformanceFrequency", "Int64*", freq)
; DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
; Sleep 1000
; DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
; MsgBox % "Elapsed QPC time is " . (CounterAfter - CounterBefore) / freq * 1000 " ms"
; } 
*/

GetDelayTime() ;; function
{
;; Demonstrates QueryPerformanceCounter(), which gives more precision than A_TickCount's 10 ms., source: https://www.autohotkey.com/docs/v1/lib/DllCall.htm
;; video ref: https://www.youtube.com/watch?v=TKxiqnZLcz8 , title: How to Creating a self-Adjusting Sleep that adjusts to your Computer's Load
;; !!!! usage example = sleep getdelaytime() * 1000 ;; the * 1000 matches the bottomline of the fucntion both can be delected
	global delay_time, delaytick
	DllCall("QueryPerformanceFrequency", "Int64*", freq := 0)
	DllCall("QueryPerformanceCounter", "Int64*", CounterBefore := 0)
	loop 1000
		delaytick := A_Index
	DllCall("QueryPerformanceCounter", "Int64*", CounterAfter := 0)
	; MsgBox "Elapsed QPC time is "  (CounterAfter - CounterBefore) / freq * 1000 " ms" ; debug view output from docs

	return delay_time := (CounterAfter - CounterBefore) / freq * 1000
}
;///////////////////////////////////////////////////////////////////////////

;; read ini functions ini read iniread () ;; Functions
INIReadHotkeySection(sectionName)
{
    global
	; global HotkeyLabels

    IniRead, HotkeySection, %inifile%, %sectionName%
    if (HotkeySection = "ERROR")
        return

    local inikeycount := 0  ; Local count for this section
    local MenuItems := ""  ; String to store menu items for sorting
    ; MenuItems := ""  ; String to store menu items for sorting

    Loop, Parse, HotkeySection, `n, `r
    {
        if (A_LoopField = "")
            continue

        KeyParts := StrSplit(A_LoopField, "=")
        if (KeyParts.Length() < 2)
            continue

        LabelName := Trim(KeyParts[1])
        FullValue := Trim(KeyParts[2])

        if (FullValue = "" || FullValue = "ERROR")
            continue

        ValueParts := StrSplit(FullValue, "|")
        HotkeyValue := Trim(ValueParts[1])
        FriendlyName := (ValueParts.Length() > 1 && ValueParts[2] != "") ? Trim(ValueParts[2]) : LabelName  ; Ensure fallback to LabelName

        %LabelName% := HotkeyValue  ; Store hotkey as a global variable ;; og keep
        ; HotkeyLabels[LabelName] := HotkeyValue  ; Store in global object
		
        try {
            Hotkey, %HotkeyValue%, %LabelName%, On
            inikeycount++
            totaliniCount++
        } catch {
            continue
        }

        ; Convert symbols to words for display
        ReadableHotkey := ConvertAHKSymbolToWords(HotkeyValue)

        ; Store in string for sorting
        MenuItems .= FriendlyName "¦" ReadableHotkey "¦" LabelName "`n"
    }

    ; Sort the menu items alphabetically by FriendlyName
    Sort, MenuItems

    ; Add sorted items to menu
    Loop, Parse, MenuItems, `n
    {
        if (A_LoopField = "")
            continue

        Parts := StrSplit(A_LoopField, "¦")
        FriendlyName := Parts[1]
        ReadableHotkey := Parts[2]
        LabelName := Parts[3]

        Menu, k, Add, %FriendlyName%`t%ReadableHotkey%, %LabelName%
    }
}


inimenukeyWrapper:
    iniMenuItemHandler(A_ThisMenuItem)
return
iniMenuItemHandler(labelName) {
    if (GetKeyState("Shift", "P")) {  ; If Shift is held
        Clipboard := labelName
    } else {
        Gosub, %labelName%  ; Run the corresponding label
    }
}

ConvertAHKSymbolToWords(hotkey)
{
	global
    hotkey := StrReplace(hotkey, "+", "Shift+")
    hotkey := StrReplace(hotkey, "^", "Ctrl+")
    hotkey := StrReplace(hotkey, "!", "Alt+")
    ; hotkey := StrReplace(hotkey, "#", "Win+")
    hotkey := StrReplace(hotkey, "#", "⊞+") ; ⊞ + 
    return hotkey
}

showlivehotkeymenu:
; CoordMode,menu,client
; menu, k, show,10,10
INIReadHotkeySection("Global_Hotkeys")
menu, k, show
return

; INIReadGlobal_Hotkeys() ;; function
; {
;     global
;     IniRead, HotkeySection, %inifile%, Global_Hotkeys
;     if (HotkeySection = "ERROR")
;         return

;     Loop, Parse, HotkeySection, `n, `r
;     {
;         if (A_LoopField = "")
;             continue
            
;         KeyParts := StrSplit(A_LoopField, "=")
;         if (KeyParts.Length() < 2)
;             continue

;         LabelName := KeyParts[1]
;         HotkeyValue := KeyParts[2]
        
;         if (HotkeyValue = "" || HotkeyValue = "ERROR")
;             continue
            
;         try {
;             Hotkey, %HotkeyValue%, %LabelName%, On
;         } catch {
;             continue
;         }
;     }
; } 

INIReadPrograms() ;; function
{
global
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
}



INIReadToggles() ;; fucntion
{
    global  ; Make variables global
    IniRead, toggleSection, %inifile%, Toggles
    if (toggleSection = "ERROR")
        return
        
    Loop, Parse, toggleSection, `n, `r
    {
        if (A_LoopField = "")
            continue
            
        ToggleParts := StrSplit(A_LoopField, "=")
        if (ToggleParts.Length() < 2)
            continue
            
        ToggleName := ToggleParts[1]
        ToggleValue := ToggleParts[2]
        
        if (ToggleValue = "" || ToggleValue = "ERROR")
            ToggleValue := 0  ; Default to false if error or empty
            
        ; Make the toggle name a global variable and assign its value
        %ToggleName% := ToggleValue
    }
}


; IconsDir := A_ScriptDir . "\Icons" ; Path to the Icons folder
markiconsdirasreadonly() ;; function
{
Loop, Files, %IconsDir%\*.* ; Iterate through all files in the Icons folder
	{
		FileGetAttrib, attrib, %A_LoopFileFullPath% ; Get the file's attributes
		If !(InStr(attrib, "R")) ; Check if the file is NOT read-only
		{
			FileSetAttrib, +R, %A_LoopFileFullPath% ; Mark the file as read-only
			; MsgBox, File marked as read-only: %A_LoopFileName%
		}
	}
; MsgBox, Finished processing files in`n %IconsDir%
Return
}
markclogfileasreadonly() ;; function ;; 
{
FileGetAttrib, attrib, %clogfile%
if !(InStr(attrib, "R"))
	{
	FileSetAttrib, +R, %clogfile%
	}
}

CheckUpdates:
    ; Create and send the HTTP request
    HttpRequest := ComObjCreate("MSXML2.XMLHTTP.6.0")
    HttpRequest.Open("GET", GitHubAPI, False)
    HttpRequest.Send()

    ; Retrieve the HTTP status and response text
    Status := HttpRequest["status"] ; Use bracket notation for compatibility
    Response := HttpRequest["responseText"]

    ; Handle errors
    If (Status != 200) {
        MsgBox, 48, Error, Failed to fetch release info from GitHub.`nHTTP Status: %Status%
        Return
    }

    ; Parse the JSON response to extract the "tag_name"
    LatestVersion := RegexMatch(Response, """tag_name"":\s*""(.*?)""", Match) ? Match1 : ""
    If (LatestVersion = "") {
        MsgBox, 48, Error, Failed to parse the version from GitHub API response.
        Return
    }

    ; Compare versions
    If (ScriptVersion = LatestVersion) {
        MsgBox, 64, Up-to-Date, Your script is up-to-date! Current version: %ScriptVersion%.
    } Else {
        MsgBox, 48, Update Available, A new version is available: %LatestVersion%.`nYour version: %ScriptVersion%.
    }
Return

; GitHubVersionFile := "https://raw.githubusercontent.com/indigofairyx/Extended_Capslock_Context_Menu/refs/heads/main/Extended%20Capslock%20Context%20Menu/version.txt" ; URL to the version file in your GitHub repo
; Tempupdatecheck := A_Temp . "\version.txt" ; Temporary file to store the downloaded version


CheckUpdatesStartup:
if !FileExist(tempupdatecheck)
	{
		URLDownloadToFile, %GitHubVersionFile%, %Tempupdatecheck% ; Download the version file from GitHub
			If (ErrorLevel)
			{
				; MsgBox, 4112, Error!, Failed to download version info from GitHub!`n`nIf your offline that will cause this error.`nPlease try again later or visit the ECLM Repo directly., 7
				Return
			}
		; Read the downloaded version
		; FileRead, LatestVersion, %Tempupdatecheck%
	}
	
	FileReadLine, LatestVersion, %Tempupdatecheck%, 1
    LatestVersion := Trim(LatestVersion) ; Remove extra spaces/newlines

    If (ScriptVersion != LatestVersion) ; Compare versions
    {
        MsgBox, 4161, New Version Available., A new version of ECLM is available!`n`nLast Updated: %LatestVersion%`n`nYour version: %ScriptVersion%`n`nClick OK to visit the Github Releases page where you can see the Change Log and Download the new version.`n`nReplace this directory with the new one and reload.,30
		IfMsgBox OK
			{
			run https://github.com/indigofairyx/Extended_Capslock_Context_Menu/releases/tag/%latestversion%
			filedelete, %tempupdatecheck%
			}
    }
sleep 400
return

CheckUpdatesmanual:
    URLDownloadToFile, %GitHubVersionFile%, %Tempupdatecheck% ; Download the version file from GitHub
    If (ErrorLevel)
    {
        MsgBox, 4112, Error!, Failed to download version info from GitHub!`n`nPlease try again later or visit the ECLM Repo directly., 10
        Return
    }
    ; Read the downloaded version
    ; FileRead, LatestVersion, %Tempupdatecheck%
	FileReadLine, LatestVersion, %Tempupdatecheck%, 1

    LatestVersion := Trim(LatestVersion) ; Remove extra spaces/newlines

    
    If (ScriptVersion = LatestVersion) ; Compare versions
    {
		FileDelete, %Tempupdatecheck%
		MsgBox, 4096, Up to Date, Your ECLM is Up To Date.`n`nVersion:  %scriptversion%`n, 7
    }
    Else
    {
        MsgBox, 4161, New Version Available., A new version of ECLM is available!`n`nLast Updated: %LatestVersion%`n`nYour version: %ScriptVersion%`n`nClick OK to visit the Github Releases page where you can see the Change Log and Download the new version.`n`nReplace this directory with the new one and reload.`n`nYou Can turn ON Automatically checking for Updates in the settings menu.,30
		IfMsgBox OK
			run https://github.com/indigofairyx/Extended_Capslock_Context_Menu/releases/tag/%latestversion%
    }
sleep 800
filedelete, %tempupdatecheck%
Return

;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------INSERT MENU LABELS--------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

; OpenEmojiKeyboard() ;; function ;; dup
; {
    ; Send {LWin down}.
    ; Send {LWin up}
; }



;---------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////

; if fileExist(snipdir)
	; gosub buildsnippetfoldermenu
	

showinsertmenu:
gosub buildinsertmenu
menu, i, show
return

buildinsertmenu:
menu, i, add, 
menu, i, DeleteAll
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
Menu, UpDownArrow, Add, Insert Arrow >>     ↑, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     ⬆, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     ⇧, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     ▲, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     △, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     🡱, InsertSymbols
Menu, UpDownArrow, Add, Insert Ar​row >>     ⮙, InsertSymbols
Menu, UpDownArrow, Add, Insert Ar​row >>     ⮝, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     ⌃, InsertSymbols
Menu, UpDownArrow, Add,
Menu, UpDownArrow, Add,
Menu, UpDownArrow, Add, Insert Ar​row >>     ↓, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     ⬇, InsertSymbols
Menu, UpDownArrow, Add, Insert Ar​row >>     ⇩, InsertSymbols
Menu, UpDownArrow, Add, Insert Ar​row >>     ▼, InsertSymbols
Menu, UpDownArrow, Add, Insert Ar​row >>     ▽, InsertSymbols
Menu, UpDownArrow, Add, Insert Arrow >>     🡳, InsertSymbols
Menu, UpDownArrow, Add, Insert Arr​ow >>     ⮛, InsertSymbols
Menu, UpDownArrow, Add, Insert Arr​ow >>     ⮟, InsertSymbols
Menu, UpDownArrow, Add, Insert Ar​row >>     ⌄, InsertSymbols
;;∙-----------------------------------------∙
Menu, LeftRightArrow, Add, Insert Ar​row >>     ←, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⬅, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⇦, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ◀, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ◁, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     🡰, InsertSymbols
Menu, LeftRightArrow, Add, Insert Arr​ow >>     ⮘, InsertSymbols
Menu, LeftRightArrow, Add, Insert Arr​ow >>     ⮜, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⏴, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⇐, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⟪, InsertSymbols 
Menu, LeftRightArrow, Add
Menu, LeftRightArrow, Add
Menu, LeftRightArrow, Add, Insert Ar​row >>     →, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ➞, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⇨, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ▶, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ▷, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     🡲, InsertSymbols
Menu, LeftRightArrow, Add, Insert Arr​ow >>     ⮚, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⮞, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⏵, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⇒, InsertSymbols
Menu, LeftRightArrow, Add, Insert Ar​row >>     ⟫, InsertSymbols
;;∙-----------------------------------------∙
Menu, BiDirectionala, Add, Insert Ar​row >>     ↕, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⬍, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⇳, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     🡙, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⇕, InsertSymbols
Menu, BiDirectionala, Add
Menu, BiDirectionala, Add
Menu, BiDirectionala, Add, Insert Ar​row >>     ↔, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⬌, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⬄, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     🡘, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⇿, InsertSymbols
Menu, BiDirectionala, Add, Insert Ar​row >>     ⟷, InsertSymbols
;;∙-----------------------------------------∙
Menu, DiagUpArrow, Add, Insert Ar​row >>     ↖, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ⬉, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ⬁, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ◤, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ◸, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     🡴, InsertSymbols
Menu, DiagUpArrow, Add
Menu, DiagUpArrow, Add
Menu, DiagUpArrow, Add, Insert Ar​row >>     ↗, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ⬈, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ⬀, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ◥, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     ◹, InsertSymbols
Menu, DiagUpArrow, Add, Insert Ar​row >>     🡵, InsertSymbols
;;∙-----------------------------------------∙
Menu, DiagDownArrow, Add, Insert Ar​row >>     ↘, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ⬊, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ⬂, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ◢, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ◿, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     🡶, InsertSymbols
Menu, DiagDownArrow, Add
Menu, DiagDownArrow, Add
Menu, DiagDownArrow, Add, Insert Ar​row >>     ↙, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ⬋, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ⬃, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ◣, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     ◺, InsertSymbols
Menu, DiagDownArrow, Add, Insert Ar​row >>     🡷, InsertSymbols
;;∙-----------------------------------------∙
Menu, CircularArrow, Add, Insert Ar​row >>     ↩, InsertSymbols
Menu, CircularArrow, Add, Insert Ar​row >>     ↪, InsertSymbols
Menu, CircularArrow, Add
Menu, CircularArrow, Add, Insert Ar​row >>     ↶, InsertSymbols
Menu, CircularArrow, Add, Insert Ar​row >>     ↷, InsertSymbols
Menu, CircularArrow, Add
Menu, CircularArrow, Add, Insert Ar​row >>     ↺, InsertSymbols
Menu, CircularArrow, Add, Insert Ar​row >>     ↻, InsertSymbols
Menu, CircularArrow, Add
Menu, CircularArrow, Add, Insert Ar​row >>     ⥀, InsertSymbols
Menu, CircularArrow, Add, Insert Ar​row >>     ⥁, InsertSymbols
;;∙======∙BULLETS∙==============================================∙
Menu, Bullet, Add, Insert Bullet >>     ◦, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     •, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ●, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ◎, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ◉, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ○, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ◯, InsertSymbols
Menu, Bullet, Add
Menu, Bullet, Add, Insert Bullet >>     ▫, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ▪, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ☐, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ■, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ▣, InsertSymbols
Menu, Bullet, Add
Menu, Bullet, Add, Insert Bullet >>     ◇, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ◈, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ◆, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ✧, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ✦, InsertSymbols
Menu, Bullet, Add
Menu, Bullet, Add, Insert Bullet >>     ▹, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ▸, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ⪧, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     🠺, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     √, InsertSymbols
Menu, Bullet, Add, Insert Bullet >>     ⬢, InsertSymbols
;;∙======∙STARS∙================================================∙
Menu, Stars, Add, Insert Star >>     ✶, InsertSymbols
Menu, Stars, Add, Insert Star >>     ✹, InsertSymbols
Menu, Stars, Add, Insert Star >>     ✸, InsertSymbols
Menu, Stars, Add, Insert Star >>     ★, InsertSymbols
Menu, Stars, Add, Insert Star >>     ✦, InsertSymbols
Menu, Stars, Add
Menu, Stars, Add, Insert Star >>     ❊, InsertSymbols
Menu, Stars, Add, Insert Star >>     ❈, InsertSymbols
Menu, Stars, Add, Insert Star >>     ❋, InsertSymbols
Menu, Stars, Add, Insert Star >>     ❉, InsertSymbols
Menu, Stars, Add, Insert Star >>     ✺, InsertSymbols
Menu, Stars, Add
Menu, Stars, Add, Insert Star >>     ⛤, InsertSymbols
Menu, Stars, Add, Insert Star >>     ⚝, InsertSymbols
Menu, Stars, Add, Insert Star >>     ⛧, InsertSymbols
Menu, Stars, Add, Insert Star >>     ✰, InsertSymbols
Menu, Stars, Add, Insert Star >>     ☆, InsertSymbols
;;∙======∙SYMBOLS∙=============================================∙
Menu, Symbols, Add, Insert  Symbol >>     ÷, InsertSymbols
Menu, Symbols, Add, Insert  Symbol >>     ⨯, InsertSymbols
Menu, Symbols, Add, Insert  Symbol >>     ∓, InsertSymbols
Menu, Symbols, Add, Insert  Symbol >>     ±, InsertSymbols
Menu, Symbols, Add, Insert  Symbol >>     ≥, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ≤, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ≠, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ≈, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     °, InsertSymbols 
Menu, Symbols, Add
Menu, Symbols, Add, Insert  Symbol >>     ➕, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ➖, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ✖️, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ➗, InsertSymbols 
Menu, Symbols, Add,
Menu, Symbols, Add, Insert  Symbol >>     ©, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ®, InsertSymbols 
Menu, Symbols, Add, Insert  Symbol >>     ™, InsertSymbols 

/*

; Menu, Arrow, Add, 🡱 Up 🡳 Down Arrows, :UpDownArrow
; Menu, Arrow, Add, 🡰 Left 🡲 Right Arrows, :LeftRightArrow
; Menu, Arrow, Add
; Menu, Arrow, Add, Bi 🡙 && 🡘 Arrows, :BiDirectionala
; Menu, Arrow, Add
; Menu, Arrow, Add, Diagonal 🡴 Up Arrows, :DiagUpArrow
; Menu, Arrow, Add, Diagonal 🡶 Down Arrows, :DiagDownArrow
; Menu, Arrow, Add
; Menu, Arrow, Add, Circular ↩ ↻ Arrows, :CircularArrow 

*/
;--------------------------------------------------
;--------------------------------------------------
specialChars := [ "°", "…", "∅", "⊕", "⊗", "¢", "€", "¥", "£", "ツ", "≡", "⌫", "⊞", "⌘", "∞",  "෴", "∴",  "∵", "¶", "∑", "彡", "☉", "☽", "☾", "⎋", "☨", "¦", "ʘ"]
interval := 5  ; Add a separator after every 5 items
for index, char in specialChars
{
    Menu, moreSymbols, Add, Insert Symbol >>     %char%, SendSymbol
    if Mod(index, interval) = 0  ; Every 5 items, add a separator
        Menu, moreSymbols, Add  ; Creates a separator line
}
;--------------------------------------------------
symbols3 := ["♪", "♫", "♬", "♣", "♦", "♥", "♠","☥", "Ϟ", "♆", "⚚", "𓆙", "𐰔", "𓃠", "𓂀", "𓃗", "𓆣", "⌖", "‡", "†", "⏚", "ᛞ", "ᚦ", "⌕", "🖫", "⇆", "♂", "♀", "⚐", "⎆", "⎈", "⎊", "␦"]
syline := 5
for index, char in symbols3
{
    Menu, symbols3, Add, Insert Symbol >>     %char%, SendSymbol
    if Mod(index, syline) = 0  ; Every 5 items, add a separator
        Menu, symbols3, Add  ; Creates a separator line
}
;--------------------------------------------------
greekchars := ["Γ", "Δ", "Θ", "Λ", "Ξ", "Π", "Σ", "Φ", "Ψ", "Ω", "α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ", "ν", "ξ", "ξ", "π", "ρ", "ς", "σ", "τ", "υ", "φ", "χ", "ψ", "ω"]
for index, char in greekchars
{
    Menu, greek, Add, Insert Symbol >>     %char%, SendSymbol
    if (char = "Ω")  ; After Ω, add a separator
        Menu, greek, Add  ; Creates a separator line
}
;--------------------------------------------------
RomanN1 := [ "ⅰ", "ⅱ", "ⅲ", "ⅳ", "ⅴ", "ⅵ", "ⅶ", "ⅷ", "ⅸ", "ⅹ", "ⅺ", "ⅻ", "ⅼ", "ⅽ", "ⅾ", "ⅿ"]
; romanline := 16  ; Add a separator after the 16th character

for index, char in RomanN1
{
    Menu, romanl, Add, Insert Symbol >>     %char%, SendSymbol
}
RomanN2 := ["Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ", "Ⅺ", "Ⅻ", "Ⅼ", "Ⅽ", "Ⅾ", "Ⅿ"]
for index, char in RomanN2
{
    Menu, romanu, Add, Insert Symbol >>     %char%, SendSymbol
}
;--------------------------------------------------
runechar := ["ᚠ", "ᚢ", "ᚦ", "ᚬ", "ᚱ", "ᚲ", "ᚷ", "ᚹ", "ᚺ", "ᚾ", "ᛁ", "ᛃ", "ᛇ", "ᛈ", "ᛉ", "ᛋ", "ᛏ", "ᛒ", "ᛖ", "ᛗ", "ᛚ", "ᛦ", "ᛧ", "ᛨ"]
for index, char in runechar
	menu, rune, add, Insert Rune >>      %char%, sendrune


;;∙======∙Menu, HEADERS∙=======================================∙


menu, inssym, add, Insert Symbols Menu`t%showinsertsymbolsmenu%, showinsertsymbolsmenu
menu, inssym, icon, Insert Symbols Menu`t%showinsertsymbolsmenu%, %icons%\emoji-symbols media play stop_256x256.ico,,28
menu, inssym, add, ; line -------------------------
Menu, InsSym, Add, Bullets   ▣ ● ⪧, :Bullet
Menu, InsSym, Add, Stars   ✶ ☆ ✹, :Stars
Menu, InsSym, Add, Symbols Set1   ≠ © ÷, :Symbols
menu, insSym, add, Symbols Set2  ⊞ ¢ ∞, :moreSymbols
menu, insSym, add, Symbols Set3  🖫 ␦ ♬, :symbols3
menu, inssym, Add
; Menu, InsSym, Add, Arrows   ⮘ ⬇ ⮚ , showinsertsymbolsmenu
menu, inssym, Add, Arrows   🡱 Up 🡳 Down, :UpDownArrow
menu, inssym, Add, Arrows   🡰 Left 🡲 Right, :LeftRightArrow
menu, inssym, Add, Arrows   Bi 🡙 && 🡘, :BiDirectionala
menu, inssym, Add, Arrows   Diagonal 🡴 Up, :DiagUpArrow
menu, inssym, Add, Arrows   Diagonal 🡶 Down, :DiagDownArrow
menu, inssym, Add, Arrows   Circular ↩ ↻, :CircularArrow
menu, inssym, Add
menu, inssym, add, Runes   ᚠ ᛋ ᛦ, :rune
menu, inssym, add, Greek   φ Ψ θ, :greek
menu, Inssym, add, Roman Numerals Upper Ⅳ Ⅻ, :romanu
menu, Inssym, add, Roman Numerals Lower ⅳ ⅻ, :romanl

;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


Menu, i, add, < --- Insert Text Menu --- >`t%showinsertmenu%, showinsertmenu
Menu, i, icon, < --- Insert Text Menu --- >`t%showinsertmenu%, %icons%\insert-text_48x48.ico,,32



Menu, i, add, ; line -------------------------
if FileExist(snipdir)
{
	gosub BuildSnippetFolderMenu
Menu, i, add, Snippets Folder Menu (Live) >>>>`t%ShowSnippetFolderMenu%, :%sf% ;; gosub BuildSnippetFolderMenu

Menu, i, icon, Snippets Folder Menu (Live) >>>>`t%ShowSnippetFolderMenu%, %Icons%\edit code bliss_64x64.ico,,24
}
gosub buildClipboardMenu
menu, i, add, Clipboard Menu (Live)`t%ShowClipboardMenu%, :c
menu, i, icon, Clipboard Menu (Live)`t%ShowClipboardMenu%, %icons%\checkclipboard.ico,,24

Menu, i, add, ; line -------------------------



dtmenurefresh()
Menu, i, add, Date && Time`t%showdtmenu%, :dtmenu
Menu, i, icon, Date && Time`t%showdtmenu%, %Icons%\clock SHELL32_16771 256x256.ico,,24
Menu, i, add, ; line -------------------------
Menu, i, add, Insert Symbols  ᚠΞ☉•彡🡲෴`t%showinsertsymbolsmenu%, :InsSym
Menu, i, icon, Insert Symbols  ᚠΞ☉•彡🡲෴`t%showinsertsymbolsmenu%, %icons%\emoji-symbols media play stop_256x256.ico,,24
Menu, i, Add, Windows Emoji Keyboard`t⊞>, OpenEmojiKeyboard
Menu, i, icon, Windows Emoji Keyboard`t⊞>, %Icons%\emoji face smilesvg_36x36.ico,,24

return

;///////////////////////////////////////////////////////////////////////////
;--------------------------------------------------------------------------- 

;---------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////

ShowSnippetFolderMenu:
if (GetKeyState("Control", "P") && GetKeyState("Shift", "P"))
	{
		run %texteditor% "%A_LineFile%"
		return
	}
; sf = %snipdir%
gosub BuildSnippetFolderMenu
menu, %sf%, show
return

BuildSnippetFolderMenu:
; global active_id
WinGet, active_id, ID, A  ;; Save the currently active window
; WinActivate, ahk_id %active_id%
sf = %snipdir%

if !FileExist(sf)
	{
		tooltip ERR! This folder cannot be found.`n@ Line#:  %A_LineNumber%
		sleep 2000
		tooltip
		Menu, %sf%, Add
		return
	}
Menu, %sf%, Add
Menu, %sf%, deleteall
;---------------------------------------------------------------------------
LastMenu := sf


menu, %sf%, add, Live Snippets Menu - Click a file to paste.`t%ShowSnippetFolderMenu%, ShowSnippetFolderMenu
menu, %sf%, icon, Live Snippets Menu - Click a file to paste.`t%ShowSnippetFolderMenu%, %Icons%\edit code bliss_64x64.ico,,28
menu, %sf%, Default, Live Snippets Menu - Click a file to paste.`t%ShowSnippetFolderMenu%
menu, %sf%, Add, ; line -------------------------


Loop, %sf%\*.*, 2,1	; add folders first, Recurse into subfolders.
{
	If InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "S")
		Continue 

	StringGetPos, pos, A_LoopFileLongPath, \, R
	if (pos <> -1) ; it has a parent
		StringLeft, ParentFolderDirectory, A_LoopFileLongPath, %pos%
	if (pos = -1) ; it has no parent 
		ParentFolderDirectory := rootdir
		; ParentFolderDirectory := folder

	Menu, %A_LoopFileLongPath%, add
	Menu, %A_LoopFileLongPath%, deleteall
	
	
	Menu, %A_LoopFileLongPath%, add, Open - %A_LoopFileName% - Folder, OpenSnipHeader
	IconPath := GetFileIcon(A_LoopFileFullPath)
	Menu, %A_LoopFileLongPath%, icon, Open - %A_LoopFileName% - Folder, %iconpath%
	if (iconpath = "")
		Menu, %A_LoopFileLongPath%, icon, Open - %A_LoopFileName% - Folder, %dopus%
		
	Menu, %A_LoopFileLongPath%, add, ; line -------------------------

	Menu, %A_LoopFileDir%, Add, %A_LoopFileName% , Snipmenuaction
	IconPath := GetFileIcon(A_LoopFileFullPath)
	Menu, %A_LoopFileDir%, Icon, %A_LoopFileName%, %IconPath%
	
	If (A_LoopFileDir != LastMenu) and (LastMenu != sf)
	{ 
		; MsgBox %sf% %LastMenu%
		AddMenu(LastMenu)
	}
	LastMenu := A_LoopFileDir ; Save menu name
}
menu, %sf%, add, ; line -------------------------

Loop, %sf%\*.*, 0, 1 ;; add files below folder
{
	If InStr(A_LoopFileAttrib, "H") or InStr(A_LoopFileAttrib, "S")  || InStr(A_LoopFileExt, "exe") ; or InStr(A_LoopFileExt, "ico") or InStr(A_LoopFileExt, "png") or InStr(A_LoopFileExt, "psd") or InStr(A_LoopFileExt, "old")	or InStr(A_LoopFileExt, "jpeg") or InStr(A_LoopFileExt, "bak")
		Continue 
		
		Menu, %A_LoopFileDir%, Add, %A_LoopFileName% , Snipmenuaction
		IconPath := GetFileIcon(A_LoopFileFullPath)
		Menu, %A_LoopFileDir%, Icon, %A_LoopFileName%, %IconPath%	
	
		; If (A_LoopFileExt = "ahk" || A_LoopFileExt = "txt") 
		; {	
			; this is is an option that only show .ahk and .txt file, which i mostly prefer. if shared i should leave it open
		; Menu, %A_LoopFileDir%, Add, %A_LoopFileName% , Snipmenuaction
		; IconPath := GetFileIcon(A_LoopFileFullPath)
		; Menu, %A_LoopFileDir%, Icon, %A_LoopFileName%, %IconPath%
		
		If (A_LoopFileDir != LastMenu) and (LastMenu != sf)
		{
			; MsgBox %sf% %LastMenu%
			AddMenu(LastMenu)
		}
		LastMenu := A_LoopFileDir ; Save menu name
		; }
}
   
Menu, %sf%, Add, ;line ;-------------------------  
Menu, %sf%, Add, ;line ;------------------------- 
menu, %sf%, add, Save Selection + New Snippet, addsnip
menu, %sf%, icon, Save Selection + New Snippet, %icons%\newsnipclip.ico
menu, %sf%, add, Open Snippets Folder, opensnipfolder
Menu, %sf%, icon, Open Snippets Folder, %icons%\newsnipfolder.ico
Menu, %sf%, Add, ;line ;------------------------- 
menu, %sf%, Add, ?? Mods: ^Edit`, +Copy`, ^+Run`, ⊞^Append`, ⊞+Delete, aboutsnipsmsgbox
menu, %sf%, icon, ?? Mods: ^Edit`, +Copy`, ^+Run`, ⊞^Append`, ⊞+Delete, %icons%\about.ico


AddMenu(LastMenu)
; Menu, %sf%, Show
Return

;**************************************************************************
;**************************************************************************
Snipmenuaction:
snipfile := A_thismenuitem
fullsnippath := A_thisMenu "\" A_thismenuitem
; splitpath, fullsnippath,,,ext

if (GetKeyState("Control", "P") && GetKeyState("shift", "P")) ;; run the snippet
	{
		try run, "%A_thismenu%\%A_ThisMenuItem%"
		return
	}
if (GetKeyState("Lwin", "P") && GetKeyState("control", "P")) ;; append selection to another snippet
	{
		sleep 350 ; give time to let the window underneath the menu reactivate 
		copyclipboardclm()
		addsnip:=clipboard
		RestoreClipboard()
		sleep 300
		; MsgBox %fullsnippath%`n`n%addsnip%
		FileAppend,`n`n%addsnip%,%fullsnippath%
		sleep 200
		if !ErrorLevel
			{
				tooltip Snip added to ...`n`n  %snipfile%
				SetTimer, RemoveToolTip, -1500
			}
		sleep 250
		addsnip:=""
		return
	}
if (GetKeyState("Lwin", "P") && GetKeyState("Shift", "P")) ;; delete snippet
	{
		MsgBox, 4132, Delete Snippet?, Do you want to delete`n`n   %snipfile%`n`nto the Recycle Bin?
		IfMsgBox No
			Return
		FileRecycle, %fullsnippath%
		return
	}
if (GetKeyState("Control", "p")) ;; edit the snippet
	{
		Run %texteditor% "%fullsnippath%"
		return
	}
if (GetKeyState("Shift", "P")) ;; Copy snippet to Clipboard, doesn't auto paste
	{
		Clipboard =
		sleep 75
		fileread, sniptoclipboard,%fullsnippath%
		sleep 100
		clipboard := sniptoclipboard
		clipwait,0.5
		if (clipboard != "")
			{
			tooltip Copied to Clipboard...`n %A_thismenuitem%
			SetTimer, RemoveToolTip, -1500
			}
		return
	}
else ;; normal click, past the text text in the clicked snippet
	{
		WinActivate, ahk_id %active_id%
		sleep 150 ; give time to let the window underneath the menu reactivate 
		sniptopaste:=""
		backupclipboard()
		sleep 100
		fileread, sniptopaste, %fullsnippath%
		Clipboard:=sniptopaste
		ClipWait, 1
		if ErrorLevel
			{
				Tooltip, ERR! Fail to copy file to clipboard! `n @ Line#:  %A_LineNumber%`n %A_LineFile%
				SetTimer, RemoveToolTip, -2000
				RestoreClipboard()
				Return
			}
		; MsgBox, %sniptopaste%
		; sleep 150
		send ^v
		sleep 300
		RestoreClipboard()
		sleep 300
		sniptosend:=""
		; return
	}
snipfile := ""
fullsnippath := ""
return

addsnip:
WinActivate, ahk_id %active_id%
sleep 200 ; give time to let the window underneath the menu reactivate 
snipname:=""
copyclipboardclm()
if (ErrorLevel || Clipboard = "")
	{
		tooltip ERR! Failed To Copy Snippet!`n @ Line: %A_LineNumber%`n %A_LineFile%
		SetTimer, RemoveToolTip, -2000
		RestoreClipboard()
		sleep 300
		return
	}
newsnip:=Clipboard
RestoreClipboard()
sleep 300
FileSelectFile, Snipname, S, %snipdir%, Save As + Creating New Snippet
if (snipname = "")
	{
		Tooltip Cancel!`nA File Name is Required.
		SetTimer, RemoveToolTip, -1500
		return
	}
SplitPath, snipname,, , ext
if (ext = "")
   {
		if (A_Username = "CLOUDEN")
			snipname := snipname . ".ahk" 
		Else
			snipname := snipname . ".txt" 
	}
else
	snipname := snipname  ; Keep original filename with extension
; msgbox sd: %snipdir%`n`nsn: %snipname%`n`n%ext%
Fileappend,%newsnip%,%snipname%,utf-8
if !errorlevel
	{
		tooltip New Snippet Saved.
		SetTimer, RemoveToolTip, -1500
	}
newsnip:=""
snipname:=""
return

opensnipfolder:
run %snipdir% ; run %sf%
return

OpenSnipHeader:
run %A_ThisMenu%
return
aboutsnipsmsgbox:
MsgBox, 262144, - ECLM - ? About Live Snippets Menu, Snippet are Pre-Saved Text-Based* documents that you can use to quickly paste`, with a click`, to save yourself the time of repetitively typing them out.`n`nThis is a live & interactive folder menu linked the "Snippets" folder next to this app.`n`nDepending on your office environment or coding language these can vary wildly so this menu\folder is ment to be populated by you.`n`nOpen an empty Text Editor or Notepad and click ...`nOpen Notepad && Click this file to learn about Snippets!.txt`n... it will be pasted into the editor where you can read more.`n`n-------------------------`n`nYou can interact with the files in this folder menu by holding done Modifier keys when clicking a item. The key at the bottom of the menu is a guide.`n`nAutoHotkey's Abbreviations for the Modifier keys are...`n`n^ = Ctrl `, + = Shift `, # ⊞ = Windows Key`n`n`n^Ctrl & Click`nwill open the snippet in your text editor or notepad for editing.`n`n+Shift & Click`nwill copy the text to your Clipboard so can paste it yourself.`n`n^Ctrl & ⊞Windows Key & Click`nwill copy select text to Add\Append it to bottom of the snippet.`n`n+Shift & ⊞Windows Key`nClick will Delete a Snippet to the Recycle Bin.`n`n^Ctrl & +Shift & Click`nwill RUN a snippet.`n`n

return



aboutsnips:

snipinfo := " ;"
(

Click this file to paste a Snippet about Snippets

;--------------------------------------------------
??? What are snippets?
;--------------------------------------------------

Snippet are Pre-Saved Text Based* documents that you can
use to quickly paste, with a click, to save yourself the
time of repetitively typing them out.


;**************************************************
??? Who will find them useful?
;**************************************************

Anyone who does a lot of monotonous typing computer work!

e.g. Something simple, I use a dozen+ times a day..
if ErrorLevel
	{
		Tooltip, ERROR!``n @ Line#:  ``%A_LineNumber``%``n ``%A_LineFile``%
		SetTimer, RemoveToolTip, -2000
		Return
	}

Or this can be Standard reply phrase or Full Letter ...
( such as this one )

Most people working in a computer driven environments
where emails, documents, invoices, reports, logs, etc.,
are large part of your workflow... e.g. Customer Relations, HR,
PR, Secretaries, Receptions, DRs, etc., Can benefit from this menu.

Don't type out the stock reply outline again and again and.... again.
Just click and paste!

Most coders, Programmers, Developers, IT Techs, and so on,
are likely already familiar with and using some form of snippets.

And there are many automation application for these
kinds of text macro out there. Soo..

;**************************************************
??? What makes this Snippet Menu stand out?
;**************************************************

This is a *Live* Menu! Its linked to 'Snippets' folder next this app.
Any files inside that directory will show up in the menu, in realtime.

Just click the file to paste the text inside of it
into any window that has text field with a blinking cursor.

Copy your own text based* documents inside of it to
have them instantly available for production.

+++ Additionally, You can create new snippets using the menu, on the fly!
Selected some text, click the 'Save Selection + New Snippet' menu item.
It will copy it and save it to a new file inside the Snippets Folder,
ask you to crate a file name.
Which you can use to paste else where seconds later!

Its that simple.

;**************************************************
??? How to use this live snippet menu?
;**************************************************

As already stated, just click a file to paste the text content inside of it.

Holding down Modifier Keys while clicking on a snippet \ menu item
will carry out different actions on that file.

The key on the bottom of the menu is reminder guide,
they are AutoHotkey's abbreviated
symbols for Modifier Keys on your keyboard.

^ = Ctrl , + = Shift , ⊞ = Windows Key
( The ! = Alt key can't be use on menus, only hotkeys. )

^Ctrl & Click
will open the snippet in your text editor or notepad for editing.

+Shift & Click
will copy the text to your Clipboard so can paste it yourself.

^Ctrl & ⊞Windows Key & Click
will copy select text to Add\Append it to bottom of the snippet.

+Shift & ⊞Windows Key
Click will Delete a Snippet to the Recycle Bin.

^Ctrl & +Shift & Click
will RUN a snippet.
( This options mostly for coders who keep automation scripts in snippets )

To organize the menu open the Snippet directory then
create and rearrange a folder structure that benefits your workflow.
The menu will update to reflect your layout.


;**************************************************
* ! Footnotes ! *
;**************************************************

*Text Based documents should be used in this menu.
Pretty much anything you can open in Notepad++ is good to go!


**MS Office documents are not Standard text based computer documents!
You can paste text INTO an Office app but 
you cannot paste the text OUT of Office document.
They will *NOT* work from this menu.

The hotkey for this menu is Ctrl + Insert or ^Insert.
You can change it in the ini file if you'd a different key combo.

)" 


; Fileappend,%snipinfo%,%aboutsnipsfile%,utf-8
; sleep 750
return

;"
;///////////////////////////////////////////////////////////////////////////
;--------------------------------------------------------------------------- 
; " 
;---------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////

ShowClipboardMenu:
gosub buildClipboardMenu
menu, c, show
menu, c, deleteall  ; Clear the menu after showing 
return

buildClipboardMenu:
    menu, c, add
    menu, c, deleteall  ; Clear the menu before rebuilding
    
    menu, c, add, Clipboard Menu%showclipboardmenu%, showclipboardmenu
    menu, c, icon, Clipboard Menu%showclipboardmenu%, %icons%\checkclipboard.ico,,32
    menu, c, default, Clipboard Menu%showclipboardmenu%
    menu, c, add, ; line -------------------------

    if (Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$"))
    {
        menu, c, add, Clipboard is empty or has no text, DoNothing
        menu, c, icon, Clipboard is empty or has no text, %iconerror%,,32
        menu, c, default, Clipboard is empty or has no text
        return
    }

    paths := Clipboard  ; Use existing clipboard content
    countFiles := 0
    countText := 0
    totalLines := 0
    foundValidPath := false
    validPaths := ""  ; Store valid file paths
    RawText := false
    PathTooLong := false

    if (MaxClipboardLines = "" || MaxClipboardLines = 0)
        MaxClipboardLines := 50
    
    ; First pass - count total lines to know what we're dealing with
    totalLines := 0
    Loop, Parse, paths, `n, `r
    {
        totalLines++
    }
    
    ; Process file paths first
    Loop, Parse, paths, `n, `r
    {
        path := Trim(A_LoopField)
        if (path = "" || countFiles >= MaxClipboardLines)  ; Ignore empty lines, limit to 50 items
            continue
            
        if (SubStr(path, 1, 2) = "/*")  ; Ignore lines that start with /*
            continue

        if FileExist(path)  ; Check if the path exists
        {
            if (StrLen(path) > 250)  
            {
                SplitPath, path, fileName,,ext,namestem,drive
                path := "**  " drive "\..\..\" filename 
                PathTooLong := true
            }
                
            menu, c, add, %path%, ClipboardMenuFileActions
            iconpath := Getfileicon(path)
            menu, c, icon, %path%, %iconpath%
            
            validPaths .= path "`r`n"   ; Store for bulk copy
            
            countFiles++
            foundValidPath := true
            
            if (countFiles >= MaxClipboardLines)
                break
        }
    } 

    if (foundValidPath)
    {
        If (PathTooLong)
        {
            menu, c, add, ; line -------------------------
            Menu, c, add, ** <- Error! "\..\..\" These paths are too long for the menu to display!, ShowClipboardMenu
            Menu, c, icon, ** <- Error! "\..\..\" These paths are too long for the menu to display!, %iconerror%,,24
            menu, c, Default,  ** <- Error! "\..\..\" These paths are too long for the menu to display!
            PathTooLong := false
        }

        menu, c, add, ; line -------------------------
        menu, c, add, 🡱 Existing Folders\Files 🡱 - (?? Mod-Click Options)`tFile Count: %countFiles%, aboutclipfiles
        menu, c, icon, 🡱 Existing Folders\Files 🡱 - (?? Mod-Click Options)`tFile Count: %countFiles%, %icons%\documents multimedia imageres_5334_256x256.ico,,24
		; menu, c, add,  Click=Run`, ^Open In File Manager`, ^+Copy to Clipboard`, ⊞+Clip Extract Existing List 🡱`tFile Count: %countFiles%, showclipboardmenu
		; menu, c, icon,  Click=Run`, ^Open In File Manager`, ^+Copy to Clipboard`, ⊞+Clip Extract Existing List 🡱`tFile Count: %countFiles%, %icons%\about.ico
    }

    ; First check if there's any non-file text to display
    textLineCount := 0
    Loop, Parse, paths, `n, `r
    {
        line := Trim(A_LoopField)
        if (line = "")
            continue

        if !FileExist(line)  ; It's plain text, not a file
            textLineCount++
    }

    ; Only proceed with text section if we found text lines
    if (textLineCount > 0)
    {
        textIcon := icons "\paint_text_32x32.ico"
        menu, c, add, ; line -------------------------
        menu, c, add, 🡳 Plain Text Per-Line. 🡳   - Click to Paste\Insert a Single Line 🡳`tLine Count: %textLineCount%, ShowClipboardMenu
        menu, c, icon, 🡳 Plain Text Per-Line. 🡳   - Click to Paste\Insert a Single Line 🡳`tLine Count: %textLineCount%, %icons%\ToolAdd line document_32x32.ico,,28
        menu, c, add, ; line -------------------------
        
        ; Reset counter for the actual menu addition
        addedTextLines := 0
        
        Loop, Parse, paths, `n, `r
        {
            line := Trim(A_LoopField)
            if (line = "")
                continue

            if !FileExist(line)  ; Ensure it's plain text, not a file
            {
                ; Limit text lines to remaining slots in MaxClipboardLines
                if (addedTextLines >= (MaxClipboardLines - countFiles))
                    break
                    
                if (StrLen(line) > 240)  ; Trim long lines
                    line := SubStr(line, 1, 240) . "..."

                menu, c, add, %line%, PasteClipboardText
                menu, c, icon, %line%, %textIcon%
                    
                addedTextLines++
                RawText := True
            }
        }
    }

    menu, c, add, ; line -------------------------
    menu, c, add, Save Clipboard to New Text Document`t%SaveClipboardAsTxt%, SaveClipboardAsTxt
    menu, c, icon, Save Clipboard to New Text Document`t%SaveClipboardAsTxt%, %Icons%\clipboard save b_xedit_48x48.ico
    menu, c, add, View Clipboard Text`t%viewclip%, viewclip
    menu, c, icon, View Clipboard Text`t%viewclip%, %Icons%\QAP-preview_pane_c_26x26.ico
    menu, c, add, Clear the Clipboard`t%clearclip%, clearclip
    menu, c, icon, Clear the Clipboard`t%clearclip%, %icons%\clean_clear_clipboard_empty_xedit3_32x32.ico
    
    ; Add a note if we had to limit items due to MaxClipboardLines
    ; if (textLineCount > MaxClipboardLines)
    ; {
        ; menu, c, add, ; line -------------------------
        ; menu, c, add, ** Note: Clipboard has %totalLines% lines, only showing %MaxClipboardLines% items **, ShowClipboardMenu
        ; menu, c, icon, ** Note: Clipboard has %totalLines% lines, only showing %MaxClipboardLines% items **, %iconerror%,,24
    ; }
return

/*

 buildClipboardMenu:
	menu, c, add
    menu, c, deleteall  ; Clear the menu before rebuilding
	
    menu, c, add, Clipboard Menu`t%showclipboardmenu%, showclipboardmenu
    menu, c, icon, Clipboard Menu`t%showclipboardmenu%, %icons%\checkclipboard.ico,,32
	menu, c, default, Clipboard Menu`t%showclipboardmenu%
	menu, c, add, ; line -------------------------

    ; if (clipboard = "")  
	if (Clipboard = "" || Clipboard = A_Tab || RegExMatch(Clipboard, "^\s+$"))
    {
        menu, c, add, Clipboard is empty or has no text, DoNothing
        menu, c, icon, Clipboard is empty or has no text, %iconerror%,,32
        menu, c, default, Clipboard is empty or has no text
        return
    }

	paths := Clipboard  ; Use existing clipboard content
    countFiles := 0
    countText := 0
    foundValidPath := false
	validPaths := ""  ; Store valid file paths
	RawText := false
	PathTooLong := false

	if (MaxClipboardLines = "" || MaxClipboardLines = 0)
		MaxClipboardLines := 50
    
	    ; First pass - count total lines to know what we're dealing with
    ; totalLines := 0
    ; Loop, Parse, paths, `n, `r
    ; {
        ; totalLines++
    ; }
	
	Loop, Parse, paths, `n, `r ; --- Process file paths first --- ; this matching file paths one Per-Line, hold shows them if they exist on the computer
    {
        path := Trim(A_LoopField)
        if (path = "" || countFiles >= MaxClipboardLines)  ; Ignore empty lines, limit to 50 items
            continue
			
		if (SubStr(path, 1, 2) = "/*")  ; Ignore lines that start with /*
        continue

        if FileExist(path)  ; Check if the path exists
        {
			if (StrLen(path) > 250)  
			{
				; Menu, c, UseErrorLevel, 1 ; Reset user errorlevel
				SplitPath, path, fileName,,ext,namestem,drive
				path := "**  " drive "\..\..\" filename 
				PathTooLong := true
			}
				; Menu, c, UseErrorLevel, 0 ; Reset user errorlevel
            menu, c, add, %path%, ClipboardMenuFileActions
            iconpath := Getfileicon(path)
            menu, c, icon, %path%, %iconpath%
			
			
			validPaths .= path "`r`n"   ; Store for bulk copy
			
            countFiles++
            foundValidPath := true
        }

    } 

    if (foundValidPath)
        {
			If (PathTooLong)
				{
					menu, c, add, ; line -------------------------
					Menu, c, add, ** <- Error! "\..\..\" These paths are too long for the menu to display!, ShowClipboardMenu
					Menu, c, icon, ** <- Error! "\..\..\" These paths are too long for the menu to display!, %iconerror%,,24
					menu, c, Default,  ** <- Error! "\..\..\" These paths are too long for the menu to display!
					PathTooLong := false
				}

			menu, c, add, ; line -------------------------
			menu, c, add, 🡱 Existing Folders\Files 🡱 - (?? Mod-Click Options)`tFile Count: %countFiles%, aboutclipfiles
			menu, c, icon, 🡱 Existing Folders\Files 🡱 - (?? Mod-Click Options)`tFile Count: %countFiles%, %icons%\documents multimedia imageres_5334_256x256.ico,,24
			; menu, c, add,  Click=Run`, ^Open In File Manager`, ^+Copy to Clipboard`, ⊞+Clip Extract Existing List 🡱`tFile Count: %countFiles%, showclipboardmenu
			; menu, c, icon,  Click=Run`, ^Open In File Manager`, ^+Copy to Clipboard`, ⊞+Clip Extract Existing List 🡱`tFile Count: %countFiles%, %icons%\about.ico ; gpt, leave this line alone

		}
;---------------------------------------------------------------------------
 ; First check if there's any non-file text to display
    ; textLineCount := 0

; Second Pass: Process Raw Text
 Loop, Parse, paths, `n, `r
    { ;; this loop first checks for raw text, the lower adds it to the menu with its own heading. otherwise it will always show even if the clipboard only contains files.
        line := Trim(A_LoopField)
        ; if (line = "" || countText >= MaxClipboardLines)
        if (line = "")
            continue

        if !FileExist(line)  ; Ensure it's plain text, not a file
        {
            countText++
			rawtext := True
        }
    }

if (RawText)
{
    textIcon := icons "\paint_text_32x32.ico"
	menu, c, add, ; line -------------------------
	menu, c, add, 🡳 Plain Text Per-Line. 🡳   - Click to Paste\Insert a Single Line 🡳`tLine Count: %counttext%, ShowClipboardMenu
	menu, c, icon, 🡳 Plain Text Per-Line. 🡳   - Click to Paste\Insert a Single Line 🡳`tLine Count: %counttext%, %icons%\ToolAdd line document_32x32.ico,,28
	menu, c, add, ; line -------------------------
	
    Loop, Parse, paths, `n, `r ; --- Process text lines separately ---
    {
        line := Trim(A_LoopField)
        if (line = "" || countText >= MaxClipboardLines)
            continue

        if !FileExist(line)  ; Ensure it's plain text, not a file
        {
            if (StrLen(line) > 240)  ; Trim long lines
                line := SubStr(line, 1, 240) . "..."

            menu, c, add, %line%, PasteClipboardText
            menu, c, icon, %line%, %textIcon%
				
            countText++
			rawtext := True
        }
    }
} 


;---------------------------------------------------------------------------

; if (rawtext = True)
	; {
			; can't think of any to put here to process raw text on its own?
	
	; }
menu, c, add, ; line -------------------------
menu, c, add, Save Clipboard to New Text Document`t%SaveClipboardAsTxt%, SaveClipboardAsTxt
menu, c, icon, Save Clipboard to New Text Document`t%SaveClipboardAsTxt%, %Icons%\clipboard save b_xedit_48x48.ico
menu, c, add, View Clipboard Text`t%viewclip%, viewclip
menu, c, icon, View Clipboard Text`t%viewclip%, %Icons%\QAP-preview_pane_c_26x26.ico
menu, c, add, Clear the Clipboard`t%clearclip%, clearclip
menu, c, icon, Clear the Clipboard`t%clearclip%, %icons%\clean_clear_clipboard_empty_xedit3_32x32.ico
return 

*/


PasteClipboardText:
    ClipSaved := ClipboardAll  ; Save current clipboard
	sleep 100
    Clipboard := A_ThisMenuItem  ; Set selected menu text
	sleep 100
    Send, ^v  ; Paste
    Sleep 100
    Clipboard := ClipSaved  ; Restore clipboard
	sleep 500
return

ClipboardMenuFileActions:
splitpath, A_ThisMenuItem, filename, dir, ext
; MsgBox athisMI: %A_thismenuitem%`n`nfn: %filename%`n`ndir:  %dir%`n`next:  %ext%`n`ndispalpath:  %displaypath%
if (GetKeyState("Control", "P") && GetKeyState("Shift", "P"))
	{
		clipboard =
		sleep 30
		if FileExist(dopusrt)
		{
			Run, %dopusrt% /CMD Clipboard COPY FILE "%A_ThisMenuItem%", , UseErrorLevel
			ToolTip, %A_ThisMenuItem% ...`n... copied to your Clipboard with Directory Opus!
			SetTimer, RemoveToolTip, -2500
			return
		}
		else
		{
			CopyToClipboard(A_ThisMenuItem)
			ToolTip, %A_ThisMenuItem% ...`n... copied to your Clipboard.
			SetTimer, RemoveToolTip, -2000
		}
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
		Clipboard := RTrim(validPaths, "`r`n")  ; Copy all existing paths to clipboard
		tooltip, All Valid Files Paths have been`ncopied to your clipboard.
		SetTimer, RemoveToolTip, -2000
		return
	}
if (GetKeyState("Control", "P"))
	{
		try Run, %dopusrt% /cmd Go "%A_ThisMenuItem%" NEWTAB TOFRONT
		catch
			Run explorer.exe /select`,"%A_ThisMenuItem%"
		SetTimer, RemoveToolTip, -2000
		return
	}
if (GetKeyState("Shift", "P"))
	{

	}
else ;; normal click
	{

		Run, %A_ThisMenuItem%,,UseErrorLevel
		if ErrorLevel
		{
			run, C:\Windows\System32\OpenWith.exe "%A_ThisMenuItem%"
			Tooltip, ERR!`n`n Couldn't Run This File!`n @ Line#:  %A_LineNumber%`n %A_LineFile%
			SetTimer, RemoveToolTip, -3000
			; Return
		}

	}
return 

CopyValidAllFiles:
Clipboard := RTrim(validPaths, "`r`n")  ; Copy all paths to clipboard
return

CopyToClipboard(ItemPath)
{
    if !FileExist(ItemPath)
        return  ; Safety check, but shouldn't trigger since paths exist in the menu

    clipboardData := ComObjCreate("Shell.Application").Namespace(0) ; Create an object for clipboard operations

    fileObj := clipboardData.ParseName(ItemPath)  ; Get the file object
    
    if !fileObj
        return  ; In case something goes wrong

    fileObj.InvokeVerb("Copy")  ; Copy to clipboard
}


aboutclipfiles:
MsgBox, 262176, ECLM - ?? About Live Clipboard Files, Holding down the modifier keys when clicking on a file will carry out different actions. The there a reminder guide on the menu. The Modifer keys symbols are`n`n ^ = Ctrl `, + = Shift `, ⊞ = Windows Key`n`nCtrl + Shift = will copy the actually file to you clipboard from the list.`n`nWin + Shift = will extract & Copy the text paths of all existing found on your clipboard.`n`nCtrl = will open that files folder in your file manager`n`nA regular click will run\open the file in it default handler.`n

return

;///////////////////////////////////////////////////////////////////////////
;--------------------------------------------------------------------------- 


;---------------------------------------------------------------------------
;///////////////////////////////////////////////////////////////////////////

;; insert menu labels
;---------------------------------------------------------------------------
OpenEmojiKeyboard() ;; function
{
    Send {LWin down}.
    Send {LWin up}
}

;---------------------------------------------------------------------------


;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
InsertSymbols:
Switch A_ThisMenuItem { 

;;∙======∙ARROWS∙============================================∙
;;-------∙Up Arrows∙-----------------------------------∙
    Case "Insert Arrow >>     ↑": 

        SendInput {Raw}↑

    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     ⬆": 

        SendInput {Raw}⬆

    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     ⇧": 
        SendInput {Raw}⇧
    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     ▲": 
        SendInput {Raw}▲
    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     △": 
        SendInput {Raw}△
    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     🡱": 
        SendInput {Raw}🡱
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⮙": 
        SendInput {Raw}⮙
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⮝": 
        SendInput {Raw}⮝
    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >> ∙    ⌃": 
        SendInput {Raw}⌃
    Return
;;-------∙Down Arrows∙-------------------------------∙
    Case "Insert Ar​row >>     ↓": 
        SendInput {Raw}↓
    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     ⬇": 
        SendInput {Raw}⬇
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇩": 
        SendInput {Raw}⇩
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ▼": 
        SendInput {Raw}▼
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ▽": 
        SendInput {Raw}▽
    Return
;;∙-----------------------------------------∙
    Case "Insert Arrow >>     🡳": 
        SendInput {Raw}🡳
    Return
;;∙-----------------------------------------∙
    Case "Insert Arr​ow >>     ⮛": 
        SendInput {Raw}⮛
    Return
;;∙-----------------------------------------∙
    Case "Insert Arr​ow >>     ⮟": 
        SendInput {Raw}⮟
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⌄": 
        SendInput {Raw}⌄
    Return
;;-------∙Left Arrows∙----------------------------------∙
    Case "Insert Ar​row >>     ←": 
        SendInput {Raw}←
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬅": 
        SendInput {Raw}⬅
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇦": 
        SendInput {Raw}⇦
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◀": 
        SendInput {Raw}◀
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◁": 
        SendInput {Raw}◁
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇒":
		SendInput {Raw}⇒
	Return
    Case "Insert Ar​row >>     ⇐": 
		SendInput {Raw}⇐
	Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     🡰": 
        SendInput {Raw}🡰
    Return
;;∙-----------------------------------------∙
    Case "Insert Arr​ow >>     ⮘": 
        SendInput {Raw}⮘
    Return
;;∙-----------------------------------------∙
    Case "Insert Arr​ow >>     ⮜": 
        SendInput {Raw}⮜
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⟪": 
        SendInput {Raw}⟪
    Return
;;-------∙Right Arrows∙--------------------------------∙○
    Case "Insert Ar​row >>     →": 
        SendInput {Raw}→
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ➞": 
        SendInput {Raw}➞
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇨": 
        SendInput {Raw}⇨
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ▶": 
        SendInput {Raw}▶
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ▷": 
        SendInput {Raw}▷
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     🡲": 
        SendInput {Raw}🡲
    Return
;;∙-----------------------------------------∙
    Case "Insert Arr​ow >>     ⮚": 
        SendInput {Raw}⮚
    Return
;;∙-----------------------------------------∙ 
    Case "Insert Ar​row >>     ⮞": 
        SendInput {Raw}⮞
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⏴": 
        SendInput {Raw}⏴
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⏵": 
        SendInput {Raw}⏵
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⟫": 
        SendInput {Raw}⟫
    Return
;;-------∙UpDown Arrows∙---------------------------∙
    Case "Insert Ar​row >>     ↕": 
        SendInput {Raw}↕
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬍": 
        SendInput {Raw}⬍
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇳": 
        SendInput {Raw}⇳
    Return
;;∙-----------------------------------------∙ 
    Case "Insert Ar​row >>     🡙": 
        SendInput {Raw}🡙
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇕": 
        SendInput {Raw}⇕
    Return
;;-------∙LeftRight Arrows∙---------------------------∙
    Case "Insert Ar​row >>     ↔": 
        SendInput {Raw}↔
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬌": 
        SendInput {Raw}⬌
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬄": 
        SendInput {Raw}⬄
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     🡘": 
        SendInput {Raw}🡘
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⇿": 
        SendInput {Raw}⇿
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⟷": 
        SendInput {Raw}⟷
    Return
;;-------∙UpLeft Arrows∙------------------------------∙
    Case "Insert Ar​row >>     ↖": 
        SendInput {Raw}↖
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬉": 
        SendInput {Raw}⬉
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬁": 
        SendInput {Raw}⬁
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◤": 
        SendInput {Raw}◤
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◸": 
        SendInput {Raw}◸
    Return
;;∙----------------------------------------∙
    Case "Insert Ar​row >>     🡴": 
        SendInput {Raw}🡴
    Return
;;-------∙UpRight Arrows∙----------------------------∙
    Case "Insert Ar​row >>     ↗": 
        SendInput {Raw}↗
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬈": 
        SendInput {Raw}⬈
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬀": 
        SendInput {Raw}⬀
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◥": 
        SendInput {Raw}◥
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◹": 
        SendInput {Raw}◹
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     🡵": 
        SendInput {Raw}🡵
    Return
;;-------∙DownRight Arrows∙------------------------∙
    Case "Insert Ar​row >>     ↘": 
        SendInput {Raw}↘
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬊": 
        SendInput {Raw}⬊
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬂": 
        SendInput {Raw}⬂
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◢": 
        SendInput {Raw}◢
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◿": 
        SendInput {Raw}◿
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     🡶": 
        SendInput {Raw}🡶
    Return
;;-------∙DownLeft Arrows∙--------------------------∙
    Case "Insert Ar​row >>     ↙": 
        SendInput {Raw}↙
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬋": 
        SendInput {Raw}⬋
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⬃": 
        SendInput {Raw}⬃
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◣": 
        SendInput {Raw}◣
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ◺": 
        SendInput {Raw}◺
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     🡷": 
        SendInput {Raw}🡷
    Return
;;-------∙Circular Arrows∙-----------------------------∙
    Case "Insert Ar​row >>     ↩": 
        SendInput {Raw}↩
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ↪": 
        SendInput {Raw}↪
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ↶": 
        SendInput {Raw}↶
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ↷": 
        SendInput {Raw}↷
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ↺": 
        SendInput {Raw}↺
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ↻": 
        SendInput {Raw}↻
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⥀": 
        SendInput {Raw}⥀
    Return
;;∙-----------------------------------------∙
    Case "Insert Ar​row >>     ⥁": 
        SendInput {Raw}⥁
    Return

;;∙======∙BULLETS∙=============================================∙
   Case "Insert Bullet >>     ◦": 
        SendInput {Raw}◦
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     •": 
        SendInput {Raw}•
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ○": 
        SendInput {Raw}○
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ●": 
        SendInput {Raw}●
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ▫": 
        SendInput {Raw}▫
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ▪": 
        SendInput {Raw}▪
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ☐": 
       SendInput {Raw}☐
   Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ■ ), CCase": 
       SendInput {Raw}■
   Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ◇": 
       SendInput {Raw}◇
   Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ◈": 
        SendInput {Raw}◈
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ◆": 
        SendInput {Raw}◆
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ✧": 
        SendInput {Raw}✧
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ✦": 
        SendInput {Raw}✦
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ▹": 
        SendInput {Raw}▹
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ▸": 
        SendInput {Raw}▸
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ⪧": 
        SendInput {Raw}⪧
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     🠺": 
        SendInput {Raw}🠺
   Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ▣": 
        SendInput {Raw}▣
    Return
;;∙-----------------------------------------∙
    Case "Insert Bullet >>     ⬢": 
        SendInput {Raw}⬢
    Return
    Case "Insert Bullet >>     ◯": 
        SendInput {Raw}◯
    Return
	    Case "Insert Bullet >>     ◎": 
        SendInput {Raw}◎
    Return
	    Case "Insert Bullet >>     ◉": 
        SendInput {Raw}◎
    Return
;;∙======∙STARS∙===============================================∙
    Case "Insert Star >>     ✶": 
        SendInput {Raw}✶
    Return
;;∙-----------------------------------------∙
    Case "Insert Star >>     ✹": 
        SendInput {Raw}✹
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ✸": 
        SendInput {Raw}✸
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ★": 
        SendInput {Raw}★
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ✦": 
        SendInput {Raw}✦
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ❊": 
        SendInput {Raw}❊
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ❈": 
        SendInput {Raw}❈
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ❋": 
        SendInput {Raw}❋
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ❉": 
        SendInput {Raw}❉
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ✺": 
        SendInput {Raw}✺
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ⛤": 
        SendInput {Raw}⛤
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ⚝": 
        SendInput {Raw}⚝
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ⛧": 
        SendInput {Raw}⛧
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ✰": 
        SendInput {Raw}✰
    Return
;;∙-----------------------------------------∙
Case "Insert Star >>     ☆": 
        SendInput {Raw}☆
    Return

;;∙======∙SYMBOLS∙============================================∙
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     °":  
        SendInput {Raw}°
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ÷": 
        SendInput {Raw}÷
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ⨯":  
        SendInput {Raw}⨯
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ±":  
        SendInput {Raw}±
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ≥":  
        SendInput {Raw}≥
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ≤":  
        SendInput {Raw}≤
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ≈":  
        SendInput {Raw}≈
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ∓":  
        SendInput {Raw}∓
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ➕":  
        SendInput {Raw}➕
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ➖":  
        SendInput {Raw}➖
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ✖️":  
        SendInput {Raw}✖️
    Return
;;∙-----------------------------------------∙
    Case "Insert  Symbol >>     ➗":  
        SendInput {Raw}➗
    Return
	
Case "Insert  Symbol >>     ∞":
SendInput {Raw}∞
Return
Case "Insert  Symbol >>     ⊞":
SendInput {Raw}⊞
Return
Case "Insert  Symbol >>     ©":
SendInput {Raw}©
Return
Case "Insert  Symbol >>     ®":
SendInput {Raw}®
Return
Case "Insert  Symbol >>     ™":
SendInput {Raw}™
Return
Case "Insert  Symbol >>     ≠":
SendInput {Raw}≠
Return
} 	 ; ⮘⮘ Keep this last curly bracket at the end of ALL Case Things! 
	
;---------------------------------------------------------------------------
SendSymbol:
    ; Extract only the last character from the menu item
    StringTrimLeft, symbol, A_ThisMenuItem, StrLen("Insert Symbol >>     ")
    SendInput {Raw}%symbol%
return

sendrune:
    ; Extract only the last character from the menu item
    StringTrimLeft, symbol, A_ThisMenuItem, StrLen("Insert Rune >>      ")
    SendInput {Raw}%symbol%
return
    ; SendInput {Raw}%A_ThisMenuItem%
    ; SendInput {Raw}%char%
; return
;---------------------------------------------------------------------------
showinsertsymbolsmenu:
menu, inssym, show
return

;---------------------------------------------------------------------------

;///////////////////////////////////////////////////////////////////////////
;--------------------------------------------------------------------------- 
















;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;
; Function: AddTooltip v2.0
;
; Description:
;
;   Add/Update tooltips to GUI controls.
;
; Parameters:
;
;   p1 - Handle to a GUI control.  Alternatively, set to "Activate" to enable
;       the tooltip control, "AutoPopDelay" to set the autopop delay time,
;       "Deactivate" to disable the tooltip control, or "Title" to set the
;       tooltip title.
;
;   p2 - If p1 contains the handle to a GUI control, this parameter should
;       contain the tooltip text.  Ex: "My tooltip".  Set to null to delete the
;       tooltip attached to the control.  If p1="AutoPopDelay", set to the
;       desired autopop delay time, in seconds.  Ex: 10.  Note: The maximum
;       autopop delay time is ~32 seconds.  If p1="Title", set to the title of
;       the tooltip.  Ex: "Bob's Tooltips".  Set to null to remove the tooltip
;       title.  See the *Title & Icon* section for more information.
;
;   p3 - Tooltip icon.  See the *Title & Icon* section for more information.
;
; Returns:
;
;   The handle to the tooltip control.
;
; Requirements:
;
;   AutoHotkey v1.1+ (all versions).
;
; Title & Icon:
;
;   To set the tooltip title, set the p1 parameter to "Title" and the p2
;   parameter to the desired tooltip title.  Ex: AddTooltip("Title","Bob's
;   Tooltips"). To remove the tooltip title, set the p2 parameter to null.  Ex:
;   AddTooltip("Title","").
;
;   The p3 parameter determines the icon to be displayed along with the title,
;   if any.  If not specified or if set to 0, no icon is shown.  To show a
;   standard icon, specify one of the standard icon identifiers.  See the
;   function's static variables for a list of possible values.  Ex:
;   AddTooltip("Title","My Title",4).  To show a custom icon, specify a handle
;   to an image (bitmap, cursor, or icon).  When a custom icon is specified, a
;   copy of the icon is created by the tooltip window so if needed, the original
;   icon can be destroyed any time after the title and icon are set.
;
;   Setting a tooltip title may not produce a desirable result in many cases.
;   The title (and icon if specified) will be shown on every tooltip that is
;   added by this function.
;
; Remarks:
;
;   The tooltip control is enabled by default.  There is no need to "Activate"
;   the tooltip control unless it has been previously "Deactivated".
;
;   This function returns the handle to the tooltip control so that, if needed,
;   additional actions can be performed on the Tooltip control outside of this
;   function.  Once created, this function reuses the same tooltip control.
;   If the tooltip control is destroyed outside of this function, subsequent
;   calls to this function will fail.
;
; Credit and History:
;
;   Original author: Superfraggle
;   * Post: <http://www.autohotkey.com/board/topic/27670-add-tooltips-to-controls/>
;
;   Updated to support Unicode: art
;   * Post: <http://www.autohotkey.com/board/topic/27670-add-tooltips-to-controls/page-2#entry431059>
;
;   Additional: jballi.
;   Bug fixes.  Added support for x64.  Removed Modify parameter.  Added
;   additional functionality, constants, and documentation.
;
;-------------------------------------------------------------------------------


AddTooltip(p1,p2:="",p3="")
    {
    Static hTT := ""

          ;-- Misc. constants
          ,CW_USEDEFAULT:=0x80000000
          ,HWND_DESKTOP :=0

          ;-- Tooltip delay time constants
          ,TTDT_AUTOPOP:=2
                ;-- Set the amount of time a tooltip window remains visible if
                ;   the pointer is stationary within a tool's bounding
                ;   rectangle.

          ;-- Tooltip styles
          ,TTS_ALWAYSTIP:=0x1
                ;-- Indicates that the tooltip control appears when the cursor
                ;   is on a tool, even if the tooltip control's owner window is
                ;   inactive.  Without this style, the tooltip appears only when
                ;   the tool's owner window is active.

          ,TTS_NOPREFIX:=0x2
                ;-- Prevents the system from stripping ampersand characters from
                ;   a string or terminating a string at a tab character.
                ;   Without this style, the system automatically strips
                ;   ampersand characters and terminates a string at the first
                ;   tab character.  This allows an application to use the same
                ;   string as both a menu item and as text in a tooltip control.

          ;-- TOOLINFO uFlags
          ,TTF_IDISHWND:=0x1
                ;-- Indicates that the uId member is the window handle to the
                ;   tool.  If this flag is not set, uId is the identifier of the
                ;   tool.

          ,TTF_SUBCLASS:=0x10
                ;-- Indicates that the tooltip control should subclass the
                ;   window for the tool in order to intercept messages, such
                ;   as WM_MOUSEMOVE.  If this flag is not used, use the
                ;   TTM_RELAYEVENT message to forward messages to the tooltip
                ;   control.  For a list of messages that a tooltip control
                ;   processes, see TTM_RELAYEVENT.

          ;-- Tooltip icons
          ,TTI_NONE         :=0
          ,TTI_INFO         :=1
          ,TTI_WARNING      :=2
          ,TTI_ERROR        :=3
          ,TTI_INFO_LARGE   :=4
          ,TTI_WARNING_LARGE:=5
          ,TTI_ERROR_LARGE  :=6

          ;-- Extended styles
          ,WS_EX_TOPMOST:=0x8

          ;-- Messages
          ,TTM_ACTIVATE      :=0x401                    ;-- WM_USER + 1
          ,TTM_ADDTOOLA      :=0x404                    ;-- WM_USER + 4
          ,TTM_ADDTOOLW      :=0x432                    ;-- WM_USER + 50
          ,TTM_DELTOOLA      :=0x405                    ;-- WM_USER + 5
          ,TTM_DELTOOLW      :=0x433                    ;-- WM_USER + 51
          ,TTM_GETTOOLINFOA  :=0x408                    ;-- WM_USER + 8
          ,TTM_GETTOOLINFOW  :=0x435                    ;-- WM_USER + 53
          ,TTM_SETDELAYTIME  :=0x403                    ;-- WM_USER + 3
          ,TTM_SETMAXTIPWIDTH:=0x418                    ;-- WM_USER + 24
          ,TTM_SETTITLEA     :=0x420                    ;-- WM_USER + 32
          ,TTM_SETTITLEW     :=0x421                    ;-- WM_USER + 33
          ,TTM_UPDATETIPTEXTA:=0x40C                    ;-- WM_USER + 12
          ,TTM_UPDATETIPTEXTW:=0x439                    ;-- WM_USER + 57

    ;-- Save/Set DetectHiddenWindows
    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    ;-- Tooltip control exists?
    if not hTT
        {
        ;-- Create Tooltip window
        hTT:=DllCall("CreateWindowEx"
            ,"UInt",WS_EX_TOPMOST                       ;-- dwExStyle
            ,"Str","TOOLTIPS_CLASS32"                   ;-- lpClassName
            ,"Ptr",0                                    ;-- lpWindowName
            ,"UInt",TTS_ALWAYSTIP|TTS_NOPREFIX          ;-- dwStyle
            ,"UInt",CW_USEDEFAULT                       ;-- x
            ,"UInt",CW_USEDEFAULT                       ;-- y
            ,"UInt",CW_USEDEFAULT                       ;-- nWidth
            ,"UInt",CW_USEDEFAULT                       ;-- nHeight
            ,"Ptr",HWND_DESKTOP                         ;-- hWndParent
            ,"Ptr",0                                    ;-- hMenu
            ,"Ptr",0                                    ;-- hInstance
            ,"Ptr",0                                    ;-- lpParam
            ,"Ptr")                                     ;-- Return type

        ;-- Disable visual style
        ;   Note: Uncomment the following to disable the visual style, i.e.
        ;   remove the window theme, from the tooltip control.  Since this
        ;   function only uses one tooltip control, all tooltips created by this
        ;   function will be affected.
; DllCall("uxtheme\SetWindowTheme","Ptr",hTT,"Ptr",0,"UIntP",0)

        ;-- Set the maximum width for the tooltip window
        ;   Note: This message makes multi-line tooltips possible
        ; SendMessage TTM_SETMAXTIPWIDTH,0,A_ScreenWidth,,ahk_id %hTT% ;; og
		SendMessage TTM_SETMAXTIPWIDTH,0,A_ScreenWidth*96//A_ScreenDPI,,ahk_id %hTT%  ; <--- was A_ScreenWidth
        }

    ;-- Other commands
    if p1 is not Integer
        {
        if (p1="Activate")
            SendMessage TTM_ACTIVATE,True,0,,ahk_id %hTT%

        if (p1="Deactivate")
            SendMessage TTM_ACTIVATE,False,0,,ahk_id %hTT%

        if (InStr(p1,"AutoPop")=1)  ;-- Starts with "AutoPop"
            SendMessage TTM_SETDELAYTIME,TTDT_AUTOPOP,p2*1000,,ahk_id %hTT%
        
        if (p1="Title")
            {
            ;-- If needed, truncate the title
            if (StrLen(p2)>99)
                p2:=SubStr(p2,1,99)

            ;-- Icon
            if p3 is not Integer
                p3:=TTI_NONE

            ;-- Set title
            SendMessage A_IsUnicode ? TTM_SETTITLEW:TTM_SETTITLEA,p3,&p2,,ahk_id %hTT%
            }

        ;-- Restore DetectHiddenWindows
        DetectHiddenWindows %l_DetectHiddenWindows%
    
        ;-- Return the handle to the tooltip control
        Return hTT
        }

    ;-- Create/Populate the TOOLINFO structure
    uFlags:=TTF_IDISHWND|TTF_SUBCLASS
    cbSize:=VarSetCapacity(TOOLINFO,(A_PtrSize=8) ? 64:44,0)
    NumPut(cbSize,      TOOLINFO,0,"UInt")              ;-- cbSize
    NumPut(uFlags,      TOOLINFO,4,"UInt")              ;-- uFlags
    NumPut(HWND_DESKTOP,TOOLINFO,8,"Ptr")               ;-- hwnd
    NumPut(p1,          TOOLINFO,(A_PtrSize=8) ? 16:12,"Ptr")
        ;-- uId

    ;-- Check to see if tool has already been registered for the control
    SendMessage
        ,A_IsUnicode ? TTM_GETTOOLINFOW:TTM_GETTOOLINFOA
        ,0
        ,&TOOLINFO
        ,,ahk_id %hTT%

    l_RegisteredTool:=ErrorLevel

    ;-- Update the TOOLTIP structure
    NumPut(&p2,TOOLINFO,(A_PtrSize=8) ? 48:36,"Ptr")
        ;-- lpszText

    ;-- Add, Update, or Delete tool
    if l_RegisteredTool
        {
        if StrLen(p2)
            SendMessage
                ,A_IsUnicode ? TTM_UPDATETIPTEXTW:TTM_UPDATETIPTEXTA
                ,0
                ,&TOOLINFO
                ,,ahk_id %hTT%
         else
            SendMessage
                ,A_IsUnicode ? TTM_DELTOOLW:TTM_DELTOOLA
                ,0
                ,&TOOLINFO
                ,,ahk_id %hTT%
        }
    else
        if StrLen(p2)
            SendMessage
                ,A_IsUnicode ? TTM_ADDTOOLW:TTM_ADDTOOLA
                ,0
                ,&TOOLINFO
                ,,ahk_id %hTT%

    ;-- Restore DetectHiddenWindows
    DetectHiddenWindows %l_DetectHiddenWindows%

    ;-- Return the handle to the tooltip control
    Return hTT
    }

;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
; END AddTooltip FUNCTION CALL




