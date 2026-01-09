# Remote Login Notifier (PowerShell)

PowerShell script that monitors a remote computer and sends email notifications when it comes online. Configurable via a separate configuration file to keep credentials secure.

---

## Setup Instructions

### 1. Clone the repository

```powershell
git clone https://github.com/<YourUsername>/RemoteLoginNotifier.git
cd RemoteLoginNotifier

2. Create your configuration file

Create a file called login_notify.conf in a safe location (e.g., your Documents folder):

# login_notify.conf
# Fill in your own details

# IP or hostname of the computer to monitor
TargetHost=192.168.1.100

# Email to receive notifications
NotificationEmail=youremail@example.com

# Gmail address for sending email notifications
GmailAddress=youremail@gmail.com

# Gmail App Password (16 characters, must have 2FA enabled)
GmailAppPassword=xxxxxxxxxxxxxxxx

    Important: Never commit your real login_notify.conf to GitHub.

3. Update the script to point to your config file

In remote_login_notifier.ps1, confirm the config path:

$ConfigFile = "$env:USERPROFILE\Documents\login_notify.conf"

4. Run the script

Open PowerShell and run:

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\remote_login_notifier.ps1

    The script checks every 5 minutes if the target computer is online and sends an email notification.

    Logs are saved in $env:TEMP\login_monitor.log.

    A flag file prevents duplicate notifications during the same session.

Optional

    You can schedule the script to run automatically in the background using Task Scheduler.

    Multiple instances are prevented automatically.

Notes

    Designed for Windows PowerShell.

    Gmail 2FA must be enabled, and an App Password is required for sending emails.

    Uses Test-Connection (ping) to detect if the target is online.
