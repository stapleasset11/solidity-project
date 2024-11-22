// SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;


contract CryptoKids {
    // Owner: Dad

    address owner;

    event logKidFundingReceived(address addr,uint amount,uint contractBalnce);

    constructor () {
        owner = msg.sender;
    }

    // Define Kid Object

    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;

    }

    Kid[] public kids;

    modifier onlyOwner() {
        require(msg.sender == owner,"Only the owner can add kids to this contract");
        _;
    }

    // Add Kid to Contract

    function addKid(address payable walletAddress,string memory firstName,string memory lastName,uint releaseTime,uint amount,bool canWithdraw) public onlyOwner {
        kids.push(Kid(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            amount,
            canWithdraw));

        

    } 
    function balanceOf () public view returns (uint) {
        return address(this).balance;
    }

    //Deposit funds to Contract, Specifically to the Kid's account.

    function deposit (address walletAddress) payable  public {
        addToKidsBalance(walletAddress);

    }

    function addToKidsBalance(address walletAddress) private {
        for (uint i = 0;i < kids.length; i++){
            if (kids[i].walletAddress == walletAddress){
                kids[i].amount += msg.value;
                emit logKidFundingReceived(walletAddress,msg.value,balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint){
        for (uint i = 0; i < kids.length;i++){
            if (kids[i].walletAddress == walletAddress){
                return i;
            }
        }
        return 404;
    }
    // Check if kid is able to withdraw.
    function availableToWithdraw(address walletAddress) public  returns(bool){
        uint i = getIndex((walletAddress));
        require(block.timestamp > kids[i].releaseTime,"You aren't permitted to withdraw at this time");
        if (block.timestamp > kids[i].releaseTime){
            kids[i].canWithdraw = true;
            return true;
        }

        else {
            return  false;
        }
    }

    // Kid withdraws the mmoney.

    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require (msg.sender == kids[i].walletAddress,"You can only withdraw you own Ether");
        require(kids[i].canWithdraw == true,"You aren't permitted to withdraw at this time");
        kids[i].walletAddress.transfer(kids[i].amount);

    }

}
