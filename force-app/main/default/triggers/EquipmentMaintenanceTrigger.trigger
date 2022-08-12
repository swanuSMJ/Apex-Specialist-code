trigger EquipmentMaintenanceTrigger on Case (before insert,after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
    
   if(trigger.new[0].status == 'Closed' && trigger.old[0].status != 'Closed')
   {
       if (trigger.new[0].Type == 'Repair' || trigger.new[0].Type == 'Routine Maintenance')
       {
          AggregateResult[] results = [SELECT MIN(Equipment__r.Maintenance_Cycle__c)cycle 
                                     FROM Equipment_Maintenance_Item__c 
                                     WHERE Maintenance_Request__c = :trigger.old[0].Id
                                     GROUP BY Maintenance_Request__c];
           //System.debug(results);
           
           Case c =new Case(ParentId=trigger.old[0].Id,
                           Status = 'New',
                           Subject= 'Routine Maintenance',
                           Type = 'Routine Maintenance',
                           Vehicle__c = trigger.old[0].Vehicle__c,
                           Equipment__c =trigger.old[0].Equipment__c,
                           origin = 'web',
                           Date_Reported__c = Date.Today(),
                           Date_Due__c = Date.today().addDays(((Integer)results[0].get('cycle')))                          
                           
                            );
           insert(c);
           //Date_Due__c = Date.today().addDays(((Integer)results[0]))
       }
   }
    }
}