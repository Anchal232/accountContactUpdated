public with sharing class ActivateAccountClass {
    @AuraEnabled
    public static void activateAccount(Id recordId){
        try {
            Account acc = [SELECT Id, Active__c, Type, Account_Activation_Summary__c FROM Account WHERE Id = :recordId];
            if(acc.Type == 'Customer' && acc.Account_Activation_Summary__c != null){
                acc.Active__c = true;
                update acc;
            }
            else{
                throw new AuraHandledException('Either account type is not customer or summary is empty');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}