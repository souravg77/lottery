// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LotteryRoundHistory {
    // Struct to represent a lottery round
    struct LotteryRound {
        uint256 roundNumber;
        uint256 timestamp;
        address winner;
        uint256 potSize;
        bool completed;
    }

    // Mapping to store lottery rounds
    mapping(uint256 => LotteryRound) public lotteryRounds;
    uint256 public totalRounds;

    // Event to log new round creation
    event RoundCreated(
        uint256 indexed roundNumber, 
        uint256 timestamp, 
        uint256 potSize
    );

    // Event to log round completion
    event RoundCompleted(
        uint256 indexed roundNumber, 
        address winner, 
        uint256 potSize
    );

    /**
     * @dev Create a new lottery round
     * @return The round number of the newly created round
     */
    function createNewRound() internal returns (uint256) {
        totalRounds++;
        LotteryRound storage newRound = lotteryRounds[totalRounds];
        newRound.roundNumber = totalRounds;
        newRound.timestamp = block.timestamp;
        newRound.completed = false;

        emit RoundCreated(totalRounds, block.timestamp, 0);
        return totalRounds;
    }

    /**
     * @dev Complete a lottery round and record the winner
     * @param roundNumber The round number to complete
     * @param winner The address of the round winner
     * @param potSize The total pot size for the round
     */
    function completeRound(
        uint256 roundNumber, 
        address winner, 
        uint256 potSize
    ) internal {
        require(roundNumber > 0 && roundNumber <= totalRounds, "Invalid round number");
        require(!lotteryRounds[roundNumber].completed, "Round already completed");

        LotteryRound storage round = lotteryRounds[roundNumber];
        round.winner = winner;
        round.potSize = potSize;
        round.completed = true;

        emit RoundCompleted(roundNumber, winner, potSize);
    }

    /**
     * @dev Fetch details of a specific lottery round
     * @param roundNumber The round number to retrieve
     * @return A tuple containing round details
     */
    function getLotteryRound(uint256 roundNumber) 
        public 
        view 
        returns (
            uint256 _roundNumber,
            uint256 _timestamp,
            address _winner,
            uint256 _potSize,
            bool _completed
        ) 
    {
        require(roundNumber > 0 && roundNumber <= totalRounds, "Round does not exist");
        
        LotteryRound memory round = lotteryRounds[roundNumber];
        
        return (
            round.roundNumber,
            round.timestamp,
            round.winner,
            round.potSize,
            round.completed
        );
    }

    /**
     * @dev Get the total number of lottery rounds
     * @return Total number of rounds
     */
    function getTotalRounds() public view returns (uint256) {
        return totalRounds;
    }
}