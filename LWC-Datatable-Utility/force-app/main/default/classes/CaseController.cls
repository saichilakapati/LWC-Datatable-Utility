public with sharing class CaseController {
    @AuraEnabled(cacheable=true)
    public static list<Case>  getCases(){
        return [SELECT AccountId, CaseNumber, 
                Type,Status, Origin, Priority, 
                Contact.Name, ClosedDate 
                FROM Case WHERE AccountId = Null 
                WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static void  mergeCases(String accId, String selectedRows){
        try{
            System.debug('==accId===='+accId);
            System.debug('==selectedRows===='+selectedRows);
            List<Object> selectedRecords =  (List<Object>)JSON.deserializeUntyped(selectedRows);
            Set<Id> caseIdSet = new Set<Id>();
            List<Case> updateList = new List<Case>();
            for(Object selectedRec: selectedRecords){
                Map<String, Object> rec = (Map<String, Object>)selectedRec;
                caseIdSet.add((String)rec.get('Id'));
            }
            System.debug('==caseIdSet==='+caseIdSet);
            if(!String.isBlank(accId) && !caseIdSet.isEmpty()){
                for(Case ca: [SELECT AccountId FROM Case WHERE Id IN: caseIdSet 
                                WITH SECURITY_ENFORCED]){
                    ca.AccountId = accId;
                    updateList.add(ca);
                }
            }
            If(!updateList.isEmpty()){
                UPDATE updateList;
            }
        }catch(Exception e){
            System.debug('===Exception====='+e);
        }
    }
}