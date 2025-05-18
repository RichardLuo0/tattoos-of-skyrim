$ErrorActionPreference = 'Stop'
& $Env:USERPROFILE\.vscode\extensions\joelday.papyrus-lang-vscode-*\pyro\pyro.exe "--input-path" skyrimse.ppj "--game-path" "C:\Games\Steam\steamapps\common\Skyrim Special Edition" 
7z a -tzip TattoosOfSkyrimImproved.zip interface MCM Scripts Source *.ini *.esp
