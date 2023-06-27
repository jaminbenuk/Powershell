$accessToken = "Graph API Access Token"
$csvFilePath = ".\output.csv"
$limitResults = 5

$managedDevicesEndpoint = "https://graph.microsoft.com/beta/deviceManagement/manageddevices"

$headers = @{
    "Authorization" = "Bearer $accessToken"
}

$workingOnDevice = 0
$limitResultsCounter = 0

$UserResponse = Invoke-RestMethod -Uri $managedDevicesEndpoint -Headers $headers -Method Get -Verbose

$cloudData = $UserResponse.value
$UserNextLink = $UserResponse.'@odata.nextLink'

while ($UserNextLink -ne $null) {
    $UserResponse = Invoke-RestMethod -Uri $UserNextLink -Headers $headers -Method Get -Verbose
    $UserNextLink = $UserResponse.'@odata.nextLink'
    $cloudData += $UserResponse.value
}

$cloudDataCount = $cloudData.Count
$detectedAppData = @()

foreach ($device in $cloudData | Select-Object -First $limitResults) {
    $deviceId = $device.id
    $deviceType = $device.deviceType
    $operatingSystem = $device.operatingSystem
    $detectedAppsEndpoint = "https://graph.microsoft.com/beta/deviceManagement/manageddevices('$deviceId')?`$expand=detectedApps"
    $detectedAppsResponse = Invoke-RestMethod -Uri $detectedAppsEndpoint -Headers @{
        "Authorization" = "Bearer $accessToken"
    }

    if ($detectedAppsResponse) {
        foreach ($app in $detectedAppsResponse.detectedApps) {
            $appData = [PSCustomObject]@{
                DeviceId = $deviceId
                DeviceType = $deviceType
                OperatingSystem = $operatingSystem
                AppId = $app.id
                DisplayName = $app.displayName
                Version = $app.version
            }
            $detectedAppData += $appData
        }
    }

    $workingOnDevice++
    Write-Host -NoNewline "Retrieving Apps for Device: $workingOnDevice of $cloudDataCount`r"

    Start-Sleep -Milliseconds 100
}

Write-Host "CSV file exported to: $csvFilePath"
$detectedAppData | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "Total Devices: $cloudDataCount"