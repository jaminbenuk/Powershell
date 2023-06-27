
$accessToken = "Graph API Access Token"

# Define the path to the CSV file containing user email addresses
$csvFileName = "userEmailAddresses.csv"
$csvFilePath = Join-Path -Path $PSScriptRoot -ChildPath $csvFileName

# Import user email addresses from the CSV file
$upnList = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty EmailAddress

# Count the number of users in the CSV file
$totalUsers = $upnList.Count

# Output the user count
Write-Host "`nTotal users in CSV: $totalUsers`n"

# Create an empty array to store the results
$results = @()

# Retrieve the user profiles for each user
for ($currentUser = 1; $currentUser -le $totalUsers; $currentUser++) {
    $userEmailAddress = $upnList[$currentUser - 1]
    Write-Host -NoNewline "Processing user $currentUser of $totalUsers - $userEmailAddress`r"

    # Construct the user profile request
    $userProfileEndpoint = "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq '$userEmailAddress'&`$select=userPrincipalName,givenName,surname,accountEnabled,signInActivity,lastNonInteractiveSignInDateTime"
    $userProfileHeaders = @{
        'Authorization' = "Bearer $accessToken"
    }

    # Request the user profile from Microsoft Graph API
    try {
        $userProfile = Invoke-RestMethod -Uri $userProfileEndpoint -Method GET -Headers $userProfileHeaders

        if ($userProfile.value) {
            $user = $userProfile.value[0]
            $givenName = $user.givenName
            $surname = $user.surname
            $accountEnabled = $user.accountEnabled

            if ($accountEnabled) {
                $signInActivity = $user.signInActivity
                if ($signInActivity) {
                    $lastSignInTime = $signInActivity[0].lastSignInDateTime
                    $lastNonInteractiveSignInTime = $signInActivity[0].lastNonInteractiveSignInDateTime
                } else {
                    $lastSignInTime = "No sign-in activity found"
                    $lastNonInteractiveSignInTime = "No sign-in activity found"
                }
            } else {
                $lastSignInTime = "Account not active"
                $lastNonInteractiveSignInTime = "Account not active"
            }

            # Create a custom object with the user and sign-in information
            $result = [PSCustomObject]@{
                UserEmailAddress = $userEmailAddress
                FirstName = $givenName
                LastName = $surname
                AccountStatus = $accountEnabled
                LastSignInTime = $lastSignInTime
                LastNonInteractiveSignInTime = $lastNonInteractiveSignInTime
            }

            # Add the result to the array
            $results += $result
        } else {
            Write-Host "User not found: $userEmailAddress"
        }
    } catch {
        Write-Host "Error retrieving user profile for: $userEmailAddress"
        Write-Host $_.Exception.Message
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path (Join-Path -Path $PSScriptRoot -ChildPath "userSignInActivity.csv") -NoTypeInformation


Write-Host "`nPress any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
