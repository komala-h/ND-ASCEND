import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJECT_OPPORTUNITY from '@salesforce/schema/Opportunity';
import FIELD_OPPORTUNITY_RECORDTYPEID from '@salesforce/schema/Opportunity.RecordTypeId';
import FIELD_OPPORTUNITY_NAME from '@salesforce/schema/Opportunity.Name';
import FIELD_OPPORTUNITY_DESCRIPTION from '@salesforce/schema/Opportunity.Description';
import FIELD_OPPORTUNITY_TYPE from '@salesforce/schema/Opportunity.Type';
import FIELD_OPPORTUNITY_STAGENAME from '@salesforce/schema/Opportunity.StageName';
import FIELD_OPPORTUNITY_ACCOUNTID from '@salesforce/schema/Opportunity.AccountId';
import FIELD_OPPORTUNITY_CAMPAIGNID from '@salesforce/schema/Opportunity.CampaignId';
import FIELD_OPPORTUNITY_LIKELIHOODTOCLOSE from '@salesforce/schema/Opportunity.nd_Likelihood_to_Close__c';
import FIELD_OPPORTUNITY_RESEARCHAWARDNUMBER from '@salesforce/schema/Opportunity.nd_Research_Award_Number__c';
import FIELD_OPPORTUNITY_EXPECTEDTOCLOSEDATE from '@salesforce/schema/Opportunity.ucinn_ascendv2__Expected_Close_Date__c';
import FIELD_OPPORTUNITY_SUBMITTEDDATE from '@salesforce/schema/Opportunity.ucinn_ascendv2__Submitted_Date__c';
import FIELD_OPPORTUNITY_SUBMITTEDAMOUNT from '@salesforce/schema/Opportunity.ucinn_ascendv2__Submitted_Amount__c';
import FIELD_OPPORTUNITY_ANSWERDATE from '@salesforce/schema/Opportunity.nd_Answer_Date__c';
import FIELD_OPPORTUNITY_ANSWERAMOUNT from '@salesforce/schema/Opportunity.nd_Answer_Amount__c';
import FIELD_OPPORTUNITY_TITLE from '@salesforce/schema/Opportunity.Title__c';
import FIELD_SUBPROPOSAL_AMOUNT from '@salesforce/schema/Sub_Proposal__c.Amount__c';
import FIELD_SUBPROPOSAL_TYPE from '@salesforce/schema/Sub_Proposal__c.Type__c';
import FIELD_SUBPROPOSAL_PLANNEDGIFTTYPE from '@salesforce/schema/Sub_Proposal__c.Planned_Gift_Type__c';
import FIELD_SUBPROPOSAL_FUNDINGPRIORITY from '@salesforce/schema/Sub_Proposal__c.Funding_Priority__c';
import FIELD_SUBPROPOSAL_COMMENTS from '@salesforce/schema/Sub_Proposal__c.Comments__c';
import FIELD_OPPORTUNITYTEAMMEMBER_USERID from '@salesforce/schema/OpportunityTeamMember.UserId';
import FIELD_OPPORTUNITYTEAMMEMBER_TEAMMEMBERROLE from '@salesforce/schema/OpportunityTeamMember.TeamMemberRole';
import FIELD_OPPORTUNITYTEAMMEMBER_OPPORTUNITYACCESSLEVEL from '@salesforce/schema/OpportunityTeamMember.OpportunityAccessLevel';
import FIELD_OPPORTUNITYCONTACTROLE_CONTACTID from '@salesforce/schema/OpportunityContactRole.ContactId';
import FIELD_OPPORTUNITYCONTACTROLE_ROLE from '@salesforce/schema/OpportunityContactRole.Role';
import saveOpportunity from '@salesforce/apex/NewOpportunityController.saveOpportunity';
import getFieldHelpText from '@salesforce/apex/NewOpportunityController.getFieldHelpText';
import getAccount from '@salesforce/apex/NewOpportunityController.getAccount';
import getStrategy from '@salesforce/apex/NewOpportunityController.getStrategy';
import getCurrentComprehensiveCampaign from '@salesforce/apex/NewOpportunityController.getCurrentComprehensiveCampaign';

