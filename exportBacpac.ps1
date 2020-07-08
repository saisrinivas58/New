
     [String]$ResourceGroupName="DEVOPS-TRAINING-RG"
     [String]$DatabaseServerName="mytestdb456"
     [String]$DatabaseAdminUsername="cproot"
	 [String]$DatabaseAdminPassword= ConvertTo-SecureString –String "Password@" –AsPlainText -Force 
	 [String]$DatabaseNames="Mydb"
     [String]$StorageAccountName="devopstraineestroage"
     [String]$BlobStorageEndpoint="https://devopstraineestroage.blob.core.windows.net"
     [String]$StorageKey="J8CvjuRa5BG1yuULUxj7znnuYVkktGMwyE5/KhBZ+htZP4/qfGI/Jsy+fFOz2d8XKUFjVldeRwKO2kMbzCd8+w=="
	 [String]$BlobContainerName="backups"
     
    function Login() {
	$connectionName = "AzureRunAsConnection"
	try
	{
		$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

		Write-Verbose "Logging in to Azure..." -Verbose

		Add-AzureRmAccount `
			-ServicePrincipal `
			-TenantId $servicePrincipalConnection.TenantId `
			-ApplicationId $servicePrincipalConnection.ApplicationId `
			-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
      Write-Output "login success"
	}
	catch {
		if (!$servicePrincipalConnection)
		{
			$ErrorMessage = "Connection $connectionName not found."
			throw $ErrorMessage
		} else{
			Write-Error -Message $_.Exception
			throw $_.Exception
		}
	}
}




function Create-Blob-Container([string]$blobContainerName, $storageContext) {
    Write-Output "function Create-Blob-Container"
	Write-Verbose "Checking if blob container '$blobContainerName' already exists" -Verbose
	if (Get-AzureStorageContainer -ErrorAction "Stop" -Context $storageContext | Where-Object { $_.Name -eq $blobContainerName }) {
        Write-Output "function Create-Blob-Container if inside"
		Write-Verbose "Container '$blobContainerName' already exists" -Verbose
	} else {
        Write-Output "funtion Create-Blob-Container else part"
		New-AzureStorageContainer -ErrorAction "Stop" -Name $blobContainerName -Permission Off -Context $storageContext
		Write-Verbose "Container '$blobContainerName' created" -Verbose
	}
}

function Export-To-Blob-Storage([string]$resourceGroupName, [string]$databaseServerName, [string]$databaseAdminUsername, [string]$databaseAdminPassword, [string[]]$databaseNames, [string]$storageKey, [string]$blobStorageEndpoint, [string]$blobContainerName) {
	Write-Output "funtion Export-To-Blob-Storage inside "
    Write-Verbose "Starting database export to databases '$databaseNames'" -Verbose
	#$securePassword = ConvertTo-SecureString –String $databaseAdminPassword –AsPlainText -Force 
	$creds = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $databaseAdminUsername, $DatabaseAdminPassword -replace '\p{Pd}','-'
     Write-Output " database server login success "
	foreach ($databaseName in $databaseNames.Split(",").Trim()) {
		Write-Output "Creating request to backup database '$databaseName'"
        
		$bacpacFilename = $databaseName + (Get-Date).ToString("yyyyMMddHHmm") + ".bacpac"
		$bacpacUri = $blobStorageEndpoint + "/" + $blobContainerName + "/" + $bacpacFilename
        Write-Output "backup files created"   
		$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $resourceGroupName –ServerName $databaseServerName `
			–DatabaseName $databaseName –StorageKeytype "StorageAccessKey" –storageKey $storageKey -StorageUri $BacpacUri `
			–AdministratorLogin $creds.UserName –AdministratorLoginPassword $creds.Password -ErrorAction "Stop"
		Write-Output "backupfile exported"
		# Print status of the export
		Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink -ErrorAction "Stop"
        Write-Output "backupfile upload status"
	}
}



Write-Verbose "Starting database backup" -Verbose

$StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

Login

Create-Blob-Container `
	-blobContainerName $blobContainerName `
	-storageContext $storageContext
	
Export-To-Blob-Storage `
	-resourceGroupName $ResourceGroupName `
	-databaseServerName $DatabaseServerName `
	-databaseAdminUsername $DatabaseAdminUsername `
	-databaseAdminPassword $DatabaseAdminPassword `
	-databaseNames $DatabaseNames `
	-storageKey $StorageKey `
	-blobStorageEndpoint $BlobStorageEndpoint `
	-blobContainerName $BlobContainerName
	
	
Write-Verbose "Database backup script finished" -Verbose
	

