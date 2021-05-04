@isTest public with sharing class PurchaseOrderCheckoutControllerTest {
    @isTest (SeeAllData=true) public static void testRecordsRetrieved(){
        //For this test we are using User Andy Young, and Account Dickenson Plc
        User testUser = [SELECT Id, AccountId FROM User WHERE alias = 'ayoun'];

        //Create a new inventory item to use in our purchase order
        Inventory__c order = new Inventory__c(
            Ore_Type__c = 'Gold',
            Weight__c = 300,
            Mining_Site_List__c = 'Helicaon (30942)',
            Status__c ='Approved');

        insert order;

        //retrieve newly created inventory item
        Inventory__c newOrder = [SELECT id FROM Inventory__c WHERE Ore_Type__c = 'Gold' AND Weight__c = 300 AND Status__c = 'Approved' LIMIT 1];

        // Create new purchase order with user's account and the new inventory item
        Purchase_Orders__c purchaseOrder = new Purchase_Orders__c(
            Account__c = testUser.AccountId,
            Inventory__c= newOrder.id
        );

        insert purchaseOrder;

        // Select thre newly created purchase order to test against our controller's method
        List<Purchase_Orders__c> testAgainst = [SELECT id, Name FROM Purchase_Orders__c WHERE Account__c = :testUser.AccountId];

        System.runAs(testUser){
            // Instantiate instance of custome set controller
            PurchaseOrderCheckoutController controller = new PurchaseOrderCheckoutController();
            // Call get purchase orders method from controller
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
