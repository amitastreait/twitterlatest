import { LightningElement, wire, track } from 'lwc';
import getTwitterTimeline from '@salesforce/apex/TwitterOperations.getTwitterTimeline';
export default class TwitterTimeline extends LightningElement {

    @track timelines;
    @track errors;

    @wire(getTwitterTimeline)
        wiredTimeline({error, data }){
            if ( error ) {
                this.errors = error;
                this.timelines = undefined;
            }
            if ( data ) {
                this.timelines = JSON.parse(data);
                this.errors =  undefined;
                window.console.log(' timelined ', this.timelines);
            }
        }
}