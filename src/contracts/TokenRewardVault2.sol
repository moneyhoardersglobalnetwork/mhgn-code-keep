pragma solidity ^0.5.0;

import "./MhgToken.sol";


contract TokenRewardVault2 {
    string public name = "Blocks Of Passion Protocol";
    address public owner;
    MhgToken public mhgToken;
   

    address[] public mhgstakers;
    mapping(address => uint) public stakingBalanceMhg;
    mapping(address => bool) public hasStakedMhg;
    mapping(address => bool) public isStakingMhg;
   

    constructor(MhgToken _mhgToken) public {
        mhgToken = _mhgToken;
        owner = msg.sender;
    }

    function stakeMhgTokens(uint _amount) public {
        // Require amount greater than 0
        require(_amount > 0, "amount cannot be 0");


        // Trasnfer MHG tokens to this contract for staking
        mhgToken.transferFrom(msg.sender, address(this), _amount);

        // Update staking balance
        stakingBalanceMhg[msg.sender] = stakingBalanceMhg[msg.sender] + _amount;
        
        // Add user to stakers array *only* if they haven't staked already
        if(!hasStakedMhg[msg.sender]) {
            mhgstakers.push(msg.sender);
        }

        // Update staking status
        isStakingMhg[msg.sender] = true;
        hasStakedMhg[msg.sender] = true;
    }

    // Unstaking MHG Tokens (Withdraw)
    function unstakeMhgTokens() public {
        // Fetch staking balance
        uint balance = stakingBalanceMhg[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        // Transfer MHG tokens to this contract for staking
        mhgToken.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalanceMhg[msg.sender] = 0;

        // Update staking status
        isStakingMhg[msg.sender] = false;
    }

     
    // Issuing Tokens
    function issueTokens() public {
        // Only owner can call this function
        require(msg.sender == owner, "caller must be the owner");

        // Issue tokens to all stakers
        for (uint i=0; i<mhgstakers.length; i++) {
            address recipient = mhgstakers[i];
            uint balance = stakingBalanceMhg[recipient];
            if(balance > 0) {
                mhgToken.transfer(recipient, balance);
            }
        }
    }
}
