// SPDX-License-Identifier: MIT
/*M.H.G.N Hoarder Labs gaming contract where users search for the real BOP token on the game board. The logic of the game uses randomness
to get a number as the user eats a specific token.  */
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract EatTheBopVrf is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event Result(address player, uint256 num, bool isWinner);
    event Pooled(address indexed user, uint256 amount);

    struct Hoarder {
        uint256 timeStarted;
        bool canPlay;
        uint256 reward;
        uint256 Total_AllTime_Reward;
    }

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    // State Variables some were taken from BopHoardingContract
    mapping (address => Hoarder) public hoarders;
    uint256 timeStarted;
    uint256 public points = 0;
    uint256[] public nums;
    mapping(address => uint256) public life;
    uint public reward = 6000000000000000000000; //Should reward 6000 BOP tokens
    ERC20 public gameToken;
    uint256 public Total_Reward_Pool;
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash =
        0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 1;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    uint256 public randomResult; //Publicly displays the random Number
    uint256 public maximum = 10; //Sets the max of random number given

    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     */
    constructor(
        uint64 subscriptionId
        
    )
        VRFConsumerBaseV2(0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625)
        ConfirmedOwner(msg.sender)
        
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        );
        s_subscriptionId = subscriptionId;

        gameToken = ERC20(0x76f9d116a4263b0b193E3174bC5b52946B10548b);  //Deploy token b4 game contract change to your token address.
    }

    function playGame() public payable {
        require(msg.value >= 0.01 ether, "Failed to send enough value");
        //require(address(this).balance >= reward, "Not enough reward"); // Uncomment if you want to use ETH reward
        require(gameToken.balanceOf(address(this)) >= reward, "The contract does not have enough tokens to give you the reward");
        /*Above we require that the contract has BOP tokens to reward before hoarders can play*/
        life[msg.sender] += 6; //Hoarders can buy 6 lifes at a time
    }

    /* Assumes the subscription is funded sufficiently. Check @ vrf.chain.link
    The main game function which is called when a player collides with a BOP token
    This Contract uses Chainlink VRF to get randomness the original contract.
    
    */
     function earnPoint()  external
        
        returns (uint256 requestId)
        
         {
        require(life[msg.sender] > 0, "Out of life"); //Required to have lifes to play
        uint randomNumber = randomResult;
        nums.push(randomNumber);

        bool isWinner = false; //Not a winner
       /**Here we set the winning number to 6 following the Project 6 model*/
        if (randomNumber == 6) {
            isWinner = true;
        // Function to transfer reward for finding the real BOP token
        require(gameToken.balanceOf(address(this)) >= reward, "The contract does not have enough tokens to give you the reward");
        gameToken.transfer(msg.sender, reward); //tranfers BOP tokens to winner address
        Total_Reward_Pool -= reward; //decrements the rewards pool when a hoarder wins
        hoarders[msg.sender].Total_AllTime_Reward += reward; //updates Hoarders All Time Reward tracking
        points += 1; //increments when a real BOP token is found
        }

        else if (randomNumber < 5) {
            life[msg.sender] -= 1;
        }

        emit Result(msg.sender, randomNumber, isWinner);
// Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;     
    }

    function getNums() public view returns (uint256[] memory) {
        return nums;
    }

    function canPlay() public view returns (bool) {
        if (life[msg.sender] > 0) return true;
        return false;
    }

 //Read only function that checks the hoarders hoarding time in seconds.
    function GetPlayTimeInSeconds(address _hoarder) public view returns (uint256) {
        return block.timestamp - hoarders[_hoarder].timeStarted;
    }

     //Transfers tokens to the BOP rewards pool the tokens can't be withdrawn!
    function DonationPool(uint256 _amount) public  {
        require(gameToken.balanceOf(msg.sender) >= 0, "You cannot pool more tokens than you hold");
        gameToken.transferFrom(msg.sender, address(this), _amount);
        Total_Reward_Pool += _amount;
        emit Pooled(msg.sender, _amount);
    }


    // Assumes the subscription is funded sufficiently. Check @ vrf.chain.link
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        randomResult = _randomWords[0] % maximum + 1;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}
