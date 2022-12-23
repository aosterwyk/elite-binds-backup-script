param(
    [switch]$force,
    [string]$backupPath,
    [switch]$resotre,
    [string]$restorePath,
    [switch]$update
)

$downloadURL = "https://github.com/aosterwyk/elite-config-backup-script/releases/latest"
$bindsLocation = "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options\Bindings"

write-host "Elite Config Backup Tool v0.1.0"
write-host -foregroundcolor Yellow "This tool does not automatically update. Please periodically check for updates at the link below or use -update to open the downloads page."
write-host $downloadURL
write-host "`r`no7 CMDR"

if($update) {
    start $downloadURL
    return
}

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
    write-host "Found $($_.name)"
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
        # write-host "File $($_.name) does not already exist in backup destination."
        $backupFilename = $_.name
    }
    copy-item $_ -Destination "$($backupPath)\$($backupFilename)"
    write-host -foregroundcolor green "Copied to $($backupPath)\$($backupFilename)"
}
