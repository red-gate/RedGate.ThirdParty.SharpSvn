<#
.SYNOPSIS
    Build the RedGate.ThirdParty.SharpSvn nuget package.
.DESCRIPTION
    * Download nuget.exe
    * Install the SharpSvn official packages. (both x86 and x64 versions)
    * nuget pack RedGate.ThirdParty.SharpSvn.nuspec.
    * The created RedGate.ThirdParty.SharpSvn has the same version as the SharpSvn packages it was created from.

    Note that this script doesn't push the package anywhere. Do it youself.
#>
param (
    # The name of the SharpSVN packages to wrap. (-x86 and x64 will be appended to it)
    # Default to SharpSvn.1.9
    [string] $PackageName = 'SharpSvn.1.9',
    # The version of the SharpSVN packages to wrap.
    # Default to 1.9003.3799.86
    [string] $Version = '1.9003.3799.86'
)

$VerbosePreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

if($PackageName -like '*-x86') { throw 'No -x86 suffix please.'}
if($PackageName -like '*-x64') { throw 'No -x64 suffix please.'}

try {
    Push-Location $PSScriptRoot

    if(!(Test-Path .\nuget.exe)) {
        Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/v3.3.0/nuget.exe' -OutFile .\nuget.exe
    }

    if(Test-Path .\packages) { Remove-Item .\packages -Force -Recurse -verbose }
    if(Test-Path .\files) { Remove-Item .\files -Force -Recurse -verbose }
    New-Item packages -ItemType Directory -verbose| Out-Null
    New-Item files\x86 -ItemType Directory -Force -verbose| Out-Null
    New-Item files\x64 -ItemType Directory -Force -verbose | Out-Null

    .\nuget.exe install $PackageName-x86 -OutputDirectory packages -ExcludeVersion
    .\nuget.exe install $PackageName-x64 -OutputDirectory packages -ExcludeVersion

    # Move the content of the packages to fit our nuspec file.
    # we are only interest in files in the net20\ folder.
    Get-ChildItem .\packages\$PackageName-x86\lib\net20\* -Include '*.svn*', '*.dll' | Copy-Item -Destination .\files\x86 -verbose
    Get-ChildItem .\packages\$PackageName-x64\lib\net20\* -Include '*.svn*', '*.dll' | Copy-Item -Destination .\files\x64 -verbose

    # Rename the SharpSvn.dll assemblies that will be packaged in the build\ folder so that
    # they cannot be confused with lib\net20\SharpSvn.dll that is the only 'lib' assembly of the RedGate.ThirdParty.SharpSvn package.
    # (if we don't do this, this assemblies can end up being resolved by Msbuild at build time, which can cause processor architecture related compile errors)
    Rename-Item .\files\x86\SharpSvn.dll -NewName SharpSvn-x86.dll
    Rename-Item .\files\x64\SharpSvn.dll -NewName SharpSvn-x64.dll

    # This is the package main assembly that will be referenced in 'lib'
    Copy-Item .\files\x86\SharpSvn-x86.dll .\files\SharpSvn.dll

    .\nuget.exe pack RedGate.ThirdParty.SharpSVN.nuspec -Version $Version -BasePath files -NoDefaultExclude -verbosity detailed

} finally {
    Pop-Location
}
