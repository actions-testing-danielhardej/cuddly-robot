#
# Test-DNSResolution.ps1
# PowerShell script to test DNS resolution for GitHub Actions artifact upload endpoints
#

param(
    [string[]]$Endpoints = @(
        "uploads.github.com",
        "api.github.com", 
        "github.com",
        "objects.githubusercontent.com",
        "*.blob.core.windows.net"
    ),
    [switch]$Detailed
)

Write-Host "=== GitHub Actions DNS Resolution Test ===" -ForegroundColor Cyan
Write-Host "Testing DNS resolution for GitHub Actions artifact upload endpoints" -ForegroundColor Yellow
Write-Host ""

$results = @()
$totalTests = 0
$successfulTests = 0

foreach ($endpoint in $Endpoints) {
    Write-Host "Testing endpoint: $endpoint" -ForegroundColor Green
    $totalTests++
    
    try {
        # Test DNS resolution
        $dnsResult = Resolve-DnsName -Name $endpoint -ErrorAction Stop
        
        if ($dnsResult) {
            $successfulTests++
            Write-Host "  ✓ DNS Resolution: SUCCESS" -ForegroundColor Green
            
            if ($Detailed) {
                foreach ($record in $dnsResult) {
                    Write-Host "    Type: $($record.Type), Name: $($record.Name)" -ForegroundColor Gray
                    if ($record.IPAddress) {
                        Write-Host "    IP Address: $($record.IPAddress)" -ForegroundColor Gray
                    }
                    if ($record.NameHost) {
                        Write-Host "    Target: $($record.NameHost)" -ForegroundColor Gray
                    }
                }
            }
            
            # Try to get IP addresses specifically
            $aRecords = $dnsResult | Where-Object { $_.Type -eq "A" -or $_.Type -eq "AAAA" }
            if ($aRecords) {
                $ipAddresses = $aRecords | ForEach-Object { $_.IPAddress } | Where-Object { $_ }
                if ($ipAddresses) {
                    Write-Host "  IP Addresses: $($ipAddresses -join ', ')" -ForegroundColor Cyan
                }
            }
            
            $results += [PSCustomObject]@{
                Endpoint = $endpoint
                Status = "SUCCESS"
                IPAddresses = ($aRecords | ForEach-Object { $_.IPAddress } | Where-Object { $_ }) -join ', '
                RecordCount = $dnsResult.Count
            }
        } else {
            Write-Host "  ✗ DNS Resolution: NO RECORDS FOUND" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Endpoint = $endpoint
                Status = "NO_RECORDS"
                IPAddresses = ""
                RecordCount = 0
            }
        }
    }
    catch {
        Write-Host "  ✗ DNS Resolution: FAILED" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        
        $results += [PSCustomObject]@{
            Endpoint = $endpoint
            Status = "FAILED"
            IPAddresses = ""
            RecordCount = 0
            Error = $_.Exception.Message
        }
    }
    
    Write-Host ""
}

# Summary
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Total endpoints tested: $totalTests" -ForegroundColor Yellow
Write-Host "Successful resolutions: $successfulTests" -ForegroundColor Green
Write-Host "Failed resolutions: $($totalTests - $successfulTests)" -ForegroundColor Red
Write-Host ""

# Results table
Write-Host "=== Detailed Results ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

# Test additional connectivity (basic network test)
Write-Host "=== Network Connectivity Test ===" -ForegroundColor Cyan
try {
    $testConnection = Test-NetConnection -ComputerName "github.com" -Port 443 -InformationLevel Quiet
    if ($testConnection) {
        Write-Host "✓ HTTPS connectivity to github.com:443 - SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "✗ HTTPS connectivity to github.com:443 - FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Network connectivity test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan

# Exit with appropriate code
if ($successfulTests -eq $totalTests) {
    Write-Host "All DNS resolution tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some DNS resolution tests failed!" -ForegroundColor Red
    exit 1
}