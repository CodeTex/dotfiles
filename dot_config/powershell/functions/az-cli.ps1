# Azure CLI functions
# Reads subscription IDs from ~/.config/powershell/az-registry.json (untracked, local)

function Get-PostgresTokenProd {
    $config = Get-Content (Join-Path $HOME ".config/powershell/az-registry.json") | ConvertFrom-Json
    az account get-access-token --resource-type oss-rdbms --query accessToken --output tsv --subscription $config.prod | Set-Clipboard
    Write-Host "Bearer token copied to clipboard (prod)" -ForegroundColor Green
}

function Get-PostgresTokenTest {
    $config = Get-Content (Join-Path $HOME ".config/powershell/az-registry.json") | ConvertFrom-Json
    az account get-access-token --resource-type oss-rdbms --query accessToken --output tsv --subscription $config.test | Set-Clipboard
    Write-Host "Bearer token copied to clipboard (test)" -ForegroundColor Green
}
