trigger Payment_Int_out_Trigger on ucinn_ascendv2__Payment__c (after insert, after Update, after delete, after undelete) 
{
   if (Trigger.isInsert || Trigger.isUndelete)
   {         
       Integration_Out_Class.InsertNewRecord(Trigger.New);
   }
   else if (Trigger.isUpdate)
   {
       Integration_Out_Class.UpdateRecord(Trigger.New);
   }
   else if (Trigger.isDelete)
   {
       Integration_Out_Class.DeleteRecord(Trigger.Old);
   }
 
}