param(
    [switch]$force,
    [string]$backupPath,
    [switch]$resotre,
    [string]$restorePath
)

write-host "o7 CMDR"
$bindsLocation = "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options\Bindings"


if($backupPath) {
    write-host "Backup destination set to $($backupPath)."
}
else {
    $backupPath = get-location 
    write-host "No backup destination set. Using working directory.($($backupPath))"
    write-host -foregroundcolor cyan "Hint: Use -backupPath to set backup destination"
}

write-host "`nChecking for binds in $($bindsLocation)`n"

get-childitem "$($bindsLocation)\*.binds" | foreach-object {
    write-host "Found $($_.name) in binds directory"
    if(Test-Path "$($backupPath)\$($_.name)") {
        write-host -forgroundcolor yellow "File already exists in backup destination."
        if($force) {
            write-host -foregroundcolor yellow "Force set. Overwriting file in backup destination."
            $backupFilename = $_.name
        }
        else {
            $backupFilename = "$($_.basename)-$(get-date -format "yyyyMMdd-HHmmss")$($_.extension)"
            write-host -foregroundcolor yellow "Using filename $($backupFilename)."
            write-host -foregroundcolor cyan "Hint: Use -force to ignore this check and overwrite the file."
        }
    }
    else {
        write-host "File $($_.name) does not already exist in backup destination."
        $backupFilename = $_.name
    }
    copy-item $_ -Destination "$($backupPath)\$($backupFilename)"
    write-host -foregroundcolor green "Copied to $($backupPath)\$($backupFilename)"
}

