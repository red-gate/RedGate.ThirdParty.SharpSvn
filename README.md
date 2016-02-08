# RedGate.ThirdParty.SharpSvn
A package to wrap SharpSvn x86 and x64.

This package installs:
* SharpSvn-x86 assemblies as content files into a `x86` folder which will be copied to the build output.
* SharpSvn-x64 assemblies as content files into a `x64` folder which will be copied to the build output.

## How to build
In powershell
```
git clone https://github.com/red-gate/RedGate.ThirdParty.SharpSvn
cd .\RedGate.ThirdParty.SharpSvn

# Update the version to build/grab a different version of sharpvn.
# Update the package name once SharpSvn ship another major version.
.\build.ps1 -PackageName 'SharpSvn.1.9' -Version '1.9003.3799.86'
```
