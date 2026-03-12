on run argv
    set noteName to item 1 of argv
    set noteContent to item 2 of argv
    
    tell application "Notes"
        set targetNote to note noteName
        set body of targetNote to (body of targetNote) & "<br><br>" & noteContent
    end tell
end run