#!/usr/bin/env pwsh

# Get the signed-in user's UPN (email alias) from Azure AD
# This avoids needing to ask for manual input during deployment

Write-Host "Retrieving signed-in user's UPN from Azure AD..."

$userPrincipalName = az ad signed-in-user show --query userPrincipalName -o tsv

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($userPrincipalName)) {
    Write-Error "Failed to retrieve signed-in user's UPN. Make sure you are logged in with 'az login'."
    exit 1
}

Write-Host "Setting AZURE_ADMIN_ALIAS to: $userPrincipalName"
azd env set AZURE_ADMIN_ALIAS $userPrincipalName
