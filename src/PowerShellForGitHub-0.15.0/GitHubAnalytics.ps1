# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

function Group-GitHubIssue
{
<#
    .SYNOPSIS
        Groups the provided issues based on the specified grouping criteria.

    .DESCRIPTION
        Groups the provided issues based on the specified grouping criteria.

        Currently able to group Issues by week.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER Issue
        The Issue(s) to be grouped.

    .PARAMETER Weeks
        The number of weeks to group the Issues by.

    .PARAMETER DateType
        The date property that should be inspected when determining which week grouping the issue
        if part of.

    .INPUTS
        GitHub.Issue

    .OUTPUTS
        [PSCustomObject[]]
        Collection of issues and counts, by week, along with the total count of issues.

    .EXAMPLE
        $issues = @()
        $issues += Get-GitHubIssue -Uri 'https://github.com/powershell/xpsdesiredstateconfiguration'
        $issues += Get-GitHubIssue -Uri 'https://github.com/powershell/xactivedirectory'
        $issues | Group-GitHubIssue -Weeks 12 -DateType Closed
#>
    [CmdletBinding(DefaultParameterSetName = 'Weekly')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification="DateType due to PowerShell/PSScriptAnalyzer#1472")]
    param
    (
        [Parameter(
            Mandatory,
            ValueFromPipeline)]
        [PSCustomObject[]] $Issue,

        [Parameter(
            Mandatory,
            ParameterSetName='Weekly')]
        [ValidateRange(0, 10000)]
        [int] $Weeks,

        [Parameter(ParameterSetName='Weekly')]
        [ValidateSet('Created', 'Closed')]
        [string] $DateType = 'Created'
    )

    begin
    {
        Write-InvocationLog

        if ($PSCmdlet.ParameterSetName -eq 'Weekly')
        {
            $weekDates = Get-WeekDate -Weeks $Weeks

            $result = [ordered]@{}
            foreach ($week in $weekDates)
            {
                $result[$week] = ([PSCustomObject]([ordered]@{
                    'WeekStart' = $week
                    'Count' = 0
                    'Issues' = @()
                }))
            }

            $result['total'] = ([PSCustomObject]([ordered]@{
                'WeekStart' = 'total'
                'Count' = 0
                'Issues' = @()
            }))
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'Weekly')
        {
            $endOfWeek = Get-Date
            foreach ($week in $weekDates)
            {
                $filteredIssues = @($Issue | Where-Object {
                    (($DateType -eq 'Created') -and
                     ($_.created_at -ge $week) -and
                     ($_.created_at -le $endOfWeek)) -or
                    (($DateType -eq 'Closed') -and
                     ($_.closed_at -ge $week) -and
                     ($_.closed_at -le $endOfWeek))
                })

                $endOfWeek = $week

                $result[$week].Issues += $filteredIssues
                $result[$week].Count += ($filteredIssues.Count)

                $result['total'].Issues += $filteredIssues
                $result['total'].Count += ($filteredIssues.Count)
            }
        }
        else
        {
            Write-Output -InputObject $Issue
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq 'Weekly')
        {
            foreach ($entry in $result.Values.GetEnumerator())
            {
                Write-Output -InputObject $entry
            }
        }
    }
}

