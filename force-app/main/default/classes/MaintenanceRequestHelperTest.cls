@isTest
public with sharing class MaintenanceRequestHelperTest {
   
    
    private static Vehicle__c createVehicle()
    {
        Vehicle__c Vehicle = new Vehicle__c(name='My test super vehicle');
        return Vehicle;
    }
  private static Product2 createEq(){
        product2 equipment = new product2(name = 'My test SuperEquipment',
                                         lifespan_months__C = 10,
                                         maintenance_cycle__C = 10,
                                         replacement_part__c = true);
        return equipment;
    }
      private static Case createMaintenanceRequest(id vehicleId, id equipmentId)
      {
        case cs = new case(Type='Repair',
                          Status='New',
                          Origin='Web',
                          Subject='Testing subject',
                          Equipment__c=equipmentId,
                          Vehicle__c=vehicleId);
        return cs;
    }
    private static Equipment_Maintenance_Item__c createWorkPart(id equipmentId,id requestId)
    {
        Equipment_Maintenance_Item__c warkpart = new Equipment_Maintenance_Item__c(Equipment__c = equipmentId,
                                                                            Maintenance_Request__c = requestId);
        return warkpart;
    }
    @isTest
    private static void testMaintenanceRequestPositive()
    {
         Vehicle__c vehicle = createVehicle();
        insert vehicle;
       
        
        Product2 equipment = createEq();
        insert equipment;
       
        
        case somethingToUpdate = createMaintenanceRequest(vehicle.Id,equipment.Id);
        insert somethingToUpdate;
        
        Equipment_Maintenance_Item__c workP = createWorkPart(equipment.Id,somethingToUpdate.id);
        insert workP;
        
        test.startTest();
        somethingToUpdate.status = 'Closed';
        update somethingToUpdate;
        test.stopTest();
        
         Case newReq = [Select id, subject, type, Equipment__c, Date_Reported__c, Vehicle__c, Date_Due__c
                      from case
                      where status =:'new'];
         Equipment_Maintenance_Item__c workPart = [select id
                                                 from Equipment_Maintenance_Item__c
                                                 where Maintenance_Request__c =:newReq.Id];
        
        system.assert(workPart != null);
        system.assert(newReq.Subject != null);
        system.assertEquals(newReq.Type, 'Routine Maintenance');
        SYSTEM.assertEquals(newReq.Equipment__c, equipment.Id);
        SYSTEM.assertEquals(newReq.Vehicle__c, vehicle.Id);
        SYSTEM.assertEquals(newReq.Date_Reported__c, system.today());        
    }
    @istest
    private static void testMaintenanceRequestNegative()
    {
        Vehicle__C vehicle = createVehicle();
        insert vehicle;
                
        product2 equipment = createEq();
        insert equipment;        
        
        case emptyReq = createMaintenanceRequest(vehicle.Id,equipment.Id);
        insert emptyReq;
        
        Equipment_Maintenance_Item__c workP = createWorkPart(equipment.Id, emptyReq.Id);
        insert workP;
        
        test.startTest();
        emptyReq.Status = 'Working';
        update emptyReq;
        test.stopTest();
        
         list<case> allRequest = [select id from case];
                                 
        
         system.assert(allRequest.size() == 1);
        
    }
    @istest
    private static void testMaintenanceRequestBulk()
    {
         list<Vehicle__C> vehicleList = new list<Vehicle__C>();
        list<Product2> equipmentList = new list<Product2>();
        list<Equipment_Maintenance_Item__c> workPartList = new list<Equipment_Maintenance_Item__c>();
        list<case> requestList = new list<case>();
        list<id> oldRequestIds = new list<id>();
        
        for(integer i = 0; i < 300; i++){
           vehicleList.add(createVehicle());
            equipmentList.add(createEq());
        }
        insert vehicleList;
        insert equipmentList;
        
        for(integer i = 0; i < 300; i++){
            requestList.add(createMaintenanceRequest(vehicleList.get(i).id, equipmentList.get(i).id));
        }
        insert requestList;
        
            for(integer i = 0; i < 300; i++){
            workPartList.add(createWorkPart(equipmentList.get(i).id, requestList.get(i).id));
        }
        insert workPartList;
        
         test.startTest();
        for(case req : requestList){
            req.Status = 'Closed';
            oldRequestIds.add(req.Id);
        }
         update requestList;
        test.stopTest();
        
         list<case> allRequests = [select id from case];                                
                      
        system.assert(allRequests.size() == 600);
    }
}