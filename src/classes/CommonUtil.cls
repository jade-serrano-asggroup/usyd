public class CommonUtil {
	
	public static List<String> getApiNames(String fieldsToTokenize, String objectName){

		List<String> fieldNamesList = fieldsToTokenize.split(',');
		Set<String> fieldNamesSet = new Set<String>(fieldNamesList);
		List<String> fieldApiNames = new List<String>();

		DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();

		for (String field : fieldNamesSet) {
			 DescribeFieldResult fieldResult = objectResult.fields.getMap().get(field).getDescribe();
		   	 fieldApiNames.add(fieldResult.getName());
		}
		
		return fieldApiNames;
    }

    public static Map<String, Schema.SObjectField> getFieldDescriptionDetails(String objectName){

    	Map<String, Schema.SObjectType> objectDescriptionMap = Schema.getGlobalDescribe();

		Schema.Describesobjectresult result = objectDescriptionMap.get(objectName).getDescribe();
		Map<String, Schema.SObjectField> fieldsDescriptionMap = result.fields.getMap();

		return fieldsDescriptionMap;
    }

    /*public static DescribeObjectResult getFieldDetails(String objectName){

    	DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
		

		return objResult;
    }*/
    
}