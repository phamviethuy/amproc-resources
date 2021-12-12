$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

$myDocumentsPath = [Environment]::GetFolderPath("MyDocuments")
$companyPath = $myDocumentsPath + "\amproc"
$configPath = $companyPath + "\configurations"

$currentFolder = [System.Environment]::CurrentDirectory + "\*"
Write-Output "----------Chọn cài đặt mong muốn---------------"
Write-Output "Chọn 2 nếu bạn thực sự hiểu lựa chọn này"
Write-Output "1: Bỏ qua"
Write-Output "2: Tạo mới Setting hoặc cập nhật cài đặt khi có cập nhật mới. Chỉ sử dụng khi lỗi phần mềm hoặc có yêu cầu từ vendor"

$option = Read-Host -Prompt "Nhập lựa chọn"

if($option -eq "2"){
    stop-process -Id $PID
}


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