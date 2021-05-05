public class AccountAddressesExtension {

  public ApexPages.StandardSetController BillingAddressControl {
    get {
        if(BillingAddressControl == null) {
           
            id userId = UserInfo.getUserId();
           
            User u = [SELECT accountId FROM User WHERE id = :userId];
            id acct = u.accountId;

            BillingAddressControl = new ApexPages.StandardSetController(Database.getQueryLocator(
            [SELECT Id, Name, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingStreet, 
            BillingLatitude, BillingLongitude 
            FROM Account WHERE Account.id=:acct Limit 1]
            ));
        }
        return BillingAddressControl;
      }
      set;
    }
    
  public Account getAccount(){
    return (Account) BillingAddressControl.getrecord();
  }


}


  /*[SELECT Id, Name, BillingCountry, BillingPostalCode, BillingState, BillingCity, BillingStreet, 
BillingLatitude, BillingLongitude 
FROM Account WHERE Id = :controller.acct
]; */