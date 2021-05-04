public class AccountAddressesExtension {
    public Account record{get; private set;}
    public AccountAddressesExtension(ApexPages.StandardController controller) {
      record = [SELECT Id, Name, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingStreet, 
                BillingLatitude, BillingLongitude 
                FROM Account WHERE Id = :controller.getId()
              ]; 
   }
  
}
  
