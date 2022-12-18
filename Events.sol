// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Events{
    struct Event{
        address organiser;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextId;

    function createEvent(string memory _name, uint _date, uint _price, uint _ticketCount) external{
        require(_date>block.timestamp,"You can organize event for future date");
        require(_ticketCount>100,"You can organize event only if you create more than 100 tickets");

        events[nextId] = Event(msg.sender, _name, _date, _price, _ticketCount, _ticketCount);
        nextId++;
    }

    function buyTicket(uint id, uint quantity) external payable{
        require(events[id].date!=0,"This event does not exist");
        require(events[id].date > block.timestamp,"Event has already occured");

        Event storage _event = events[id];
        require(msg.value == (_event.price*quantity), "Ether is not enough");
        require(_event.ticketRemain >= quantity, "Not enough tickets");
        _event.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint id, uint quantity, address to) external{
        require(events[id].date!=0,"This event does not exist");
        require(events[id].date > block.timestamp,"Event has already occured");
        require(tickets[msg.sender][id] >= quantity, "You do not have enough tickets");
        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }

}
