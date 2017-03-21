pragma solidity ^0.4.9;
contract CrowdFunder {
    
    address public creator;
    address public fundRecipient; 
    uint public minimumToRaise; 
    string campaignUrl;
    byte constant version = 1;

    enum State {
        Fundraising,
        ExpiredRefund,
        Successful
    }
    struct Contribution {
        uint amount;
        address contributor;
    }

    State public state = State.Fundraising; 
    uint public totalRaised;
    uint public raiseBy;
    uint public completeAt;
    Contribution[] contributions;

    event LogFundingReceived(address addr, uint amount, uint currentTotal);
    event LogWinnerPaid(address winnerAddress);

    modifier inState(State _state) {
        if (state != _state) throw;
        _
    }

    modifier isCreator() {
        if (msg.sender != creator) throw;
        _
    }

    modifier atEndOfLifecycle() {
    if(!((state == State.ExpiredRefund || state == State.Successful) &&
        completeAt + 6 months < now)) {
            throw;
        }
        _
    }

    function CrowdFunder(
        uint timeInHoursForFundraising,
        string _campaignUrl,
        address _fundRecipient,
        uint _minimumToRaise)
    {
        creator = msg.sender;
        fundRecipient = _fundRecipient;
        campaignUrl = _campaignUrl;
        minimumToRaise = _minimumToRaise;
        raiseBy = now + (timeInHoursForFundraising * 1 hours);
    }

    function contribute()
    public
    inState(State.Fundraising)
    {
        contributions.push(
            Contribution({
                amount: msg.value,
                contributor: msg.sender
            }) // use array, so can iterate
        );
        totalRaised += msg.value;

        LogFundingReceived(msg.sender, msg.value, totalRaised);

        checkIfFundingCompleteOrExpired();
        return contributions.length - 1; 
    }

    function checkIfFundingCompleteOrExpired() {
        if (totalRaised > minimumToRaise) {
            state = State.Successful;
            payOut();

        } else if ( now > raiseBy )  {
            state = State.ExpiredRefund; 
        }
        completeAt = now;
    }

    function payOut()
    public
    inState(State.Successful)
    {
        if(!fundRecipient.send(this.balance)) {
            throw;
        }


        LogWinnerPaid(fundRecipient);
    }

    function getRefund(id)
    public
    inState(State.ExpiredRefund)
    {
        if (contributions.length <= id || id < 0 || contributions[id].amount == 0 ) {
            throw;
        }

        uint amountToRefund = contributions[id].amount;
        contributions[id].amount = 0;

        if(!contributions[id].contributor.send(amountToSend)) {
            contributions[id].amount = amountToSend;
            return false;
        }

      return true;
    }

    function removeContract()
    public
    isCreator()
    atEndOfLifecycle()
    {
        selfdestruct(msg.sender);
    }

    function () { throw; }
}