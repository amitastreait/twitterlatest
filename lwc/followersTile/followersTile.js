/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';

export default class FollowersTile extends LightningElement {
    @api follower;
    @track isSelected = true;
    @track state = true;
    @track variant = 'success';

    handleClick( ) {

    }
}