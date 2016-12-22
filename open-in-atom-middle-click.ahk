#NoEnv
#Warn All
#Warn UseUnsetGlobal, Off
#SingleInstance force

SetTitleMatchMode, RegEx      ; Enable Regex

; Globals
PATH_USERHOME :=
PATH_TOATOM :=
INITIALIZED := false

init()
{
	global PATH_USERHOME
	global PATH_TOATOM
	global INITIALIZED
	if INITIALIZED
		return
	INITIALIZED = true
	EnvGet, PATH_USERHOME, USERPROFILE
	PATH_TOATOM := PATH_USERHOME . "\AppData\Local\atom\bin\atom"
}

~^s::                         ; ~ prevents blocking the save command.
AhkScriptReload()             ; AhkScriptReload() reloads this script when saved
{
	IfWinActive, %A_ScriptName%
	{
		Inform(A_ScriptName, "Reloading")
		reload
		return
	}
}

~MButton::                    ; ~ prevents blocking MButton event
OpenItemInAtom()              ; OpenItemInAtom() opens a file or path in the running instance of atom.exe
{
	global PATH_TOATOM
	init()
	IfWinActive ahk_exe i)Explorer\.EXE$
	{
		IfNotExist, %PATH_TOATOM%
			return                  ; Must have atom
		Clipboard =               ; Start clean
		Send {LButton}            ; Ensure file is selected
		Send {alt}hcp             ; ALT + H then CP (which copies the filepath of the selected file in windows 8)
		ClipWait, 0, "text"       ; Max wait time for copying clipboard data (in seconds)
		if ErrorLevel             ; Something happened preventing access to clipboard contents
		{
			return
		}
		Clipboard = %Clipboard%   ; Ensure clipboard contents are text (even though specified in ClipWait)
		targetPath := Clipboard
		IfNotInString, targetPath, :\ ; In testing this never occurred. Here just in case clipboard text is not a file path.
		{
			return
		}
		shell := ComObjCreate("WScript.Shell")
		shell.Run(PATH_TOATOM . " -a " . targetPath, 0, true)
                              ; -a command appends file to last active atom.exe.
															; If atom is not running, it opens a new instance.
		return
	}
}

Inform(text, title:="", dur:=600)
{
	Progress, B2 FM9 FS8 WM600 CWefefef CT333333 ZH0, %text%, %title%, , Consolas
	Sleep dur
	Progress, Off
}
