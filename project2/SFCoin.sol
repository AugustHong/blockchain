pragma solidity ^0.4.11;

contract SFCoin{
  address[] public minter;

  //貨幣基本資訊（分別為貨幣名稱、貨幣代號、貨幣目前流通上限）
  string public name = "SFCoin";
  string public symbol = "SF@";
  uint public max_supply;

  mapping (address => uint) public balances;

  event Transfer(address from, address to, uint amount);

  function SFCoin(){
    minter.push(msg.sender);
  }

  //發行貨幣
  function mint(uint amount) returns (bool success){
    require(minter[0] == msg.sender && amount >0);

    balances[minter[0]] += amount;
    max_supply += amount;
    
    return true;
  }

  //自行送貨幣
  function transfer(address receiver, uint amount) returns (bool success){
    require(balances[msg.sender] >= amount && amount > 0);

    balances[msg.sender] -= amount;
    balances[receiver] += amount;
    Transfer(msg.sender,receiver,amount);

    return true;
  }

  //第三人送貨幣
  function transfer(address from, address receiver, uint amount) returns (bool success){
    require(balances[from] >= amount && amount > 0);

    balances[from] -= amount;
    balances[receiver] += amount;
    Transfer(from,receiver,amount);

    return true;
  }


  //查餘額
  function balancesOf(address _account) constant returns (uint){
    return balances[_account];
  }

}
