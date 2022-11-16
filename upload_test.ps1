# get winscp .NET dll for uploads
  # activate higher TLS version. Seems PS only uses 1.0 by default
  # credit: https://stackoverflow.com/questions/41618766/powershell-invoke-webrequest-fails-with-ssl-tls-secure-channel/48030563#48030563
  [Net.ServicePointManager]::SecurityProtocol = [System.Security.Authentication.SslProtocols] "tls, tls11, tls12"
  (New-Object System.Net.WebClient).DownloadFile("https://downloads.sourceforge.net/project/winscp/WinSCP/5.21.5/WinSCP-5.21.5-Automation.zip?ts=gAAAAABjdU7yfz3jBCtk86Yif2GdJhhZQEMzJQye7xk1r9lh_8BxWqmPN4l9WCuLj1zhuYOmy8dRoPuDFiCV8hYCtM8a9_Y6ZA%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fwinscp%2Ffiles%2FWinSCP%2F5.21.5%2FWinSCP-5.21.5-Automation.zip%2Fdownload", "Winscp-automation.zip")
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory("Winscp-automation.zip", "${Env:APPVEYOR_BUILD_FOLDER}\Winscp-automation\")
  Add-Type -Path "${Env:APPVEYOR_BUILD_FOLDER}\Winscp-automation\WinSCPnet.dll"

  # do the upload
  $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    # sftp://
    Protocol = [WinSCP.Protocol]::Scp
    HostName = "mudlet.org"
    UserName = "mudmachine"
    SshPrivateKeyPath = "$Env:SshSecretKey"
  }
  $session = New-Object WinSCP.Session
  $fingerprint =  $session.ScanFingerprint($sessionOptions, "SHA-256")
  $sessionOptions.SshHostKeyFingerprint = $fingerprint
  # Connect
  Write-Output "=== Uploading installer to https://www.mudlet.org/wp-content/files/?C=M;O=D ==="
  $session.Open($sessionOptions)
  $session.PutFiles("${Env:APPVEYOR_BUILD_FOLDER}\testfile", "testfile")
  $session.Close()
  $session.Dispose()
