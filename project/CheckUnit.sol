pragma solidity ^0.4.11;

import "./player.sol";
import "./HoldingUnit.sol";

contract CheckUnit is Player{

  address public minter;

  function CheckUnit() public {
    minter = msg.sender;
  }


  //驗票（因還沒說明hash之事，故先隨便用）
  function valiate(address from, uint number){
    if(balances[from].number != number) throw;

    expire(from, balances[from].amount);
  }


  //使用過的（即send給驗票單位）
  function expire(address from, uint amount){
    Player account = Player(from);
    account.send(minter, amount);
  }
}