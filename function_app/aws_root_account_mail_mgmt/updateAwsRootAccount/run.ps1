using namespace System.Net

param($Request, $TriggerMetadata)

if(-not ($Request.body.aws_mail) -and -not $($Request.body.aws_account_id)) {
    $http_response = 400
    $result = @{
        'error'    = "Body needs to contain the properties aws_mail and aws_account_id"
    }
} else {
    Import-Module Az.Storage
    Import-Module AzTable

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $env:resource_group_name -Name $env:storage_account_name
    $ctx = $storageAccount.Context
    $tableName = $env:table_name
    $storageTable = Get-AzStorageTable –Name $tableName –Context $ctx
    $cloudTable = $storageTable.CloudTable

    $filter = "(aws_mail eq '{0}')" -f $Request.Body.aws_mail
    $result = Get-AzTableRow -table $cloudTable -customFilter $filter

    if ($result) {
        if($result.in_use) {
            $result.aws_account_id = $Request.body.aws_account_id
    
            $result | Update-AzTableRow -table $cloudTable
            $http_response = 200
        } else {
            http_response = 400
            $result = @{
                'error' = "aws_mail $($Request.body.aws_mail) is not in use - no changes made"
            }
        }
    } else {
        $http_response = 400
        $result = @{
            'error' = "no entry found with aws_mail $($Request.body.aws_mail)"
        }
    }
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $http_response
        Body       = (ConvertTo-Json -InputObject $result)
    })
