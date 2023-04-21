/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-22-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class WarehouseCalloutService implements queueable {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void makeGetCallout() {
        List<Product2> warehouselist = new List<Product2>();
    	Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
               for (Object eq : results){
                Map<String,Object> mapJson = (Map<String,Object>)eq;
                Product2 myEqlist = new Product2();
                myEqlist.Replacement_Part__c = (Boolean) mapJson.get('replacement');
                myEqlist.Name = (String) mapJson.get('name');
                myEqlist.Maintenance_Cycle__c = (Integer) mapJson.get('maintenanceperiod');
                myEqlist.Lifespan_Months__c = (Integer) mapJson.get('lifespan');
                myEqlist.Cost__c = (Integer) mapJson.get('cost');
                myEqlist.Warehouse_SKU__c = (String) mapJson.get('sku');
                myEqlist.Current_Inventory__c = (Double) mapJson.get('quantity');
                myEqlist.ProductCode = (String) mapJson.get('_id');
                warehouselist.add(myEqlist);
            }  
        }
        if (warehouselist.size() > 0){
                upsert warehouselist;
                System.debug('Your equipment was synced with the warehouse one');
        }
        }
    
    public void execute(QueueableContext context) {
        makeGetCallout();
        
    }
    
}