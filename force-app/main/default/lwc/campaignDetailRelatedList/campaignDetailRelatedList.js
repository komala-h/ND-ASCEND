import { LightningElement, wire, api, track } from 'lwc';
import getRecords from '@salesforce/apex/CampaignDetailController.getRecords';

export default class CampaignDetailRelatedList extends LightningElement {
    @api mykey;
    @api myparams;
    @api userid;
    @api campaignid;
    mycolumns = [];
    mydata = [];
    recordsToDisplay = [];
    mylabel;
    paramobj;
    totalRecords = 0;
    totalPages;
    pageSize = 10;
    pageNumber = 1;
    displayNewButton = false;
    newButtonLabel = '';
    newButtonFormLabel = '';
    newButtonFormURL = '';
    newButtonObjectName = '';
    newButtonRecordTypeId = '';

    get disableFirst() {
        return this.pageNumber == 1;
    }

    get disableLast() {
        return this.pageNumber == this.totalPages;
    }

    connectedCallback() {
        if (this.userid != '' && this.campaignid != '' && this.myparams != '') {
            this.myparams = this.myparams.replace(/#userid#/gi, this.userid);
            this.paramobj = JSON.parse(this.myparams);
            this.mylabel = this.paramobj['Label'];
            this.mycolumns = this.paramobj['Columns'];
            this.loadData();
        }
    }

    loadData() {
        let query = this.paramobj['Query'];
        let queryVariables = this.paramobj['QueryVariables'];
        let aliases = this.paramobj['FieldAliases'];
        let newButton = this.paramobj['NewButton'];
        let dataSourceSubqueryRelationshipName = this.paramobj['DataSourceSubqueryRelationshipName'];

        if (newButton.Label != undefined || newButton.Label == '') {
            this.displayNewButton = true;
            this.newButtonLabel = newButton.Label;
            this.newButtonFormLabel = newButton.FormLabel;
            this.newButtonFormURL = newButton.FormURL;
            this.newButtonObjectName = newButton.ObjectName;
            this.newButtonRecordTypeId = newButton.RecordTypeId;

            if (this.newButtonFormURL != null && this.newButtonFormURL != '') {
                this.newButtonFormURL = this.newButtonFormURL.replace(/#sfdcbaseurl#/gi, window.location.origin);
            }
        }

        getRecords( { userId: this.userid, campaignId: this.campaignid, query: query, queryVariables: JSON.stringify(queryVariables), dataSourceSubqueryRelationshipName : dataSourceSubqueryRelationshipName } )
        .then(result => {
            if (result) {
                this.mydata = result;
                this.totalRecords = result.length;

                this.mydata.forEach(function(data) {
                    try {
                        for (let i = 0; i < aliases.length; i++) {
                            let valueFormula = aliases[i]['ValueFormula'];
                            let fieldLevels = aliases[i]['FieldName'].split('.');
                            let fieldValue = data;

                            for (let fl = 0; fl<fieldLevels.length; fl++) {
                                fieldValue = fieldValue[fieldLevels[fl]];
                            }
                            
                            data[aliases[i]['NewFieldName']] = valueFormula.replace(/#fieldname#/gi, fieldValue);
                        }
                    }catch(e){}
                });

                this.loadPager();
            }
        })
        .catch(error => {
            console.log('ERROR: '+JSON.stringify(error));
        });
    }

    loadPager() {
        this.recordsToDisplay = [];

        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        if (this.totalPages == 0) {
            this.totalPages = 1;
        }

        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.mydata[i]);
        }
    }

    handleGoToPreviousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.loadPager();
    }

    handleGoToNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.loadPager();
    }

    handleGoToFirstPage() {
        this.pageNumber = 1;
        this.loadPager();
    }

    handleGoToLastPage() {
        this.pageNumber = this.totalPages;
        this.loadPager();
    }

    handleCreateNewRecord() {
        if (this.newButtonFormURL != '') {
            window.open(this.newButtonFormURL, '_blank');
        } else {
            const newrecform = this.template.querySelector('[data-id="' + this.mykey + '"]');
            newrecform.showForm();
        }
    }

    handleCreateNewRecordSuccess(e) {
        this.loadData();
    }

    handleRefresh(e) {
        this.pageNumber = 1;
        this.loadData();
    }
}