// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract BlindAuction {
    
    struct Bid{
        bytes32 blindedBid;
        uint deposit;
    }

    address payable public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    error TooEarly(uint time);
    error TooLate(uint time);
    error AuctionEndAlreadyCalled();

    modifier onlyBefore(uint time) {
        if (block.timestamp >= time)
            revert TooLate(time);
        _;    
    }

    modifier onlyAfter(uint time) {
        if (block.timestamp <= time) 
            revert TooEarly(time);
        _;
    }

    constructor(uint biddingTime, uint revealTime, address payable beneficiaryAddress) {
        beneficiary = beneficiaryAddress;
        biddingEnd = block.timestamp + biddingTime;
        revealEnd = biddingEnd + revealTime;
    }
        
    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(Bid({ blindedBid: blindedBid, deposit: msg.value}));
  
    }
}
