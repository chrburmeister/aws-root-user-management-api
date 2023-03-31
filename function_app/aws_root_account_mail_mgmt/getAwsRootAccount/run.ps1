using namespace System.Net

param($Request, $TriggerMetadata)

if($Request.Query.aws_account_id) {
    $filter = "(aws_account_id eq '{0}')" -f $Request.Query.aws_account_id
} elseif ( $Request.Query.user_mail ) {
    $filter = "(user_mail eq '{0}')" -f  $Request.Query.user_mail
} elseif ( $Request.Query.aws_mail ) {
    $filter = "(aws_mail eq '{0}')" -f  $Request.Query.aws_mail
    
} else {
    $http_response = 400
    $result = @{
        'error'    = "query parameter aws_account_id, user_mail or aws_mail needs to be available."
    }
}

Import-Module Az.Storage
Import-Module AzTable

$storageAccount = Get-AzStorageAccount -ResourceGroupName $env:resource_group_name -Name $env:storage_account_name
$ctx = $storageAccount.Context
$tableName = $env:table_name
$storageTable = Get-AzStorageTable –Name $tableName –Context $ctx
$cloudTable = $storageTable.CloudTable

$result = Get-AzTableRow -table $cloudTable -customFilter $filter

if(-not($result)) {
    $http_response = 204
    $result = @()
} else {
    $http_response = 200
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $http_response
    Body = (ConvertTo-Json -InputObject $result)
})
