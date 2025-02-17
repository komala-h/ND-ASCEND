import { LightningElement, wire , api} from 'lwc';
import getData from '@salesforce/apex/NDFundingInterestTagController.getData';

export default class FITag extends LightningElement {
    columns = [
        { label: 'Name',  sortable: false, fieldName: 'InterestUrl', type: 'url', typeAttributes: { label: { fieldName: 'InterestUrlName' }, target: '_blank'}},
        { label: 'Household Name',  sortable: false, fieldName: 'AccountUrl', type: 'url', typeAttributes: { label: { fieldName: 'AccountUrlName' }, target: '_blank'}},
        { label: 'Tag',  sortable: false, fieldName: 'TagUrl', type: 'url', typeAttributes: { label: { fieldName: 'TagUrlName' }, target: '_blank'}}
        
    ];
    @api recordId;
    householdTags;
    sortBy;
    sortDirection;

    @wire(getData, {FundInterestPriorityId: '$recordId'})
    wiredContacts({ error, data }) {
        if (data) {
            let resultList = [];
        data.forEach(r => {
        let record = { ...r };
        //here is the important bit - generating yourUrl and yourUrlName
        record.InterestUrl = `/lightning/r/${r.Id}/view`;
        record.InterestUrlName = r.Name;
        record.AccountUrl = `/lightning/r/Account/${r.ucinn_ascendv2__Account__c}/view`;
        record.AccountUrlName = r.ucinn_ascendv2__Account__r.Name;
        record.TagUrl = `/lightning/r/${r.ucinn_ascendv2__Foundation_Funding_Interest__c}/view`;
        record.TagUrlName = r.ucinn_ascendv2__Foundation_Funding_Interest__r.Name;
        resultList.push(record);
        });
            //this.data = data.map(row => { ...row, HouseholdName: row.ucinn_ascendv2__Account__r.Name });
            /*this.data = this.data.map(row=>{
                return{...row, HouseholdName: row.ucinn_ascendv2__Account__r.Name}
            })*/

            /*let preparedArr = [];
            data.forEach(record => {
                let preparedRec = {};
                preparedRec.Name = record.Name;
                preparedRec.HouseholdName = record.arketing_Activity__r.Name;

                preparedArr.push(preparedRec);
            });
            //this.log = preparedArr;*/

            this.householdTags = resultList;
            this.error = undefined;

            
            //alert(JSON.stringify(data));
            //console.log(`Data returned: + ${this.householdTags}`);
        } else if (error) {
            this.error = error;
            this.householdTags = undefined;
        }
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }
}