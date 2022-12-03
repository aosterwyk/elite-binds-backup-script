param(
    [switch]$force,
    [string]$backupDestination
)

write-host "o7 CMDR"
$bindsLocation = "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options\Bindings"


if($backupDestination) {
    write-host "Backup destination set to $($backupDestination)."
}
else {
    $backupDestination = get-location 
    write-host "No backup destination set. Using working directory.($($backupDestination))"
    write-host -foregroundcolor cyan "Hint: Use -backupDestination to set backup destination"
}

write-host "`nChecking for binds in $($bindsLocation)`n"

get-childitem "$($bindsLocation)\*.binds" | foreach-object {
    write-host "Found $($_.name) in binds directory"
    if(Test-Path "$($backupDestination)\$($_.name)") {
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
    copy-item $_ -Destination "$($backupDestination)\$($backupFilename)"
    write-host -foregroundcolor green "Copied to $($backupDestination)\$($backupFilename)"
}

