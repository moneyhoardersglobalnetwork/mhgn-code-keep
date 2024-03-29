// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// AutomationCompatible.sol imports the functions from both ./AutomationBase.sol and
// ./interfaces/AutomationCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
    function balanceOf(address account) external returns (uint);  
}

contract MHGDAuto is AutomationCompatibleInterface {

    uint256 public amountToken;
    address public to;
    TokenInterface public token;

    uint public counter;
    uint public immutable interval;
    uint public lastTimeStamp;

    constructor(uint updateInterval, address tokenMinter) {
        token = TokenInterface(tokenMinter);
        to = msg.sender;
        amountToken = 100;

        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        counter = 0;
    }

    function mint() public returns (bool) {
        token.mint(to, amountToken);
        return true;
    } 
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            counter = counter + 1;
            mint();
        }
        // We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function
    }
}