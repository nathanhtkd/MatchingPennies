pragma solidity >= 0.7.0 < 0.9.0;

import "hardhat/console.sol";

contract MatchingPennies {
    // address variables to keep track of player's address
    address public player1;
    address public player2;
    address public winner;
    
    // variable to store the reward for the winner
    uint256 public reward;

    // variables to store player's choice, PRIVATE so participants cannot view other's answers
    string private player1Choice;
    string private player2Choice;

    // to join game, must commit .1 ether or 100 finney to play
    function joinGame() public payable {
        require(player1 == address(0x0) || player2 == address(0x0), "Game is full");
        require(msg.sender != player1, "You can't play against yourself!");
        // msg.value represents amount of ether sent with a message
        require(msg.value == 0.1 ether, "Please bet 0.1 ETH (100 finney) to enter the game");

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
            require(bytes(player1Choice).length == 0, "You have already made a choice!");
            player1Choice = choice;
        } else {
            require(bytes(player2Choice).length == 0, "You have already made a choice!");
            player2Choice = choice;
        }

        // p1 wins if choices are the same, otherwise p2 wins
        // MAKE SURE TO CHECK IF BOTH STRINGS HAVE BEEN FILLED
        if (bytes(player1Choice).length != 0 && bytes(player2Choice).length != 0) {
            console.log("Player 1's Choice was ", player1Choice);
            console.log("Player 2's Choice was ", player2Choice);
            if (keccak256(abi.encodePacked(player1Choice)) == keccak256(abi.encodePacked(player2Choice))) {
                // payable(player1).transfer(reward);
                winner = player1;
                console.log("Player 1 won! Withdraw your reward!");
            } else {
                // payable(player2).transfer(reward);
                winner = player2;
                console.log("Player 2 won! Withdraw your reward!");
            }
        }
    }

    // pull over push design to prevent reentrancy attacks
    function withdrawReward() public {
        require(winner != address(0x0), "A winner has not been decided yet!");
        require(msg.sender == winner, "You are not the winner!");

        player1Choice = "";
        player2Choice = "";
        player1 = address(0x0);
        player2 = address(0x0);
        
        payable(winner).transfer(reward);

        // Reset game, set states to invalid/default
        winner = address(0x0);
        reward = 0;
    }
}
