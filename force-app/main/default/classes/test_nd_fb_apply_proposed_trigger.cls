@isTest(SeeAllData=false)
public class test_nd_fb_apply_proposed_trigger
{
    @TestSetup
    public static void testSetup() {
        Account a = new Account(name='Gerry Household');
        insert new List<Account>{a};

        Contact c = new Contact(accountid = a.Id, ucinn_ascendv2__Donor_ID__c='129419', ucinn_ascendv2__External_System_ID__c='hb', firstname = 'Bobbert', lastname = 'Gerry', ucinn_ascendv2__Personal_Email__c='bgerry@nowhere.edu', Constituent_Status__c='A');
        insert new List<Contact>{c};

            
        ucinn_ascendv2__Trigger_Handler__c h = new ucinn_ascendv2__Trigger_Handler__c( name ='apy - Lottery Apply Proposed App',
                                                                                       ucinn_ascendv2__Class__c = 'nd_fb_apply_proposed_trigger_handler',
                                                                                       ucinn_ascendv2__Object__c = 'Lottery_Application__c',
                                                                                       ucinn_ascendv2__Is_Active__c = true,
                                                                                       ucinn_ascendv2__Load_Order__c = 100,
                                                                                       ucinn_ascendv2__Is_User_Managed__c = true,
                                                                                       ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate'
                                                                                     );
        insert new List<ucinn_ascendv2__Trigger_Handler__c>{h};
    }

    static void print_before_after( Lottery_Application__c app_before,  Lottery_Application__c app_after )
    {
        System.debug('****************************************************************');
        System.debug('***************   ' + 'app_before.sfl_load_group_id__c'                         + ': ' + app_before.sfl_load_group_id__c);
        System.debug('****************************************************************');
        System.debug('***************   ' + 'app_before.Apply_Proposed_Lottery_Application__c'        + ': ' + app_before.Apply_Proposed_Lottery_Application__c);
        System.debug('***************   ' + 'app_before.proposed_Lottery_Application_Level__c'        + ': ' + app_before.Proposed_Lottery_Application_Level__c);
        System.debug('***************   ' + 'app_before.Lottery_Application_Level__c'                 + ': ' + app_before.Lottery_Application_Level__c);
        System.debug('***************   ' + 'app_before.Earned_Application_Audit__c'                  + ': ' + app_before.Earned_Application_Audit__c);
        System.debug('***************   ' + 'app_before.Proposed_Earned_Application_Audit__c'         + ': ' + app_before.Proposed_Earned_Application_Audit__c);
        System.debug('***************   ' + 'app_before.Replaced_Lottery_Application_Level__c'        + ': ' + app_before.Replaced_Lottery_Application_Level__c);
        System.debug('***************   ' + 'app_before.Replaced_Lottery_Application_Level_Audit__c'  + ': ' + app_before.Replaced_Lottery_Application_Level_Audit__c);
        System.debug('***************   ' + 'app_before.locked_for_automated_updates__c'  + ': '      + app_before.locked_for_automated_updates__c);
        System.debug('****************************************************************');
        System.debug('***************   ' + 'app_after.Apply_Proposed_Lottery_Application__c'         + ': ' + app_after.Apply_Proposed_Lottery_Application__c);
        System.debug('***************   ' + 'app_after.proposed_Lottery_Application_Level__c'         + ': ' + app_after.Proposed_Lottery_Application_Level__c);
        System.debug('***************   ' + 'app_after.Lottery_Application_Level__c'                  + ': ' + app_after.Lottery_Application_Level__c);
        System.debug('***************   ' + 'app_after.Earned_Application_Audit__c'                   + ': ' + app_after.Earned_Application_Audit__c);
        System.debug('***************   ' + 'app_after.Proposed_Earned_Application_Audit__c'          + ': ' + app_after.Proposed_Earned_Application_Audit__c);
        System.debug('***************   ' + 'app_after.Replaced_Lottery_Application_Level__c'         + ': ' + app_after.Replaced_Lottery_Application_Level__c);
        System.debug('***************   ' + 'app_after.Replaced_Lottery_Application_Level_Audit__c'   + ': ' + app_after.Replaced_Lottery_Application_Level_Audit__c);
        System.debug('***************   ' + 'app_after.locked_for_automated_updates__c'               + ': ' + app_after.locked_for_automated_updates__c);
        System.debug('****************************************************************');
    }

