/*****************************************************
 * @description Handles matching of player contacts and updated data when new
 *  requests are received from Microsoft Dataverse.
 * 
 * @date 2024
 *****************************************************/
public with sharing class DataverseContactService {

    private Dataverse_Contact_Request__c request;
    private Id contactId;

    /**
     * @description Constructor requires a Dataverse_Contact_Request__c record with
     *  at least First Name, Last Name and Email
     * @param Dataverse_Contact_Request__c
     */
    public DataverseContactService(Dataverse_Contact_Request__c request) {
        this.request = request;
    }

    /**
     * @description Get contact id or create a new family for the request
     * @return Id of the player contact
     */
    public Id getContactId() {
        if (this.contactId == null) {
            Id ctId = searchMatchingContact(request);
            if (ctId != null) {
                this.contactId = ctId;
            } else {
                this.contactId = createFamilyFromRequest(request);
            }
        }
        return this.contactId;
    }

    /**
     * TODO - Bulkify this nonsense
     * @description Create new player and parent contact
     * @return Id of the new player contact record
     */
    public Id createFamilyFromRequest(Dataverse_Contact_Request__c dcr) {
        Contact parentContact = new Contact();
        parentContact.FirstName = request.Parent_Guardian_First_Name__c;
        parentContact.LastName = request.Parent_Guardian_Last_Name__c;
        insert parentContact;

        parentContact = [SELECT Id, AccountId FROM Contact WHERE Id = :parentContact.Id WITH USER_MODE LIMIT 1];

        // Create player contact
        Contact playerContact = new Contact();
        playerContact.AccountId = parentContact.AccountId;
        playerContact.FirstName = request.Player_First_Name__c;
        playerContact.LastName = request.Player_Last_Name__c;
        insert playerContact;

        contactId = playerContact.Id;
        return contactId;
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