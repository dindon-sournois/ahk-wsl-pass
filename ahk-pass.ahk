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

!i::{
    global field
    field := "interactive"
}

#+p::{

    ; enable Alt shortcuts to select which password field we want
    SetHotkeys("On")

    terminal := "wsl.exe" ; use default WSL instance
    passdb := "$HOME/bin/passdb" ; install location of passdb bash script inside WSL

    global field
    fzf_header := "(alt+u: user,  alt+p: passwd,  alt+o: OTP, alt+i: interactive)"
    fzf_opts := "--height=20 --border=rounded --no-scrollbar --header=`"" fzf_header "`""
    fzf := "fzf " fzf_opts
    field := "-p" ; default is password

    ; list passwords, do fuzzy matching, give that to clip.exe
    RunWait(terminal " " passdb " -l | " fzf " | clip.exe")

    ; remove unwanted carriage return
    entry := A_Clipboard
    if RegExMatch(entry, "[`r`n]$")
        entry := RTrim(entry, "`r`n")

    if field = "interactive" ; interactively select user field
    {
        ; list all fields of this password entry and fuzzy match that
        RunWait(terminal " " passdb " -lf " entry " | " fzf " | clip.exe")

        ; remove unwanted carriage return
        selected := A_Clipboard
        if RegExMatch(selected, "[`r`n]$")
            selected := RTrim(selected, "`r`n")

        field := "-f " selected
    }

    RunWait(terminal " " passdb " -show " field " " entry " | clip.exe",, "Hide")

    ; restore alt shortcuts
Hotkeys_Off:
    SetHotkeys("Off")
    return
}

SetHotkeys(p_state:="Toggle") {
    Hotkey "!u", p_state
    Hotkey "!p", p_state
    Hotkey "!o", p_state
    Hotkey "!i", p_state
}