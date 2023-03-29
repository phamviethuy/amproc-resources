
Write-Output "------------------------BUILD RELASE------------------------"

$ownerName = "phamviethuy"
$repositoryName = "amproc-resources"
$fileName="src/index.html"

Import-Module -Name "./PowerShellForGitHub-0.15.0/PowerShellForGitHub.psm1"
$PSDefaultParameterValues["*-GitHub*:AccessToken"] = "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"
Set-GitHubConfiguration -DisableTelemetry

function Get-ReleaseId([string]$Tagname) {
    
    $releases = Get-GitHubRelease -OwnerName $ownerName -RepositoryName $repositoryName
    $releaseId = 0
    foreach ($release in $releases) {
        Write-Host "in for release loop tag name: $($release.tag_name)" 
        Write-Host "in for release loop id: $($release.id)" 

        if ($release.tag_name -eq $TagName) {
            $releaseId = $release.id
            Write-Host "Found release $($release.id) $($release.tag_name)"
        }
    }

    return $releaseId
}

function Get-HasAsset([string]$Name, [int]$ReleaseId) {
    $assetId = 0
    $assets = Get-GitHubReleaseAsset -OwnerName $ownerName -RepositoryName $repositoryName -Release $ReleaseId
    foreach ($asset in $assets) {
        Write-Host "Get asset: $($asset.name)"
        if ($asset.name -eq $Name) {
            $assetId = $asset.id
            Write-Host "Found asset $($asset.name) $($assetId)"
        }
    }
    return $assetId
}

function Set-LogModule([string]$Content) {
    Write-Host "-----------------------------$($Content)-----------------------------"
}


try { 

    Set-LogModule  'Update HTML file'
    Set-GitHubContent -OwnerName $ownerName -RepositoryName $repositoryName  -Path $fileName -CommitMessage $content -Content $content -BranchName main
    Write-Host "CREATE HTML FILE DONE"
    
}
catch { 
    Write-Host "An error occurred:"
    Write-Host $_
}

Write-Host "Create HTML file done" 
Read-Host "Enter to exsit"