/*****************************************************
 * @description Handles matching of player contacts and updated data when new
 *  requests are received from Microsoft Dataverse.
 * 
 * @date 2024
 *****************************************************/
public with sharing class DataverseContactService {

    private List<Dataverse_Contact_Request__c> lstRequests;
    private List<Dataverse_Contact_Request__c> lstRequestsForInsert;
    private Map<Id, Id> mapAccountIds;

    /**
     * @description Constructor takes a list of requests to process
     * @param Dataverse_Contact_Request__c[]
     */
    public DataverseContactService(List<Dataverse_Contact_Request__c> requests) {
        this.lstRequests = requests;
    }

    /**
     * @description Upsert contacts
     */
    public void upsertContactsFromRequests() {
        lstRequestsForInsert = filterToNewContacts();

        if (!lstRequestsForInsert.isEmpty()) {
            insertParentContacts();
            insertPlayerContacts();
        }
    }

    private void insertParentContacts() {
        List<Contact> lstParentContacts = new List<Contact>();
        for (Dataverse_Contact_Request__c dcr : lstRequestsForInsert) {
            Contact parentContact = new Contact();
            parentContact.FirstName = dcr.Parent_Guardian_First_Name__c;
            parentContact.LastName = dcr.Parent_Guardian_Last_Name__c;
            parentContact.Legacy_Id__c = dcr.Player_Contact_ID__c;
            lstParentContacts.add(parentContact);
        }
        insert lstParentContacts;

        List<Account> lstAccounts = [
            SELECT Id, Legacy_Id__c
              FROM Account
             WHERE Id IN (SELECT AccountId FROM Contact WHERE Id IN :lstParentContacts)
              WITH USER_MODE
        ];

        mapAccountIds = new Map<Id, Id>();
        for (Account acc : lstAccounts) {
            mapAccountIds.put(acc.Legacy_Id__c, acc.Id);
        }
    }

    private void insertPlayerContacts() {
        List<Contact> lstPlayerContacts = new List<Contact>();
        for (Dataverse_Contact_Request__c dcr : lstRequestsForInsert) {
            Contact playerContact = new Contact();
            playerContact.AccountId = mapAccountIds.get(dcr.Id);
            playerContact.FirstName = dcr.Player_First_Name__c;
            playerContact.LastName = dcr.Player_Last_Name__c;
            playerContact.Legacy_Id__c = dcr.Player_Contact_ID__c;
            lstPlayerContacts.add(playerContact);
        }
        insert lstPlayerContacts;
    }

    /**
     * @description
     */
    private List<Dataverse_Contact_Request__c> filterToNewContacts() {
        List<Dataverse_Contact_Request__c> results = new List<Dataverse_Contact_Request__c>();
        for (Dataverse_Contact_Request__c dcr : lstRequests) {
            if (dcr.Contact__c == null) {
                results.add(dcr);
            }
        }
        return results;
    }
    
    /**
     * @description Get a matching contact for the incoming request
     *  If the request has a valid contact id, return that contact
     *  Otherwise, look for a contact with matching first and last name
     * @param Dataverse_Contact_Request__c request
     * @return Id of the matching contact record
     */
    private Id searchMatchingContact(Dataverse_Contact_Request__c dcr) {
        List<Contact> lstContacts = [
            SELECT Id
              FROM Contact
             WHERE Id = :dcr.Contact__c
                OR (FirstName = :dcr.Player_First_Name__c
                    AND LastName = :dcr.Player_Last_Name__c)
              WITH USER_MODE
             LIMIT 1
        ];
        if (!lstContacts.isEmpty()) {
            return lstContacts[0].Id;
        } else {
            return null;
        }
    }

}