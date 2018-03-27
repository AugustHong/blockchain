pragma solidity ^0.4.11;

contract Ticket{

  address[] minter;

  //票卷的資料
  string public activity_name;
  uint public start_time;
  uint public end_time;
  uint public price;
  string holding;
  string owner;


  //看是否建置過（沒建置過不能set，且只能建置一次）
  bool public is_build = false;

  //時間相關處理
  uint nowyear = 1970;
  uint nowmonth;
  uint nowday;
  uint[] day_number = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  //相關event
  event Build(string activity_name, uint s_time, uint e_time, uint price, string holding, uint n_time);
  event Set_time(uint s_time, uint e_time, uint n_time);
  event Set_price(uint money, uint n_time);
  event Transaction(string data, uint n_time);



  function Ticket(){
    minter.push(msg.sender);
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
      
    if(date_is_error(year, month, day) == false){return false;}
    
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

  //將數字format並且看要選擇檢查哪一個
  function date_format_check(uint time, uint num) public returns (bool){
    require(num >= 0 && num <= 1 && time >=0);

    uint year;
    uint month;
    uint day;

    year = time / 10000;
    month = (time - year * 10000) / 100;
    day = (time - year * 10000 - month * 100);

    if (num == 0){
      return date_is_error(year, month, day);  //檢查是否有日期錯誤
    }else{
      return intime(year, month, day);  //檢查是否比現在時間還大
    }
    
  }

  //判斷日期的合理
  function date_is_error(uint year, uint month, uint day) public returns (bool){
    //判斷不合理的日期
    if(year <1 || month <1 || month >12 || day <1 || (day > day_number[month] && month != 2) || (year%4 == 0 && month == 2 && day >29) || (year%4 != 0 && month == 2 && day >28)) {return false;} else {return true;}
  }

  //字串比較
  function string_match(string a, string b) public returns (bool){
    require(bytes(a).length == bytes(b).length);

    uint x = 0;
    for(uint i = 0; i < bytes(a).length ; i++){
      if(bytes(a)[i] != bytes(b)[i]){x = 1; break;}
    }

    if(x == 0){return true;}else{return false;}
  }

  //假設兩字串長度皆相同（這只是讓存到區塊上的資料不會一眼就會到資料而做的處理）
  function interlock_str(string a, string b) public returns (string){
    string z;
    bytes(z).length = bytes(a).length + bytes(b).length;

    for(uint i = 0; i < bytes(a).length; i = i + 1){
      bytes(z)[i * 2] = bytes(a)[i];
      bytes(z)[i * 2 + 1] = bytes(b)[i];
    }

    return z;
  }


  //建立票卷
  function build(string name, uint s_time, uint e_time, uint p, string h) public returns (bool){

    require(minter[0] == msg.sender && p >=0 && s_time >=0 && e_time >=0 && e_time >= s_time && date_format_check(s_time, 0) && date_format_check(e_time, 0) && date_format_check(e_time, 1) && is_build == false);

    activity_name = name;
    start_time = s_time;
    end_time = e_time;
    price = p;
    holding = h;
    owner = h;

    is_build = true;

    Build(name, s_time, e_time, p, h, nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //修改時間
  function set_time(uint s_time, uint e_time) public returns (bool){
    require(minter[0] == msg.sender && s_time >=0 && e_time >=0 && e_time >= s_time && date_format_check(s_time, 0) && date_format_check(e_time, 0) && date_format_check(e_time, 1) && is_build == true);

    start_time = s_time;
    end_time = e_time;

    Set_time(s_time, e_time, nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //修改價錢
  function set_price(uint money) public returns (bool){
    require(minter[0] == msg.sender && money >=0 && is_build == true);

    price = money;

    Set_price(money, nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //所有權轉移
  function transaction(string original_owner, string now_owner) public returns (bool){
    require(minter[0] == msg.sender && string_match(original_owner, owner) && is_build == true);

    owner = now_owner;

    Transaction(interlock_str(original_owner, owner), nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //得到holding和owner（較為隱密，所以用函式取得，而不在變數前加上public） => 0=holding，1=owner
  function get_data(uint num) public returns (string){
    require(minter[0] == msg.sender && num >=0 && num <=1 && is_build == true);

    if(num == 0){return holding;}
    if(num == 1){return owner;}
  }


  //銷毀合約
  function kill() returns (bool){
    if(msg.sender == minter[0]){selfdestruct(minter[0]); return true;} else {return false;}
  }

}
