Option Explicit
dim objShell,psFile,objFSO,strFolder
 Set objShell = CreateObject("Wscript.Shell")
 Set objFSO = CreateObject("Scripting.FileSystemObject")
 strFolder = objFSO.GetParentFolderName(WScript.ScriptFullName)
 psFile = "powershell.exe -ExecutionPolicy Bypass -File " & strFolder & "\update_image.ps1"
 objShell.Run(psFile)