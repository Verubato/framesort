<# install-luacheck.ps1
Installs luacheck for Lua 5.1 x86 using Chocolatey LuaRocks (win32) + MSVC x86 + WinSDK.
Does NOT rely on luarocks "run" or "path" commands (since your loaded core lacks them).

It:
- Forces MSVC x86 + WinSDK include/lib env
- Forces LuaRocks module paths to avoid loading old 2.0.2 LuaRocks modules from LuaForWindows
- Installs luafilesystem, argparse, luacheck into: <LuaRocksRoot>\systree
#>

param(
    [string]$LuaExe = "C:\Program Files (x86)\Lua\5.1\lua.exe",
    [string]$LuaRocksRoot = "C:\ProgramData\chocolatey\lib\luarocks\luarocks-2.4.4-win32",

    [string]$VsBuildToolsRoot = "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools",
    [string]$MsvcVersion = "14.50.35717",

    [string]$WindowsKitsIncludeVersion = "10.0.26100.0",
    [string]$WindowsKitsLibVersion     = "10.0.26100.0",
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Path([string]$p, [string]$hint) {
    if (-not (Test-Path -LiteralPath $p)) { throw "Missing: $p`n$hint" }
}

function Find-FirstExistingSdkVersion([string]$baseDir) {
    if (-not (Test-Path -LiteralPath $baseDir)) { return $null }
    Get-ChildItem -LiteralPath $baseDir -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' } |
        Sort-Object Name -Descending |
        Select-Object -First 1 -ExpandProperty Name
}

function Prepend-Path([string]$dir) {
    if (-not (Test-Path -LiteralPath $dir)) { return }
    $parts = $env:Path -split ';'
    if ($parts[0] -ne $dir) { $env:Path = $dir + ";" + $env:Path }
}

function Append-Path([string]$dir) {
    if (-not (Test-Path -LiteralPath $dir)) { return }
    $parts = $env:Path -split ';'
    if ($parts -notcontains $dir) { $env:Path = $env:Path.TrimEnd(';') + ";" + $dir }
}

function Invoke-LuaRocks {
    param([Parameter(Mandatory=$true)][string[]]$Args)

    $luarocksLua = Join-Path $LuaRocksRoot "luarocks.lua"
    Assert-Path $luarocksLua "LuaRocks script not found at: $luarocksLua"

    # Force LuaRocks 2.4.4 module tree (avoid old LuaForWindows luarocks 2.0.2 collisions)
    $oldLuaPath  = $env:LUA_PATH
    $oldLuaCPath = $env:LUA_CPATH
    try {
        $env:LUA_PATH  = (Join-Path $LuaRocksRoot "lua\?.lua") + ";" + (Join-Path $LuaRocksRoot "lua\?\init.lua") + ";;"
        $env:LUA_CPATH = (Join-Path $LuaRocksRoot "lua\?.dll") + ";;"

        Write-Host ("`n>> lua luarocks.lua " + ($Args -join ' ')) -ForegroundColor Cyan
        & $LuaExe $luarocksLua @Args
        if ($LASTEXITCODE -ne 0) { throw "LuaRocks failed (exit code $LASTEXITCODE) for: $($Args -join ' ')" }
    }
    finally {
        $env:LUA_PATH  = $oldLuaPath
        $env:LUA_CPATH = $oldLuaCPath
    }
}

function New-TreeLuaPaths([string]$tree) {
    # Build LUA_PATH/LUA_CPATH for the installed tree without relying on 'luarocks path'
    $paths = New-Object System.Collections.Generic.List[string]

    # Standard locations
    $paths.Add((Join-Path $tree "share\lua\5.1\?.lua"))
    $paths.Add((Join-Path $tree "share\lua\5.1\?\init.lua"))
    $paths.Add((Join-Path $tree "lib\lua\5.1\?.lua"))
    $paths.Add((Join-Path $tree "lib\lua\5.1\?\init.lua"))

    # Rock-specific locations (older rocks often place lua modules under these)
    $rocks = Join-Path $tree "lib\luarocks\rocks"
    if (Test-Path -LiteralPath $rocks) {
        # include lua modules under ...\rocks\<rock>\<ver>\lua\?.lua etc
        $paths.Add((Join-Path $rocks "?\?\lua\?.lua"))
        $paths.Add((Join-Path $rocks "?\?\lua\?\init.lua"))

        # include src/lib layouts too (luacheck 1.2.0 often uses these)
        $paths.Add((Join-Path $rocks "?\?\src\?.lua"))
        $paths.Add((Join-Path $rocks "?\?\src\?\init.lua"))
        $paths.Add((Join-Path $rocks "?\?\lib\?.lua"))
        $paths.Add((Join-Path $rocks "?\?\lib\?\init.lua"))
    }

    $luaPath = ($paths -join ';') + ';;'

    # C modules (.dll)
    $cpaths = New-Object System.Collections.Generic.List[string]
    $cpaths.Add((Join-Path $tree "lib\lua\5.1\?.dll"))
    if (Test-Path -LiteralPath $rocks) {
        $cpaths.Add((Join-Path $rocks "?\?\lib\?.dll"))
        $cpaths.Add((Join-Path $rocks "?\?\?.dll"))
    }
    $luaCPath = ($cpaths -join ';') + ';;'

    return @{ LUA_PATH = $luaPath; LUA_CPATH = $luaCPath }
}

# --- Validate inputs ---
Assert-Path $LuaExe "Install Lua 5.1 x86 at $LuaExe (or pass -LuaExe)."
Assert-Path (Join-Path $LuaRocksRoot "luarocks.lua") "Chocolatey LuaRocks not found at: $LuaRocksRoot"

# --- MSVC (x86) ---
$msvcBase = Join-Path $VsBuildToolsRoot "VC\Tools\MSVC"
$msvcRoot = Join-Path $msvcBase $MsvcVersion
if (-not (Test-Path -LiteralPath $msvcRoot)) {
    $found = Get-ChildItem -LiteralPath $msvcBase -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($found) {
        $msvcRoot = $found.FullName
        $MsvcVersion = $found.Name
        Write-Host "Using detected MSVC version: $MsvcVersion" -ForegroundColor Yellow
    }
}
$msvcBin = Join-Path $msvcRoot "bin\Hostx86\x86"
$msvcInc = Join-Path $msvcRoot "include"
$msvcLib = Join-Path $msvcRoot "lib\x86"

Assert-Path (Join-Path $msvcBin "cl.exe") "MSVC x86 cl.exe not found. Install MSVC Build Tools."
Assert-Path (Join-Path $msvcInc "vcruntime.h") "MSVC headers missing."

# --- Windows SDK ---
$kitsRoot = "C:\Program Files (x86)\Windows Kits\10"
$kitsIncludeBase = Join-Path $kitsRoot "Include"
$kitsLibBase     = Join-Path $kitsRoot "Lib"

if (-not (Test-Path -LiteralPath (Join-Path $kitsIncludeBase $WindowsKitsIncludeVersion))) {
    $det = Find-FirstExistingSdkVersion $kitsIncludeBase
    if ($det) { $WindowsKitsIncludeVersion = $det; Write-Host "Using detected Windows Kits Include: $WindowsKitsIncludeVersion" -ForegroundColor Yellow }
}
if (-not (Test-Path -LiteralPath (Join-Path $kitsLibBase $WindowsKitsLibVersion))) {
    $det = Find-FirstExistingSdkVersion $kitsLibBase
    if ($det) { $WindowsKitsLibVersion = $det; Write-Host "Using detected Windows Kits Lib: $WindowsKitsLibVersion" -ForegroundColor Yellow }
}

$kitsInc = Join-Path $kitsIncludeBase $WindowsKitsIncludeVersion
$kitsLib = Join-Path $kitsLibBase     $WindowsKitsLibVersion

Assert-Path (Join-Path $kitsInc "ucrt\errno.h") "Windows SDK headers missing."
Assert-Path (Join-Path $kitsLib "um\x86\uuid.lib") "Windows SDK libs missing (uuid.lib)."

# --- Force toolchain env in THIS PowerShell process ---
Prepend-Path $msvcBin
$env:INCLUDE = @(
    $msvcInc
    (Join-Path $kitsInc "ucrt")
    (Join-Path $kitsInc "um")
    (Join-Path $kitsInc "shared")
    (Join-Path $kitsInc "winrt")
    (Join-Path $kitsInc "cppwinrt")
) -join ';'
$env:LIB = @(
    $msvcLib
    (Join-Path $kitsLib "ucrt\x86")
    (Join-Path $kitsLib "um\x86")
) -join ';'

Write-Host "`nUsing:" -ForegroundColor Green
Write-Host ("  Lua:      " + $LuaExe)
Write-Host ("  LuaRocks:  " + (Join-Path $LuaRocksRoot "luarocks.lua"))
Write-Host ("  MSVC bin:  " + $msvcBin)
Write-Host ("  WinSDK:    " + $WindowsKitsIncludeVersion + " / " + $WindowsKitsLibVersion)

# --- Install into a known tree ---
$tree = Join-Path $LuaRocksRoot "systree"
New-Item -ItemType Directory -Force -Path $tree | Out-Null

Invoke-LuaRocks -Args @("install", "--tree", $tree, "luafilesystem")
Invoke-LuaRocks -Args @("install", "--tree", $tree, "argparse")
Invoke-LuaRocks -Args @("install", "--tree", $tree, "luacheck")

Write-Host "`nInstalled rocks in tree:" -ForegroundColor Green
Invoke-LuaRocks -Args @("list", "--tree", $tree)
