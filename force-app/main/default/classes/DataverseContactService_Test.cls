@IsTest
private class DataverseContactService_Test {

    @TestSetup
    static void makeData() {
        List<Contact> lstContacts = TestDataFactory.createContacts(1);
        insert lstContacts;
    }
    
    @IsTest
    static void testMatchingContact() {
        Contact ct = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];

        Dataverse_Contact_Request__c dcr = new Dataverse_Contact_Request__c();
        dcr.Contact__c = ct.Id;
        dcr.Player_First_Name__c = ct.FirstName;
        dcr.Player_Last_Name__c = ct.LastName;
        
        Test.startTest();
        DataverseContactService service = new DataverseContactService(dcr);
        Id contactId = service.getContactId();
        Test.stopTest();

        Assert.areEqual(ct.Id, contactId, 'Should have received the matching contact id');
    }

    @IsTest
    static void testNewContact() {
        Contact ct = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];

        Dataverse_Contact_Request__c dcr = new Dataverse_Contact_Request__c();
        dcr.Contact__c = null;
        dcr.Player_First_Name__c = 'Newguy';
        dcr.Player_Last_Name__c = 'Test';
        dcr.Parent_Guardian_First_Name__c = 'Parentnewguy';
        dcr.Parent_Guardian_Last_Name__c = 'Test';

        Test.startTest();
        DataverseContactService service = new DataverseContactService(dcr);
        Id contactId = service.getContactId();
        Test.stopTest();

        Assert.areNotEqual(ct.Id, contactId, 'Should have received a new contact');
    }

}