    static Lottery_Application__c get_app_by_id( ID lot_app_id )
    {
        return [SELECT id,
                       sfl_load_group_id__c,
                       Proposed_Lottery_Application_Level__c,
                       Lottery_Application_Level__c,
                       Apply_Proposed_Lottery_Application__c,
                       Earned_Application_Audit__c,
                       Proposed_Earned_Application_Audit__c,
                       Replaced_Lottery_Application_Level__c,
                       Replaced_Lottery_Application_Level_Audit__c,
                       locked_for_automated_updates__c
                  FROM Lottery_Application__c
                 WHERE Id = :lot_app_id
               ];
    }

	@isTest
    static void test_create_and_update()
    {

        ///////////////////////////////////////
        // test 1 - insert, apply proposed is false, no change in app
        ///////////////////////////////////////
        Lottery_Application__c app = new Lottery_Application__c();
        app.sfl_load_group_id__c = 'test 1 - insert, apply proposed is false, no change in app';
        app.year__c = '1999';
        app.Proposed_Lottery_Application_Level__c = 'GR';
        app.Lottery_Application_Level__c = 'GR';
        app.Apply_Proposed_Lottery_Application__c = false;
        app.locked_for_automated_updates__c = false;        

        app.Earned_Application_Audit__c = 'earned audit';
        app.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app.Replaced_Lottery_Application_Level__c = 'X';
        app.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app};

        Lottery_Application__c new_app = get_app_by_id( app.Id );

        print_before_after(app, new_app);

        System.assertEquals('earned audit',   new_app.Earned_Application_Audit__c,                 'should not be changed, section: ' + app.sfl_load_group_id__c );
        System.assertEquals('replaced audit', new_app.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app.sfl_load_group_id__c );
        System.assertEquals('X',              new_app.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app.sfl_load_group_id__c );
        System.assertEquals(false,            new_app.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 2 - insert, apply proposed is false, yes change in app
        ///////////////////////////////////////
        Lottery_Application__c app2 = new Lottery_Application__c();
        app2.sfl_load_group_id__c = 'test 2 - insert, apply proposed is false, yes change in app';
        app2.year__c = '1999';
        app2.Proposed_Lottery_Application_Level__c = 'GR';
        app2.Lottery_Application_Level__c = 'GO';
        app2.Apply_Proposed_Lottery_Application__c = false;
        app2.locked_for_automated_updates__c = false;        

        app2.Earned_Application_Audit__c = 'earned audit';
        app2.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app2.Replaced_Lottery_Application_Level__c = 'X';
        app2.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app2};

        Lottery_Application__c new_app2 = get_app_by_id( app2.Id );

        print_before_after(app2, new_app2);

        System.assertEquals('earned audit',   new_app2.Earned_Application_Audit__c,                 'should not be changed, section: ' + app2.sfl_load_group_id__c );
        System.assertEquals('replaced audit', new_app2.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app2.sfl_load_group_id__c );
        System.assertEquals('X',              new_app2.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app2.sfl_load_group_id__c );
        System.assertEquals(false,            new_app2.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app2.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 3 - insert, apply proposed is true, no change in app
        ///////////////////////////////////////
        Lottery_Application__c app3 = new Lottery_Application__c();
        app3.sfl_load_group_id__c = 'test 3 - insert, apply proposed is true, no change in app';
        app3.year__c = '1999';
        app3.Proposed_Lottery_Application_Level__c = 'GR';
        app3.Lottery_Application_Level__c = 'GR';
        app3.Apply_Proposed_Lottery_Application__c = true;
        app3.locked_for_automated_updates__c = false;        

        app3.Earned_Application_Audit__c = 'earned audit';
        app3.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app3.Replaced_Lottery_Application_Level__c = 'X';
        app3.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app3};

        Lottery_Application__c new_app3 = get_app_by_id( app3.Id );

        print_before_after(app3, new_app3);

        System.assertEquals('earned audit',   new_app3.Earned_Application_Audit__c,                 'should not be changed, section: ' + app3.sfl_load_group_id__c );
        System.assertEquals('replaced audit', new_app3.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app3.sfl_load_group_id__c );
        System.assertEquals('X',              new_app3.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app3.sfl_load_group_id__c );
        System.assertEquals(false,            new_app3.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app3.sfl_load_group_id__c );
        
