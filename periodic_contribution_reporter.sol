pragma solidity ^0.4.2;

import "std.sol";
import "minnie_bank.sol";

contract PeriodicContributionRepository is owned, bankTrusted{
/* -
This contract registers contributions reports of known contributors
It also rewards contributors once the period is closed

ToDo :
 - Add events
 - Add givable tokens
 - Allow owner to registered a contribution for a closed period (and reward the targeted contributor)

*/

// Describe a period
    struct Period {
    address[] contributors;
    mapping(address=>uint) reports;
    bool payedOut;
    }

//Set price for each score
// Initial values are set in initializer function
    mapping(uint => uint) public rewardForScore;
    mapping(uint => Period) public periods;

// Period length in seconds
    uint constant PERIOD_LENGTH = 604800;
// 1 week = 604800
// 5 mins = 300 (test purpose)

// When do we change period ?
    uint constant TIMESTAMP_OFFSET = 345600;
/*
0	    Thursday 00:00 GMT
6400	Friday 00:00 GMT
172800	Saturday 00:00 GMT
259200	Sunday 00:00 GMT
345600	Monday 00:00 GMT
432000	Tuesday 00:00 GMT
518400	Wednesday 00:00 GMT
*/
// Return current period number (number of periods since Epoch+Offset)
    function currentPeriodNumber() constant returns(uint) {
        return (now-TIMESTAMP_OFFSET)/604800;
    }

// Adds up all scores for a given period
    function totalScoreForPeriod(uint period) constant returns(uint){
        uint score=0;
        for(uint i = 0; i<periods[period].contributors.length; i++ ){
            score+=periods[period].reports[periods[period].contributors[i]];
        }
        return score;
    }

    event Report(
    uint period,
    address contributor,
    uint score
    );

    event Payout(
    uint period
    );

    event RewardScoreChanged (
    uint score,
    uint newReward,
    uint previousReward
    );

//INITIALIZER
    function PeriodicContributionRepository(MinnieBank bank) bankTrusted(bank) {

    // Set reward for each score reported
    // We may choose to pay for it since the contributor
    // made the effort of reporting a non worked week
        rewardForScore[0]=0;
        rewardForScore[1]=100;
        rewardForScore[2]=250;
        rewardForScore[3]=500;

    //Scores above 3 do not exists and are therefore not rewarded
    }


    function reportContributionFor(address contributor,uint score) {

        if(!(contributor==msg.sender || owner==msg.sender )){throw;}

    // If contributor wasn't registered for this period, register it
        bool alreadyRegistered = false;
        for(uint i = 0; i<periods[currentPeriodNumber()].contributors.length; i++ ){
            if(periods[currentPeriodNumber()].contributors[i]==contributor){alreadyRegistered=true;}
        }
        if(!alreadyRegistered){
            periods[currentPeriodNumber()].contributors.push(contributor);
        }

    // Update report
        periods[currentPeriodNumber()].reports[contributor]=score;
        Report(currentPeriodNumber(),contributor,score);
    }

// Report a contribution for the current period
// If a report already existed, update it
    function reportContribution(uint score) onlycontributor {
        reportContributionFor(msg.sender,score);
    }

//Anyone can trigger a payout since only contributors are rewarded
    function payOut(uint periodNumber) {
    // You can only pay out a closed period
        if(periodNumber >= currentPeriodNumber()){ throw; }

    // You can't pay out a period already payed out
        if(periods[periodNumber].payedOut) {throw;}
        periods[periodNumber].payedOut=true;

        Payout(periodNumber);

    // Pay each contributors
        for(uint i = 0; i<periods[periodNumber].contributors.length; i++ ){
            address contributor = periods[periodNumber].contributors[i] ;
            tokenBank.addTokenTo(contributor, rewardForScore[periods[periodNumber].reports[contributor]]);
        }
    }

// Owner address can change rewards
    function changeRewardForScore(uint score, uint reward) onlyowner {
        log0("Called changeRewardForScore");
        log1(bytes32(score),bytes32(reward));
        RewardScoreChanged(score,rewardForScore[score],reward);
        rewardForScore[score]=reward;
    }

}