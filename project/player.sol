pragma solidity ^0.4.11;

contract Player{


  struct ticket{      //票的結構
    uint number;     //編號
    string activity_name;
    address hodingunit_address;
    uint expire_year;
    uint expire_month;
    uint expire_day;
    uint amount;
  }


  mapping(address => ticket) balances;


  event Sent(address from, address to, uint amount);


  function Player(){
      balances[msg.sender] = ticket(0, "", 0x0000000000000000000000000000000000000000, 0, 0, 0, 0);
  }


  //送票
  function send(address receiver, uint amount) public {
    require(receiver != msg.sender);
    require(balances[msg.sender].amount >=  amount);
    balances[msg.sender].amount -= amount;
    
    if(balances[receiver].number == 0){
        balances[receiver].number = balances[msg.sender].number;
        balances[receiver].activity_name = balances[msg.sender].activity_name;
        balances[receiver].hodingunit_address = balances[msg.sender].hodingunit_address;
        balances[receiver].expire_year = balances[msg.sender].expire_year;
        balances[receiver].expire_month = balances[msg.sender].expire_month;
        balances[receiver].expire_day = balances[msg.sender].expire_day;
        balances[receiver].amount = amount;
    }else{
        balances[receiver].amount += amount;
    }

    Sent(msg.sender, receiver, amount);
  }


  //查餘額
  function balanceOf(address account) public returns(uint num, string name, address HU_addr, uint y, uint m, uint d, uint amount){
    num = balances[account].number;
    name = balances[account].activity_name;
    HU_addr = balances[account].hodingunit_address;
    y = balances[account].expire_year;
    m = balances[account].expire_month;
    d = balances[account].expire_day;
    amount = balances[account].amount;
  }

}