export default class NewOpportunityForm extends NavigationMixin(LightningElement) {
    @api objectInfo;
    @track subproposals = [];
    @track oppteammembers = [];
    @track oppcontactroles = [];
    recordTypeId;
    opportunityTypePicklist
    modalWorkPlanUnitTreeModalSubProposalKey;
    fieldHelpTextSubProposalAmount;
    fieldHelpTextSubProposalType;
    fieldHelpTextSubProposalPlannedGiftType;
    fieldHelpTextSubProposalFundingPriority;
    fieldHelpTextSubProposalComments;
    displayResearchAwardNumber = false;
    displayAnswerDate = false;
    displayAnswerAmount = false;
    displayModal = true;
    displayWorkPlanUnitTreeModal = false;
    btnSubmitDisabled = false;
    btnSubmitText = 'Save';
    @track opportunityRec = {
        RecordTypeId: FIELD_OPPORTUNITY_RECORDTYPEID, 
        Name: FIELD_OPPORTUNITY_NAME, 
        Description: FIELD_OPPORTUNITY_DESCRIPTION, 
        Type: FIELD_OPPORTUNITY_TYPE, 
        StageName: FIELD_OPPORTUNITY_STAGENAME, 
        AccountId: FIELD_OPPORTUNITY_ACCOUNTID, 
        CampaignId: FIELD_OPPORTUNITY_CAMPAIGNID, 
        nd_Likelihood_to_Close__c: FIELD_OPPORTUNITY_LIKELIHOODTOCLOSE, 
        nd_Research_Award_Number__c: FIELD_OPPORTUNITY_RESEARCHAWARDNUMBER, 
        ucinn_ascendv2__Expected_Close_Date__c: FIELD_OPPORTUNITY_EXPECTEDTOCLOSEDATE, 
        ucinn_ascendv2__Submitted_Date__c: FIELD_OPPORTUNITY_SUBMITTEDDATE, 
        ucinn_ascendv2__Submitted_Amount__c: FIELD_OPPORTUNITY_SUBMITTEDAMOUNT, 
        nd_Answer_Date__c: FIELD_OPPORTUNITY_ANSWERDATE, 
        nd_Answer_Amount__c: FIELD_OPPORTUNITY_ANSWERAMOUNT,
        Title__c: FIELD_OPPORTUNITY_TITLE
    };

    @wire(getObjectInfo, { objectApiName: OBJECT_OPPORTUNITY })
    wiredOpportunityObjectInfo({error, data}) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Proposal');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: FIELD_OPPORTUNITY_TYPE })
    wiredOpportunityTypePicklist({ data, error }) {
        if (data) this.opportunityTypePicklist = data.values;
    }

    get modalDisplayCss() {
        return (this.displayWorkPlanUnitTreeModal) ? 'display:none;' : 'display:block;';
    }

    get fieldHelpTextSubProposalAmountDisplay() {
        return (this.fieldHelpTextSubProposalAmount == null) ? false : true;
    }

    get fieldHelpTextSubProposalTypeDisplay() {
        return (this.fieldHelpTextSubProposalType == null) ? false : true;
    }

    get fieldHelpTextSubProposalPlannedGiftTypeDisplay() {
        return (this.fieldHelpTextSubProposalPlannedGiftType == null) ? false : true;
    }

    get fieldHelpTextSubProposalFundingPriorityDisplay() {
        return (this.fieldHelpTextSubProposalFundingPriority == null) ? false : true;
    }

    get fieldHelpTextSubProposalCommentsDisplay() {
        return (this.fieldHelpTextSubProposalComments == null) ? false : true;
    }

    connectedCallback() {
        this.opportunityRec.Name = null;
        this.opportunityRec.Description = null;
        this.opportunityRec.Type = null;
        this.opportunityRec.StageName = null;
        this.opportunityRec.AccountId = null;
        this.opportunityRec.CampaignId = null;
        this.opportunityRec.nd_Likelihood_to_Close__c = null;
        this.opportunityRec.nd_Research_Award_Number__c = null;
        this.opportunityRec.ucinn_ascendv2__Expected_Close_Date__c = null;
        this.opportunityRec.ucinn_ascendv2__Submitted_Date__c = null;
        this.opportunityRec.ucinn_ascendv2__Submitted_Amount__c = 0;
        this.opportunityRec.nd_Answer_Date__c = null;
        this.opportunityRec.nd_Answer_Amount__c = null;
        this.opportunityRec.Title__c = null;

        this.loadFieldHelpText();
        this.loadAccount();
        this.loadCurrentComprehensiveCampaign();
        this.handleSubProposalAddRow();
        this.handleOpportunityTeamMemberAddRow();
        //this.handleOpportunityContactRoleAddRow();
    }

