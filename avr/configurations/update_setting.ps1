$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

$myDocumentsPath = [Environment]::GetFolderPath("MyDocuments")
$companyPath = $myDocumentsPath + "\amproc"
$configPath = $companyPath + "\configurations"
Write-Output "Update configurations"
Write-Output "Start..."
If (!(test-path $companyPath))
{
    New-Item -Path $myDocumentsPath -Name "amproc" -ItemType "directory"
    Write-Output "Create folder amproc"
}

If (!(test-path $configPath))
{
    New-Item -Path $companyPath -Name "configurations" -ItemType "directory"
    Write-Output "Create folder configurations"
}
 Write-Output "Start copy ..."
	Copy-Item -Path $currentFolder -Recurse -Destination $configPath -Container
 Write-Output "Copy completed."

 Read-Host "Enter to exsit"