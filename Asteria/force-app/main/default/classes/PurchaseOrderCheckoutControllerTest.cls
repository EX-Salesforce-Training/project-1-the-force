@isTest public with sharing class PurchaseOrderCheckoutControllerTest {
    @isTest (SeeAllData=true) public static void testRecordsRetrieved(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community User'];
        
        User testUser = [SELECT Id, AccountId FROM User WHERE alias = 'ayoun'];
        
        

        // User u = new User(Alias = 'jonman', 
        //                 Email='standarduser@testorg.com', 
        //                 EmailEncodingKey='UTF-8', 
        //                 LastName='Testing', 
        //                 LanguageLocaleKey='en_US',
        //                 LocaleSidKey='en_US',  
        //                 ProfileId = p.Id,
        //                 TimeZoneSidKey='America/Los_Angeles',
        //                 UserName=uniqueUserName,
        //                 AccountId='0015e000004EAdPAAW',
        //                 ContactId='0035e000002sHJ8AAM');

        Inventory__c order = new Inventory__c(
            Ore_Type__c = 'Gold',
            Weight__c = 300,
            Mining_Site_List__c = 'Helicaon (30942)',
            Status__c ='Approved');

        insert order;

        Inventory__c newOrder = [SELECT id FROM Inventory__c WHERE Ore_Type__c = 'Gold' AND Weight__c = 300 AND Status__c = 'Approved' LIMIT 1];

        Purchase_Orders__c purchaseOrder = new Purchase_Orders__c(
            Account__c = testUser.AccountId,
            Inventory__c= newOrder.id
        );

        insert purchaseOrder;

        List<Purchase_Orders__c> testAgainst = [SELECT id, Name FROM Purchase_Orders__c WHERE Account__c = :testUser.AccountId];

        System.runAs(testUser){
            PurchaseOrderCheckoutController controller = new PurchaseOrderCheckoutController();
            List<Purchase_Orders__c> usersOrders = controller.getPurchaseOrders();
            
            system.assertEquals(testAgainst,usersOrders);
        }
        

    }

    @isTest (SeeAllData=true) public static void testSubmitOrder(){
        User testUser = [SELECT Id, AccountId FROM User WHERE alias = 'ayoun'];

        List<Purchase_Orders__c> testAgainst = [SELECT id, Name, Status__c FROM Purchase_Orders__c WHERE Account__c = :testUser.AccountId];

        for(Purchase_Orders__c o: testAgainst){
            o.Status__c = 'Pending';
        }

        System.runAs(testUser){
            PurchaseOrderCheckoutController controller = new PurchaseOrderCheckoutController();
            PageReference page = controller.submitOrder();
            List<Purchase_Orders__c> testThis = controller.getPurchaseOrders();      
                  
            system.assertEquals(testAgainst,testThis);
        }
        

    }
}
