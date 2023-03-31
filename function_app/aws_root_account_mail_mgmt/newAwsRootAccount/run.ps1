using namespace System.Net

param($Request, $TriggerMetadata)

if(-not ($Request.body.user_mail)) {
    $http_response = 400
    $result = @{
        'error'    = "Body needs to contain the property user_mail"
    }
} else {
    Import-Module Az.Storage
    Import-Module AzTable

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $env:resource_group_name -Name $env:storage_account_name
    $ctx = $storageAccount.Context
    $tableName = $env:table_name
    $storageTable = Get-AzStorageTable –Name $tableName –Context $ctx
    $cloudTable = $storageTable.CloudTable

    $filter = "(in_use eq false)"
    $result = Get-AzTableRow -table $cloudTable -customFilter $filter | Select-Object -First 1

    if ($result) {
        $result.in_use = $true
        $result.user_mail = $Request.body.user_mail
        $result.aws_account_id = ""

        $result | Update-AzTableRow -table $cloudTable
        $http_response = 200
    } else {
        $http_response = 400
        $result = @{
            'response' = 'no mail addresses left - get in contact with IT department'
            'error'    = $_.Exception.Message
        }
    }
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $http_response
        Body       = (ConvertTo-Json -InputObject $result)
    })
