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


  mapping(address => ticket[]) balances;


  event Sent(address from, address to, uint amount);


  function Player(){

  }


  //資料是否存在
  function isexist(address from, uint number) public returns (uint){
      uint register = 10000;
      for(uint i = 0; i < balances[from].length; i++){
          if(number == balances[from][i].number){register = i; break;}
      }
      
      return register;
  }


  //送票
  function send(address receiver, uint number, uint amount) public {
    require(receiver != msg.sender);
    uint sender_exist = isexist(msg.sender, number);
    require((sender_exist != 10000) && (balances[msg.sender][sender_exist].amount >=  amount));
    balances[msg.sender][sender_exist].amount -= amount;
    
    uint receiver_exist = isexist(receiver, number);
    if(receiver_exist == 10000){
        balances[receiver].push(ticket(number, balances[msg.sender][sender_exist].activity_name, balances[msg.sender][sender_exist].hodingunit_address, balances[msg.sender][sender_exist].expire_year, balances[msg.sender][sender_exist].expire_month, balances[msg.sender][sender_exist].expire_day, amount));
    }
    else{
        balances[receiver][receiver_exist].amount += amount;
    }

    Sent(msg.sender, receiver, amount);
  }


  //查餘額
  function balanceOf(address account, uint number) public returns(uint num, string name, address HU_addr, uint y, uint m, uint d, uint amount){
    uint exist = isexist(account, number);

    if (exist != 10000){
      num = balances[account][exist].number;
      name = balances[account][exist].activity_name;
      HU_addr = balances[account][exist].hodingunit_address;
      y = balances[account][exist].expire_year;
      m = balances[account][exist].expire_month;
      d = balances[account][exist].expire_day;
      amount = balances[account][exist].amount;
    }else{
      num = 0;
      name = "";
      HU_addr = 0x0000000000000000000000000000000000000000;
      y = 0;
      m=0;
      d=0;
      amount = 0;
    }
  }

}