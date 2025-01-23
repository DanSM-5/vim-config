#!/usr/bin/env pwsh

# NOTE: Curl should be present since windows 10

if ($IsWindows -or ($env:OS -eq 'Windows_NT')) {
  $platform = 'windows'
  $ext = 'zip'
  $dirsep = '\'
  $mpls = 'mpls.exe'
} elseif ($IsLinux) {
  $platform = 'linux'
  $ext = 'tar.gz'
  $dirsep = '/'
  $mpls = 'mpls'
} else {
  $platform = 'darwin'
  $ext = 'tar.gz'
  $dirsep = '/'
  $mpls = 'mpls'
}

$architecture = if (([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) -eq 'X64') { 'amd64' } else { 'arm64' }

$url_match = "browser_download_url.*${platform}_${architecture}.*"
# I could have used iwr and native json module but I'm too lazy too look the documentation up... sorry
$string_url = curl -sL 'https://api.github.com/repos/mhersson/mpls/releases/latest' | Select-String $url_match
$string_url -match 'https.*[(zip)|(tar.gz)]'
$string_url = $matches[0]

if (-Not $string_url) {
  exit 1
}

$tmp_dir = if ($platform -eq 'windows') { $env:TEMP } else { '/tmp' }
$download_file = "mpls_download.${ext}"
$download_path = "${tmp_dir}${dirsep}${download_file}"
$extract_dir = "${$tmp_dir}${dirsep}mpls_extracted"

# It will always override unless you use `--no-clobber` flag
curl -sL "$string_url" -o "$download_path"

if ($platform -eq 'windows') {
  Expand-Archive -Path $download_path -DestinationPath "$extract_dir"
} else {
  New-Item -ItemType Directory -Path "$extract_dir" -ErrorAction SilentlyContinue
  tar -xzf "$download_path" -C "$extract_dir"
  chmod +x "${download_path}${dirsep}${mpls}"
}

Move-Item "${extract_dir}${dirsep}${mpls}" "${HOME}${dirsep}.local${dirsep}bin${mpls}" -Force -ErrorAction SilentlyContinue