    renderedCallback() {
        // This is to fix the issue where required validation message still showing even the field is no longer blank
        if (this.subproposals.length > 0) {
            let hasval = false;
            for(let i=0; i<this.subproposals.length; i++){
                if (this.subproposals[i].FundingPriorityName != null) {
                    hasval = true;
                    break;
                }
            }

            if (hasval) {
                let isValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
                    return (validSoFar && field.reportValidity());
                }, true);
            }
        }
    }

    loadFieldHelpText() {
        this.fieldHelpTextSubProposalAmount = null;
        this.fieldHelpTextSubProposalType = null;
        this.fieldHelpTextSubProposalPlannedGiftType = null;
        this.fieldHelpTextSubProposalFundingPriority = null;
        this.fieldHelpTextSubProposalComments = null;
        
        getFieldHelpText( { sobjectName: 'Sub_Proposal__c', fieldName : 'Amount__c' } )
        .then(result => {
            if (result) this.fieldHelpTextSubProposalAmount = result;
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });

        getFieldHelpText( { sobjectName: 'Sub_Proposal__c', fieldName : 'Type__c' } )
        .then(result => {
            if (result) this.fieldHelpTextSubProposalType = result;

            console.log('#### this.fieldHelpTextSubProposalType: '+this.fieldHelpTextSubProposalType);
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });

        getFieldHelpText( { sobjectName: 'Sub_Proposal__c', fieldName : 'Planned_Gift_Type__c' } )
        .then(result => {
            if (result) this.fieldHelpTextSubProposalPlannedGiftType = result;
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });

        getFieldHelpText( { sobjectName: 'Sub_Proposal__c', fieldName : 'Funding_Priority__c' } )
        .then(result => {
            if (result) this.fieldHelpTextSubProposalFundingPriority = result;
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });

        getFieldHelpText( { sobjectName: 'Sub_Proposal__c', fieldName : 'Comments__c' } )
        .then(result => {
            if (result) this.fieldHelpTextSubProposalComments = result;
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });
    }

    loadAccount() {
        let url = decodeURIComponent(window.location);
        
        if (url.includes('/Account/')) {
            let accId = url.substr(url.search('/Account/') + 9, 18);

            getAccount( { accountId: accId } )
            .then(result => {
                if (result) {
                    let accRec = result;
                    this.opportunityRec.AccountId = accRec.Id;

                    if (accRec.ucinn_ascendv2__PRM__c != null && this.oppteammembers.length == 1 && this.oppteammembers[0].UserId == null) {
                        this.oppteammembers[0].UserId = accRec.ucinn_ascendv2__PRM__c;
                        this.oppteammembers[0].TeamMemberRole = 'RM';
                    }
                }
            })
            .catch(error => {
                console.log('ERROR: '+error);
            });
        } else if (url.includes('/ucinn_ascendv2__Strategy__c/')) {
            let strategyId = url.substr(url.search('/ucinn_ascendv2__Strategy__c/') + 29, 18);

            getStrategy( { strategyId: strategyId } )
            .then(result => {
                if (result) {
                    let strategyRec = result;
                    this.opportunityRec.AccountId = strategyRec.ucinn_ascendv2__Account__c;

                    if (strategyRec.ucinn_ascendv2__Account__r.ucinn_ascendv2__PRM__c != null && this.oppteammembers.length == 1 && this.oppteammembers[0].UserId == null) {
                        this.oppteammembers[0].UserId = strategyRec.ucinn_ascendv2__Account__r.ucinn_ascendv2__PRM__c;
                        this.oppteammembers[0].TeamMemberRole = 'RM';
                    }
                }
            })
            .catch(error => {
                console.log('ERROR: '+error);
            });
        }
    }

    loadCurrentComprehensiveCampaign() {
        getCurrentComprehensiveCampaign()
        .then(result => {
            if (result) {
                let campaignRec = result;
                this.opportunityRec.CampaignId = campaignRec.Id;
            }
        })
        .catch(error => {
            console.log('ERROR: '+error);
        });
    }

    handleSubProposalAddRow() {
        let rec = {
            Key : '', 
            Amount__c: FIELD_SUBPROPOSAL_AMOUNT, 
            Type__c: FIELD_SUBPROPOSAL_TYPE, 
            Comments__c: FIELD_SUBPROPOSAL_COMMENTS,
            Planned_Gift_Type__c: FIELD_SUBPROPOSAL_PLANNEDGIFTTYPE, 
            Funding_Priority__c: FIELD_SUBPROPOSAL_FUNDINGPRIORITY,
            FundingPriorityName: ''
        };
        
        rec.Key = Math.random().toString(36).substring(2, 15);
        rec.Amount__c = null;
        rec.Type__c = null;
        rec.Comments__c = null;
        rec.Planned_Gift_Type__c = null;
        rec.Funding_Priority__c = null;
        rec.FundingPriorityName = null;
        this.subproposals.push(rec);
    }
    
    handleSubProposalRemoveRow(e) {
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.subproposals.length > 1) {
            let idx = -1;
            for(let i=0; i<this.subproposals.length; i++){
                if (this.subproposals[i].Key == key) {
                    idx = i;
                    break;
                }
            }
            if (idx > -1) {
                this.subproposals.splice(idx, 1);
            }
        } else if (this.subproposals.length == 1) {
            this.subproposals = [];
        }

        this.recalculateSudmittedAmount();
    }

    handleOpportunityTeamMemberAddRow() {
        let rec = {
            Key : '', 
            UserId: FIELD_OPPORTUNITYTEAMMEMBER_USERID, 
            TeamMemberRole: FIELD_OPPORTUNITYTEAMMEMBER_TEAMMEMBERROLE, 
            OpportunityAccessLevel: FIELD_OPPORTUNITYTEAMMEMBER_OPPORTUNITYACCESSLEVEL
        };

        rec.Key = Math.random().toString(36).substring(2, 15);
        rec.UserId = null;
        rec.TeamMemberRole = null;
        rec.OpportunityAccessLevel = null;
        this.oppteammembers.push(rec);
    }
    
    handleOpportunityTeamMemberRemoveRow(e) {
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.oppteammembers.length > 1) {
            let idx = -1;
            for(let i=0; i<this.oppteammembers.length; i++){
                if (this.oppteammembers[i].Key == key) {
                    idx = i;
                    break;
                }
            }
            if (idx > -1) {
                this.oppteammembers.splice(idx, 1);
            }
        } else if (this.oppteammembers.length == 1) {
            this.oppteammembers = [];
        }
    }

    handleOpportunityContactRoleAddRow() {
        let rec = {
            Key : '', 
            ContactId: FIELD_OPPORTUNITYCONTACTROLE_CONTACTID, 
            Role: FIELD_OPPORTUNITYCONTACTROLE_ROLE
        };

        rec.Key = Math.random().toString(36).substring(2, 15);
        rec.ContactId = null;
        rec.Role = null;
        this.oppcontactroles.push(rec);
    }
    
    handleOpportunityContactRoleRemoveRow(e) {
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.oppcontactroles.length > 1) {
            let idx = -1;
            for(let i=0; i<this.oppcontactroles.length; i++){
                if (this.oppcontactroles[i].Key == key) {
                    idx = i;
                    break;
                }
            }
            if (idx > -1) {
                this.oppcontactroles.splice(idx, 1);
            }
        } else if (this.oppcontactroles.length == 1) {
            this.oppcontactroles = [];
        }
    }

    handleChange(e) {
        const field = e.target.fieldName;
        const val = e.target.value;
        
        if (field === 'Name') {
            this.opportunityRec.Name = val;
        } else if (field === 'Description') {
            this.opportunityRec.Description = val;
        } else if (field === 'Type') {
            let targetLabel = this.opportunityTypePicklist.find(opt => opt.value === e.target.value).label;

            this.opportunityRec.Type = val;
            this.displayResearchAwardNumber = false;
            this.displayAnswerDate = false;
            this.displayAnswerAmount = false;
            
            if (targetLabel.startsWith('CFR')) {
                this.displayResearchAwardNumber = true;
                this.displayAnswerDate = true;
                this.displayAnswerAmount = true;
            }
        } else if (field === 'StageName') {
            this.opportunityRec.StageName = val;
        } else if (field === 'AccountId') {
            this.opportunityRec.AccountId = val;
        } else if (field === 'CampaignId') {
            this.opportunityRec.CampaignId = val;

            // Clear out funding priority
            if (this.subproposals.length > 0) {
                for(let i=0; i<this.subproposals.length; i++){
                    this.subproposals[i].Funding_Priority__c = null;
                    this.subproposals[i].FundingPriorityName = null;
                }
            }
        } else if (field === 'nd_Likelihood_to_Close__c') {
            if (val > 100) {
                this.displayToastErrorMessage('Percent Likelihood to Close cannot exceed 100%');
                this.opportunityRec.nd_Likelihood_to_Close__c = null;
            } else {
                this.opportunityRec.nd_Likelihood_to_Close__c = val;
            }
        } else if (field === 'nd_Research_Award_Number__c') {
            this.opportunityRec.nd_Research_Award_Number__c = val;
        } else if (field === 'ucinn_ascendv2__Expected_Close_Date__c') {
            this.opportunityRec.ucinn_ascendv2__Expected_Close_Date__c = val;
        } else if (field === 'ucinn_ascendv2__Submitted_Date__c') {
            this.opportunityRec.ucinn_ascendv2__Submitted_Date__c = val;
        } else if (field === 'ucinn_ascendv2__Submitted_Amount__c') {
            this.opportunityRec.ucinn_ascendv2__Submitted_Amount__c = val;
        } else if (field === 'nd_Answer_Date__c') {
            this.opportunityRec.nd_Answer_Date__c = val;
        } else if (field === 'nd_Answer_Amount__c') {
            this.opportunityRec.nd_Answer_Amount__c = val;
        } else if (field == 'Title__c') {
            this.opportunityRec.Title__c = val;
        }
    }

    handleSubProposalClick(e) {
        const name = e.target.name;
        //const val = e.target.value;
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.subproposals.length > 0) {
            for(let i=0; i<this.subproposals.length; i++){
                if (this.subproposals[i].Key == key) {
                    if (name === 'tbxSubProposalFundingPriority') {
                        this.displayWorkPlanUnitTreeModal = true;
                        this.modalWorkPlanUnitTreeModalSubProposalKey = key;
                    }
                    break;
                }
            }
        }
    }

    handleSubProposalChange(e) {
        const field = e.target.fieldName;
        const val = e.target.value;
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.subproposals.length > 0) {
            for(let i=0; i<this.subproposals.length; i++){
                if (this.subproposals[i].Key == key) {
                    if (field === 'Amount__c') {
                        this.subproposals[i].Amount__c = val;
                        this.recalculateSudmittedAmount();
                    } else if (field === 'Type__c') {
                        this.subproposals[i].Type__c = val;
                    } else if (field === 'Comments__c') {
                        this.subproposals[i].Comments__c = val;
                    } else if (field === 'Planned_Gift_Type__c') {
                        this.subproposals[i].Planned_Gift_Type__c = val;
                    } else if (field === 'Funding_Priority__c') {
                        this.subproposals[i].Funding_Priority__c = val;
                    }
                    break;
                }
            }
        }
    }

    handleOpportunityTeamMemberChange(e) {
        const field = e.target.fieldName;
        const val = e.target.value;
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.oppteammembers.length > 0) {
            for(let i=0; i<this.oppteammembers.length; i++){
                if (this.oppteammembers[i].Key == key) {
                    if (field === 'UserId') {
                        this.oppteammembers[i].UserId = val;
                    } else if (field === 'TeamMemberRole') {
                        this.oppteammembers[i].TeamMemberRole = val;
                    }
                    break;
                }
            }
        }
    }

    handleOpportunityContactRoleChange(e) {
        const field = e.target.fieldName;
        const val = e.target.value;
        var selectedRow = e.currentTarget;
        var key = selectedRow.dataset.id;

        if (this.oppcontactroles.length > 0) {
            for(let i=0; i<this.oppcontactroles.length; i++){
                if (this.oppcontactroles[i].Key == key) {
                    if (field === 'ContactId') {
                        this.oppcontactroles[i].ContactId = val;
                    } else if (field === 'Role') {
                        this.oppcontactroles[i].Role = val;
                    }
                    break;
                }
            }
        }
    }

    handleCloseModal(e) {
        this.displayModal = false;
    }

    handleCloseWorkPlanUnitTreeModal(e) {
        this.displayWorkPlanUnitTreeModal = false;
    }

    handleSelectWorkPlanUnit(e) {
        this.template.querySelector("c-work-plan-unit-tree").handleSubmit();
    }

    handleWorkPlanUnitTreeSelected(e) {
        if (this.subproposals.length > 0) {
            for(let i=0; i<this.subproposals.length; i++){
                if (this.subproposals[i].Key == this.modalWorkPlanUnitTreeModalSubProposalKey) {
                    this.subproposals[i].Funding_Priority__c = e.detail.name;
                    this.subproposals[i].FundingPriorityName = e.detail.label;
                    this.displayWorkPlanUnitTreeModal = false;
                    break;
                }
            }
        }
    }

    handleWorkPlanUnitTreeError(e) {
        this.displayToastErrorMessage(e.detail.message);
        this.displayWorkPlanUnitTreeModal = false;
    }

    handleSubmit(e) {
        this.disableSubmitButton();
        this.opportunityRec.RecordTypeId = this.recordTypeId;

        let isValid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);

        if (isValid) {
            isValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
                return (validSoFar && field.reportValidity());
            }, true);
        }

        if (!isValid) {
            this.displayToastErrorMessage('Please complete the required fields');
            this.enableSubmitButton();
            return;
        }

        if (this.subproposals.length == 0) {
            this.displayToastErrorMessage('At least one purpose is required');
            this.enableSubmitButton();
            return;
        } else {
            let totalamount = 0;
            for(let i=0; i<this.subproposals.length; i++){
                totalamount += parseFloat(this.subproposals[i].Amount__c);
            }

            if (totalamount != this.opportunityRec.ucinn_ascendv2__Submitted_Amount__c) {
                this.displayToastErrorMessage('Ask Amount is not equal to the total of Purpose Amounts');
                this.enableSubmitButton();
                return;
            }
        }

        saveOpportunity( {
            opp: this.opportunityRec,
            subproposals: this.subproposals,
            oppteammembers: this.oppteammembers,
            oppcontactroles: this.oppcontactroles
        } ) 
        .then(result => {
            if (result['OpportunityId'] != '') {
                const completedEvent = new CustomEvent('submitcompleted', {
                    detail: { opportunityId: result['OpportunityId'] }
                });
                this.dispatchEvent(completedEvent);
    
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result['OpportunityId'],
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
            } else {
                this.displayToastErrorMessage(result['ErrorMessage']);
                this.enableSubmitButton();
            }
        })
        .catch(error => {
            this.enableSubmitButton();
            console.log('ERROR: '+error);
        });
    }

    disableSubmitButton() {
        this.btnSubmitDisabled = true;
        this.btnSubmitText = 'Saving...';
    }

    enableSubmitButton() {
        this.btnSubmitDisabled = false;
        this.btnSubmitText = 'Save';
    }

    displayToastErrorMessage(msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: msg,
                variant: 'error'
            })
        );
    }

    recalculateSudmittedAmount() {
        this.opportunityRec.ucinn_ascendv2__Submitted_Amount__c = 0;
        if (this.subproposals.length > 0) {
            for(let i=0; i<this.subproposals.length; i++){
                if (!isNaN(this.subproposals[i].Amount__c)) {
                    this.opportunityRec.ucinn_ascendv2__Submitted_Amount__c = parseFloat(this.opportunityRec.ucinn_ascendv2__Submitted_Amount__c) + parseFloat(this.subproposals[i].Amount__c);
                }
            }
        }
    }

    getObjectFieldHelpText(objName, fldname) {
        getFieldHelpText( { sobjectName: objName, fieldName : fldname } )
            .then(result => {
                
                console.log('#### objName: '+objName+' fldname: '+fldname+' result: '+result);
                
                return result;
            })
            .catch(error => {
                console.log('ERROR: '+error);
            });
    }
}