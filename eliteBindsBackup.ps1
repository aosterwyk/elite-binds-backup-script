param(
    [switch]$force,
    [switch]$backup,
    [string]$backupPath,
    [switch]$restore,
    [switch]$help,
    [switch]$update
)

$downloadURL = "https://github.com/aosterwyk/elite-binds-backup-script/releases/latest"
$bindsLocation = "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options\Bindings"
$version = "1.0.0"

# Start UI

Add-Type -AssemblyName PresentationFramework

[xml]$Form = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Elite Binds Backup Tool" Height="325" Width="625">
    <Grid>
        <Button Name="Backup" Content="Backup" HorizontalAlignment="Left" Margin="10,54,0,0" VerticalAlignment="Top"/>
        <Button Name="Restore" Content="Restore" HorizontalAlignment="Left" Margin="57,54,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="Overwrite" Content="Overwrite?" HorizontalAlignment="Left" Margin="10,81,0,0" VerticalAlignment="Top" Background="White"/>
        <TextBlock Name="PathTitle" HorizontalAlignment="Left" Margin="10,6,0,0" TextWrapping="Wrap" Text="Config Backup Location" VerticalAlignment="Top" Width="221"/>
        <TextBox Name="Path" HorizontalAlignment="Left" Margin="10,25,0,0" Text="" VerticalAlignment="Top" Width="571" TextWrapping="WrapWithOverflow"/>
        <Button Name="Browse" Content="Browse" HorizontalAlignment="Left" Margin="539,24,0,0" VerticalAlignment="Top" Visibility="Hidden"/>
        <TextBox Name="StatusMsg" VerticalScrollBarVisibility="Auto" BorderThickness="1" HorizontalAlignment="Left" Margin="10,101,0,0" TextWrapping="Wrap" Text="Loading..." VerticalAlignment="Top" Width="571" Height="150" Style="{Binding VerticalScrollBarVisibility.Auto, ElementName=textBox}" IsReadOnly="True"/>
        <Button Name="OpenBackups" Content="Open Backup Location" HorizontalAlignment="Left" Margin="339,59,0,0" VerticalAlignment="Top"/>
        <Button Name="OpenBinds" Content="Open Binds Location" HorizontalAlignment="Left" Margin="467,59,0,0" VerticalAlignment="Top"/>
        <TextBlock Name="Version" HorizontalAlignment="Left" Margin="10,263,0,0" TextWrapping="Wrap" Text="version" VerticalAlignment="Top" FontSize="8"/>

    </Grid>
</Window>
"@

$XMLReader = (New-Object System.Xml.XmlNodeReader $Form)
$Window = [Windows.Markup.XamlReader]::Load($XMLReader)

$backupButton = $Window.FindName('Backup')
$restoreButton = $Window.FindName('Restore')
$overwriteCheckbox = $Window.FindName('Overwrite')
$pathTextBox = $Window.FindName('Path')
$browseButton = $Window.FindName('Browse')
$statusMsg = $Window.FindName('StatusMsg')
$foundConfigsText = $Window.FindName('FoundConfigsTextBox')
$openBackupButton = $Window.FindName('OpenBackups')
$openBindsButton = $Window.FindName('OpenBinds')
$versionText = $Window.FindName('Version')

# End UI

write-host -foregroundcolor Cyan "Elite Binds Backup Script $($version)"
# write-host -foregroundcolor Cyan $downloadURL
# write-host "This script does not automatically update. Please use -update to open the downloads page to check for updates."

function Update-Status {
    param(
        [Parameter(Mandatory=$true)]
        [string]$text,
        [Parameter(Mandatory=$false)]
        [string]$foregroundcolor
    )
    if($foregroundcolor) { write-host -foregroundcolor $foregroundcolor $text}
    else { write-host $text }
    $statusMsg.text += "$($text)`n"
}   

# if($restore) {
function Restore-Config {
    write-host -foregroundcolor green "Restore mode" 
    
    # Get location of binds files to be restored 
    if($backupPath) { 
        write-host "Restoring binds from $($backupPath)"
    }
    else {
        $backupPath = get-location
        update-status "No backup path set. Restoring binds from working directory ($($backupPath))"
        # write-host "No backup path set. Restoring binds from working directory ($($backupPath))"
        update-status -foregroundcolor cyan "Hint: Use -backupPath to set backup location" 
        # write-host -foregroundcolor cyan "Hint: Use -backupPath to set backup location" 
    }
    
    # Check for Bindings directory. This may not exist on new installs.
    if(test-path $bindsLocation) {
        update-status -foregroundcolor green "Bindings location exists ($($bindsLocation))"
        # write-host -foregroundcolor green "Bindings location exists ($($bindsLocation))"
    }
    else {
        update-status -foregroundcolor red "Bindings location does not exit."
        # write-host -foregroundcolor red "Bindings location does not exit."
        new-item -path "$($Env:localappdata)\Frontier Developments\Elite Dangerous\Options" -name "Bindings" -itemtype "directory" | out-null
        update-status -foregroundcolor green "Created directory $($bindsLocation)."
        # write-host -foregroundcolor green "Created directory $($bindsLocation)."
    }
    get-childitem "$($backupPath)\*.binds" | foreach-object {
        update-status "Found $($_.name) in backups directory"
        # write-host "Found $($_.name) in backups directory"
        if(test-path "$($bindsLocation)\$($_.name)") {
            update-status -foregroundcolor Yellow "$($_.name) already exists in Bindings directory." 
            # write-host -foregroundcolor Yellow "$($_.name) already exists in Bindings directory." 
            if($force) {
                update-status -foregroundcolor yellow "Force set. Overwriting $($_.name)" 
                copy-item $_ -destination "$($bindsLocation)\$($_.name)" 
            }
            else {
                $overwritePrompt = read-host "Overwrite? (y/n)"
                if($overwritePrompt -eq "y") {
                    update-status -foregroundcolor Yellow "Overwriting $($_.name)" 
                    # write-host -foregroundcolor Yellow "Overwriting $($_.name)" 
                    update-status -foregroundcolor Cyan "Hint: Use -force or check overwrite to ignore this check and overwrite the file" 
                    copy-item $_ -destination "$($bindsLocation)\$($_.name)" 
                }
                else { 
                    write-host "Skipping $($_.name)"
                }
            }
        }
        else {
            copy-item $_ -destination "$($bindsLocation)\$($_.name)" 
            update-status "Copied $($_.name) to Bindings directory" 
            # write-host "Copied $($_.name) to Bindings directory" 
        }   
    }
    update-status -foregroundcolor green "Done"
    return
}