function Group-GitHubPullRequest
{
<#
    .SYNOPSIS
        Groups the provided pull requests based on the specified grouping criteria.

    .DESCRIPTION
        Groups the provided pull requests based on the specified grouping criteria.

        Currently able to group Pull Requests by week.

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER PullRequest
        The Pull Requests(s) to be grouped.

    .PARAMETER Weeks
        The number of weeks to group the Pull Requests by.

    .PARAMETER DateType
        The date property that should be inspected when determining which week grouping the
        pull request if part of.

    .INPUTS
        GitHub.PullRequest

    .OUTPUTS
        [PSCustomObject[]] Collection of pull requests and counts, by week, along with the
        total count of pull requests.

    .EXAMPLE
        $pullRequests = @()
        $pullRequests += Get-GitHubPullRequest -Uri 'https://github.com/powershell/xpsdesiredstateconfiguration'
        $pullRequests += Get-GitHubPullRequest -Uri 'https://github.com/powershell/xactivedirectory'
        $pullRequests | Group-GitHubPullRequest -Weeks 12 -DateType Closed
#>
    [CmdletBinding(DefaultParameterSetName='Weekly')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification="DateType due to PowerShell/PSScriptAnalyzer#1472")]
    param
    (
        [Parameter(
            Mandatory,
            ValueFromPipeline)]
        [PSCustomObject[]] $PullRequest,

        [Parameter(
            Mandatory,
            ParameterSetName='Weekly')]
        [ValidateRange(0, 10000)]
        [int] $Weeks,

        [Parameter(ParameterSetName='Weekly')]
        [ValidateSet('Created', 'Merged')]
        [string] $DateType = 'Created'
    )

    begin
    {
        Write-InvocationLog

        if ($PSCmdlet.ParameterSetName -eq 'Weekly')
        {
            $weekDates = Get-WeekDate -Weeks $Weeks

            $result = [ordered]@{}
            foreach ($week in $weekDates)
            {
                $result[$week] = ([PSCustomObject]([ordered]@{
                    'WeekStart' = $week
                    'Count' = 0
                    'PullRequests' = @()
                }))
            }

            $result['total'] = ([PSCustomObject]([ordered]@{
                'WeekStart' = 'total'
                'Count' = 0
                'PullRequests' = @()
            }))
        }
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'Weekly')
        {
            $endOfWeek = Get-Date
            foreach ($week in $weekDates)
            {
                $filteredPullRequests = @($PullRequest | Where-Object {
                    (($DateType -eq 'Created') -and
                     ($_.created_at -ge $week) -and
                     ($_.created_at -le $endOfWeek)) -or
                    (($DateType -eq 'Merged') -and
                     ($_.merged_at -ge $week) -and
                     ($_.merged_at -le $endOfWeek))
                })

                $endOfWeek = $week

                $result[$week].PullRequests += $filteredPullRequests
                $result[$week].Count += ($filteredPullRequests.Count)

                $result['total'].PullRequests += $filteredPullRequests
                $result['total'].Count += ($filteredPullRequests.Count)
            }
        }
        else
        {
            Write-Output -InputObject $PullRequest
        }
    }

    end
    {
        if ($PSCmdlet.ParameterSetName -eq 'Weekly')
        {
            foreach ($entry in $result.Values.GetEnumerator())
            {
                Write-Output -InputObject $entry
            }
        }
    }
}

function Get-WeekDate
{
<#
    .SYNOPSIS
        Retrieves an array of dates with starts of $Weeks previous weeks.
        Dates are sorted in reverse chronological order

    .DESCRIPTION
        Retrieves an array of dates with starts of $Weeks previous weeks.
        Dates are sorted in reverse chronological order

        The Git repo for this module can be found here: http://aka.ms/PowerShellForGitHub

    .PARAMETER Weeks
        The number of weeks prior to today that should be included in the final result.

    .OUTPUTS
        [DateTime[]] List of DateTimes representing the first day of each requested week.

    .EXAMPLE
        Get-WeekDate -Weeks 10
#>
    [CmdletBinding()]
    [OutputType([DateTime[]])]
    param(
        [ValidateRange(0, 10000)]
        [int] $Weeks = 12
    )

    $dates = @()

    $midnightToday = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    $startOfWeek = $midnightToday.AddDays(- ($midnightToday.DayOfWeek.value__ - 1))

    $i = 0
    while ($i -lt $Weeks)
    {
        $dates += $startOfWeek
        $startOfWeek = $startOfWeek.AddDays(-7)
        $i++
    }

    return $dates
}

