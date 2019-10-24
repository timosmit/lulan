param(
    [string]$Action = "help",
    [string]$Arg
)

$Dir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$Lua = "$($Dir)/lua/lua50.exe"
$LuaLink = "https://liquidtelecom.dl.sourceforge.net/project/luabinaries/5.0.3/Tools%20Executables/lua5_0_3_Win32_bin.zip"

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Downloads and installs Lua.
function LuaGet
{
	if (Test-Path $Lua)
	{
		return
	}

	"Downloading Lua binaries."
	Invoke-WebRequest -Uri $LuaLink -OutFile ".lua.zip"

	"Extracting Lua binaries."
	New-Item -ItemType Directory -Path "$($Dir)/lua"
	[System.IO.Compression.ZipFile]::ExtractToDirectory(".lua.zip", "$($Dir)/lua")
	Remove-Item -Path ".lua.zip"
}

# Executes a Lua file.
function LuaRun
{
    param([string]$File)

	LuaGet

    &$Lua $File

    if($LASTEXITCODE -ne 0)
    {
        "$($Dir)/$($File) returned non-zero exit code."
        exit
    }
}

# Executes a test suite.
function RunTest
{
    param([string]$File)
    "TEST: $($File)"
    LuaRun $File
}

# Executes all test suites.
function RunTestAll
{
    $files = Get-ChildItem $Dir -name -recurse *.test.lua
    foreach($file in $files)
    {
        RunTest $file
    }
}

switch($Action)
{

    "test"
    {

        if ($Arg -eq "")
        {
            RunTestAll
        } else
        {
            RunTest $Arg
        }

    }

    Default
    {
        "powershell -Action <action> [-Arg <argument>]"
        "Actions:"
        "- help"
        "- test [-Arg dir/?.test.lua]"
        "- build"
    }

}