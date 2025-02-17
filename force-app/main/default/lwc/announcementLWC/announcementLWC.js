import { LightningElement,wire, api } from 'lwc';
import getAnnouncements from '@salesforce/apex/AnnouncementController.getAnnouncements'
import getCMT from '@salesforce/apex/AnnouncementController.getCMT'
import { refreshApex } from '@salesforce/apex';

export default class AnnouncementLWC extends LightningElement {


@api wiredRecords;
    @api cmtRecord;
    @api isLoading;
    refreshVal;
    currentPage =1
    totalRecords
    @api recordSize = 5;
    totalPage = 0

    connectedCallback(){
        this.refreshComponent();
    }

    @wire(getAnnouncements) 
    wiredAlerts(value){
        this.refreshVal = value;
        if(value.data) {
            let records = Object.values(Object.assign({},value.data));
            let updatedList =[];  
            for (var i = 0; i < records.length; i++) { 
              let rec = {...records[i]};
              rec.recURL = "/"+rec.Id;
              updatedList.push(rec);
            }        
            this.totalRecords = updatedList;
            //this.wiredRecords = updatedList;
            this.recordSize = Number(this.recordSize)
            this.totalPage = Math.ceil(this.totalRecords.length/this.recordSize)
            this.updateRecords()
        }
        else if(value.error) {
            console.log(value.error);
        }
    }
    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize
        const end = this.recordSize*this.currentPage
        this.wiredRecords = this.totalRecords.slice(start, end)

    }
    get disablePrevious(){ 
        return this.currentPage<=1
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage
    }
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1
            this.updateRecords()
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            this.updateRecords()
        }
    }
    @wire(getCMT) 
    wiredCMT({ error, data}){
        if(data) {
            this.cmtRecord = JSON.parse(JSON.stringify(data));
        }
        else if(error) {
            console.log(error);
        }
    }

    refreshComponent(){
        this.isLoading = true;
        refreshApex(this.refreshVal)
        .then(() => {
            setTimeout(() => {
                this.isLoading = false
            }, 750);
        })
        .catch(() => {
            setTimeout(() => {
                this.isLoading = false
            }, 750);
        })
    }

}