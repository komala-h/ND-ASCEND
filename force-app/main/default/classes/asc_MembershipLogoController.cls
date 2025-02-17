/**
 * @description     Controller for asc_MembershipLogo Lightning Component
 *
 * @author          UC Innovation
 * @date            07/22/2022
 */

public without sharing class asc_MembershipLogoController {

    /**
    * Get the list of membership logos that meet the criteria defined in the custom metadata type.
    *
    * @param recId      The record ID of Constituent/Organization to display the membership logo on.
    *
    * @return           List of membership logos that meet the criteria defined in the custom metadata type.
    */
    @AuraEnabled
    public static List<MembershipLogo> getMembershipLogos(String recId) {
        List<ucinn_ascendv2__Society_Membership__c> societyMemberships = getMemberships(recId);

        if (societyMemberships != null && !societyMemberships.isEmpty()) {
            List<MembershipLogo> membershipLogos = getLogosForMemberships(societyMemberships);
            return membershipLogos;
        }
        else {
            return null;
        }
    }

    /**
    * Get the Society Membership records of the Constituent/Organization that meet the criteria defined in the custom metadata type.
    *
    * @param recId          The record ID of Constituent/Organization to display the membership logo on.
    *
    * @return               List of Society Membership records of the Constituent/Organization that meet the criteria defined in the custom metadata type.
    */
    public static List<ucinn_ascendv2__Society_Membership__c> getMemberships(String recId) {
        List<String> givingSocietiesNames = getGivingSocietiesToQuery();
        Id recordId = Id.valueOf(recId);
        List<ucinn_ascendv2__Society_Membership__c> societyMemberships;

        if (givingSocietiesNames.size() > 0) {
            String query = 'SELECT Id, ucinn_ascendv2__Giving_Society__c, ucinn_ascendv2__Giving_Society__r.Name, ucinn_ascendv2__Membership_Level__c, ucinn_ascendv2__Membership_Level__r.Name, ucinn_ascendv2__Membership_Level__r.ucinn_ascendv2__Order__c, ucinn_ascendv2__Membership_Level__r.nd_Membership_Level_Code__c FROM ucinn_ascendv2__Society_Membership__c';
            String whereClause = ' WHERE ucinn_ascendv2__Giving_Society__r.Name IN :givingSocietiesNames AND ucinn_ascendv2__Giving_Society__r.ucinn_ascendv2__Status__c = \'Active\' AND nd_Status__c = \'A\'';
            if (recordId.getSObjectType() == Schema.Account.getSObjectType()) {
                whereClause += ' AND ucinn_ascendv2__Account__c =\'' + String.escapeSingleQuotes(recId) + '\'';
            } else if (recordId.getSObjectType() == Schema.Contact.getSObjectType()) {
                whereClause += ' AND ucinn_ascendv2__Contact__c =\'' + String.escapeSingleQuotes(recId) + '\'';
            }
            query += whereClause;
            societyMemberships = Database.query(query);
        }

        return societyMemberships;
    }

    /**
    * Get the list of Giving Societies defined in the custom metadata type.
    *
    * @param N/A
    *
    * @return       List of Giving Societies defined in the custom metadata type.
    */
    public static List<String> getGivingSocietiesToQuery() {
        Set<String> givingSocieties = new Set<String>();

        for (Membership_Logo__mdt ml: [SELECT Giving_Society__c FROM Membership_Logo__mdt]) {
            givingSocieties.add(ml.Giving_Society__c);
        }

        return new List<String>(givingSocieties);
    }

    /**
    * Get the list of membership logos that meet the criteria defined in the custom metadata type.
    *
    * @param societyMemberships     The Society Membership records of the Constituent/Organization that meet the criteria defined in the custom metadata type.
    *
    * @return                       List of membership logos that meet the criteria defined in the custom metadata type.
    */
    public static List<MembershipLogo> getLogosForMemberships(List<ucinn_ascendv2__Society_Membership__c> societyMemberships) {
        List<MembershipLogo> membershipLogos = new List<MembershipLogo>();
        Map<String, ucinn_ascendv2__Society_Membership__c> gsNameToMembershipRec = new Map<String, ucinn_ascendv2__Society_Membership__c>();

        // Create a mapping of Giving Society to the highest membership level of the Society Memberships record
        for (ucinn_ascendv2__Society_Membership__c sm : societyMemberships) {
            Integer memberLevel = 1; // default member level to "1" if ucinn_ascendv2__Membership_Level__c is blank

            if (sm.ucinn_ascendv2__Membership_Level__c != null) {
                if (sm.ucinn_ascendv2__Membership_Level__r.ucinn_ascendv2__Order__c != null) {
                    memberLevel = integer.valueOf(sm.ucinn_ascendv2__Membership_Level__r.ucinn_ascendv2__Order__c);
                }
            }
            
            if (gsNameToMembershipRec.containsKey(sm.ucinn_ascendv2__Giving_Society__r.Name)) {
                Integer storedMemberLevel = 1; // default member level to "1" if ucinn_ascendv2__Membership_Level__c is blank

                if (gsNameToMembershipRec.get(sm.ucinn_ascendv2__Giving_Society__r.Name).ucinn_ascendv2__Membership_Level__c != null) {
                    if (gsNameToMembershipRec.get(sm.ucinn_ascendv2__Giving_Society__r.Name).ucinn_ascendv2__Membership_Level__r.ucinn_ascendv2__Order__c != null) {
                        storedMemberLevel = integer.valueOf(gsNameToMembershipRec.get(sm.ucinn_ascendv2__Giving_Society__r.Name).ucinn_ascendv2__Membership_Level__r.ucinn_ascendv2__Order__c);
                    }
                }
                
                // update the Society Membership record stored inside the map with the Society Membership record that has a higher membership level
                if (memberLevel > storedMemberLevel) {
                    gsNameToMembershipRec.put(sm.ucinn_ascendv2__Giving_Society__r.Name, sm);
                }
            } else {
                gsNameToMembershipRec.put(sm.ucinn_ascendv2__Giving_Society__r.Name, sm);
            }
        }

        Map<String, Map<String, String>> gsNameToMemberLevelCodeToStatResource = new Map<String, Map<String, String>>();
        for (Membership_Logo__mdt ml: [SELECT Giving_Society__c, Membership_Level_Code__c, Static_Resource__c FROM Membership_Logo__mdt WHERE Giving_Society__c IN :gsNameToMembershipRec.keySet()]) {
            if (ml.Giving_Society__c != null && ml.Membership_Level_Code__c != null && ml.Static_Resource__c != null) {
                if (gsNameToMemberLevelCodeToStatResource.containsKey(ml.Giving_Society__c)) {
                    gsNameToMemberLevelCodeToStatResource.get(ml.Giving_Society__c).put(ml.Membership_Level_Code__c, ml.Static_Resource__c);
                } else {
                    gsNameToMemberLevelCodeToStatResource.put(ml.Giving_Society__c, new Map<String, String>{ml.Membership_Level_Code__c=>ml.Static_Resource__c});
                }
            }
        }

        for (ucinn_ascendv2__Society_Membership__c membership : gsNameToMembershipRec.values()) {
            String memberLevelCode;

            if (membership.ucinn_ascendv2__Membership_Level__c != null) {
                if (membership.ucinn_ascendv2__Membership_Level__r.nd_Membership_Level_Code__c != null) {
                    memberLevelCode = membership.ucinn_ascendv2__Membership_Level__r.nd_Membership_Level_Code__c;
                }

                if (memberLevelCode != null) {
                    if (gsNameToMemberLevelCodeToStatResource.containsKey(membership.ucinn_ascendv2__Giving_Society__r.Name)) {
                        if (gsNameToMemberLevelCodeToStatResource.get(membership.ucinn_ascendv2__Giving_Society__r.Name).containsKey(memberLevelCode)) {
                            String staticResourceName = gsNameToMemberLevelCodeToStatResource.get(membership.ucinn_ascendv2__Giving_Society__r.Name).get(memberLevelCode);
                            membershipLogos.add(new MembershipLogo(staticResourceName, null));
                        }
                    }
                }
            }
        }
        
        return membershipLogos;
    }

    /**
    * Inner class, creating our 'MembershipLogo' object and attributes
    */
    public class MembershipLogo{
        //first, the attributes:
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String url {get; set;}

       /**
        * Constructor
        *
        * @param name   The name of the static resource.
        * @param url    The url string of the static resource to display on the page.(The string is created in js code of the lightning page)
        */
        public MembershipLogo(String name, String url) {
            this.name = name;
            this.url = url;
        }
    }
}