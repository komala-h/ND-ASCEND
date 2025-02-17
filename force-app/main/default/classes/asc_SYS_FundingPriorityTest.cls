@IsTest
global class asc_SYS_FundingPriorityTest {

    @IsTest
    global static void testInsert() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Custom Work Plan Unit Handler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_WorkPlanUnitHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler;
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        String SObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        Integer sortOrder = 0;
        
        List<Campaign> newCampaigns = new List<Campaign> {
            new Campaign(
            	Name = 'New Campaign 01',
            	RecordTypeId = utils.levelToRecordType.get(0)
            ),
            new Campaign(
            	Name = 'New Campaign 02',
            	RecordTypeId = utils.levelToRecordType.get(0)
            )
        };
        insert newCampaigns;
        
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L1s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
				Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            )
        };
            
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, false);
        insert L1s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L2s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            )
        };
        insert L2s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L3s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[2].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[4].Id
            )
        };
        insert L3s;
        

        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, true);

        test.startTest();
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L4s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[2].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[4].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[5].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            )
        };
        insert L4s;
        
        test.stopTest();
        
        List<Campaign> myCampaigns = [SELECT Id, Goal__c FROM Campaign ORDER BY Name];
        for (Campaign cmp : myCampaigns) {
            System.debug(cmp);
        }
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> myWorkPlanUnits = [SELECT Id, Goal__c, Name FROM ucinn_ascendv2__Work_Plan_Unit__c ORDER BY Name];
        for (ucinn_ascendv2__Work_Plan_Unit__c fp : myWorkPlanUnits) {
            System.debug(fp);
        }
        
    }

    @IsTest
    global static void testButton02() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Custom Work Plan Unit Handler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_WorkPlanUnitHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler;
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        String SObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        Integer sortOrder = 0;
        
        List<Campaign> newCampaigns = new List<Campaign> {
            new Campaign(
            	Name = 'New Campaign 01',
            	RecordTypeId = utils.levelToRecordType.get(0)
            ),
            new Campaign(
            	Name = 'New Campaign 02',
            	RecordTypeId = utils.levelToRecordType.get(0)
            )
        };
        insert newCampaigns;
        
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L1s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
				Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            )
        };
            
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, false);
        insert L1s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L2s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            )
        };
        insert L2s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L3s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[2].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[4].Id
            )
        };
        insert L3s;
        


        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L4s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[2].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[4].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[5].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            )
        };
        insert L4s;
        
        test.startTest();
        asc_UTIL_FundingPrioritiesUtils.recalculateFundingPriorityButtonInitiate(new List<String> {L1s[1].Id});
        test.stopTest(); 
        
        List<Campaign> myCampaigns = [SELECT Id, Goal__c FROM Campaign ORDER BY Name];
        for (Campaign cmp : myCampaigns) {
            System.debug(cmp);
        }
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> myWorkPlanUnits = [SELECT Id, Goal__c, Name FROM ucinn_ascendv2__Work_Plan_Unit__c ORDER BY Name];
        for (ucinn_ascendv2__Work_Plan_Unit__c fp : myWorkPlanUnits) {
            System.debug(fp);
        }
    }
    
    @IsTest
    global static void testButton() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Custom Work Plan Unit Handler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_WorkPlanUnitHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler;
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        String SObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        Integer sortOrder = 0;
        
        List<Campaign> newCampaigns = new List<Campaign> {
            new Campaign(
            	Name = 'New Campaign 01',
            	RecordTypeId = utils.levelToRecordType.get(0)
            ),
            new Campaign(
            	Name = 'New Campaign 02',
            	RecordTypeId = utils.levelToRecordType.get(0)
            )
        };
        insert newCampaigns;
        
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L1s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
				Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            )
        };
            
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, false);
        insert L1s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L2s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            )
        };
        insert L2s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L3s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[2].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[4].Id
            )
        };
        insert L3s;
        


        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L4s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[2].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[4].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[5].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            )
        };
        insert L4s;
        
        test.startTest();
        asc_UTIL_FundingPrioritiesUtils.recalculateFundingPriorityButtonInitiate(new List<String> {newCampaigns[0].Id});
        test.stopTest();
        
        List<Campaign> myCampaigns = [SELECT Id, Goal__c FROM Campaign ORDER BY Name];
        for (Campaign cmp : myCampaigns) {
            System.debug(cmp);
        }
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> myWorkPlanUnits = [SELECT Id, Goal__c, Name FROM ucinn_ascendv2__Work_Plan_Unit__c ORDER BY Name];
        for (ucinn_ascendv2__Work_Plan_Unit__c fp : myWorkPlanUnits) {
            System.debug(fp);
        }
    }
    
    
    
    @IsTest
    global static void testBatch() {        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        String SObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        Integer sortOrder = 0;
        
        List<Campaign> newCampaigns = new List<Campaign> {
            new Campaign(
            	Name = 'New Campaign 01',
            	RecordTypeId = utils.levelToRecordType.get(0)
            ),
            new Campaign(
            	Name = 'New Campaign 02',
            	RecordTypeId = utils.levelToRecordType.get(0)
            )
        };
        insert newCampaigns;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L1s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
				Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id
            )
        };
            
        insert L1s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L2s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id
            )
        };
        insert L2s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L3s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[0].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[2].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[4].Id
            )
        };
        insert L3s;
        


        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L4s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[2].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[4].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[5].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            )
        };
        insert L4s;
        test.startTest();
		Database.executeBatch(new asc_BATCH_RecalculateFundingPriority(20), 20);
        test.stopTest();
        
        List<Campaign> myCampaigns = [SELECT Id, Goal__c FROM Campaign ORDER BY Name];
        for (Campaign cmp : myCampaigns) {
            System.debug(cmp);
        }
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> myWorkPlanUnits = [SELECT Id, Goal__c, Name FROM ucinn_ascendv2__Work_Plan_Unit__c ORDER BY Name];
        for (ucinn_ascendv2__Work_Plan_Unit__c fp : myWorkPlanUnits) {
            System.debug(fp);
        }
        
    }
    
    @IsTest
    global static void testUpdate() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Custom Work Plan Unit Handler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_WorkPlanUnitHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler;
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        String SObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        Integer sortOrder = 0;
        
        List<Campaign> newCampaigns = new List<Campaign> {
            new Campaign(
            	Name = 'New Campaign 01',
            	RecordTypeId = utils.levelToRecordType.get(0),
                Goal__c = 400
            ),
            new Campaign(
            	Name = 'New Campaign 02',
            	RecordTypeId = utils.levelToRecordType.get(0),
                Goal__c = 700
            )
        };
        insert newCampaigns;
        
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L1s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
				Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[0].Id,
                Goal__c = 400
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id,
                Goal__c = 500
            )
        };
            
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, false);
        insert L1s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L2s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id,
                Goal__c = 300
            )
        };
        insert L2s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L3s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[0].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id,
                Goal__c = 100
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[2].Id,
                Goal__c = 200
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id,
                Goal__c = 100
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id,
                Goal__c = 100
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[4].Id,
                Goal__c = 300
            )
        };
        insert L3s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L4s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[2].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[4].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[5].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            )
        };
        insert L4s;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, true);

        test.startTest();
        
        update new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	Id = L4s[2].Id,
                Goal__c = 700
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	Id = L2s[3].Id,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id
            )
        };
            
        test.stopTest();
        
        List<Campaign> myCampaigns = [SELECT Id, Goal__c FROM Campaign ORDER BY Name];
        for (Campaign cmp : myCampaigns) {
            System.debug(cmp);
        }
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> myWorkPlanUnits = [SELECT Id, Goal__c, Name FROM ucinn_ascendv2__Work_Plan_Unit__c ORDER BY Name];
        for (ucinn_ascendv2__Work_Plan_Unit__c fp : myWorkPlanUnits) {
            System.debug(fp);
        }
        
    }
    
    @IsTest
    global static void testDelete() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Custom Work Plan Unit Handler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_WorkPlanUnitHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler;
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        String SObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
        Integer sortOrder = 0;
        
        List<Campaign> newCampaigns = new List<Campaign> {
            new Campaign(
            	Name = 'New Campaign 01',
            	RecordTypeId = utils.levelToRecordType.get(0),
                Goal__c = 400
            ),
            new Campaign(
            	Name = 'New Campaign 02',
            	RecordTypeId = utils.levelToRecordType.get(0),
                Goal__c = 700
            )
        };
        insert newCampaigns;
        
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L1s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
				Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[0].Id,
                Goal__c = 400
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(1),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L1 ' + sortOrder,
                Comprehensive_Campaign__c = newCampaigns[1].Id,
                Goal__c = 500
            )
        };
            
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, false);
        insert L1s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L2s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[0].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[1].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(2),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L2 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L1s[2].Id,
                Goal__c = 300
            )
        };
        insert L2s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L3s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[0].Id,
                Goal__c = 200
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[1].Id,
                Goal__c = 100
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[2].Id,
                Goal__c = 200
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id,
                Goal__c = 100
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[3].Id,
                Goal__c = 100
            ),            
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(3),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L3 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L2s[4].Id,
                Goal__c = 300
            )
        };
        insert L3s;
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> L4s = new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[0].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[1].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[2].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[3].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[4].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[5].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            ),
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	RecordTypeId = utils.levelToRecordType.get(4),
                Sort_Order__c = sortOrder++,
                Name = 'Funding Priority L4 ' + sortOrder,
                ucinn_ascendv2__Work_Plan_Unit__c = L3s[6].Id,
                Goal__c = 100
            )
        };
        insert L4s;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, true);

        test.startTest();
        
        delete new List<ucinn_ascendv2__Work_Plan_Unit__c> {
            new ucinn_ascendv2__Work_Plan_Unit__c(
            	Id = L2s[3].Id
            )
        };
            
        test.stopTest();
        
        List<Campaign> myCampaigns = [SELECT Id, Goal__c FROM Campaign ORDER BY Name];
        for (Campaign cmp : myCampaigns) {
            System.debug(cmp);
        }
        
        List<ucinn_ascendv2__Work_Plan_Unit__c> myWorkPlanUnits = [SELECT Id, Goal__c, Name FROM ucinn_ascendv2__Work_Plan_Unit__c ORDER BY Name];
        for (ucinn_ascendv2__Work_Plan_Unit__c fp : myWorkPlanUnits) {
            System.debug(fp);
        }
        
    }

}