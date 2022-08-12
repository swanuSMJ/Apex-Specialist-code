@isTest
public with sharing class WarehouseSyncScheduleTest 
{
     @isTest 
    static void WarehousescheduleTest()
    {
        String scheduleTime = '00 00 01 * * ?';
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String jobID=System.schedule('Warehouse Time To Schedule to Test', scheduleTime, new WarehouseSyncSchedule());	        
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM Product2]);
    }
}