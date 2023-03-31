$subscription_id = ""

Import-Module Az.Storage
Import-Module AzTable

Add-AzAccount
Select-AzSubscription -SubscriptionId $subscription_id

$storageAccount = Get-AzStorageAccount -ResourceGroupName 'comp-aws-root-acc-mgmt-live-rg' -Name 'comp6f2twtlivest'
$ctx = $storageAccount.Context
$storageTable = Get-AzStorageTable –Name 'awsrootaccounts' –Context $ctx
$cloudTable = $storageTable.CloudTable

Connect-ExchangeOnline

$tld = "company.com"

New-Mailbox -Shared -Name "awsmain@$($tld)" -DisplayName "AWS Main"

foreach($shared_mailbox_number in (2..2)) {
    $aws_root_account_shared_mailbox_name = "comp{0:d3}" -f $shared_mailbox_number
    $aws_root_account_shared_mailbox_displayname = "AWS Root Account Mgmt {0:d3}" -f $shared_mailbox_number
    Write-Output "Creating shared Mailbox $($aws_root_account_shared_mailbox_name) // $($aws_root_account_shared_mailbox_displayname)"
    New-Mailbox -Shared -Name $aws_root_account_shared_mailbox_name -DisplayName $aws_root_account_shared_mailbox_displayname
    Start-Sleep -Seconds 10
    Get-Mailbox $aws_root_account_shared_mailbox_name | set-mailbox -ForwardingAddress "awsmain@$($tld)"

    $i = 1
    foreach($alias_number in (1..300)) {
        $guid = New-Guid | Select-Object -ExpandProperty Guid
        $alias_name = "aws_$($guid)@$($tld)"
        Write-Output "Adding Alias $($alias_name) // $($i)/300"

        Set-Mailbox $aws_root_account_shared_mailbox_name –EmailAddresses @{Add=$alias_name}


        $props = @{
            "aws_mail"       = $alias_name
            "in_use"         = $false
            "id"             = $guid
            "user_mail"      = ""
            "root_mailbox"   = "$($aws_root_account_shared_mailbox_name)@$($tld)"
            "aws_account_id" = ""
        }

        $result = Add-AzTableRow -table $cloudTable -partitionKey 'root' -rowKey $guid -property $props
        $i++
    }
}
