public without sharing class PurchaseOrderCheckoutController {
    
    public ApexPages.StandardSetController purchaseOrderSetController {
        get {
            if(purchaseOrderSetController == null) {
                // User the user class to get the ID of the logged in user
                id userId = UserInfo.getUserId();
                // Use the Id to get AccountId from the actual user object
                User u = [SELECT AccountId, contactId FROM User WHERE id = :userId];
                id acct = u.accountId;
                
                
                // Create a custom Set Controller for only specific Purchase Orders (New and Related to our account)
                purchaseOrderSetController = new ApexPages.StandardSetController(Database.getQueryLocator(
                    // User the account ID to get purchase orders related to the account
                    [SELECT Id, Name FROM Purchase_Orders__c WHERE Status__c = 'New'AND Account__c = :acct ]
                ));
            }
            return purchaseOrderSetController;
        }
        set;
    }

    public list<Purchase_Orders__c> getPurchaseOrders() {
        return (List<Purchase_Orders__c>) purchaseOrderSetController.getRecords();
    }

    public PageReference submitOrder(){
        List<Purchase_Orders__c> updateList = purchaseOrderSetController.getRecords();

        for(Purchase_Orders__c o: updateList){
            o.status__c = 'Pending';
        }

        insert updateList;
        PageReference page = System.Page.SiteRegisterConfirm;
        page.setRedirect(true);
        return page;

    }
}
