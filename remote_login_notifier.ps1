# -------------------------------
# Remote Login Notifier (with config file)
# -------------------------------

# Path to config file
$ConfigFile = "$env:USERPROFILE\Documents\login_notify.conf"

if (-not (Test-Path $ConfigFile)) {
    Write-Host "Config file not found: $ConfigFile"
    exit
}

# Load config
Get-Content $ConfigFile | ForEach-Object {
    if ($_ -match "^\s*([^=]+)=(.+)$") {
        Set-Variable -Name $matches[1].Trim() -Value $matches[2].Trim()
    }
}

# Flag & log files
$FlagFile = "$env:TEMP\login_notified.flag"
$LogFile = "$env:TEMP\login_monitor.log"

# Single instance check
$MyScriptName = [System.IO.Path]::GetFileName($PSCommandPath)
if (Get-Process | Where-Object { $_.ProcessName -eq "powershell" -and $_.Path -eq $PSCommandPath -and $_.Id -ne $PID }) {
    Write-Output "Script already running. Exiting."
    exit
}

# Email function
function Send-LoginEmail {
    param($Subject, $Body)
    
    $smtp = New-Object System.Net.Mail.SmtpClient("smtp.gmail.com", 587)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($GmailAddress, $GmailAppPassword)
    
    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = $GmailAddress
    $mail.To.Add($ToEmail)
    $mail.Subject = $Subject
    $mail.Body = $Body
    
    try {
        $smtp.Send($mail)
        "$((Get-Date).ToString()) - Email sent successfully." | Out-File -Append $LogFile
    } catch {
        "$((Get-Date).ToString()) - Email failed: $_" | Out-File -Append $LogFile
    }
}

# Monitoring loop
while ($true) {
    $ping = Test-Connection -ComputerName $KidHost -Count 1 -Quiet -ErrorAction SilentlyContinue

    if ($ping) {
        if (-not (Test-Path $FlagFile)) {
            Send-LoginEmail -Subject "Kid logged in" -Body "Your kid logged in on $KidHost at $(Get-Date)"
            New-Item -ItemType File -Path $FlagFile | Out-Null
        }
    } else {
        if (Test-Path $FlagFile) { Remove-Item $FlagFile }
    }

    Start-Sleep -Seconds 300
}

