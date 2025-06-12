// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./VRFv2DirectFundingConsumer.sol";

contract Lottery is ConfirmedOwner, VRFv2DirectFundingConsumer {
    using SafeMath for uint256;

    struct RoundInfo {
        uint256 roundId;
        uint256 timestamp;
        address winner;
        uint256 potSize;
        uint256 playerCount;
    }

    address payable[] public players;
    address[] public winners;
    uint256 public lotteryId;
    uint256 public potWidthdrawalEndTime;

    // Store round history mapping
    mapping(uint256 => RoundInfo) public roundHistory;

    event PlayerEntered(address indexed player, uint256 amount);
    event WinnerPicked(address indexed winner, uint256 amount);
    event LotteryReset(uint256 indexed lotteryId);
    event Received(address, uint);

    constructor() VRFv2DirectFundingConsumer() {
        lotteryId = 1;
        potWidthdrawalEndTime = block.timestamp;
    }

    // Existing methods remain the same...

    function finishPickingWinner(uint256 _randomNumber) internal {
        uint256 randomPlayerIndex = _randomNumber % players.length;
        address payable winner = players[randomPlayerIndex];
        uint256 pot = address(this).balance;
        winners.push(winner);

        // Store round history
        roundHistory[lotteryId] = RoundInfo({
            roundId: lotteryId,
            timestamp: block.timestamp,
            winner: winner,
            potSize: pot,
            playerCount: players.length
        });

        lotteryId = lotteryId.add(1);

        emit WinnerPicked(winner, pot);
        emit LotteryReset(lotteryId);

        players = new address payable[](0);
        potWidthdrawalEndTime = block.timestamp + 10 minutes;
    }

    // New method to retrieve round history
    function getRoundHistory(uint256 _roundId) public view returns (RoundInfo memory) {
        require(_roundId > 0 && _roundId < lotteryId, "Invalid round ID");
        return roundHistory[_roundId];
    }

    // Method to get total number of rounds
    function getTotalRounds() public view returns (uint256) {
        return lotteryId - 1;
    }
}