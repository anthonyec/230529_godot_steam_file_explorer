#!/usr/bin/osascript
on run argv
    set filePath to item 1 of argv
    tell application "Finder"
        delete (POSIX file filePath as alias)
    end tell
end run
