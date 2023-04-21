@IsTest
private class WarehouseCalloutServiceTest {   
    @isTest  
    static void testWareHouseCallout(){
        Test.startTest();
        // implement mock callout test here
        Test.setMock(HTTPCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.makeGetCallout();
        Test.stopTest();
        System.assertEquals(1,[SELECT count() FROM Product2]);
    }    
    
    @isTest  
    static void testQueueableJob(){
        Test.startTest();
         WarehouseCalloutService updateJob = new WarehouseCalloutService();
        ID jobID = System.enqueueJob(updateJob);
        Test.stopTest();
        System.assertNotEquals(null, jobID);
    }  

}