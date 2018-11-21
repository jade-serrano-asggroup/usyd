/*
*    @description:    RecordPromptController test class
*    @author:         Jade Serrano (jade.serrano@asggroup.com.au)
*    @createddate:    October 25,2018
*/
@isTest
private class RecordPromptControllerTest {
	
	@isTest static void recordPromptTest() {
		Contact con = new Contact();
		con.LastName = 'James';
		con.Phone = '1234567890';
		con.Email = 'test@test.com';
		con.Prompt_Message__c = 'Lebron James';
		insert con;

		Test.startTest();
			String ret = RecordPromptController.recordPrompt(con.Id, 'Prompt_Message__c');

			System.assertEquals('Lebron James', ret);
		Test.stopTest();
	}	
}