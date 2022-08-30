$token = "your token here"
$organization = "your_organization_name_here"
$backuproot = "C:\your_repo_backup_folder\"
$backupfolder = "$($backuproot)\$(get-date -f MM-dd-yyyy_HH_mm_ss)\"


$e = @{
    Uri     = "https://dev.azure.com/$($organization)/_apis/projects?api-version=5.1"
    Headers = @{"Authorization" = "Basic $($Token)"}
}
try { 

$response = Invoke-RestMethod @e

foreach ($i in $response.value)
{
    $e2 = @{
    Uri     = "https://dev.azure.com/$($organization)/$($i.name)/_apis/git/repositories?api-version=5.1"
    Headers = @{"Authorization" = "Basic $($token)"}
    }
    $response2 = Invoke-RestMethod @e2
    foreach ($i2 in $response2.value)
    {
        $Subrepo = $i2.Name -replace '\(',"" -replace '\)',""
        Write-Host "git clone --mirror -c http.extraheader=`"AUTHORIZATION: Basic $($token)`" $($i2.WebURL) $backupfolder$($i.name)_$($Subrepo)"
        Invoke-Expression "git clone --mirror -c http.extraheader=`"AUTHORIZATION: Basic $($token)`" $($i2.WebURL) `"$backupfolder$($i.name)_$($Subrepo)`""
    }
}

Get-ChildItem $backuproot  -Directory | foreach{ if ($_.CreationTime -le (Get-Date).AddDays(-15)){ Remove-Item $_.fullname -Force  -Recurse}}

Write-Host -NoNewLine 'END. Press any key to continue...';

}
catch {
  Write-Host "An error occurred:"
  Write-Host $_
  $wshell = New-Object -ComObject Wscript.Shell
  $wshell.Popup($_,0,"Error Azure backup",0x0)

}
