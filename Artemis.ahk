#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, -1, -1
Menu, Tray, Icon, %A_ScriptDir%\wowdark.ico,,1
#maxthreadsperhotkey 6
#SingleInstance force
Pause, On


Macro1:
Loop
{
;	if WinActive("ahk_class".GxWindowClass)
	CoordMode, Pixel, Screen
	PixelGetColor, OutputVar, 0, 0, RGB
	if OutputVar = 0x010101
	{
		ControlSend,,{Numpad1},World of Warcraft
		Sleep, 200
	}	
	if OutputVar = 0x020202
	{
		ControlSend,,{Numpad2},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x030303
	{
		ControlSend,,{Numpad3},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x040404
	{
		ControlSend,,{Numpad4},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x050505
	{
		ControlSend,,{Numpad5},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x060606
	{
		ControlSend,,{Numpad6},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x070707
	{
		ControlSend,,{Numpad7},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x080808
	{
		ControlSend,,{Numpad8},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x090909
	{
		ControlSend,,{Numpad9},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0A0A0A
	{
		ControlSend,,{Numpad0},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0B0B0B
	{
		ControlSend,,{ctrl down}{Numpad1}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0C0C0C
	{
		ControlSend,,{ctrl down}{Numpad2}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0D0D0D
	{
		ControlSend,,{ctrl down}{Numpad3}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0E0E0E
	{
		ControlSend,,{ctrl down}{Numpad4}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0F0F0F
	{
		ControlSend,,{ctrl down}{Numpad5}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x101010
	{
		ControlSend,,{ctrl down}{Numpad6}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x111111
	{
		ControlSend,,{ctrl down}{Numpad7}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x121212
	{
		ControlSend,,{ctrl down}{Numpad8}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x131313
	{
		ControlSend,,{ctrl down}{Numpad9}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x141414
	{
		ControlSend,,{ctrl down}{Numpad0}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x151515
	{
		ControlSend,,{alt down}{Numpad1}{alt up},World of Warcraft
		Sleep, 200
	}
	
	
	if OutputVar = 0x010000
	{
		ControlSend,,{F1},World of Warcraft
		Sleep, 200
	}	
	if OutputVar = 0x020000
	{
		ControlSend,,{F2},World of Warcraft
		Sleep, 200
	}	
	if OutputVar = 0x030000
	{
		ControlSend,,{F3},World of Warcraft
		Sleep, 200
	}	
	if OutputVar = 0x040000
	{
		ControlSend,,{F4},World of Warcraft
		Sleep, 200
	}	
	if OutputVar = 0x050000
	{
		ControlSend,,{F5},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x060000
	{
		ControlSend,,{F6},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x070000
	{
		ControlSend,,{F7},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x080000
	{
		ControlSend,,{F8},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x090000
	{
		ControlSend,,{F9},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0A0000
	{
		ControlSend,,{F10},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0B0000
	{
		ControlSend,,{ctrl down}{F1}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0C0000
	{
		ControlSend,,{ctrl down}{F2}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0D0000
	{
		ControlSend,,{ctrl down}{F3}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0E0000
	{
		ControlSend,,{ctrl down}{F4}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x0F0000
	{
		ControlSend,,{ctrl down}{F5}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x100000
	{
		ControlSend,,{ctrl down}{F6}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x110000
	{
		ControlSend,,{ctrl down}{F7}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x120000
	{
		ControlSend,,{ctrl down}{F8}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x130000
	{
		ControlSend,,{ctrl down}{F9}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x140000
	{
		ControlSend,,{ctrl down}{F10}{ctrl up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x150000
	{
		ControlSend,,{alt down}{F1}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x160000
	{
		ControlSend,,{alt down}{F2}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x170000
	{
		ControlSend,,{alt down}{F3}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x180000
	{
		ControlSend,,{alt down}{F4}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x190000
	{
		ControlSend,,{alt down}{F5}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x1A0000
	{
		ControlSend,,{alt down}{F6}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x1B0000
	{
		ControlSend,,{alt down}{F7}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x1C0000
	{
		ControlSend,,{alt down}{F8}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x1D0000
	{
		ControlSend,,{alt down}{F9}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x1E0000
	{
		ControlSend,,{alt down}{F10}{alt up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x1F0000
	{
		ControlSend,,{shift down}{F1}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x200000
	{
		ControlSend,,{shift down}{F2}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x210000
	{
		ControlSend,,{shift down}{F3}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x220000
	{
		ControlSend,,{shift down}{F3}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x230000
	{
		ControlSend,,{shift down}{F4}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x240000
	{
		ControlSend,,{shift down}{F5}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x250000
	{
		ControlSend,,{shift down}{F6}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x260000
	{
		ControlSend,,{shift down}{F7}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x270000
	{
		ControlSend,,{shift down}{F8}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x280000
	{
		ControlSend,,{shift down}{F9}{shift up},World of Warcraft
		Sleep, 200
	}
	if OutputVar = 0x290000
	{
		ControlSend,,{shift down}{F10}{shift up},World of Warcraft
		Sleep, 200
	}
}

#IfWinActive

`::
Menu, Tray, Icon, %A_ScriptDir%\wowlight.ico,,1

  soundbeep 

; if resuming from sleep our status flag is set and a second beep is issued 

  if issleeping 
  
	Menu, Tray, Icon, %A_ScriptDir%\wowdark.ico,,1
    soundbeep 

; toogle the status flag 

  issleeping := !issleeping 

  pause 

  return