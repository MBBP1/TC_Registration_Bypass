# === Created by Mikkel BB-P ===

# === Base path (portable & clean) ===
$basePath = "$env:APPDATA\TC-Auto"
New-Item -ItemType Directory -Path $basePath -Force | Out-Null

$ps1Path = Join-Path $basePath "StartTC.ps1"
$vbsPath = Join-Path $basePath "StartTC.vbs"
$shortcutPath = "$env:USERPROFILE\Desktop\Total Commander.lnk"

# === Find Total Commander ===
$tcPaths = @(
    "$env:ProgramFiles\totalcmd\TOTALCMD64.EXE",
    "$env:ProgramFiles(x86)\totalcmd\TOTALCMD.EXE"
)

$tcExe = $tcPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $tcExe) {
    Write-Host "Total Commander ikke fundet!"
    exit
}

# === StartTC.ps1 (automation) ===
$ps1Content = @'
Start-Process "__TC_PATH__" | Out-Null

Start-Sleep -Milliseconds 300

Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class W{
  public delegate bool E(IntPtr h,IntPtr p);
  [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern IntPtr FindWindow(string c,string t);
  [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr p,E f,IntPtr l);
  [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr h,StringBuilder s,int n);
  [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern int GetClassName(IntPtr h,StringBuilder s,int n);
  [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr h,int m,IntPtr w,IntPtr l);
  public const int BM_CLICK=0x00F5;
}
"@

function T($h){
  $b=New-Object Text.StringBuilder 512
  [void][W]::GetWindowText($h,$b,$b.Capacity)
  $b.ToString()
}

function C($h){
  $b=New-Object Text.StringBuilder 64
  [void][W]::GetClassName($h,$b,$b.Capacity)
  $b.ToString()
}

$w=0
for($i=0;$i -lt 400;$i++){
    $w=[W]::FindWindow("TNASTYNAGSCREEN","Total Commander")
    if($w -ne 0){break}
    Start-Sleep -Milliseconds 10
}
if($w -eq 0){exit}

$n=$null
for($j=0;$j -lt 200 -and -not $n;$j++){
  $script:n=$null
  [W]::EnumChildWindows($w,[W+E]{
    param($h,$p)
    $t=(T $h).Trim()
    if($t){
      foreach($l in ($t -split "(`r`n|`n|`r)")){
        $l=$l.Trim()
        if($l -match '^[123]$'){
          $script:n=$l
          return $false
        }
      }
    }
    $true
  },[IntPtr]::Zero) | Out-Null

  if(-not $n){ Start-Sleep -Milliseconds 50 }
}
if(-not $n){exit}

$a="&$n"
$b="$n"
$btn=[IntPtr]::Zero

for($k=0;$k -lt 200 -and $btn -eq [IntPtr]::Zero;$k++){
  $script:btn=[IntPtr]::Zero
  [W]::EnumChildWindows($w,[W+E]{
    param($h,$p)
    if($script:btn -ne [IntPtr]::Zero){return $false}
    if((C $h) -ne "Button"){return $true}

    $t=(T $h).Trim()
    if($t -eq $script:a -or $t -eq $script:b){
      $script:btn=$h
      return $false
    }
    $true
  },[IntPtr]::Zero) | Out-Null

  if($btn -eq [IntPtr]::Zero){ Start-Sleep -Milliseconds 50 }
}

if($btn -ne [IntPtr]::Zero){
  [void][W]::SendMessage($btn,[W]::BM_CLICK,[IntPtr]::Zero,[IntPtr]::Zero)
}
'@

# insert correct path
$ps1Content = $ps1Content.Replace("__TC_PATH__", $tcExe)

Set-Content -Path $ps1Path -Value $ps1Content -Encoding UTF8

# === VBS ===
$vbsContent = @"
CreateObject("Wscript.Shell").Run "powershell.exe -ExecutionPolicy Bypass -File ""$ps1Path""", 0, False
"@

Set-Content -Path $vbsPath -Value $vbsContent -Encoding ASCII

# === Shortcut ===
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)

$Shortcut.TargetPath = "$env:SystemRoot\System32\wscript.exe"
$Shortcut.Arguments = "`"$vbsPath`""
$Shortcut.WorkingDirectory = $basePath
$Shortcut.IconLocation = $tcExe

$Shortcut.Save()

Write-Host "Setup finished Shortcut created on desktop."


