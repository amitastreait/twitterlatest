import { LightningElement, track, wire } from 'lwc';
import findFollowers from '@salesforce/apex/TwitterFollowersMap.findFollowers';
export default class SearchFollowers extends LightningElement {
    @track searchParam = null;
    @track locationSearchParam = null;
    @track followersData;
    @track errors;
    @track isloading = true;
    @wire(findFollowers, { 
        searchParam : '$searchParam',
        locationParam : '$locationSearchParam'
    })
        wiredFollowers({ error, data }){
            if ( data ) {
                this.errors = undefined;
                this.followersData = data;
                this.isloading = false;
            }
            if ( error ) {
                this.errors = error;
                this.followersData = undefined;
                this.isloading = false;
            }
            
        }

    handleSearch(event) {
        this.searchParam = event.detail;
        
    }

    handleLocationSearch( event ) {
        this.locationSearchParam = event.detail;
    }
}