        ///////////////////////////////////////
        // test 4 - insert, apply proposed is true, yes change in app
        ///////////////////////////////////////

        Lottery_Application__c app4 = new Lottery_Application__c();
        app4.sfl_load_group_id__c = 'test 4 - insert, apply proposed is true, yes change in app';
        app4.year__c = '1999';
        app4.Proposed_Lottery_Application_Level__c = 'GR';
        app4.Lottery_Application_Level__c = 'GO';
        app4.Apply_Proposed_Lottery_Application__c = true;
        app4.locked_for_automated_updates__c = false;        

        app4.Earned_Application_Audit__c = 'earned audit';
        app4.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app4.Replaced_Lottery_Application_Level__c = 'X';
        app4.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app4};

        Lottery_Application__c new_app4 = get_app_by_id( app4.Id );

        print_before_after(app4, new_app4);

        System.assertEquals('proposed audit', new_app4.Earned_Application_Audit__c,                 'should not be changed, section: ' + app4.sfl_load_group_id__c );
        System.assertEquals('earned audit',   new_app4.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app4.sfl_load_group_id__c );
        System.assertEquals('GO',             new_app4.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app4.sfl_load_group_id__c );
        System.assertEquals(false,            new_app4.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app4.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 5 - update, apply proposed is false, no change in app
        ///////////////////////////////////////

        Lottery_Application__c app5 = new Lottery_Application__c();
        app5.sfl_load_group_id__c = 'test 5 - update, apply proposed is false, no change in app';
        
        // first insert an app to later update, this won't match the parameters yet
        app5.year__c = '1999';
        app5.Proposed_Lottery_Application_Level__c = 'GR';
        app5.Lottery_Application_Level__c = 'GR';
        app5.Apply_Proposed_Lottery_Application__c = false;
        app5.locked_for_automated_updates__c = false;        

        app5.Earned_Application_Audit__c = 'earned audit';
        app5.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app5.Replaced_Lottery_Application_Level__c = 'X';
        app5.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app5};

        Lottery_Application__c new_app5 = get_app_by_id( app5.Id );

        // now set our test parameters
        new_app5.Apply_Proposed_Lottery_Application__c = false;        
        new_app5.Proposed_Lottery_Application_Level__c = 'GR';

        update new List<Lottery_Application__c>{new_app5};

        Lottery_Application__c updated_app5 = get_app_by_id( app5.Id );
 
        print_before_after(new_app5, updated_app5);

        System.assertEquals('earned audit',   updated_app5.Earned_Application_Audit__c,                 'should not be changed, section: ' + app5.sfl_load_group_id__c );
        System.assertEquals('replaced audit', updated_app5.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app5.sfl_load_group_id__c );
        System.assertEquals('X',              updated_app5.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app5.sfl_load_group_id__c );
        System.assertEquals(false,            updated_app5.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app5.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 6 - update, apply proposed is false, yes change in app
        ///////////////////////////////////////

        Lottery_Application__c app6 = new Lottery_Application__c();
        app6.sfl_load_group_id__c = 'test 6 - update, apply proposed is false, yes change in app';
        
        // first insert an app to later update, this won't match the parameters yet
        app6.year__c = '1999';
        app6.Proposed_Lottery_Application_Level__c = 'GR';
        app6.Lottery_Application_Level__c = 'GR';
        app6.Apply_Proposed_Lottery_Application__c = false;
        app6.locked_for_automated_updates__c = false;        

        app6.Earned_Application_Audit__c = 'earned audit';
        app6.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app6.Replaced_Lottery_Application_Level__c = 'X';
        app6.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app6};

        Lottery_Application__c new_app6 = get_app_by_id( app6.Id );

        // now set our test parameters
        new_app6.Apply_Proposed_Lottery_Application__c = false;
        new_app6.Proposed_Earned_Application_Audit__c = 'updated proposed audit';
        new_app6.Proposed_Lottery_Application_Level__c = 'GO';

        update new List<Lottery_Application__c>{new_app6};

        Lottery_Application__c updated_app6 = get_app_by_id( app6.Id );

        print_before_after(new_app6, updated_app6);

        System.assertEquals('GO',                      updated_app6.Proposed_Lottery_Application_Level__c,       'should not be changed, section: ' + app6.sfl_load_group_id__c );
        System.assertEquals('updated proposed audit',  updated_app6.Proposed_Earned_Application_Audit__c,        'should not be changed, section: ' + app6.sfl_load_group_id__c );
        System.assertEquals('GR',                      updated_app6.Lottery_Application_Level__c,                'should not be changed, section: ' + app6.sfl_load_group_id__c );
        System.assertEquals('earned audit',            updated_app6.Earned_Application_Audit__c,                 'should not be changed, section: ' + app6.sfl_load_group_id__c );
        System.assertEquals('replaced audit',          updated_app6.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app6.sfl_load_group_id__c );
        System.assertEquals('X',                       updated_app6.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app6.sfl_load_group_id__c );
        System.assertEquals(false,                     updated_app6.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app6.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 7 - update, apply proposed is true, no change in app
        ///////////////////////////////////////

        Lottery_Application__c app7 = new Lottery_Application__c();
        app7.sfl_load_group_id__c = 'test 7 - update, apply proposed is true, no change in app';
        
        // first insert an app to later update, this won't match the parameters yet
        app7.year__c = '1999';
        app7.Proposed_Lottery_Application_Level__c = 'GR';
        app7.Lottery_Application_Level__c = 'GR';
        app7.Apply_Proposed_Lottery_Application__c = false;
        app7.locked_for_automated_updates__c = false;        

        app7.Earned_Application_Audit__c = 'earned audit';
        app7.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app7.Replaced_Lottery_Application_Level__c = 'X';
        app7.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app7};

        Lottery_Application__c new_app7 = get_app_by_id( app7.Id );

        // now set our test parameters
        new_app7.Apply_Proposed_Lottery_Application__c = true;
        new_app7.Proposed_Earned_Application_Audit__c = 'updated proposed audit';
        new_app7.Proposed_Lottery_Application_Level__c = 'GR';

        update new List<Lottery_Application__c>{new_app7};

        Lottery_Application__c updated_app7 = get_app_by_id( app7.Id );
 
        print_before_after(new_app7, updated_app7);

        System.assertEquals('GR',                      updated_app7.Proposed_Lottery_Application_Level__c,       'should not be changed, section: ' + app7.sfl_load_group_id__c );
        System.assertEquals('updated proposed audit',  updated_app7.Proposed_Earned_Application_Audit__c,        'should not be changed, section: ' + app7.sfl_load_group_id__c );
        System.assertEquals('GR',                      updated_app7.Lottery_Application_Level__c,                'should not be changed, section: ' + app7.sfl_load_group_id__c );
        System.assertEquals('earned audit',            updated_app7.Earned_Application_Audit__c,                 'should not be changed, section: ' + app7.sfl_load_group_id__c );
        System.assertEquals('replaced audit',          updated_app7.Replaced_Lottery_Application_Level_Audit__c, 'should not be changed, section: ' + app7.sfl_load_group_id__c );
        System.assertEquals('X',                       updated_app7.Replaced_Lottery_Application_Level__c,       'should not be changed, section: ' + app7.sfl_load_group_id__c );
        System.assertEquals(false,                     updated_app7.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app7.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 8 - update, apply proposed is true, yes change in app
        ///////////////////////////////////////

        Lottery_Application__c app8 = new Lottery_Application__c();
        app8.sfl_load_group_id__c = 'test 8 - update, apply proposed is true, yes change in app';
        
        // first insert an app to later update, this won't match the parameters yet
        app8.year__c = '1999';
        app8.Proposed_Lottery_Application_Level__c = 'GR';
        app8.Lottery_Application_Level__c = 'GR';
        app8.Apply_Proposed_Lottery_Application__c = false;
        app8.locked_for_automated_updates__c = false;        

        app8.Earned_Application_Audit__c = 'earned audit';
        app8.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app8.Replaced_Lottery_Application_Level__c = 'X';
        app8.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app8};

        Lottery_Application__c new_app8 = get_app_by_id( app8.Id );

        // now set our test parameters
        new_app8.Apply_Proposed_Lottery_Application__c = true;
        new_app8.Proposed_Earned_Application_Audit__c = 'updated proposed audit';
        new_app8.Proposed_Lottery_Application_Level__c = 'GO';

        update new List<Lottery_Application__c>{new_app8};

        Lottery_Application__c updated_app8 = get_app_by_id( app8.Id );
 
        print_before_after(new_app8, updated_app8);

        System.assertEquals('GO',                      updated_app8.Proposed_Lottery_Application_Level__c,       'should not be changed, section: ' + app8.sfl_load_group_id__c );
        System.assertEquals('updated proposed audit',  updated_app8.Proposed_Earned_Application_Audit__c,        'should not be changed, section: ' + app8.sfl_load_group_id__c );
        System.assertEquals('GO',                      updated_app8.Lottery_Application_Level__c,                'should be changed, section: ' + app8.sfl_load_group_id__c );
        System.assertEquals('updated proposed audit',  updated_app8.Earned_Application_Audit__c,                 'should be changed, section: ' + app8.sfl_load_group_id__c );
        System.assertEquals('earned audit',            updated_app8.Replaced_Lottery_Application_Level_Audit__c, 'should be changed, section: ' + app8.sfl_load_group_id__c );
        System.assertEquals('GR',                      updated_app8.Replaced_Lottery_Application_Level__c,       'should be changed, section: ' + app8.sfl_load_group_id__c );
        System.assertEquals(false,                     updated_app8.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app8.sfl_load_group_id__c );

        ///////////////////////////////////////
        // test 9 - update, apply proposed is true, yes change in app, locked
        ///////////////////////////////////////

        Lottery_Application__c app9 = new Lottery_Application__c();
        app9.sfl_load_group_id__c = 'test 9 - update, apply proposed is true, yes change in app, locked';
        
        // first insert an app to later update, this won't match the parameters yet
        app9.year__c = '1999';
        app9.Proposed_Lottery_Application_Level__c = 'GR';
        app9.Lottery_Application_Level__c = 'GR';
        app9.Apply_Proposed_Lottery_Application__c = false;
        app9.locked_for_automated_updates__c = true;        

        app9.Earned_Application_Audit__c = 'earned audit';
        app9.Proposed_Earned_Application_Audit__c = 'proposed audit';
        app9.Replaced_Lottery_Application_Level__c = 'X';
        app9.Replaced_Lottery_Application_Level_Audit__c = 'replaced audit';

        insert new List<Lottery_Application__c>{app9};

        Lottery_Application__c new_app9 = get_app_by_id( app9.Id );

        // now set our test parameters
        new_app9.Apply_Proposed_Lottery_Application__c = true;
        new_app9.Proposed_Earned_Application_Audit__c = 'updated proposed audit';
        new_app9.Proposed_Lottery_Application_Level__c = 'GO';

        update new List<Lottery_Application__c>{new_app9};

        Lottery_Application__c updated_app9 = get_app_by_id( app9.Id );
 
        print_before_after(new_app9, updated_app9);

        System.assertEquals('GO',                      updated_app9.Proposed_Lottery_Application_Level__c,       'should not be changed, section: '  + app9.sfl_load_group_id__c );
        System.assertEquals('updated proposed audit',  updated_app9.Proposed_Earned_Application_Audit__c,        'should not be changed, section: '  + app9.sfl_load_group_id__c );
        System.assertEquals('GR',                      updated_app9.Lottery_Application_Level__c,                'should be changed, section: '      + app9.sfl_load_group_id__c );
        System.assertEquals('earned audit',            updated_app9.Earned_Application_Audit__c,                 'should be changed, section: '      + app9.sfl_load_group_id__c );
        System.assertEquals('replaced audit',          updated_app9.Replaced_Lottery_Application_Level_Audit__c, 'should be changed, section: '      + app9.sfl_load_group_id__c );
        System.assertEquals('X',                       updated_app9.Replaced_Lottery_Application_Level__c,       'should be changed, section: '      + app9.sfl_load_group_id__c );
        System.assertEquals(false,                     updated_app9.Apply_Proposed_Lottery_Application__c,       'should always be false, section: ' + app9.sfl_load_group_id__c );

        System.debug('****************************************************************');
        System.debug('****************************************************************');
        System.debug('**********      all tests done                       ***********');
        System.debug('****************************************************************');
        System.debug('****************************************************************');

    }
}