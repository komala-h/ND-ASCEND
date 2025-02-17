/**
 * @description    Test class for asc_MembershipLogoController.
 *
 * @author          UC Innovation
 * @date            07/22/2022
 */

@isTest
public class asc_MembershipLogoControllerTest {

    /**
    * Test getMembershipLogos method on Contact record
    */
    static testMethod void testMembershipLogosContact() {
        asc_MembershipLogoController.MembershipLogo one = new asc_MembershipLogoController.MembershipLogo('SorinBlue', null);
        TracHier.HierarchyAPI.setTriggerDisabled();
        Contact cont = new Contact(FirstName = 'first', LastName = 'last', Constituent_Status__c = 'A');
        insert cont;

        ucinn_ascendv2__Giving_Society__c givingSociety = new ucinn_ascendv2__Giving_Society__c();
        givingSociety.Name = 'Sorin Society';
        givingSociety.ucinn_ascendv2__Status__c = 'Active';
        insert givingSociety;

        List<ucinn_ascendv2__Membership_Level__c> membershipLevelList = new List<ucinn_ascendv2__Membership_Level__c>();
        ucinn_ascendv2__Membership_Level__c membershipLevel1 = new ucinn_ascendv2__Membership_Level__c();
        membershipLevel1.Name = 'Green';
        membershipLevel1.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membershipLevel1.ucinn_ascendv2__Order__c = 1;
        membershipLevel1.nd_Membership_Level_Code__c = 'SN';
        membershipLevelList.add(membershipLevel1);
        ucinn_ascendv2__Membership_Level__c membershipLevel2 = new ucinn_ascendv2__Membership_Level__c();
        membershipLevel2.Name = 'Blue';
        membershipLevel2.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membershipLevel2.ucinn_ascendv2__Order__c = 2;
        membershipLevel2.nd_Membership_Level_Code__c = 'SB';
        membershipLevelList.add(membershipLevel2);
        insert membershipLevelList;

        List<ucinn_ascendv2__Society_Membership__c> membershipList = new List<ucinn_ascendv2__Society_Membership__c>();
        ucinn_ascendv2__Society_Membership__c membership1 = new ucinn_ascendv2__Society_Membership__c();
        membership1.ucinn_ascendv2__Contact__c = cont.Id;
        membership1.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membership1.ucinn_ascendv2__Membership_Level__c = membershipLevel1.Id;
        membership1.nd_Status__c = 'A';
        membershipList.add(membership1);
        ucinn_ascendv2__Society_Membership__c membership2 = new ucinn_ascendv2__Society_Membership__c();
        membership2.ucinn_ascendv2__Contact__c = cont.Id;
        membership2.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membership2.ucinn_ascendv2__Membership_Level__c = membershipLevel2.Id;
        membership2.nd_Status__c = 'A';
        membershipList.add(membership2);
        insert membershipList;

        List<asc_MembershipLogoController.MembershipLogo> memLogoForContact = asc_MembershipLogoController.getMembershipLogos(cont.Id);
    }
    
    /**
    * Test getMembershipLogos method on Account record
    */
    static testMethod void testMembershipLogosAccount() {
        asc_MembershipLogoController.MembershipLogo one = new asc_MembershipLogoController.MembershipLogo('SorinBlue', null);
        TracHier.HierarchyAPI.setTriggerDisabled();
        Id orgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId();
        Account acct = new Account(Name = 'Test Company', RecordTypeId = orgRecTypeId);
        insert acct;

        ucinn_ascendv2__Giving_Society__c givingSociety = new ucinn_ascendv2__Giving_Society__c();
        givingSociety.Name = 'Sorin Society';
        givingSociety.ucinn_ascendv2__Status__c = 'Active';
        insert givingSociety;

        List<ucinn_ascendv2__Membership_Level__c> membershipLevelList = new List<ucinn_ascendv2__Membership_Level__c>();
        ucinn_ascendv2__Membership_Level__c membershipLevel1 = new ucinn_ascendv2__Membership_Level__c();
        membershipLevel1.Name = 'Green';
        membershipLevel1.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membershipLevel1.ucinn_ascendv2__Order__c = 1;
        membershipLevel1.nd_Membership_Level_Code__c = 'SN';
        membershipLevelList.add(membershipLevel1);
        ucinn_ascendv2__Membership_Level__c membershipLevel2 = new ucinn_ascendv2__Membership_Level__c();
        membershipLevel2.Name = 'Blue';
        membershipLevel2.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membershipLevel2.ucinn_ascendv2__Order__c = 2;
        membershipLevel2.nd_Membership_Level_Code__c = 'SB';
        membershipLevelList.add(membershipLevel2);
        insert membershipLevelList;

        List<ucinn_ascendv2__Society_Membership__c> membershipList = new List<ucinn_ascendv2__Society_Membership__c>();
        ucinn_ascendv2__Society_Membership__c membership1 = new ucinn_ascendv2__Society_Membership__c();
        membership1.ucinn_ascendv2__Account__c = acct.Id;
        membership1.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membership1.ucinn_ascendv2__Membership_Level__c = membershipLevel1.Id;
        membership1.nd_Status__c = 'A';
        membershipList.add(membership1);
        ucinn_ascendv2__Society_Membership__c membership2 = new ucinn_ascendv2__Society_Membership__c();
        membership2.ucinn_ascendv2__Account__c = acct.Id;
        membership2.ucinn_ascendv2__Giving_Society__c = givingSociety.Id;
        membership2.ucinn_ascendv2__Membership_Level__c = membershipLevel2.Id;
        membership2.nd_Status__c = 'A';
        membershipList.add(membership2);
        insert membershipList;

        List<asc_MembershipLogoController.MembershipLogo> memLogoForAccount = asc_MembershipLogoController.getMembershipLogos(acct.Id);
    }

    /**
    * Test error scenario.
    */
    static testMethod void testError() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        Contact cont = new Contact(FirstName = 'first', LastName = 'last', Constituent_Status__c = 'A');
        insert cont;

        List<asc_MembershipLogoController.MembershipLogo> memLogoForContact = asc_MembershipLogoController.getMembershipLogos(cont.Id);
    }

}