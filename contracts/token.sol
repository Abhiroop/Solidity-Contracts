pragma solidity ^0.4.9;
contract token { 
    mapping (address => uint) public coinBalanceOf;


  /* Initializes contract with initial supply tokens to the creator of the contract */
  function token(uint supply) {
        coinBalanceOf[msg.sender] = supply;
    }

  /* Very simple trade function */
    function sendCoin(address receiver, uint amount) returns(bool sufficient) {
        if (coinBalanceOf[msg.sender] < amount) return false;
        coinBalanceOf[msg.sender] -= amount;
        coinBalanceOf[receiver] += amount;
        if (!receiver.send(amount))
            throw;
        return true;
    }
}
