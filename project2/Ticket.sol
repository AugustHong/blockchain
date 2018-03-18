pragma solidity ^0.4.11;

contract Ticket{

  //票的結構
  struct Ticket_content{
    address holding;
    address owner;
    uint year;
    uint month;
    uint day;
    uint price;
  }

  mapping (string => Ticket_content[]) data;

  uint nowyear = 1970;
  uint nowmonth;
  uint nowday;
  uint[] day_number = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];


  event New(address holding_address, string activity_name, uint year, uint month, uint day, uint amount, uint price, uint t_year, uint t_month, uint t_day);
  event transaction(address from, address receiver, string activity_name, uint number);  //此number是使用者口中的Number
  event Modify(string activity_name, uint start, uint end, uint price);  //此的start和end是使用者口中的數字（所以處理時再減1）

  function Ticket(){
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


  //新增票卷
  function newticket(string activity_name, uint year, uint month, uint day, uint price, uint amount) returns (bool success){
    require(intime(year, month, day) && amount > 0 && price >0);

    uint x;
    if(data[activity_name].length <=0){x = 0;}else{x = data[activity_name].length;}

    for(uint i = x ; i < x + amount; i++){
        data[activity_name].push(Ticket_content(msg.sender, msg.sender, year, month, day, price));
    }

    New(msg.sender, activity_name, year, month, day, price, amount, nowyear, nowmonth, nowday);    

    return true;
  }


  //修改票卷價錢（此邊的start和end是使用者輸入第幾張票=>所以要做時要減1才會是陣列）
  function modify_price(string activity_name, uint start, uint end, uint price) returns (bool success){
    require(start > 0 && end > 0 && end >= start && data[activity_name].length >= end && price >0 && msg.sender == data[activity_name][i].holding);

    for(uint i = start -1; i < end ; i++){
	data[activity_name][i].price = price;
    }

    Modify(activity_name, start, end, price);    

    return true;
  }


  //查詢這張票幾號是空的
  function search_empty(string activity_name) returns (uint number){
    require(data[activity_name].length >0);

    uint x;

    for(uint i = 0; i < data[activity_name].length; i++){
        if(data[activity_name][i].owner == data[activity_name][i].holding){
            x = i+1;
            break;
        }
    }

    return x;
  }


  //驗票（確認這張票是使用者的，記得使用者輸入的都是第幾張，所以做處理時都要再減1才是陣列的號碼）
  function check(string activity_name, uint number) returns (bool is_owner){
    require(number > 0 && data[activity_name].length + 1 >= number);

    if(data[activity_name][number-1].owner == msg.sender){
        return true;
    }else{return false;}

  }


  //轉移票卷（此的number仍然是使用者口中的數字，所以要做處理時要再減1）
  function transaction_ticket(address from, address receiver, string activity_name, uint number) returns (bool success) {
    require(data[activity_name].length >0 && data[activity_name][number-1].owner == from && number >0 && data[activity_name].length +1 >= number);

    data[activity_name][number-1].owner = receiver;

    transaction(from, receiver, activity_name, number);

    return true;
  }



}
