$token = "your token here"
$organization = "your_organization_name_here"
$backuproot = "C:\your_repo_backup_folder\"
$backupfolder = "$($backuproot)\$(get-date -f MM-dd-yyyy_HH_mm_ss)\"


$e = @{
    Uri     = "https://dev.azure.com/$($organization)/_apis/projects?api-version=5.1"
    Headers = @{"Authorization" = "Basic $($token)"}
}

$response = Invoke-RestMethod @e

foreach ($i in $response.value)
{
Invoke-Expression "git clone --mirror -c http.extraheader=`"AUTHORIZATION: Basic $($token)`" https://$($organization)@dev.azure.com/$($organization)/_git/$($i.name) $backupfolder$($i.name)"
}

Get-ChildItem $backuproot  -Directory | foreach{ if ($_.CreationTime -le (Get-Date).AddDays(-15)){ Remove-Item $_.fullname -Force  -Recurse}}
