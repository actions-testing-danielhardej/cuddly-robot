# cuddly-robot

A testing repository for GitHub Actions workflows that validate DNS resolution and connectivity to GitHub Actions artifact upload endpoints using PowerShell on Windows runners.

## 🎯 Purpose

This repository provides automated testing tools to verify DNS resolution and network connectivity for GitHub Actions runners, specifically focusing on endpoints used for artifact uploads. It helps identify potential network issues that could affect GitHub Actions workflow functionality.

## 🏗️ Repository Contents

### Workflows

#### 1. **DNS Resolution Test** (`.github/workflows/dns-resolution-test.yml`)
- **Trigger**: Push to main, pull requests, manual dispatch, daily schedule (00:00 UTC)
- **Runner**: `windows-latest`
- **Purpose**: Comprehensive DNS resolution testing for GitHub Actions endpoints
- **Features**:
  - Tests core GitHub endpoints: `uploads.github.com`, `api.github.com`, `github.com`, `objects.githubusercontent.com`
  - Displays Windows version and PowerShell information
  - Network configuration analysis
  - DNS cache inspection
  - Optional detailed output mode
  - Tests additional GitHub endpoints (codeload, raw.githubusercontent.com, etc.)

#### 2. **Artifact Endpoint Test** (`.github/workflows/artifact-endpoint-test.yml`)
- **Trigger**: Push to main, pull requests, manual dispatch
- **Runner**: `windows-latest`
- **Purpose**: Focused testing of artifact upload endpoints with real upload verification
- **Features**:
  - DNS resolution testing for artifact-specific endpoints
  - Creates and uploads a test artifact to validate end-to-end functionality
  - Confirms successful artifact upload to verify connectivity

### Scripts

#### **Test-DNSResolution.ps1**
PowerShell script that performs DNS resolution testing with the following capabilities:

**Parameters:**
- `-Endpoints`: Array of endpoints to test (defaults to core GitHub Actions endpoints)
- `-Detailed`: Switch to enable detailed DNS record output

**Features:**
- DNS resolution testing using `Resolve-DnsName`
- IP address extraction and display
- Network connectivity testing using `Test-NetConnection`
- Comprehensive error handling and reporting
- Summary statistics and detailed results table
- Exit codes for CI/CD integration

**Default Endpoints Tested:**
- `uploads.github.com` - Primary artifact upload endpoint
- `api.github.com` - GitHub API endpoint
- `github.com` - Main GitHub domain
- `objects.githubusercontent.com` - Object storage endpoint
- `*.blob.core.windows.net` - Azure blob storage (used by GitHub Actions)

## 🚀 How to Use

### Running Tests Manually

1. **Manual Workflow Dispatch**:
   - Go to the "Actions" tab in your GitHub repository
   - Select "DNS Resolution Test" or "Artifact Endpoint Test"
   - Click "Run workflow"
   - For the DNS Resolution Test, optionally enable "detailed output"

2. **Local PowerShell Execution**:
   ```powershell
   # Basic test with default endpoints
   .\scripts\Test-DNSResolution.ps1
   
   # Detailed output
   .\scripts\Test-DNSResolution.ps1 -Detailed
   
   # Custom endpoints
   .\scripts\Test-DNSResolution.ps1 -Endpoints @("custom.endpoint.com", "another.endpoint.com")
   ```

### Automated Testing

- **Push/PR Testing**: Tests run automatically on pushes to main and pull requests
- **Daily Monitoring**: DNS Resolution Test runs daily at midnight UTC to monitor endpoint availability
- **CI/CD Integration**: Scripts return appropriate exit codes for automated success/failure detection

### Interpreting Results

#### DNS Resolution Test Results
- **✓ SUCCESS**: DNS resolution successful, IP addresses displayed
- **✗ NO_RECORDS**: DNS query succeeded but no records found
- **✗ FAILED**: DNS resolution failed (network/DNS server issues)

#### Network Connectivity Test
- Tests HTTPS connectivity to `github.com:443`
- Validates basic network functionality

#### Artifact Upload Test
- Successful artifact upload confirms end-to-end connectivity
- Failed upload may indicate DNS, network, or authentication issues

## 🔍 Troubleshooting

### Common Issues

1. **DNS Resolution Failures**:
   - Check DNS server configuration
   - Verify network connectivity
   - Check for corporate firewall/proxy restrictions

2. **Artifact Upload Failures**:
   - Verify GitHub token permissions
   - Check network proxy settings
   - Ensure DNS resolution is working for upload endpoints

3. **Network Connectivity Issues**:
   - Verify outbound HTTPS (port 443) access
   - Check for corporate network restrictions
   - Validate DNS server accessibility

### Diagnostic Information

The workflows provide comprehensive diagnostic information:
- Windows version and PowerShell version
- Network adapter configuration
- DNS client configuration and server addresses
- DNS cache contents
- IP configuration details

## 📊 Use Cases

- **Runner Environment Validation**: Verify new GitHub Actions runner environments
- **Network Troubleshooting**: Diagnose connectivity issues in GitHub Actions workflows
- **Monitoring**: Regular health checks for GitHub Actions infrastructure connectivity
- **Corporate Network Testing**: Validate corporate network configurations for GitHub Actions
- **DNS Server Testing**: Test DNS server reliability for GitHub endpoints

## 🤝 Contributing

This repository serves as a testing tool. To contribute:
1. Fork the repository
2. Add new test endpoints or improve existing scripts
3. Test your changes with the existing workflows
4. Submit a pull request

## 📝 License

This is a testing repository. Use the code and workflows as needed for your own testing purposes.