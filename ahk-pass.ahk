#Requires AutoHotkey v2.0
#SingleInstance

field :=
SetHotkeys("Off")
return

!u::{
    global field
    field := "-u"
}

!p::{
    global field
    field := "-p"
}

!o::{
    global field
    field := "-o"
}

#+p::{

    ; enable alt shortcuts to select which password entry we want
    SetHotkeys("On")

    terminal := "wsl.exe" ; use default WSL instance
    passdb := "$HOME/bin/passdb" ; install location of passdb bash script inside WSL

    global field
    fzf_header := "(Select [u]ser, [p]assword or [o]tp with alt+u, alt+p or alt+o)"
    fzf_opts := "--height=20 --border=rounded --no-scrollbar --header=`"" fzf_header "`""
    fzf := "fzf " fzf_opts
    field := "-p" ; default is password

    ; list passwords, do fuzzing matching, give that to clip.exe
    RunWait(terminal " " passdb " -l | " fzf " | clip.exe")

    ; remove unwanted carriage return
    clip := A_Clipboard
    if RegExMatch(clip, "[`r`n]$")
        clip := RTrim(clip, "`r`n")
    RunWait(terminal " " passdb " -show " field " " clip " | clip.exe",, "Hide")

    ; restore alt shortcuts
Hotkeys_Off:
    SetHotkeys("Off")
    return
}

SetHotkeys(p_state:="Toggle") {
    Hotkey "!u", p_state
    Hotkey "!p", p_state
    Hotkey "!o", p_state
}
