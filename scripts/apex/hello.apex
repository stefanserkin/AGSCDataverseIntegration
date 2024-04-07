// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

Dataverse_Contact_Request__c dcr = new Dataverse_Contact_Request__c();
dcr.Player_First_Name__c = 'Serk';
dcr.Player_Last_Name__c = 'theJerk';
dcr.Parent_Guardian_First_Name__c = 'Parental';
dcr.Parent_Guardian_Last_Name__c = 'theJerk';
DataverseContactService serv = new DataverseContactService(new List<Dataverse_Contact_Request__c>{dcr});
serv.upsertContactsFromRequests();
