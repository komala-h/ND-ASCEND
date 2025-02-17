import { LightningElement, wire, api, track } from 'lwc';
import getUsers from '@salesforce/apex/CampaignDetailController.getUsers';
import getCampaigns from '@salesforce/apex/CampaignDetailController.getCampaigns';
import getCampaignDetailSetting from '@salesforce/apex/CampaignDetailController.getCampaignDetailSetting';

export default class CampaignDetail extends LightningElement {
    @track userList = [];
    @track campaignList = [];
    @track relatedLists = [];
    @track relatedLists2 = [];
    userQuery;
    campaignQuery;
    relatedListConfig;
    selectedUserId = '';
    selectedCampaignId = '';
    displayLists = false;
    listcount = 0;

    connectedCallback() {
        this.loadSetting();
    }

    loadSetting() {
        getCampaignDetailSetting( { name: 'PRM' } )
        .then(result => {
            if (result) {
                this.userQuery = result.User_Selector_Query__c;
                this.campaignQuery = result.Campaign_Selector_Query__c;
                this.relatedListConfig = result.Related_List_Config__c;

                this.loadUsers();
                this.loadCampaigns();
            }
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });
    }

    loadUsers() {
        getUsers( { query: this.userQuery } )
        .then(result => {
            if (result) {
                for (let i = 0; i < result.length; i++) {
                    this.userList = [...this.userList, { label: result[i].Name, value: result[i].Id }];
                }

                const multiCombobox = this.template.querySelector('[data-id="mscSelectUser"]');
                multiCombobox.refreshOptions(this.userList);
            }
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });
        
    }

    loadCampaigns() {
        getCampaigns( { query: this.campaignQuery } )
        .then(result => {
            if (result) {
                for (let i = 0; i < result.length; i++) {
                    this.campaignList = [...this.campaignList, { label: result[i].Name, value: result[i].Id }];
                }

                const multiCombobox = this.template.querySelector('[data-id="mscSelectCampaign"]');
                multiCombobox.refreshOptions(this.campaignList);
            }
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });
    }

    loadRelatedLists() {
        this.displayLists = false;

        if (this.selectedUserId != '' && this.selectedCampaignId != '') {
            let configs = JSON.parse(this.relatedListConfig);

            this.relatedLists = [];
            this.relatedLists2 = [];

            for (let i = 0; i < configs.length; i++) {
                this.listcount++;
                if (configs[i].LayoutColumnOrder == 2) {
                    this.relatedLists2 = [...this.relatedLists2, { key : 'campaignDetailRelatedList'+this.listcount, params : JSON.stringify(configs[i]) }];
                } else {
                    this.relatedLists = [...this.relatedLists, { key : 'campaignDetailRelatedList'+this.listcount, params : JSON.stringify(configs[i]) }];
                }
             }

             this.displayLists = true;
        }
    }

    handleSelectUserChange(e) {
        var payload = e.detail.payload;
        this.selectedUserId = payload.value;
        this.loadRelatedLists();
    }

    handleSelectCampaignChange(e) {
        var payload = e.detail.payload;
        this.selectedCampaignId = payload.value;
        this.loadRelatedLists();
    }
}