///////////////////////////////////////////////////////////////
//
// Name: PurchaseOrderCheckoutControllerTest
// Author: Nate Farrey
// Created: 05/03/2021
// Updated: 05/04/2021
// Description: Test the methods on the Checkout Controller
//
///////////////////////////////////////////////////////////////
@isTest public with sharing class PurchaseOrderCheckoutControllerTest {
    @isTest (SeeAllData=true) public static void testRecordsRetrieved(){

        /* 
        Test if the user retrieves only the Purchase Orders related to his/her Account
        Purchase Orders are a junction object between Inventory__c and Account
        This test uses the default user Andy Young, and the account Dickenson Plc
        due to the difficulty in creating contact-users with linked accounts
        */

        // Retrieve ID of Andy Young's associated account
        User testUser = [SELECT Id, AccountId FROM User WHERE alias = 'ayoun'];
        
        // Generate manually an inventory item that will be used as a master lookup
        Inventory__c order = new Inventory__c(
            Ore_Type__c = 'Gold',
            Weight__c = 300,
            Mining_Site_List__c = 'Helicaon (30942)',
            Status__c ='Approved');

        insert order;

        // Retrieve the newly created inventory item
        Inventory__c newOrder = [SELECT id FROM Inventory__c WHERE Ore_Type__c = 'Gold' AND Weight__c = 300 AND Status__c = 'Approved' LIMIT 1];

        // Create purchase order using the new order and Dickenson Plc
        Purchase_Orders__c purchaseOrder = new Purchase_Orders__c(
            Account__c = testUser.AccountId,
            Inventory__c= newOrder.id
        );

        insert purchaseOrder;

        // Retrieve newly created order to test against the get method
        // Also retrieves any other orders that are 'New' and associated with the Account
        List<Purchase_Orders__c> testAgainst = [SELECT Id, Name, Account__c, Inventory__c, Inventory_Type__c, Inventory_Weight__c, Status__c FROM Purchase_Orders__c WHERE Status__c = 'New'AND Account__c = :testUser.AccountId];

        // Test the get method as Andy Young
        System.runAs(testUser){
            PurchaseOrderCheckoutController controller = new PurchaseOrderCheckoutController();
            List<Purchase_Orders__c> usersOrders = controller.getPurchaseOrders();
            
            system.assertEquals(testAgainst,usersOrders);
        }
    }

    @isTest (SeeAllData=true) public static void testSubmitOrder(){

        /* 
        Test if the user successfilly updates the status of 'New' orders to 'Pending' upon submission
        This test uses the default user Andy Young, and the account Dickenson Plc
        due to the difficulty in creating contact-users with linked accounts
        */

        // Retrieve ID of Andy Young's associated account
        User testUser = [SELECT Id, AccountId FROM User WHERE alias = 'ayoun'];

        // Retrieve any orders that are 'New' and associated with the Account
        List<Purchase_Orders__c> testAgainst = [SELECT Id, Name, Account__c, Inventory__c, Inventory_Type__c, Inventory_Weight__c, Status__c FROM Purchase_Orders__c WHERE Status__c = 'New'AND Account__c = :testUser.AccountId];

        // Manual set all statuses in the test list to 'Pending'
        // This is what we will test the method against
        for(Purchase_Orders__c o: testAgainst){
            o.Status__c = 'Pending';
        }

        // Test the submit method as Andy Young
        System.runAs(testUser){
            PurchaseOrderCheckoutController controller = new PurchaseOrderCheckoutController();
            PageReference page = controller.submitOrder();
            List<Purchase_Orders__c> testThis = controller.getPurchaseOrders();      
            system.debug(testThis);
            system.debug(testAgainst);
            system.assertEquals(testAgainst,testThis);
        }
    }
}