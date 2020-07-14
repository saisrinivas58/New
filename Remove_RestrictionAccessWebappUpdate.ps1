param
(
[Parameter(Mandatory = $true)]
[String]$RG_name,
[Parameter(Mandatory = $true)]
[String]$Webapp_name,
[Parameter(Mandatory = $true)]
[String]$name,
[Parameter(Mandatory = $true)]
[String]$location
)
$RS_type="Microsoft.Web/sites/config"


$rgAvail = Get-AzResourceGroup -Name $RG_name -Location $location -ErrorAction SilentlyContinue

$webappAvail = Get-AzureRmWebApp -Name $Webapp_name -ResourceGroupName $RG_name -ErrorAction SilentlyContinue

if ($rgAvail -and $webappAvail)
{
     
     $webapp_details = Get-AzureRmResource -ResourceGroupName $RG_name -ResourceType $RS_type -ResourceName $Webapp_name -ApiVersion 2016-08-01
     Write-Output $webapp_details
     $rule = $webapp_details.Properties.ipSecurityRestrictions 
	 Write-Output $rule
        if($rule)
		{
         Remove-AzWebAppAccessRestrictionRule -ResourceGroupName $RG_name -WebAppName $Webapp_name -Name $name
		 
		 Write-Output $name "is removed"
	    }	
        
		else
		{
		Write-Output " no rule found"
		}
  }
  