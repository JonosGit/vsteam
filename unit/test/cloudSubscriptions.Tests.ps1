Set-StrictMode -Version Latest

InModuleScope cloudSubscriptions {
   
   Describe 'CloudSubscriptions vsts' {
      # Mock the call to Get-Projects by the dynamic parameter for ProjectName
      Mock Invoke-RestMethod { return @() } -ParameterFilter {
         $Uri -like "*_apis/projects*" 
      }

      $VSTeamVersionTable.Account = 'https://test.visualstudio.com'

      Context 'Get-VSTeamCloudSubscription' {
         Mock Invoke-RestMethod { 
            return @{value = 'subs'}
         }

         It 'should return all AzureRM Subscriptions' {
            Get-VSTeamCloudSubscription

            Assert-MockCalled Invoke-RestMethod -Exactly -Scope It -Times 1 -ParameterFilter {
               $Uri -eq "https://test.visualstudio.com/_apis/distributedtask/serviceendpointproxy/azurermsubscriptions/?api-version=$($VSTeamVersionTable.DistributedTask)"
            }
         }
      }
   }

   Describe 'CloudSubscriptions TFS' {
      # Mock the call to Get-Projects by the dynamic parameter for ProjectName
      Mock Invoke-RestMethod { return @() } -ParameterFilter {
         $Uri -like "*_apis/projects*" 
      }
   
      Mock _useWindowsAuthenticationOnPremise { return $true }
      $VSTeamVersionTable.Account = 'http://localhost:8080/tfs/defaultcollection'
      
      Context 'Get-VSTeamCloudSubscription' {
         Mock Invoke-RestMethod { return @{value = 'subs'}}

         It 'should return all AzureRM Subscriptions' {
            Get-VSTeamCloudSubscription

            Assert-MockCalled Invoke-RestMethod -Exactly -Scope It -Times 1 -ParameterFilter {
               $Uri -eq "http://localhost:8080/tfs/defaultcollection/_apis/distributedtask/serviceendpointproxy/azurermsubscriptions/?api-version=$($VSTeamVersionTable.DistributedTask)"
            }
         }
      }

      # Must be last because it sets $VSTeamVersionTable.Account to $null
      Context '_buildURL handles exception' {
         
         # Arrange
         $VSTeamVersionTable.Account = $null
         
         It 'should return approvals' {
         
            # Act
            { _buildURL } | Should Throw
         }
      }
   }
}