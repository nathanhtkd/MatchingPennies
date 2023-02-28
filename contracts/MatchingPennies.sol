pragma solidity ^0.8.0;

contract MatchingPennies {
    address public player1;
    address public player2;
    uint256 public reward;
    uint256 public player1Choice;
    uint256 public player2Choice;

    function joinGame() public payable {
        require(
            player1 == address(0x0) || player2 == address(0x0),
            "Game is full"
        );
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

    function play(uint256 choice) public {
        require(
            msg.sender == player1 || msg.sender == player2,
            "You are not a player"
        );
        require(
            player1 != address(0x0) && player2 != address(0x0),
            "Game is not full"
        );
        require(choice == 0 || choice == 1, "Invalid choice");

        if (msg.sender == player1) {
            player1Choice = choice;
        } else {
            player2Choice = choice;
        }

        if (player1Choice != 0 && player2Choice != 0) {
            if (player1Choice == player2Choice) {
                payable(player1).transfer(reward);
            } else {
                payable(player2).transfer(reward);
            }

            // Reset game
            player1Choice = 0;
            player2Choice = 0;
            player1 = address(0x0);
            player2 = address(0x0);
            reward = 0;
        }
    }
}
