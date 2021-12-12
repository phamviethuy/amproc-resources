
$myPicturePath = [Environment]::GetFolderPath("MyDocuments")
$companyPath = [Environment]::GetFolderPath("MyDocuments") + "\amproc"
$resourceFolderPath = [Environment]::GetFolderPath("MyDocuments") + "\amproc\Resources"
$modelPath = $resourceFolderPath + "/avr"
$currentFolder = [System.Environment]::CurrentDirectory + "\*"


Write-Host "Start..."
If (!(test-path $companyPath))
{
    New-Item -Path $myPicturePath -Name "amproc" -ItemType "directory"
    Write-Host "Create folder amproc"
}

If (!(test-path $resourceFolderPath))
{
    New-Item -Path $companyPath -Name "Resources" -ItemType "directory"
    Write-Host "Create folder resourceFolderPath"
}

If (!(test-path $modelPath))
{
    New-Item -Path $resourceFolderPath -Name "avr" -ItemType "directory"
    Write-Host "Create folder avr"
}


 Write-Host "Start copy ..."
	Copy-Item -Path $currentFolder -Recurse -Force -Destination $modelPath -Container
 Write-Host "Copy completed."
 
 Read-Host "Enter to exsit"
