SendMode Input
SetWorkingDir %A_ScriptDir% 

OnExit, sub_exit
if (midi_in_Open(1))
	ExitApp
	
;----------------
; Global Variables
  ; true global
debug := FALSE

  ; state
state_a := FALSE
state_b := FALSE
state_pause := FALSE

last_crossfader := 0

;----------------
; Autoexec: Callback Installation
;listenNoteRange(0, 127, "LeftFXCallback", 0x00, 0x05)
listenNoteRange(0, 127, "RightFXCallback", 0x00, 0x06)
;listenNoteRange(0, 127, "LeftCueCallback", 0x00, 0x08)
;listenNoteRange(0, 127, "RightCueCallback", 0x00, 0x09)
listenNoteRange(0, 127, "PanelShiftCallback", 0x00, 0x07)

listenCC(0x0A, "FXKnobCallback", 0x07)
;listenCC(0x13, "LeftFaderCallback", 0x01)
;listenCC(0x13, "RightFaderCallback", 0x02)
listenCC(0x1F, "CrossfaderCallback", 0x07)

return

;----------------
; Routines
sub_exit:
	midi_in_Close()
ExitApp

Debug(string) {
  global debug
	if (debug) {
	  OutputDebug %string%
	}
}

; PanelShiftCallback
;   used for "start" and "select"
PanelShiftCallback(note, vel) {
  Debug("PanelShiftCallback at " . vel . " " . note)pppooooooo
	
	if (note == 120) {
	  global state_pause
		if (vel == 127) {
		  if (state_pause) {
			  send {m up}
			} else {
			  send {m down}
			}
			state_pause := !state_pause
		}
	}
	if (note == 63) {
	  if (vel == 127) {
			send {n down}	
		} else {
			send {n up}
		}	  
	}
}

LeftFXCallback(note, vel) {
  Debug("Left FX at " . vel . " " . note)
}

; RightFXCallback
;   used for "B" button
RightFXCallback(note, vel) {
  Debug("Right FX at " . vel . " " . note)
	if (vel == 127) {
	  ; pressed
		Send {b down}
	} else {
	  ; unpressed
		Send {b up}
	}
}

leftCueCallback(note, vel) {
  Debug("Left Cue at " . vel . " " . note)
}

RightCueCallback(note, vel) {
  Debug("Right Cue at " . vel . " " . note)
}

LeftFaderCallback(cc, value) {
  Debug("Left Fader at " . value)
}

RightFaderCallback(cc, value) {
  Debug("Right Fader at " . value)
}

; FXKnobCallback
;  used for "left/right" pads
FXKnobCallback(cc, value) {
  Debug("FX Knob at " . value)
	if (value > 80) {
	  Send {right down}
		Send {left up}
	} else if (value < 48) {
	  Send {left down}
		Send {right up}
	} else {
	  Send {left up}
		Send {right up}
	}
}

; CrossfaderCallback
;  used for "A" button (opening pushes button, closing releases)
CrossfaderCallback(cc, value) {
  Debug("Crossfader at " . value)
	global last_crossfader
	global state_a
	if (value > last_crossfader) {
	  if (!state_a) {
		  Send {a down}
			state_a := TRUE
		}
	}
	if (value < last_crossfader) {
	  if (state_a) {
		  Send {a up}
			state_a := FALSE
		}
	}
	last_crossfader := value
}

;-------------------------  Midi input library  ----------------------
#include midi_in_lib.ahk