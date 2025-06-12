#Requires AutoHotkey v2.0
#SingleInstance

field :=
send_selection := true

SetHotkeys("Off")
return

!u::{
    global field
    global send_selection
    field := "-u"
    send_selection := true
    Send "{Enter}"
}

!+u::{
    global field
    global send_selection
    field := "-u"
    send_selection := false
    Send "{Enter}"
}

!p::{
    global field
    global send_selection
    field := "-p"
    send_selection := true
    Send "{Enter}"
}

!+p::{
    global field
    global send_selection
    field := "-p"
    send_selection := false
    Send "{Enter}"
}

!o::{
    global field
    global send_selection
    field := "-o"
    send_selection := true
    Send "{Enter}"
}

!+o::{
    global field
    global send_selection
    field := "-o"
    send_selection := false
    Send "{Enter}"
}


!i::{
    global field
    global send_selection
    field := "interactive"
    send_selection := true
    Send "{Enter}"
}

!+i::{
    global field
    global send_selection
    field := "interactive"
    send_selection := false
    Send "{Enter}"
}

#+p::{

    ; enable Alt shortcuts to select which password field we want
    SetHotkeys("On")

    terminal := "wsl.exe" ; use default WSL instance
    passdb := "$HOME/bin/passdb" ; install location of passdb bash script inside WSL

    fzf_header := "alt+u: user,  alt+p: passwd,  alt+o: OTP, alt+i: interactive`nalt+shift+<KEY>: put in clipboard instead of typing"

    fzf_opts := "--height=20 --border=rounded --no-scrollbar --header=`"" fzf_header "`""
    fzf := "fzf " fzf_opts

    global field
    field := "-p" ; default is password
    global send_selection ; default is send
    send_selection := true

    ; save clipboard in case the user want us to type
    old_clipboard := A_Clipboard

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

    ; put selection in clipboard
    RunWait(terminal " " passdb " -show " field " " entry " | clip.exe",, "Hide")

    if send_selection = true
    {
        selection := A_Clipboard
        ; escape ` with ``, add a whitespace to prevent forming accent with dead keys
        selection := RegExReplace(selection, "``", "`` ")
        Send "{Raw}" selection
        A_Clipboard := old_clipboard ; restore clipboard
    }

; restore alt shortcuts
Hotkeys_Off:
    SetHotkeys("Off")
    return
}

SetHotkeys(p_state:="Toggle") {
    Hotkey "!u", p_state
    Hotkey "!+u", p_state
    Hotkey "!p", p_state
    Hotkey "!+p", p_state
    Hotkey "!o", p_state
    Hotkey "!+o", p_state
    Hotkey "!i", p_state
    Hotkey "!+i", p_state
}
