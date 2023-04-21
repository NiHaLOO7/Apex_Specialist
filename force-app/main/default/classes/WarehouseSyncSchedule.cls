/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class WarehouseSyncSchedule implements Schedulable{
    // implement scheduled code here
    global void execute(SchedulableContext ctx) {
		 System.enqueueJob(new WarehouseCalloutService());
    }
}

// WarehouseSyncSchedule sc = new WarehouseSyncSchedule();
// String sch = '0 0 1 * * ? *';
// String jobID = System.schedule('WarehouseSyncScheduleJob', sch, sc);