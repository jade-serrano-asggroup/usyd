public with sharing class RecordTypeModalController {
    @AuraEnabled
    public static List<sObject> getRecordTypes(String objAPIName){
        List<RecordType> rts = new List<RecordType>(); //= [select Id,Name from RecordType where sObjectType=: objAPIName];

        

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objAPIName);
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes...
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable() 
                    // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                    // We check the Id because Name can change depending on the user's language.
                    && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                    rts.add(new RecordType (id =i.getRecordTypeId(),Name = i.getName()));
            }
        }
        return rts;
    }
}