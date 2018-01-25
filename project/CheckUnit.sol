pragma solidity ^0.4.11;

import "./player.sol";
import "./HoldingUnit.sol";

contract CheckUnit is Player{

  address public minter;

  function CheckUnit() public {
    minter = msg.sender;
  }


  //驗票（因還沒說明hash之事，故先隨便用）
  function valiate(address from, uint number, address hold){
    uint exist = isexist(from, number);
    if (exist != 10000){
      if(balances[from][exist].hodingunit_address != hold) throw;
      expire(from, balances[from][exist].number, balances[from][exist].amount);
    }  
  }


  //使用過的（即send給驗票單位）
  function expire(address from, uint number, uint amount){
    Player account = Player(from);
    account.send(minter, number, amount);
  }
}