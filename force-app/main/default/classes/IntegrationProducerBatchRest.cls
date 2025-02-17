@RestResource(urlMapping='/Integration_out/*')
global with sharing class  IntegrationProducerBatchRest {
    /*
	@HttpGet
    global static id scheduleIntegration() {
        IntegrationProducerBatchScheduler schedule = new IntegrationProducerBatchScheduler();
		// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		String sch = '0 55 * * * ?';
		String jobID = System.schedule('integration producer batch 55 min', sch, schedule);
        return jobID;
    } */
    @HttpPost
    global static id execute() {
        boolean long_data = boolean.Valueof(RestContext.request.params.get('long_data'));
        Integer batch_size = Integer.ValueOf(RestContext.request.params.get('batch_size')); 
        id batchID = Database.executeBatch(new IntegrationProducerBatch(long_data), batch_size);
        return batchID;
        
    }
   
}