import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getOpportunity from '@salesforce/apex/SubProposalController.getOpportunity';

export default class SubProposalForm extends NavigationMixin(LightningElement) {
    opportunityId;
    campaignId = '';
    fundingPriorityId;
    fundingPriorityName;
    displayModal = true;
    displayWorkPlanUnitTreeModal = false;

    @wire(CurrentPageReference)
    currentPageReference;

    get modalDiplayCss() {
        return (this.displayWorkPlanUnitTreeModal) ? 'display:none;' : 'display:block;';
    }

    connectedCallback() {
        this.loadOpportunityId();
    }

    renderedCallback() {
        // This is to fix the issue where required validation message still showing even the field is no longer blank
        let hasval = false;
        if (this.fundingPriorityName != null) {
            hasval = true;
        }

        if (hasval) {
            let isValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
                return (validSoFar && field.reportValidity());
            }, true);
        }
    }

    loadOpportunityId() {
        if (this.currentPageReference.state.c__oppid) {
            this.opportunityId = this.currentPageReference.state.c__oppid;

            getOpportunity( { opportunityId: this.opportunityId } )
            .then(result => {
                if (result) {
                    this.campaignId = result.CampaignId;
                }
            })
            .catch(error => {
                console.log('ERROR: '+error);
            });
        }
    }

    handleClick(e) {
        const name = e.target.name;
        if (name === 'tbxSubProposalFundingPriority') {
            this.displayWorkPlanUnitTreeModal = true;
        }
    }

    handleChange(e) {
        const field = e.target.fieldName;
        const val = e.target.value;
    }

    handleCloseWorkPlanUnitTreeModal(e) {
        this.displayWorkPlanUnitTreeModal = false;
    }

    handleSelectWorkPlanUnit(e) {
        this.template.querySelector("c-work-plan-unit-tree").handleSubmit();
    }

    handleWorkPlanUnitTreeSelected(e) {
        this.fundingPriorityId = e.detail.name;
        this.fundingPriorityName = e.detail.label;
        this.displayWorkPlanUnitTreeModal = false;
    }

    handleWorkPlanUnitTreeError(e) {
        this.displayToastErrorMessage(e.detail.message);
        this.displayWorkPlanUnitTreeModal = false;
    }

    handleSubmit(e) {
        const btn = this.template.querySelector(".btnsubmit-hidden");
        if(btn){
            btn.click();
        }
    }

    handleCancel(e) {
        this.navigateToOpportunityPage();
    }

    handleSuccess(e) {
        console.log('SUCCESS');
        this.navigateToOpportunityPage();
    }

    navigateToOpportunityPage() {
        if (this.opportunityId != null) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.opportunityId,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            });
        }
    }
}