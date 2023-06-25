param(
    [switch]$force,
    [switch]$backup,
    [string]$backupPath,
    [switch]$restore,
    [switch]$update
)

$downloadURL = "https://github.com/aosterwyk/elite-binds-backup-script/releases/latest"
$bindsLocation = "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options\Bindings"

write-host -foregroundcolor Cyan "Elite Binds Backup Script v0.1.0"
write-host -foregroundcolor Cyan $downloadURL
write-host "This script does not automatically update. Please use -update to open the downloads page to check for updates."
write-host "`r`no7 CMDR"

if($update) {
    start $downloadURL
    return
}

if($restore) {
    write-host -foregroundcolor green "Restore mode" 
    
    # Get location of binds files to be restored 
    if($backupPath) { 
        write-host "Restoring binds from $($backupPath)"
    }
    else {
        $backupPath = get-location
        write-host "No backup path set. Restoring binds from working directory ($($backupPath))"
        write-host -foregroundcolor cyan "Hint: Use -backupPath to set backup location" 
    }
    
    # Check for Bindings directory. This may not exist on new installs.
    if(test-path $bindsLocation) {
        write-host -foregroundcolor green "Bindings location exists ($($bindsLocation))"
    }
    else {
        write-host -foregroundcolor red "Bindings location does not exit."
        new-item -path "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options" -name "Bindings" -itemtype "directory" | out-null
        write-host -foregroundcolor green "Created directory $($bindsLocation)."
    }
    get-childitem "$($backupPath)\*.binds" | foreach-object {
        write-host "Found $($_.name) in backups directory"
        if(test-path "$($bindsLocation)\$($_.name)") {
            write-host -foregroundcolor Yellow "$($_.name) already exists in Bindings directory." 
            $overwritePrompt = read-host "Overwrite? (y/n)"
            if($overwritePrompt -eq "y") {
                write-host -foregroundcolor Yellow "Overwriting $($_.name)" 
                # write-host -foregroundcolor Cyan "Hint: Use -force to ignore this check and overwrite the file" 
                # TODO - add -force for restores 
                copy-item $_ -destination "$($bindsLocation)\$($_.name)" 
            }
            else { 
                write-host "Skipping $($_.name)"
            }
        }
        else {
            copy-item $_ -destination "$($bindsLocation)\$($_.name)" 
            write-host "Copied $($_.name) to Bindings directory" 
        }   
    }
    return
}

if($backup) {
    # Set location to copy binds files 
    if($backupPath) {
        write-host "Backup destination set to $($backupPath)."
    }
    else {
        $backupPath = get-location 
        write-host "No backup destination set. Using working directory.($($backupPath))"
        write-host -foregroundcolor cyan "Hint: Use -backupPath to set backup destination"
    }

    write-host "`nChecking for binds in $($bindsLocation)`n"

    # Get binds files in bindings directory and copy to backup directory
    get-childitem "$($bindsLocation)\*.binds" | foreach-object {
        write-host "Found $($_.name)"
        # TODO - check if backup location exists
        if(Test-Path "$($backupPath)\$($_.name)") {
            write-host -foregroundcolor yellow "File already exists in backup destination."
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
    return
}

write-host "`nHelp
-backup: Backup mode
-restore: Restore mode
-backupPath: (optional) Location to backup or restore backups. Script will use working directory ($(get-location)) if not used. 
-force: (optional) Force overwriting files if they already exist in the backup or restore directory.
`nExamples
Backup binds to c:\temp\elite
eliteBindsBackup.ps1 -backup -backupPath c:\temp\elite 

Restore binds from c:\temp\elite
eliteBindsBackup.ps1 -restore -backupPath c:\temp\elite`n"
