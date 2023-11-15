// SPDX-License-Identifier: MIT
/*M.H.G.N Hoarder Labs gaming contract where users search for the real BOP token on the game board. The logic of the game uses randomness
to get a number as the user eats a specific token.  */
// An example of a consumer contract that directly pays for each request.
// This contract is being integrated with the EatTheBop game contract.
// It currently gets a random number between 1-10 using Chainlink VRF
//Save to Code Keep
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 This contract must be funded with Link before the requestRandomWords function can be called.
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN MHGN CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 We will save this code for new buidl foundations
 */

contract EatTheBopDirectFund is
    VRFV2WrapperConsumerBase,
    ConfirmedOwner
{
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    uint256 public maximum = 10; // Set the highest random number we want fetched
    uint256 public randomResult; // Displays the random number 

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher for more security.
    uint16 requestConfirmations = 3;

    // For EatTheBop, we retrieve 1 random value in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 1;

    struct Hoarder {
        uint256 timeStarted;
        bool canPlay;
        uint256 reward;
        uint256 Total_AllTime_Reward;
    }
    // State Variables from original EatTheBop Contract
    mapping (address => Hoarder) public hoarders;
    uint256 timeStarted;
    uint256 public points = 0;
    uint256[] public nums;
    mapping(address => uint256) public life;
    uint public reward = 6000000000000000000000; //Should reward 6000 BOP tokens
    ERC20 public gameToken;
    uint256 public Total_Reward_Pool;

    event Result(address player, uint256 num, bool isWinner);
    event Pooled(address indexed user, uint256 amount);
    
   

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    constructor()
        ConfirmedOwner(msg.sender)
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {
    gameToken = ERC20(0x76f9d116a4263b0b193E3174bC5b52946B10548b);  //gameToken must be deployed and the address added here
    }
     /**
     * Hoarder must buy lifes to play game 
     user gets 6 lifes for 0.01 ether or native network token
     */
    function playGame() public payable {
        require(msg.value >= 0.01 ether, "Failed to send enough value");
        //require(address(this).balance >= reward, "Not enough reward"); // Uncomment if you want to use ETH reward
        require(gameToken.balanceOf(address(this)) >= reward, "The contract does not have enough tokens to give you the reward");
        /*Above we require that the contract has BOP tokens to reward before hoarders can play*/
        life[msg.sender] += 6; //Hoarders can buy 6 lifes at a time
    }
    /**
     * View the latest random number generated
     */
    function viewLatestRandomNumber() external view returns (uint256) {
        return randomResult;
    }
    //The main function we will buidl on for EatTheBop
    function eatTheBop()
        public 
        returns (uint256 requestId)
    {
        require(life[msg.sender] > 0, "Out of life"); //Required to have lifes to play
        nums.push(randomResult); //pushes our random number to a array to see past numbers

        bool isWinner = false; //Not a winner
        /**Here we set the winning number to 6 following the Project 6 model*/
        if (randomResult == 6) {
            isWinner = true;
        // Function to transfer reward for finding the real BOP token
        require(gameToken.balanceOf(address(this)) >= reward, "The contract does not have enough tokens to give you the reward");
        gameToken.transfer(msg.sender, reward); //tranfers BOP tokens to winner address
        Total_Reward_Pool -= reward; //decrements the rewards pool when a hoarder wins
        hoarders[msg.sender].Total_AllTime_Reward += reward; //updates Hoarders All Time Reward tracking
        points += 1; //increments when a real BOP token is found
        }

        else if (randomResult < 5) {
            life[msg.sender] -= 1;
        }

        emit Result(msg.sender, randomResult, isWinner);
    //The rest of the function is VRF code
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
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
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        randomResult = _randomWords[0] % maximum + 1;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getRequestStatus(
        uint256 _requestId
    )
        external
        view
        returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
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

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

        /**
     * Function to withdraw accumulated ETH only by the owner
     */
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * Receive function to receive Ether
     */
    receive () external payable {}
}

