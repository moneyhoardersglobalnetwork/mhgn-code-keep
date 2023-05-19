// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

//import "hardhat/console.sol"; Don't remove for debugging
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }
  // Label this section for constant variables

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  mapping (address => uint256) public balances;

  // Declaring a constant threshold of 1 ether
  uint256 public constant threshold = 1 ether;

    // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  bool public openForWithdraw = true;

  // Set a deadline of block.timestamp + 30 seconds this is for quick dapp testing
  uint256 public deadline = block.timestamp + 30 seconds;

  // uint256 public deadline = block.timestamp + 72 hours; for use later in a production build

  // Events
  event Stake(address indexed sender, uint256 amount);
  event Withdraw(address indexed sender, uint256 amount);
  
  // Functions
  function stake() public payable{
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

   event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

  modifier deadlineExpired() {
    require(block.timestamp >= deadline, "Deadline not reached, please wait for timer to hit 0");
    _;
  }

  function execute() public deadlineExpired notCompleted{
    if(address(this).balance >= threshold){
      (bool sent, ) = address(exampleExternalContract).call{value: address(this).balance}(abi.encodeWithSignature("complete()"));
      require(sent, "Stake incomplete");
    }
  }

// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public notCompleted {
        uint256 userBalance = balances[msg.sender];
        require(timeLeft() == 0, "Deadline not yet expired");
        require(userBalance > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: userBalance}("");
        require(sent, "Failed to send user balance back to the user");
    }

// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256 timeleft) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    modifier deadlineReached() {
        uint256 timeRemaining = timeLeft();
        require(timeRemaining == 0, "Deadline is not reached yet");
        _;
    }

    modifier deadlineRemaining() {
        uint256 timeRemaining = timeLeft();
        require(timeRemaining > 0, "Deadline is already reached");
        _;
    }

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "staking process already completed");
        _;
    }
}

  


  

  // Add the `receive()` special function that receives eth and calls stake()


