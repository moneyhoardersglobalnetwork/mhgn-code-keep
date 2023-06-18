// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
}

contract MHGNRaffle is VRFConsumerBaseV2 {

    //VRF
    VRFCoordinatorV2Interface COORDINATOR;
    // Sepolia coordinator
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;
    uint64 public s_subscriptionId;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;

    uint256 public randomResult;
    uint256 public maximum = 10;
    uint256 public amountToken;
    TokenInterface public token;

    constructor(address tokenMinter, uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        token = TokenInterface(tokenMinter);
    }

    function getTokens() public{
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }


    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
        randomResult = s_randomWords[0] % maximum + 1;
        amountToken = randomResult * 100; //2 decimal places
        token.mint(s_owner, amountToken);
    }

}