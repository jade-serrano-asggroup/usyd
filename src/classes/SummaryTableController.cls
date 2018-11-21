public without sharing class SummaryTableController {
    @AuraEnabled
    public static Object getParentObjectName(Id recordId){
        recordId = Id.valueOf(recordId);
        String sObjLabel = recordId.getSObjectType().getDescribe().getLabel();
        String sObjAPI = recordId.getSobjectType().getDescribe().getName();
        String nameAPI;
        if (sObjAPI != 'Case'){ nameAPI = 'Name'; } else { nameAPI = 'CaseNumber';}
        String query = 'Select ' + nameAPI +' From ' + sObjAPI + ' Where Id =: recordId';
        sObject oo = database.query(query);
        Map<String,String> names = new Map<String,String>();
        names.put('parentObjLabel', sObjLabel);
        names.put('parentObjAPI',sObjAPI);
        names.put('parentRecName',string.valueOf(oo.get(nameAPI)));
        return names;
    }
    @AuraEnabled
    public static String getIconName(String sObjectName){
        
        String u;
        
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }
        
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sObjectName == tr.getSobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    u = 'standard:' + sObjectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                u = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }            
        
        return u;
    }
    
    @AuraEnabled 
    public static String getObjLabel(String objAPIName){
        system.debug(objAPIName);
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objAPIName}); // this can accept list of strings, we describe only one object here
        String objectLabel = describeSobjectsResult[0].getLabel();
        return objectLabel;
    }
    
    @AuraEnabled
    public static Integer getCountRecords(String recId, String relatedObjectName, String conditions, String relationship) 
    {
        // Charles 01/11/2018 Get Profile Name, Schools and Units
        Id userId = UserInfo.getUserId();
        User currentUser = [Select profileId, Faculty_School__c, Business_Unit__c From User Where Id =: userId];
        String FacultySchool = currentUser.Faculty_School__c;
        String BusinessUnit = currentUser.Business_Unit__c;
        
        Integer count;
        
        Id recordId = Id.valueOf(recId);
        
        try{
            count = Database.countQuery(countQueryGenerator(relatedObjectName, relationship,recordId,conditions));
        }catch(Exception e){
            System.debug('Exception: '+ e);
        }
        
        return count;
    }
    
    
    @AuraEnabled
    public static List<sObject> getRecords(String recId, String fields, String relatedObjectName, 
                                           String conditions, String sortOrder, String relationship, String recordLimit, String offset) 
    {
        // Charles 01/11/2018 Get Profile Name, Schools and Units
        Id userId = UserInfo.getUserId();
        User currentUser = [Select profileId, Faculty_School__c, Business_Unit__c From User Where Id =: userId];
        String FacultySchool = currentUser.Faculty_School__c;
        String BusinessUnit = currentUser.Business_Unit__c;
        
        List<sObject> relatedRecords = new List<sObject>();
        
        Id recordId = Id.valueOf(recId);
        Schema.SObjectType objectType = recordId.getSObjectType();
        String sObjectName = objectType.getDescribe().getName();
        DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(relatedObjectName).getDescribe();
        String finalFields = '';
        
        for (String field : fields.split(',')){
            if (string.valueOf(objectResult.fields.getMap().get(field).getDescribe().getType()) == 'REFERENCE' ){
                finalFields = finalFields + ', ' + objectResult.fields.getMap().get(field).getDescribe().getRelationshipName() + '.Name' ;
            } else {
                finalFields = finalFields + ', ' + field;
            }
        }
        
        try{
            relatedRecords = Database.query(queryGenerator(finalFields.substring(1), relatedObjectName, relationship,recordLimit,offset, recordId,conditions,sortOrder));
            System.debug('RelatedRecords: ' + relatedRecords);
            
        }catch(Exception e){
            System.debug('Exception: '+ e);
        }
        
        return relatedRecords;
    }
    
    @AuraEnabled
    public static String getRecordTypeName(String recordId, String objectName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordId).getName();
    } 
    
    @AuraEnabled
    public static List<ColumnWrapper> getColumns(String recId, String fields, String relatedObjectName) {
        List<ColumnWrapper> columns = new List<ColumnWrapper>();
        Map<String, Schema.SObjectField> fieldDescriptionMap = CommonUtil.getFieldDescriptionDetails(relatedObjectName);
        List<String> fieldNamesList = fields.split(',');
        Set<String> fieldNamesSet = new Set<String>(fieldNamesList); 
        DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(relatedObjectName).getDescribe();
        
        for(String field : fieldNamesSet){
            if(field.equalsIgnoreCase('Name')){
                TypeAttributes typeAttrib = new TypeAttributes('_self', new Label('Name'),null);
                columns.add(new ColumnWrapper('linkName', 'url', 'Name', typeAttrib, true));
            } else if (field.equalsIgnoreCase('CaseNumber')){
                TypeAttributes typeAttrib = new TypeAttributes('_self', new Label('CaseNumber'),null);
                columns.add(new ColumnWrapper('linkName', 'url', 'CaseNumber', typeAttrib, false));
            } else{
                columns.add(createColumns(objectResult, field));
            }
        }
        
        System.debug('COLUMNS: ' + columns);
        return columns;
    }
	
    //relationship is deprecated    
    private static String queryGenerator(String fields, String relatedObjectName, String relationship,String recordLimit,String offset, String recordId,String conditions,String sortOrder){
        recordLimit = recordLimit == null  ? ' ' : ' LIMIT ' + string.valueOf(recordLimit);
        offset = offset == null ? ' ' : ' OFFSET '+ string.valueOf(offset);
        conditions = conditions == null || conditions == '' ? ' ' : ' WHERE ' + conditions ;
        sortOrder = sortOrder == null || sortOrder =='' ? ' ' : ' Order By ' + sortOrder;
        String query = 'SELECT Id,' + fields + ' FROM ' + relatedObjectName + conditions + sortOrder + recordLimit + offset;
        system.debug(query);
        return query;
    }
    
    //relationship is deprecated
    private static String countQueryGenerator(String relatedObjectName, String relationship,String recordId,String conditions){
        conditions = conditions == null || conditions == '' ? ' ' : ' WHERE ' + conditions ;
        String query = 'SELECT count() FROM ' + relatedObjectName + conditions ;
        System.debug(query);
        return query;
    }
    
    private static ColumnWrapper createColumns(DescribeSObjectResult objectResult, String field){
        
        DescribeFieldResult fieldResult = objectResult.fields.getMap().get(field).getDescribe();
        
        if(String.valueOf(fieldResult.getType()) == 'REFERENCE'){
            System.debug('REFERENCE: ' + fieldResult.getName());
            return new ColumnWrapper(fieldResult.getRelationshipName()+'_Id', 'url', field, new TypeAttributes('_self', new Label(fieldResult.getRelationshipName()+'_Name'),fieldResult.getRelationshipName()),false);   
        }else{
            return new ColumnWrapper(fieldResult.getName(), String.valueOf(fieldResult.getType()), fieldResult.getLabel(), null, true);
        }
    }
    
    //Wrapper class for column attributes
    public class ColumnWrapper{
        
        @AuraEnabled
        public String fieldName {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public TypeAttributes typeAttributes{get; set;}
        @AuraEnabled
        public Boolean sortable {get;set;}
        
        public ColumnWrapper(String name, String dataType, String fieldLabel, TypeAttributes labelName, Boolean sortable){
            this.fieldName = name;
            this.type = dataType;
            this.label = fieldLabel;
            this.TypeAttributes = labelName;
            this.sortable = sortable;
        }
        
    }
    
    public class TypeAttributes{
        @AuraEnabled
        public Label label {get;set;}  
        @AuraEnabled
        public String target {get;set;}
        @AuraEnabled
        public String relationship{get;set;}
        
        public TypeAttributes(String target, Label label,String relationship){
            this.target = target;
            this.Label = label;
            this.relationship = relationship;
        }      
    }
    
    
    public class Label{
        @AuraEnabled
        public String fieldName {get;set;}
        
        public Label(String fieldName){
            this.fieldName = fieldName;
        }
    }  
}