[String]$ResourceGroupName="DEVOPS-TRAINING-RG"
[String]$DatabaseServerName="mytestdb456"
[String]$DatabaseAdminUsername="cproot"
[String]$DatabaseAdminPassword="Password@"
#[String]$DatabaseAdminPassword= ConvertTo-SecureString -String "Password@" –AsPlainText -Force 
[String]$DatabaseNames="Mydb"
[String]$StorageAccountName="devopstraineestroage"
[String]$BlobStorageEndpoint="https://devopstraineestroage.blob.core.windows.net"
[String]$StorageKey="J8CvjuRa5BG1yuULUxj7znnuYVkktGMwyE5/KhBZ+htZP4/qfGI/Jsy+fFOz2d8XKUFjVldeRwKO2kMbzCd8+w=="
[String]$BlobContainerName="backups"
[String]$StorageAccessKey="StorageAccessKey"
$creds = New-Object –TypeName System.Management.Automation.PSCredential –ArgumentList $DatabaseAdminUsername, $DatabaseAdminPassword
     
$bacpacFilename = $DatabaseNames + (Get-Date).ToString("yyyyMMddHHmm") + ".bacpac"
$bacpacUri = $BlobStorageEndpoint+ "/" + $BlobContainerName+ "/" + $bacpacFilename
 Write-Output "backup files created"   
#$exportRequest = New-AzureRmSqlDatabaseExport –DatabaseName $DatabaseNames –ServerName $DatabaseServerName –storageKey $StorageKey -storageUri $bacpacUri –AdministratorLogin $creds.UserName –AdministratorLoginPassword $creds.Password -ResourceGroupName $ResourceGroupName

$exportRequest= New-AzureRmSqlDatabaseExport -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseNames -ServerName $DatabaseServerName -StorageKey $StorageKey -StorageAccessKey $StorageAccessKey -storageUri $bacpacUri -AdministratorLogin $creds.UserName -AdministratorLoginPassword -creds.Password           

                            
                                                
                                                
                                                
                                                