# SIG # Begin signature block
# MIIjkgYJKoZIhvcNAQcCoIIjgzCCI38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBsqaUSZNZy0oqs
# YxQV8iSxHQ0y4VdmtTXJd2iUnpj+kKCCDYEwggX/MIID56ADAgECAhMzAAABh3IX
# chVZQMcJAAAAAAGHMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwMzA0MTgzOTQ3WhcNMjEwMzAzMTgzOTQ3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDOt8kLc7P3T7MKIhouYHewMFmnq8Ayu7FOhZCQabVwBp2VS4WyB2Qe4TQBT8aB
# znANDEPjHKNdPT8Xz5cNali6XHefS8i/WXtF0vSsP8NEv6mBHuA2p1fw2wB/F0dH
# sJ3GfZ5c0sPJjklsiYqPw59xJ54kM91IOgiO2OUzjNAljPibjCWfH7UzQ1TPHc4d
# weils8GEIrbBRb7IWwiObL12jWT4Yh71NQgvJ9Fn6+UhD9x2uk3dLj84vwt1NuFQ
# itKJxIV0fVsRNR3abQVOLqpDugbr0SzNL6o8xzOHL5OXiGGwg6ekiXA1/2XXY7yV
# Fc39tledDtZjSjNbex1zzwSXAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhov4ZyO96axkJdMjpzu2zVXOJcsw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDU4Mzg1MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAixmy
# S6E6vprWD9KFNIB9G5zyMuIjZAOuUJ1EK/Vlg6Fb3ZHXjjUwATKIcXbFuFC6Wr4K
# NrU4DY/sBVqmab5AC/je3bpUpjtxpEyqUqtPc30wEg/rO9vmKmqKoLPT37svc2NV
# BmGNl+85qO4fV/w7Cx7J0Bbqk19KcRNdjt6eKoTnTPHBHlVHQIHZpMxacbFOAkJr
# qAVkYZdz7ikNXTxV+GRb36tC4ByMNxE2DF7vFdvaiZP0CVZ5ByJ2gAhXMdK9+usx
# zVk913qKde1OAuWdv+rndqkAIm8fUlRnr4saSCg7cIbUwCCf116wUJ7EuJDg0vHe
# yhnCeHnBbyH3RZkHEi2ofmfgnFISJZDdMAeVZGVOh20Jp50XBzqokpPzeZ6zc1/g
# yILNyiVgE+RPkjnUQshd1f1PMgn3tns2Cz7bJiVUaqEO3n9qRFgy5JuLae6UweGf
# AeOo3dgLZxikKzYs3hDMaEtJq8IP71cX7QXe6lnMmXU/Hdfz2p897Zd+kU+vZvKI
# 3cwLfuVQgK2RZ2z+Kc3K3dRPz2rXycK5XCuRZmvGab/WbrZiC7wJQapgBodltMI5
# GMdFrBg9IeF7/rP4EqVQXeKtevTlZXjpuNhhjuR+2DMt/dWufjXpiW91bo3aH6Ea
# jOALXmoxgltCp1K7hrS6gmsvj94cLRf50QQ4U8Qwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVZzCCFWMCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAYdyF3IVWUDHCQAAAAABhzAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg0n0cEb8c
# IMHGlwEj5CNwMJ2mgsx1Fl3b3CRvFxrSfbswQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQCsGlrn5+OpileU3qs46L2pS62aHy3xDmvdZ3IgLd44
# 5IxTBMO/Blzp6hsn30mva7LrojGRiI+DtZ+ICnxna2+M0UVzFATjfbxQxnZ3PFo1
# lw6h6z361OeN3G6ashzRLvo+kpY95HHhQLROf+SqWLF9TXeLLcPXE2plwl/h4MXt
# M2JR9ThsO2WENDtOi0xfpgwb/HhRoVQOoo3Emlcw2L9HxNV9SKjddhHoZaDxMOrV
# EqGbDcIn73Xwp8pn96UYpg89fc1rnuwZmNU1hdoPls6QgHfJSa8O9awNrrL5V8Lr
# u5Zzqs/InUFYr7KawJlTAOH+F1XZhtuuxecvtr/S58HuoYIS8TCCEu0GCisGAQQB
# gjcDAwExghLdMIIS2QYJKoZIhvcNAQcCoIISyjCCEsYCAQMxDzANBglghkgBZQME
# AgEFADCCAVUGCyqGSIb3DQEJEAEEoIIBRASCAUAwggE8AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIGfcBPXdjNFXtQplJQvsDpQ3jY7irAU5QZPE1aGy
# tucZAgZf25jrm+sYEzIwMjEwMTA1MTk1MDUzLjQxMlowBIACAfSggdSkgdEwgc4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1p
# Y3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjozMkJELUUzRDUtM0IxRDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCDkQwggT1MIID3aADAgECAhMzAAABLqjSGQeT9GvoAAAA
# AAEuMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTE5MTIxOTAxMTUwNVoXDTIxMDMxNzAxMTUwNVowgc4xCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVy
# YXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjozMkJE
# LUUzRDUtM0IxRDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK7TTKJRU196LFIjMQ9q
# /UjpPhz43m5RnHgHAVp2YGni74+ltsYoO1nZ58rTbJhCQ8GYHy8B4devgbqqYPQN
# U3i+drpEtEcNLbsMr4MEq3SM+vO3a6QMFd1lDRy7IQLPJNLKvcM69Nt7ku1YyM5N
# nPNDcRJsnUb/8Yx/zcW5cWjnoj8s9fQ93BPf/J74qM1ql2CdzQV74PBisMP/tppA
# nSuNwo8I7+uWr6vfpBynSWDvJeMDrcsa62Xsm7DbB1NnSsPGAGt3RzlBV9KViciz
# e4U3fo4chdoB2+QLu17PaEmj07qq700CG5XJkpEYOjedNFiByApF7YRvQrOZQ07Q
# YiMCAwEAAaOCARswggEXMB0GA1UdDgQWBBSGmokmTguJN7uqSTQ1UhLwt1RObDAf
# BgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBH
# hkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNU
# aW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
# BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
# YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQCN4ARqpzCuutNqY2nWJDDXj35iaidl
# gtJ/bspYsAX8atJl19IfUKIzTuuSVU3caXZ6/YvMMYMcbsNa/4J28us23K6PWZAl
# jIj0G8QtwDMlQHjrKnrcr4FBAz6ZqvB6SrN3/Wbb0QSK/OlxsU0mfD7z87R2JM4g
# wKJvH6EILuAEtjwUGSB1NKm3Twrm51fCD0jxvWxzaUS2etvMPrh8DNrrHLJBR3UH
# vg/NXS2IzdQn20xjjsW0BUAiTf+NCRpxUvu/j80Nb1++vnejibfpQJ2IlXiJdIi+
# Hb+OL3XOr8MaDDSYOaRFAIfcoq3VPi4BkvSC8QGrvhjAZafkE7R6L5FJMIIGcTCC
# BFmgAwIBAgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJv
# b3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcN
# MjUwNzAxMjE0NjU1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0
# VBDVpQoAgoX77XxoSyxfxcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEw
# RA/xYIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQe
# dGFnkV+BVLHPk0ySwcSmXdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKx
# Xf13Hz3wV3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo8noqCjHw2k4G
# kbaICDXoeByw6ZnNPOcvRLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0CAwEA
# AaOCAeYwggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpcijGQ80N7
# fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0g
# AQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYB
# BQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUA
# bQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9naOh
# IW+z66bM9TG+zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RXCCtRgkQS
# +7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzymXlK
# kVIArzgPF/UveYFl2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCfMkon
# /VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3DnKOi
# PPp/fZZqkHimbdLhnPkd/DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/
# fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF0M2n0O99g/DhO3EJ3110mCII
# YdqwUB5vvfHhAN/nMQekkzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0
# cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3gMy4SKfXAL1QnIffIrE7a
# KLixqduWsqdCosnPGUFN4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQ
# cdeh0sVV42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQNdrvCScc1bN+
# NR4Iuto229Nfj950iEkSoYIC0jCCAjsCAQEwgfyhgdSkgdEwgc4xCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBP
# cGVyYXRpb25zIFB1ZXJ0byBSaWNvMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjoz
# MkJELUUzRDUtM0IxRDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
# dmljZaIjCgEBMAcGBSsOAwIaAxUA+1/CN6BILeU1yDGo+b6WkpLoQpuggYMwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIF
# AOOfI3AwIhgPMjAyMTAxMDUyMTQyMDhaGA8yMDIxMDEwNjIxNDIwOFowdzA9Bgor
# BgEEAYRZCgQBMS8wLTAKAgUA458jcAIBADAKAgEAAgIgiwIB/zAHAgEAAgIShjAK
# AgUA46B08AIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIB
# AAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBADO/v1LhYSIRa+pw
# moY4T/Wn9rGRbxSt6xluXO+NOlHsK6alpNz+tlOTXXZ4zAkQW0rgPp10q82qE+hV
# KLWiEOHxIbR9AGfCCFAWzLuso28D2tFupc3CtpWvlXhcFFJKE98fPBQCo/WrwbTA
# An+B9iLg1m5osrpdQzPUv1oVNPm2MYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAEuqNIZB5P0a+gAAAAAAS4wDQYJYIZIAWUD
# BAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0B
# CQQxIgQgeQr/xRPZDaqkFe8+ztPViRIykfOjU/4YaKKPEjqs4jUwgfoGCyqGSIb3
# DQEJEAIvMYHqMIHnMIHkMIG9BCDa/s3O8YhWiqpVN0kTeK+x2m0RAh17JpR6DiFo
# TILJKTCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# LqjSGQeT9GvoAAAAAAEuMCIEILD8Woq3rjCz7I8y8FkuHNEsftt3u/A/W70cl/6w
# 8ienMA0GCSqGSIb3DQEBCwUABIIBAButB7xqG0r5THHzf1NMV4nkDGi36cVz2c3d
# ycM4HAcMeXP+DcxpERY+QKrqx+Nu5JyA6VtdkRHbNGCcQ423MD2DBnX1yk+CPhAf
# KSSOIK1Aw7zHmGebYHvICM+65azmgLtrEBuRM4d1FRNgVOE9Sv6OHUY1xe6Hb1hT
# /Ecyr3qdiorGZWS9+AOLRgIfZ5GriyC2LkEGjU/pUtu48pTJWDK0spnUty3xKPzq
# NxSktFEzKEubW7fWevCXo7/w/7PxlEVs/CMAqSVDGNVJJVYdPllqDGnl4fMcRoOj
# qPqQNWmCKaDMgASPu4Vs1FCVLsSom5xlLHcIw07aBO1TSGO5c/c=
# SIG # End signature block