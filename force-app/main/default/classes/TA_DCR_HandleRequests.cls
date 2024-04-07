public with sharing class TA_DCR_HandleRequests implements TriggerAction.AfterInsert {

    public void afterInsert(List<Dataverse_Contact_Request__c> newList) {
        DataverseContactService service = new DataverseContactService(newList);
        service.upsertContactsFromRequests();
    }
    
}