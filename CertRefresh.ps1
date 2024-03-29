# Define an array of certificate template names
$certTemplateNames = @("Template1", "Template2", "Template3")

# Specify the subject name for the certificate
$subjectName = "CN=YourUserName"

# Iterate through each certificate template
foreach ($certTemplateName in $certTemplateNames) {
    # Check if a certificate with the specified template and subject exists
    $existingCert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Extensions | Where-Object { $_.Oid.FriendlyName -eq "Certificate Template Name" -and $_.Format(0) -eq $certTemplateName } -and $_.Subject -eq $subjectName }

    # If certificate exists and is at least a week old, do nothing; otherwise, request a new certificate
    if ($existingCert -and (Get-Date).AddDays(-7) -gt $existingCert.NotBefore) {
        Write-Host "Certificate with template '$certTemplateName' already exists and is at least a week old. No action needed."
    } else {
        # Set the path to store the issued certificate
        $certOutputPath = "C:\Path\To\Save\Certificate_${certTemplateName}.cer"

        # Build the certificate request
        $certRequestFile = "C:\Path\To\Save\CertificateRequest_${certTemplateName}.req"
        certreq -new -f -q -submit -attrib "CertificateTemplate:$certTemplateName" -attrib "Subject:$subjectName" $certRequestFile

        # Retrieve and save the issued certificate
        certreq -retrieve -config "CA_Server_Name\CA_Name" -request $certRequestFile -attrib "Disposition:DispositionAttribute" $certOutputPath
    }
}
