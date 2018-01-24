pragma solidity ^0.4.11;

import "./player.sol";

contract HoldingUnit is Player {

  uint[] public day_number = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  uint public nowyear = 1970;
  uint public nowmonth;
  uint public nowday;


  event New(uint number, string name, address holding_addr, uint year, uint month, uint day, uint amount, uint now_y, uint now_m, uint now_d);


  function HoldingUnit() public {
  	now_day();
  }


  //把now轉成日期
  function now_day(){
    uint x = now;
    
    //算是西元多少年
    while(x >= 60*60*24*365){
        if(nowyear%4 == 0){
            if(x >= 60*60*24*366){
                x -= 60*60*24*366;
                nowyear+= 1;
            }else{break;}
        }else{
            x -= 60*60*24*365;
            nowyear+= 1;
        }
    }
    
    //算是幾月幾日
    for(uint i = 1; i<=12; i++){
        if(i == 2 && nowyear%4 == 0){day_number[2] = 29;}
        
        if(x > 60*60*24*day_number[i]){
            x-= 60*60*24*day_number[i];
        }else{
            nowmonth = i;
            nowday = 1 + x/(60*60*24);
            break;
        }
    }
  }

   //是否在有效期內（即now<日期）
  function intime(uint year, uint month, uint day) public returns (bool){
      
    //判斷不合理的日期
    if(year <1 || month <1 || month >12 || day <1 || (day > day_number[month] && month != 2) || (year%4 == 0 && month == 2 && day >29) || (year%4 != 0 && month == 2 && day >28)) return false;
    
    //判斷輸入的是否比now還大（不然就是過期票）
    if(year > nowyear){return true;}
    else{ 
        if(year == nowyear){
            if(month > nowmonth){return true;}
            else{
                if(month == nowmonth){
                    if(day >= nowday){return true;}else{return false;}
                }else{return false;}
            }
          }else{return false;}
    }
    
  }


  //建立新票
  function add(uint number, string name, uint year, uint month, uint day, uint amount){
  	if(intime(year, month, day) && amount > 0){
  		balances[msg.sender] = ticket(number, name, msg.sender, year, month, day, amount);

  		New(number, name, msg.sender, year, month, day, amount, nowyear, nowmonth, nowday);
  	}
  }
}