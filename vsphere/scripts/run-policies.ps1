try {
  $DEST = "C:\bosh\lgpo"
  if(!(Test-Path -Path $DEST )){
    mkdir $DEST
  }
  $BIN = "C:\bosh\lgpo\bin"
  if(!(Test-Path -Path $BIN )){
    mkdir $BIN
  }
  $env:PATH="${env:PATH};$BIN"

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  function Unzip
  {
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)

    rm $zipfile
  }

  $LGPO_URL = "https://msdnshared.blob.core.windows.net/media/2016/09/LGPOv2-PRE-RELEASE.zip"
  Invoke-WebRequest $LGPO_URL -OutFile "$DEST\lgpo.zip"
  if (-Not (Test-Path "$DEST\lgpo.zip")) {
    Write-Error "ERROR: could not download LGPO"
    Exit 1
  }

  Unzip "$DEST\lgpo.zip" $BIN
  if (-Not (Test-Path "$BIN\LGPO.exe")) {
    Write-Error "ERROR: could not extract LGPO"
    Exit 1
  }

  Unzip "A:\policy-baseline.zip" $DEST
  if (-Not (Test-Path "$DEST\policy-baseline")) {
    Write-Error "ERROR: could not extract policy-baseline"
    Exit 1
  }

  echo "$BIN\LGPO.exe /g $DEST\policy-baseline /v 2>&1 > $DEST\LGPO.log" > "$BIN\apply-policies.bat"
} catch {
  Write-Error $_.Exception.Message
  Exit 1
}
Exit 0
