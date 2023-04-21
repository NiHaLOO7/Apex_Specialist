/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MaintenanceRequestHelper {

    public static void updateWorkOrders(List<Case> caseList, Map<Id,Case> oldCaseMap) {
        Map<String,Integer> result=getDueDate(caseList);
        List<case> newCases = new List<Case>();  
        List<Id> ids = new List<Id>();
        Map<Id,Id> idMap = new Map<Id,Id>();
        For (Case c : caseList){
	   //When an existing maintenance request of type Repair or Routine Maintenance is closed, create a new maintenance request for a future routine checkup.
            if (oldCaseMap.get(c.Id).Status != 'Closed' && c.Status == 'Closed'){
                if (c.Type == 'Repair' || c.Type == 'Routine Maintenance'){
                    Case newCase = new Case();
                    newCase.Status='New';
                    newCase.Origin='web';
                    newCase.Type='Routine Maintenance';
                    newCase.Description=c.Id;
                    newCase.Subject='Routine Maintenance of Vehicle';
                    newCase.Vehicle__c=c.Vehicle__c;
                    newCase.Date_Reported__c=Date.today();
                    newCase.Date_Due__c=Date.today()+result.get(c.Id);
                    newCases.add(newCase);                  
               }
            }
        }  
        System.debug(idMap);
        Database.SaveResult[] res = Database.insert(newCases);
        List<Id> newIds = new List<Id>();
        
        for(Database.SaveResult s : res) {
            newIds.add(s.getId());
        }
       	List<case> newcase = [SELECT Id, Description FROM Case where Id in :newIds];
        for(Case c: newcase) {
            idMap.put(c.Description,c.Id);
            ids.add(c.Description);
        }
        List<Equipment_Maintenance_Item__c> emrn = new List<Equipment_Maintenance_Item__c>();
        List<Equipment_Maintenance_Item__c> emr = [SELECT Maintenance_Request__c,Equipment__c,Quantity__c, Maintenance_Request__r.Id, Id FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__r.ID in :ids];
        
        
        for(Equipment_Maintenance_Item__c e : emr){
             Equipment_Maintenance_Item__c ab = new  Equipment_Maintenance_Item__c();
             ab.Maintenance_Request__c = idMap.get(e.Maintenance_Request__c);
             ab.Equipment__c = e.Equipment__c;
             ab.Quantity__c = e.Quantity__c;
             emrn.add(ab);
        }
        insert emrn;   
    }
    
    
     public static  Map<String,Integer> getDueDate(List<case> CaseIDs){       
       Map<String,Integer> result = new Map<String,Integer>();
        Map<Id, case> caseKeys = new Map<Id, case> (CaseIDs);        
       List<AggregateResult> wpc=[select Maintenance_Request__r.ID cID,min(Equipment__r.Maintenance_Cycle__c)cycle
                      from Equipment_Maintenance_Item__c where  Maintenance_Request__r.ID in :caseKeys.keySet() group by Maintenance_Request__r.ID ];
        for(AggregateResult res :wpc){
            Integer addDays=0;
            if(res.get('cycle')!=null)
                addDays = Integer.valueOf(res.get('cycle'));
            result.put((String)res.get('cID'),addDays);
        }
        return result;
}
        
    
}