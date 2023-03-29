
Write-Output "------------------------CREATE HTML------------------------"

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
    $releases = Get-GitHubRelease -OwnerName $ownerName -RepositoryName $repositoryName
    $htmlBody = ""
    foreach ($release in $releases) {
        if($release.tag_name -cne 'v1.0.4'){
            foreach ($asset in $release.assets) {
                if($release.tag_name -eq 'configurations'){
                   
                }elseif($release.tag_name -eq 'Resources'){

                }else{
                    $htmlBody = $htmlBody+ "<a href='$($asset.browser_download_url)'>$($release.tag_name)</a> 
                    </br>"
                }
            }
        }
    }
    Write-Host "HTML BODY: $($htmlBody)"

    $content = Get-Content template.html -Raw
    $content = $content.Replace("{body}",$htmlBody)

    Set-GitHubContent -OwnerName $ownerName -RepositoryName $repositoryName  -Path $fileName -CommitMessage 'update html' -Content $content -BranchName main
}
catch { 
    Write-Host "An error occurred:"
    Write-Host $_
}

##Get-Help New-GitHubReleaseAsset -ShowWindow

Read-Host "Enter to exsit"