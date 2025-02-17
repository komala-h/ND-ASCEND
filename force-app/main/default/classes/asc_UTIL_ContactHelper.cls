/**
 * @author UC Innovation
 * @date 4/19/2021
 * @group Trigger Handlers
 * @description Helper class for Contact
 */
public with sharing class asc_UTIL_ContactHelper {
    
    /*******************************************************************************************************
     * @description Method to get contact data
     * @param contactSet Set of contact Ids
     * @param currentContextContactRecords List of contact records of the current context
     * @param currenctContextConstituentRecords List of constituent name records of the current context
     * @return Map of Contact Id and contact data
     */
    public Static Map<Id, Map<String, Object>> getContactData(Set<Id> contactSet) {
        Map<Id, Map<String, Object>> returnMap = new Map<Id, Map<String, Object>>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, ucinn_ascendv2__Contact_Name__c> contactCnMap = new Map<Id, ucinn_ascendv2__Contact_Name__c>();
        Map<Id, Id> spouseMap = new Map<Id, Id>(); 
        
        if (!contactSet.isEmpty()) {
            
            // Collect spouse - using current contact
            for (Contact con : [Select Id, ucinn_ascendv2__Preferred_Spouse__c, nd_Partner_Significant_Other__c  From Contact Where Id In :contactSet 
                    And (ucinn_ascendv2__Preferred_Spouse__c != null Or nd_Partner_Significant_Other__c != null)]) {
                if (con.ucinn_ascendv2__Preferred_Spouse__c != null) {
                    spouseMap.put(con.Id, con.ucinn_ascendv2__Preferred_Spouse__c);
                    spouseMap.put(con.ucinn_ascendv2__Preferred_Spouse__c, con.Id);
                } else if (con.nd_Partner_Significant_Other__c != null) {
                    spouseMap.put(con.Id, con.nd_Partner_Significant_Other__c);
                    spouseMap.put(con.nd_Partner_Significant_Other__c, con.Id);
                }
            }
            
            // Collect contacts
            for (Contact con : [Select Id, AccountId, ucinn_ascendv2__Preferred_Spouse__c, ucinn_ascendv2__Lifetime_Cash__c, ucinn_ascendv2__Contact_Type__c, ucinn_ascendv2__Donor_ID__c,  
                    CreatedDate, Account.ucinn_ascendv2__Primary_Contact__c From Contact Where (Id In :contactSet Or Id In :spouseMap.KeySet())]) {
                contactMap.put(con.Id, con);
                contactCnMap.put(con.Id, null);
            }
            
            // Collect Full Names
            for (ucinn_ascendv2__Contact_Name__c cn : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Prefix__c, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, 
                    ucinn_ascendv2__Last_Name__c, ucinn_ascendv2__Nickname__c, ucinn_ascendv2__Suffix__c From ucinn_ascendv2__Contact_Name__c 
                    Where ucinn_ascendv2__Contact__c In :contactMap.keySet() And ucinn_ascendv2__Type__c = 'Full Name']) {
                contactCnMap.put(cn.ucinn_ascendv2__Contact__c, cn);
            }
            
            // Get name parts
            for (Id conId : contactMap.keySet()) {
                Contact con = contactMap.get(conId);
                ucinn_ascendv2__Contact_Name__c cn = contactCnMap.get(conId);
                Map<String, String> namePartMap = getNameParts(con, cn, '');
                
                returnMap.put(conId, new Map<String, Object>());
                
                if (spouseMap.containsKey(con.Id)) {
                    Contact con_spouse = contactMap.get(spouseMap.get(con.Id));
                    ucinn_ascendv2__Contact_Name__c cn_spouse = contactCnMap.get(spouseMap.get(con.Id));
                    
                    // Keep both contact and spouse in order
                    if (con.CreatedDate < con_spouse.CreatedDate) {
                        namePartMap.putAll(getNameParts(con, cn, 'c1_'));
                        namePartMap.putAll(getNameParts(con_spouse, cn_spouse, 'c2_'));
                    } else {
                        namePartMap.putAll(getNameParts(con, cn, 'c2_'));
                        namePartMap.putAll(getNameParts(con_spouse, cn_spouse, 'c1_'));
                    }
                    
                    returnMap.get(conId).put('contact_spouse', con_spouse);
                    returnMap.get(conId).put('contactname_spouse', cn_spouse);
                }
                
                returnMap.get(conId).put('accountId', con.AccountId);
                returnMap.get(conId).put('contact', con);
                returnMap.get(conId).put('contactname', cn);
                returnMap.get(conId).put('nameParts', namePartMap);
            }
        }
        
        return returnMap;
    }
    
    /*******************************************************************************************************
     * @description Method to setup salutation
     * @param contactData Map of contact data
     * @return N/A
     */
    public Static void setupSalutations(Map<Id, Map<String, Object>> contactData) {
        List<ucinn_ascendv2__Salutation__c> upsertSalutationList = new List<ucinn_ascendv2__Salutation__c>();
        Map<Id, ucinn_ascendv2__Salutation__c> deleteSalutationMap = new Map<Id, ucinn_ascendv2__Salutation__c>();
        Map<String, RecordType> rtMap = new Map<String, RecordType>();
        Map<String, Map<String, Map<String, String>>> individualSalMap = new Map<String, Map<String, Map<String, String>>>(); // Map<Record Type DeveloperName, Map<Type, Map<Field, Salutation>>
        Map<String, Map<String, Map<String, String>>> jointSalMap = new Map<String, Map<String, Map<String, String>>>();      // Map<Record Type DeveloperName, Map<Type, Map<Field, Salutation>>
        Map<String, Map<String, Map<String, String>>> salMap = new Map<String, Map<String, Map<String, String>>>();           // Map<Record Type DeveloperName, Map<Type, Map<Field, Salutation>>
        Map<Id, Map<String, String>> contactNameMap = new Map<Id, Map<String, String>>();
        Map<Id, Map<String, Map<String, ucinn_ascendv2__Salutation__c>>> contactTypeSalutationMap = 
                new Map<Id, Map<String, Map<String, ucinn_ascendv2__Salutation__c>>>();                                       // Map<ContactId, Map<Record Type DeveloperName, Map<Type, Salutation>>
        Map<String, Integer> hierarchyOrderMap = new Map<String, Integer>{
            'Parent'=>1,'Alumni Widow'=>2,'Employee'=>3,'Friend'=>4,'Student'=>5,'Retired Employee'=>6,
            'Former Employee'=>7,'Non-Returning Student'=>8,'Confirmed Admitted Student'=>9,
            'Parent of Non-Returning Student'=>10,'Related Entity'=>11,'Unknown Individual'=>12,'Related Child'=>13};
        Set<Id> insertedSalContactSet = new Set<Id>();
        
        if (!contactData.isEmpty()) {

            // Collect record types
            for (RecordType rt : [Select Id, DeveloperName From RecordType Where SobjectType='ucinn_ascendv2__Salutation__c']) {
                rtMap.put(rt.DeveloperName, rt);
            }
            
            // Collect existing salutation
            for (ucinn_ascendv2__Salutation__c sal : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Inside_Salutation__c, Custom_Salutation__c,
                    ucinn_ascendv2__Salutation_Type__c, RecordType.DeveloperName From ucinn_ascendv2__Salutation__c Where ucinn_ascendv2__Contact__c In :contactData.keySet() 
                    And ucinn_ascendv2__Salutation_Type__c In ('Formal','Informal') And ucinn_ascendv2__Salutation_Author__c = 'Custom']) {
                if (!contactTypeSalutationMap.containsKey(sal.ucinn_ascendv2__Contact__c)) {
                    contactTypeSalutationMap.put(sal.ucinn_ascendv2__Contact__c, new Map<String, Map<String, ucinn_ascendv2__Salutation__c>>());
                }
                if (!contactTypeSalutationMap.get(sal.ucinn_ascendv2__Contact__c).containsKey(sal.RecordType.DeveloperName)) {
                    contactTypeSalutationMap.get(sal.ucinn_ascendv2__Contact__c).put(sal.RecordType.DeveloperName, new Map<String, ucinn_ascendv2__Salutation__c>());
                }
                contactTypeSalutationMap.get(sal.ucinn_ascendv2__Contact__c).get(sal.RecordType.DeveloperName).put(sal.ucinn_ascendv2__Salutation_Type__c, sal);
            }
            
            // Collect salutations
            for (Id conId : contactData.keySet()) {
                Map<String, String> namePartMap = new Map<String, String>();
                Contact con = new Contact();
                Contact con_spouse = new Contact();
                ucinn_ascendv2__Contact_Name__c contactname = new ucinn_ascendv2__Contact_Name__c();
                ucinn_ascendv2__Contact_Name__c contactname_spouse = new ucinn_ascendv2__Contact_Name__c();
                Id accountId = null;
                
                if (contactData.containsKey(conId)) {
                    if (contactData.get(conId).containsKey('accountId')) {
                        accountId = (Id)contactData.get(conId).get('accountId');
                    }
                    if (contactData.get(conId).containsKey('nameParts')) {
                        namePartMap = (Map<String, String>)contactData.get(conId).get('nameParts');
                    }
                    if (contactData.get(conId).containsKey('contact')) {
                        con = (Contact)contactData.get(conId).get('contact');
                    }
                    if (contactData.get(conId).containsKey('contactname')) {
                        contactname = (ucinn_ascendv2__Contact_Name__c)contactData.get(conId).get('contactname');
                    }
                    
                    // Keep both contact and spouse in order
                    if (contactData.get(conId).containsKey('contact_spouse') && contactData.get(conId).containsKey('contactname_spouse')) {
                        if (con.CreatedDate < ((Contact)contactData.get(conId).get('contact_spouse')).CreatedDate) {
                            con_spouse = (Contact)contactData.get(conId).get('contact_spouse');
                            contactname_spouse = (ucinn_ascendv2__Contact_Name__c)contactData.get(conId).get('contactname_spouse');
                        } else {
                            con_spouse = con;
                            con = (Contact)contactData.get(conId).get('contact_spouse');
                            contactname_spouse = contactname;
                            contactname = (ucinn_ascendv2__Contact_Name__c)contactData.get(conId).get('contactname_spouse');
                        }
                    }
                }
                
                // Evaluate hierarchy
                String jointPrimaryPrefix = 'c1';
                String jointSecondaryPrefix = 'c2';
                /* not using at the moment
                Boolean isContactAnAlumni = false;
                Boolean isContactSpouseAnAlumni = false;
                Decimal contactLifetimeCash = (con.ucinn_ascendv2__Lifetime_Cash__c != null) ? con.ucinn_ascendv2__Lifetime_Cash__c : 0;
                Decimal contactSpouseLifetimeCash = (con_spouse.ucinn_ascendv2__Lifetime_Cash__c != null) ? con_spouse.ucinn_ascendv2__Lifetime_Cash__c : 0;
                Integer contactDonorID = (con.ucinn_ascendv2__Donor_ID__c != null && con.ucinn_ascendv2__Donor_ID__c.isNumeric()) ? Integer.valueOf(con.ucinn_ascendv2__Donor_ID__c) : 0;
                Integer contactSpouseDonorID = (con_spouse.ucinn_ascendv2__Donor_ID__c != null && con_spouse.ucinn_ascendv2__Donor_ID__c.isNumeric()) ? Integer.valueOf(con_spouse.ucinn_ascendv2__Donor_ID__c) : 0;
                Integer contactLowestHierarchy = 999;
                Integer contactSpouseLowestHierarchy = 999;
                
                for (String s : (con.ucinn_ascendv2__Contact_Type__c+'').split(';')) {
                    if (s == 'AL') {
                        isContactAnAlumni = true;
                    }
                    
                    if (hierarchyOrderMap.containsKey(s)) {
                        if (contactLowestHierarchy > hierarchyOrderMap.get(s)) {
                            contactLowestHierarchy = hierarchyOrderMap.get(s);
                        }
                    }
                }
                
                for (String s : (con_spouse.ucinn_ascendv2__Contact_Type__c+'').split(';')) {
                    if (s == 'AL') {
                        isContactSpouseAnAlumni = true;
                    }
                    
                    if (hierarchyOrderMap.containsKey(s)) {
                        if (contactSpouseLowestHierarchy > hierarchyOrderMap.get(s)) {
                            contactSpouseLowestHierarchy = hierarchyOrderMap.get(s);
                        }
                    }
                }
                */
                //W-001827 want the constituent on the relationship to be the addressee line 1 and related constituent to be on the addressee line 2
                //on the salutation. qluong - this logic is the same as the ascend logic.
                //if (con != null && con_spouse != null) {
                //    jointPrimaryPrefix = 'c1';
                //    jointSecondaryPrefix = 'c2';
                //}
                
                // T-01475: Primary Constituent should always be first in the joint salutation
                if (con != null && con_spouse != null) {                
                    if (con.AccountId == con_spouse.AccountId) {
                        if (con.Account.ucinn_ascendv2__Primary_Contact__c == con.Id) {
                            jointPrimaryPrefix = 'c1';
                            jointSecondaryPrefix = 'c2';
                        } else if (con_spouse.Account.ucinn_ascendv2__Primary_Contact__c == con_spouse.Id) {
                            jointPrimaryPrefix = 'c2';
                            jointSecondaryPrefix = 'c1';
                        }
                    } else {
                    
                        jointPrimaryPrefix = 'c1';
                        jointSecondaryPrefix = 'c2';
                    }
                }
                
                /* if (isContactAnAlumni == isContactSpouseAnAlumni) {                               // Both are either Alumni or not
                    if (contactSpouseLowestHierarchy == contactLowestHierarchy) {                 // Both have the same constituent hierachy
                        if (contactSpouseLifetimeCash == contactLifetimeCash) {
                            if (contactSpouseDonorID < contactDonorID) {
                                jointPrimaryPrefix = 'c2';
                                jointSecondaryPrefix = 'c1';
                            }
                        } else if (contactSpouseLifetimeCash > contactLifetimeCash) {
                            jointPrimaryPrefix = 'c2';
                            jointSecondaryPrefix = 'c1';
                        }
                    } else if (contactSpouseLowestHierarchy < contactLowestHierarchy) {
                        jointPrimaryPrefix = 'c2';
                        jointSecondaryPrefix = 'c1';
                    }
                    
                    
                } else {                                                                          // One of them is Alumni
                    if (isContactSpouseAnAlumni) {
                        jointPrimaryPrefix = 'c2';
                        jointSecondaryPrefix = 'c1';
                    }
                } */
                
                salMap.clear();
                
                // Individual Salutation mapping
                individualSalMap.put('Individual_Salutation', new Map<String, Map<String, String>>());
                individualSalMap.get('Individual_Salutation').put('Formal', new Map<String, String>());
             //   individualSalMap.get('Individual_Salutation').get('Formal').put('Inside','{#default_name_with_prefix#}');
                individualSalMap.get('Individual_Salutation').get('Formal').put('Inside','{#first#}');
                individualSalMap.get('Individual_Salutation').get('Formal').put('AddresseeLine1','{#prefix#} {#first#} {#middle#} {#last#} {#suffix#}');
                individualSalMap.get('Individual_Salutation').put('Informal', new Map<String, String>());
                individualSalMap.get('Individual_Salutation').get('Informal').put('Inside','{#name#}');
                individualSalMap.get('Individual_Salutation').get('Informal').put('AddresseeLine1','{#prefix#} {#first#} {#middle#} {#last#} {#suffix#}');
                salMap.putAll(individualSalMap);
                system.debug('@@ salMap -->'+salMap);
                
                // Joint Salutation mapping
                if (con_spouse.Id != null) {
                    jointSalMap.put('Joint_Salutation', new Map<String, Map<String, String>>());
                    jointSalMap.put('Joint_Salutation', new Map<String, Map<String, String>>());
                    jointSalMap.get('Joint_Salutation').put('Formal', new Map<String, String>());
                  //  jointSalMap.get('Joint_Salutation').get('Formal').put('Inside','{#'+jointPrimaryPrefix+'_default_name_with_prefix#} and {#'+jointSecondaryPrefix+'_default_name_with_prefix#}');
                    jointSalMap.get('Joint_Salutation').get('Formal').put('Inside','{#'+jointPrimaryPrefix+'_first#} and {#'+jointSecondaryPrefix+'_first#}');
                    jointSalMap.get('Joint_Salutation').get('Formal').put('AddresseeLine1','{#'+jointPrimaryPrefix+'_prefix#} {#'+jointPrimaryPrefix+'_first#} {#'+jointPrimaryPrefix+'_middle#} {#'+jointPrimaryPrefix+'_last#} {#'+jointPrimaryPrefix+'_suffix#}');
                    jointSalMap.get('Joint_Salutation').get('Formal').put('AddresseeLine2','{#'+jointSecondaryPrefix+'_prefix#} {#'+jointSecondaryPrefix+'_first#} {#'+jointSecondaryPrefix+'_middle#} {#'+jointSecondaryPrefix+'_last#} {#'+jointSecondaryPrefix+'_suffix#}');
                    jointSalMap.get('Joint_Salutation').put('Informal', new Map<String, String>());
                    jointSalMap.get('Joint_Salutation').get('Informal').put('Inside','{#'+jointPrimaryPrefix+'_name#} and {#'+jointSecondaryPrefix+'_name#}');
                    jointSalMap.get('Joint_Salutation').get('Informal').put('AddresseeLine1','{#'+jointPrimaryPrefix+'_prefix#} {#'+jointPrimaryPrefix+'_first#} {#'+jointPrimaryPrefix+'_middle#} {#'+jointPrimaryPrefix+'_last#} {#'+jointPrimaryPrefix+'_suffix#}');
                    jointSalMap.get('Joint_Salutation').get('Informal').put('AddresseeLine2','{#'+jointSecondaryPrefix+'_prefix#} {#'+jointSecondaryPrefix+'_first#} {#'+jointSecondaryPrefix+'_middle#} {#'+jointSecondaryPrefix+'_last#} {#'+jointSecondaryPrefix+'_suffix#}');
                    salMap.putAll(jointSalMap);
                } else {
                    // Collect joint salutations to delete
                    Set<Id> conSet = new Set<Id>();
                    conSet.add(con.Id);
                    conSet.add(con_spouse.Id);
                    
                    for (Id myId : conSet) {
                        if (contactTypeSalutationMap.containsKey(myId)) {
                            if (contactTypeSalutationMap.get(myId).containsKey('Joint_Salutation')) {
                                for (String t : contactTypeSalutationMap.get(myId).get('Joint_Salutation').keySet()) {
                                    ucinn_ascendv2__Salutation__c sal = contactTypeSalutationMap.get(myId).get('Joint_Salutation').get(t);
                                    
                                    System.debug('#### sal to delete: '+sal);
                                    System.debug('#### sal to delete Custom_Salutation__c: '+sal.Custom_Salutation__c);
                                    
                                    if (!sal.Custom_Salutation__c) { // Don't delete if true. Per testing, joint salutations are still deleted when they are no longer spouse
                                        deleteSalutationMap.put(sal.Id, sal);
                                    }
                                }
                            }
                        }
                    }
                }
                
                system.debug('@@ salMap --> '+salMap);
                
                // Parse name parts
                for (String rtName : salMap.keySet()) {
                    RecordType rt = rtMap.get(rtName);
                    Boolean isInsert = true;
                    
                    for (String typeName : salMap.get(rtName).keySet()) {
                        String salutationName = '';
                        String addresseeline1 = '';
                        String addresseeline2 = '';
                        
                        for (String salfield : salMap.get(rtName).get(typeName).keySet()) {
                            String name = salMap.get(rtName).get(typeName).get(salfield)+'';
                            
                            for (String s : namePartMap.keySet()) {
                                system.debug('@@ s -->'+s);
                                name = name.replace('{#' + s + '#}', namePartMap.get(s));
                                system.debug('@@ name -->'+name);
                            }
                            
                            name = name.normalizeSpace();
                            system.debug('@@ name after  -->'+name);
                            if (salfield == 'Inside') {
                                salutationName = name;
                            } else if (salfield == 'AddresseeLine1') {
                                addresseeline1 = name;
                            } else if (salfield == 'AddresseeLine2') {
                                addresseeline2 = name;
                            }
                        }
                        
                        salutationName = salutationName.normalizeSpace();
                        
                        ucinn_ascendv2__Salutation__c sal = new ucinn_ascendv2__Salutation__c();
                        sal.RecordTypeId = rt.Id;
                        sal.ucinn_ascendv2__Salutation_Type__c = typeName;
                        sal.ucinn_ascendv2__Account__c = accountId;
                        sal.ucinn_ascendv2__Contact__c = conId;
                        
                        if (contactTypeSalutationMap.containsKey(conId)) {
                            if (contactTypeSalutationMap.get(conId).containsKey(rtName)) {
                                if (contactTypeSalutationMap.get(conId).get(rtName).containsKey(typeName)) {
                                    sal = contactTypeSalutationMap.get(conId).get(rtName).get(typeName);
                                    isInsert = false;
                                }
                            }
                        }
                        
                        if (rtName == 'Joint_Salutation' && contactData.containsKey(conId) && contactData.get(conId).containsKey('contact_spouse')) {
                            sal.ucinn_ascendv2__Contact_2__c = ((Contact)contactData.get(conId).get('contact_spouse')).Id;
                            
                            // Don't add the reciprocal joint salutation. Ascend logic will create it.
                            if (isInsert && insertedSalContactSet.contains(sal.ucinn_ascendv2__Contact_2__c)) {
                                continue;
                            }
                        }
                        
                        sal.ucinn_ascendv2__Inside_Salutation__c = salutationName;
                        sal.ucinn_ascendv2__Addressee_Line_1__c = addresseeline1;
                        sal.ucinn_ascendv2__Addressee_Line_2__c = addresseeline2;
                        sal.ucinn_ascendv2__Salutation_Author__c = 'Custom';
                        sal.Status__c = 'Active';
                        
                        if (!sal.Custom_Salutation__c) { // Don't update if true
                            upsertSalutationList.add(sal);
                            
                            // Collect inserted joint salutation contact
                            if (isInsert && rtName == 'Joint_Salutation') {
                                insertedSalContactSet.add(sal.ucinn_ascendv2__Contact__c);
                            }
                        }
                    }
                } 
            }
            
            // Upsert salutations
            if (!upsertSalutationList.isEmpty()) {
                upsert upsertSalutationList;
                
                // Set constituent 2
                //for (ucinn_ascendv2__Salutation__c sal : upsertSalutationList) {
                //    if (!rtMap.containsKey('Joint_Salutation')) {
                //        continue;
                //    }
                //    
                //    if (sal.ucinn_ascendv2__Salutation_Author__c == 'Custom' && sal.RecordTypeId == rtMap.get('Joint_Salutation').Id
                //            && contactData.containsKey(sal.ucinn_ascendv2__Contact__c) && contactData.get(sal.ucinn_ascendv2__Contact__c).containsKey('contact_spouse')) {
                //        Contact con_spouse = (Contact)contactData.get(sal.ucinn_ascendv2__Contact__c).get('contact_spouse');
                //        sal.ucinn_ascendv2__Contact_2__c = con_spouse.Id;
                //    }
                //}
                
                //ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Salutation__c', false);
                //update upsertSalutationList;
                //ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Salutation__c', true);
            }
            
            System.debug('#### deleteSalutationMap: '+deleteSalutationMap);
            
            // Delete salutations
            if (!deleteSalutationMap.isEmpty()) {
                ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Salutation__c', false);
                delete deleteSalutationMap.values();
                ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Salutation__c', true);
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to get the name parts
     * @param con Contact record
     * @param cn Constituent Name record
     * @return Map of name parts
     */
    private Static Map<String, String> getNameParts(Contact con, ucinn_ascendv2__Contact_Name__c cn, String namePartPrefix) {
        Map<String, String> namePartMap = new Map<String, String>();
        String first = (cn != null && String.isNotBlank(cn.ucinn_ascendv2__First_Name__c)) ? cn.ucinn_ascendv2__First_Name__c : '';
        String last = (cn != null && String.isNotBlank(cn.ucinn_ascendv2__Last_Name__c)) ? cn.ucinn_ascendv2__Last_Name__c : '';
        String prefix = (cn != null && String.isNotBlank(cn.ucinn_ascendv2__Prefix__c)) ? cn.ucinn_ascendv2__Prefix__c : '';
        String nick = (cn != null && String.isNotBlank(cn.ucinn_ascendv2__Nickname__c)) ? cn.ucinn_ascendv2__Nickname__c : '';
        String name = first;
        String name_with_prefix = prefix + ' ' + first;
        String middle = (cn != null && String.isNotBlank(cn.ucinn_ascendv2__Middle_Name__c)) ? cn.ucinn_ascendv2__Middle_Name__c : '';
        String suffix = (cn != null && String.isNotBlank(cn.ucinn_ascendv2__Suffix__c)) ? cn.ucinn_ascendv2__Suffix__c : '';

        // Case 00001647, 7/21/21 
        //if name_with_prefix gets overwritten need default for formal salutations
        String default_name_with_prefix = name_with_prefix;
        
        if (nick != '') {
            name = nick;
            name_with_prefix = nick;
        }
        
        namePartMap.put(namePartPrefix + 'first', first);
        namePartMap.put(namePartPrefix + 'last', last);
        namePartMap.put(namePartPrefix + 'name', name);
        namePartMap.put(namePartPrefix + 'name_with_prefix', name_with_prefix);
        namePartMap.put(namePartPrefix + 'default_name_with_prefix', default_name_with_prefix);
        namePartMap.put(namePartPrefix + 'prefix',prefix);
        namePartMap.put(namePartPrefix + 'middle',middle);
        namePartMap.put(namePartPrefix + 'suffix',suffix);
                
        return namePartMap;
    }
    
}