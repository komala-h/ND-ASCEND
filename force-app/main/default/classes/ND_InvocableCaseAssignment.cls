/*********
* Author: UCInnovation, qluong
* Date: 3/22/2023
* Description: Run case assignment rules
* Parameters: List of Case Ids
**********/
public class ND_InvocableCaseAssignment {
    @InvocableMethod
    (label='Apply Case Assignment Rule' description='Runs case assignment rule on new cases.')
    public static void assignCases(List<Id> caseIds){
    
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;          
            List<Case> lstCase=[SELECT Id from Case where Id in :caseIds];
            for (Case obj:lstCase){
                obj.setOptions(dmo);
            } 
            update lstCase;
   }
   

}