if(!(Test-Path -Path "C:\bosh" )){
    mkdir "C:\bosh"
}
if(!(Test-Path -Path "C:\var\vcap\bosh\bin" )){
    mkdir "C:\var\vcap\bosh\bin"
}
if(!(Test-Path -Path "C:\var\vcap\bosh\log" )){
    mkdir "C:\var\vcap\bosh\log"
}

# Add utilities to current path.
$env:PATH="${env:PATH};C:\var\vcap\bosh\bin"

# Add utilities to system path (does not apply to current shell).
Setx $env:PATH "${env:PATH};C:\var\vcap\bosh\bin" /m

Add-Type -AssemblyName System.IO.Compression.FileSystem
  function Unzip
  {
      param([string]$zipfile, [string]$outpath)

      [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)

      rm $zipfile
  }

Invoke-WebRequest "${ENV:AGENT_DEPS_ZIP_URL}" -Verbose -OutFile "C:\bosh\agent_deps.zip"
Unzip "C:\bosh\agent_deps.zip" "C:\var\vcap\bosh\bin\"
Move-Item "C:\var\vcap\bosh\bin\tar-*.exe" "C:\var\vcap\bosh\bin\tar.exe"
Move-Item "C:\var\vcap\bosh\bin\zlib1-*.exe" "C:\var\vcap\bosh\bin\zlib1.dll"
Move-Item "C:\var\vcap\bosh\bin\job-service-wrapper-*.exe" "C:\var\vcap\bosh\bin\job-service-wrapper.exe"
Move-Item "C:\var\vcap\bosh\bin\s3cli-*-windows-amd64" "C:\var\vcap\bosh\bin\bosh-blobstore-s3.exe"
Move-Item "C:\var\vcap\bosh\bin\davcli-*-windows-amd64" "C:\var\vcap\bosh\bin\bosh-blobstore-dav.exe"

Invoke-WebRequest "${ENV:AGENT_ZIP_URL}" -Verbose -OutFile "C:\bosh\agent.zip"
Unzip "C:\bosh\agent.zip" "C:\bosh\"

$OldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$AddedFolder='C:\var\vcap\bosh\bin'
$NewPath=$OldPath+';'+$AddedFolder
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath

C:\bosh\service_wrapper.exe install
