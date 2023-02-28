pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MatchingPennies {
    // address variables to keep track of player's address
    address public player1;
    address public player2;
    // variable to store the reward for the winner
    uint256 public reward;
    // variables to store player's choice
    string public player1Choice;
    string public player2Choice;

    function joinGame() public payable {
        require(player1 == address(0x0) || player2 == address(0x0), "Game is full");
        require(msg.sender != player1, "You can't play against yourself!");
        // msg.value represents amount of ether sent with a message
        require(msg.value >= 0.1 ether, "Minimum bet is 0.1 ETH");

        if (player1 == address(0x0)) {
            player1 = msg.sender;
        } else {
            player2 = msg.sender;
        }

        if (player1 != address(0x0) && player2 != address(0x0)) {
            reward = 0.2 ether;
        }
    }

    function play(string memory choice) public {
        // only valid players can play
        require(msg.sender == player1 || msg.sender == player2, "You are not one of the current players!");
        // check if player address have been filled
        require(player1 != address(0x0) && player2 != address(0x0), "There is a missing player slot.");
        // choice has to be 1 or 0
        require(
            keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("a")) ||
            keccak256(abi.encodePacked(choice)) == keccak256(abi.encodePacked("b")),
            "Invalid Choice (a or b)"
        );

        if (msg.sender == player1) {
            player1Choice = choice;
        } else {
            player2Choice = choice;
        }

        // p1 wins if choices are the same, otherwise p2 wins
        // MAKE SURE TO CHECK IF BOTH STRINGS HAVE BEEN FILLED
        if (bytes(player1Choice).length != 0 && bytes(player2Choice).length != 0) {
            console.log("Player 1's Choice was ", player1Choice);
            console.log("Player 2's Choice was ", player2Choice);
            if (keccak256(abi.encodePacked(player1Choice)) == keccak256(abi.encodePacked(player2Choice))) {
                payable(player1).transfer(reward);
                console.log("Player 1 won .2 ether!");
            } else {
                payable(player2).transfer(reward);
                console.log("Player 2 won .2 ether!");
            }

            // Reset game, set states to invalid/default
            player1Choice = "";
            player2Choice = "";
            player1 = address(0x0);
            player2 = address(0x0);
            reward = 0;
        }
    }
}
