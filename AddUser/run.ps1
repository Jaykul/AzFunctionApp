using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
Write-Debug $($Request | ConvertTo-Json)

$User = @{}
foreach($Field in 'Email', 'Name', 'State', 'Zip', 'Phone') {
    $value = $Request.Query.$Field ?? $Request.Body.$Field
    if ($value) {
        $User[$Field] = $value
    }
}


if ($User.ContainsKey('Name') -and $User.ContainsKey('Email') -and $User.ContainsKey('Zip')) {
    $body = "Hello, $name <$email>. This HTTP triggered function executed successfully."

    $User += @{
        PartitionKey = $User.Zip
        RowKey       = $User.Email
    }

    Push-OutputBinding -Name TableBinding -Value $User
    $StatusCode = [HttpStatusCode]::OK
} else {
    $body = "This HTTP triggered function executed successfully. Pass correct values for a custom response."
    $StatusCode = [HttpStatusCode]::BadRequest
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $StatusCode
    Body = $body
})
