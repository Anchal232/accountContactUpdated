@IsTest
private class AccountTriggerTest {
    private static final String ACCOUNT_MANAGER_PS = 'Account_Manager_PS';
    private static final String SYST_ADMIN_PROFILE = 'System Administrator';
    
    @testSetup
    static void makeData(){
        Profile prof = [SELECT Id FROM profile WHERE Name LIKE :SYST_ADMIN_PROFILE];
        User user = new User();
        user.firstName = 'Anchal';
        user.lastName = 'Jain';
        user.profileId = prof.id;
        user.email = 'test@test.com';
        user.Username = 'anchalJain@cq.com';
        user.Alias = 'CQTest';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        insert user;
        
        user accountManagerUser = new user();
        accountManagerUser.firstName = 'Account';
        accountManagerUser.lastName = 'Manager';
        accountManagerUser.profileId = prof.id;
        accountManagerUser.email = 'test@test.com';
        accountManagerUser.username = 'accountManager@cq.com';
        accountManagerUser.Alias = 'CQTest';
        accountManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
        accountManagerUser.EmailEncodingKey = 'UTF-8';
        accountManagerUser.LanguageLocaleKey = 'en_US';
        accountManagerUser.LocaleSidKey = 'en_US';
        insert accountManagerUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :ACCOUNT_MANAGER_PS];
        insert new PermissionSetAssignment(AssigneeId = accountManagerUser.id, PermissionSetId = ps.Id);
    }
    
    @IsTest
    static void should_throw_error_while_account_create_if_not_account_manager(){
        //Given: A user
        Boolean isInserted;
        String exceptionMsg;
        System.runAs(getUser('Anchal Jain')){
            //When: Account is inserted
            Account acc = new Account(Name = 'test');
            try{
                insert acc;
            }
            catch(Exception e){
                isInserted = false;
                exceptionMsg = e.getMessage();
            }
            //Then: no account is created
            System.assertEquals(false, isInserted, 'Account should not be inserted');
            System.assertEquals(true, exceptionMsg.contains(Label.AccountManagerLbl), 'Error message thrown at run time');
            System.assertEquals(true, [Select Id FROM Contact].size()==0, 'No contact should be inserted');
        }
    }
    
    @IsTest
    static void should_insert_account_with_No_contact_since_account_type_not_customer(){
        //Given : a user
        User user = getUser('Account Manager');
        System.runAs(user){
            //When: account is inserted
            Account acc = new Account(Name = 'test');
            insert acc;
            
            //Then: account should get inserted and contact should be made
            System.assertEquals(true, acc.Id != null);
            System.assertEquals(true, [SELECT Id FROM Contact WHERE AccountId = :acc.Id ]. size() == 0);
            System.assertEquals(true, [Select Id FROM Contact].size()==0, 'No contact should be inserted since account type was not customer');
        }
    }
    
    @IsTest
    static void should_insert_contact_with_account_information(){
        //Given : a user
        User user = getUser('Account Manager');
        System.runAs(user){
            //When: account is inserted
            Account acc = new Account(Name = 'test',Active__c = true, Account_Activation_Summary__c = 'test', Type = 'Customer');
            insert acc;
            
            //Then: account should get inserted and contact should be made
            System.assertEquals(true, acc.Id != null);
            System.assertEquals(true, [SELECT Id FROM Contact WHERE AccountId = :acc.Id ]. size() > 0);
            Contact con = [SELECT Id, FirstName, LastName, Email, Phone, AccountId FROM Contact WHERE AccountId = :acc.Id];
            System.assertEquals(true, con.FirstName == acc.Name, 'Contact first name should be insert with account name');
            System.assertEquals(true, con.LastName == 'Customer Representative', 'Contact last name should be insert with Customer Representative value');
            System.assertEquals(true, con.AccountId == acc.Id, 'contact inserted with account id');
            System.assertEquals(true, con.Email == acc.Company_Email__c, 'contact inserted with account email field');
            System.assertEquals(true, con.Phone == acc.Phone, 'contact inserted with account email field');
            
        }
    }
    
    private static User getUser(String name){
        name = '%'+name+'%';
        return [SELECT Id FROM User WHERE Name Like :name LIMIT 1];
    }
}