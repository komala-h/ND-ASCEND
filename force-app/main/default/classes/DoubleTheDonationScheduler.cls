global class DoubleTheDonationScheduler implements Schedulable {
   
   global void execute(SchedulableContext ctx) {
       Map<String, Object> params = new Map<String, Object>();
       params.put('batchSize',18);
       String whereClause = 'ucinn_ascendv2__Double_The_Donation_Matching_Status__c = null AND ucinn_ascendv2__Double_the_Donation_ID__c = null ' +
           ' AND RecordType.Name = \'Corporations and Organizations Details\'' +
           ' AND ucinn_ascendv2__Double_the_Donation_Company_Name__c = null';
       params.put('whereClause', whereClause);
       
       ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_GIFT_DoubletheDonationBatch(params);

   }   
}