# if($backup) {
function Backup-Config {
    # Set location to copy binds files 
    if($backupPath) {
        write-host "Backup destination set to $($backupPath)."
    }
    else {
        $backupPath = get-location 
        write-host "No backup destination set. Using working directory.($($backupPath))"
        write-host -foregroundcolor cyan "Hint: Use -backupPath to set backup destination"
    }


    if(test-path $backupPath) {
        write-host "Backup path exists. Continuing." 
    }   
    else {
        update-status "Backup path does not exist."
        update-status "Creating $($backupPath)" 
        new-item -path $backupPath -itemtype "directory" | out-null
        update-status "Directory created. Continuing."
    }

    write-host "`nChecking for binds in $($bindsLocation)`n"

    # Get binds files in bindings directory and copy to backup directory
    get-childitem "$($bindsLocation)\*.binds" | foreach-object {
        update-status "Found $($_.name)"
        # TODO - check if backup location exists
        if(Test-Path "$($backupPath)\$($_.name)") {
            update-status -foregroundcolor yellow "File already exists in backup destination."
            if($force) {
                update-status -foregroundcolor yellow "Force set. Overwriting file in backup destination."
                $backupFilename = $_.name
            }
            else {
                $backupFilename = "$($_.basename)-$(get-date -format "yyyyMMdd-HHmmss")$($_.extension)"
                update-status -foregroundcolor yellow "Using filename $($backupFilename)."
                update-status -foregroundcolor cyan "Hint: Use -force or check overwrite to ignore this check and overwrite the file."
            }
        }
        else {
            # write-host "File $($_.name) does not already exist in backup destination."
            $backupFilename = $_.name
        }
        copy-item $_ -Destination "$($backupPath)\$($backupFilename)"
        update-status -foregroundcolor green "Copied to $($backupPath)\$($backupFilename)"
    }
    update-status -foregroundcolor green "Done"
    return
}

function Check-Updates {
    try {
        $updateUri = "https://api.github.com/repos/aosterwyk/elite-binds-backup-script/releases/latest"
        $updateHeaders = @{
            "Accept" = "application/vnd.github+json"
            "X-GitHub-Api-Version" = "2022-11-28"        
        }

        $updateCheck = Invoke-RestMethod -Uri $updateUri -headers $updateHeaders
        update-status "Checking for updates..."
        if($version -lt $updateCheck.name) {
            update-status -foregroundcolor green "New update available. Please run -update to download the new version."
        }
        else { update-status "Newest version: $($updateCheck.name) Current version: $($version). You are running the newest version." }
    }
    catch {
        update-status -foregroundcolor red "Error checking for updates. $($_)"
    }   
}

if($backup -or $restore -or $help -or $update) { # don't load UI if using switches
    write-host "`r`no7 CMDR"
    Check-Updates 
    if($backup) { Backup-Config }
    if($restore) { Restore-Config }
    write-host "Need help with command line mode? Run the script with -help"
    if($update) {
        start $downloadURL
        return
    }    
    if($help) {
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
        return
    }
}
else { 
    write-host "Script ran without switches. Starting UI."

    $pathTextBox.text = "$(get-location)"
    $statusMsg.text = "o7 CMDR`n"
    $versionText.text = $version    
    Check-Updates    

    $statusMsg.text += "Using $($bindsLocation)`n"
    if(test-path $bindsLocation) {
        $statusMsg.text += "Bindings location exists`n"
    }
    $statusMsg.text += "Checking for binds...`n"
    get-childitem "$($bindsLocation)\*.binds" | foreach-object {
        $statusMsg.Text += "Found $($_.name)`n"
    }
    $statusMsg.text += "Ready to backup`n"

    # add listeners 
    $openBackupButton.Add_Click({ start $pathTextBox.text })
    $openBindsButton.Add_Click({ start $bindsLocation })
    
    # backup button
    $backupButton.Add_Click({
        $force = $overwriteCheckbox.IsChecked
        $backupPath = $pathTextBox.text
        Backup-Config
    })
    
    $restoreButton.Add_Click({
        $force = $overwriteCheckbox.IsChecked
        $backupPath = $pathTextBox.text
        Restore-Config
    })

    $Window.ShowDialog() | Out-Null
}

