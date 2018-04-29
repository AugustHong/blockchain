pragma solidity ^0.4.11;

contract Ticket{

  address[] minter;

  //票卷的資料
  string public act_id;
  string public activity_name;
  uint public start_time;
  uint public end_time;
  uint public price;
  string holding;
  string owner;
  address o_addr;


  //看是否建置過（沒建置過不能set，且只能建置一次）
  bool public is_build = false;

  //看是否已使用過
  bool public is_used = false;

  //時間相關處理
  uint nowyear = 1970;
  uint nowmonth;
  uint nowday;
  uint[] day_number = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  
  //一些處理字串用的相關變數
  string w;

  //相關event
  event Build(string id, string activity_name, uint s_time, uint e_time, uint price, uint n_time);
  event Set_time(uint s_time, uint e_time, uint n_time);
  event Set_price(uint money, uint n_time);
  event Transaction(string data, uint n_time);
  event Revoke(string id);



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

  //（這只是讓存到區塊上的資料不會一眼就會到資料而做的處理）
  function interlock_str(string a, string b) public returns (string){

    if (bytes(b).length > bytes(a).length){w = a; a = b; b=w;}  //如果長度不一樣，保持a的長度是最長的

    string z;
    bytes(z).length = bytes(a).length + bytes(b).length;

    for(uint i = 0; i < bytes(b).length; i = i + 1){
      bytes(z)[i * 2] = bytes(a)[i];
      bytes(z)[i * 2 + 1] = bytes(b)[i];
    }

    for(uint j = 0 ; j < (bytes(a).length - bytes(b).length); j++){
      bytes(z)[bytes(b).length * 2 + j] = bytes(a)[bytes(b).length + j];
    }

    return z;
  }


  //建立票卷
  function build(string name, uint s_time, uint e_time, uint p, string h, string id, address addr) public returns (bool){

    require(minter[0] == msg.sender && p >=0 && s_time >=0 && e_time >=0 && e_time >= s_time && date_format_check(s_time, 0) && date_format_check(e_time, 0) && date_format_check(e_time, 1) && is_build == false);

    act_id = id;
    activity_name = name;
    start_time = s_time;
    end_time = e_time;
    price = p;
    holding = h;
    owner = h;
    o_addr = addr;

    is_build = true;

    Build(id, name, s_time, e_time, p, nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //修改時間
  function set_time(uint s_time, uint e_time) public returns (bool){
    require(minter[0] == msg.sender && s_time >=0 && e_time >=0 && e_time >= s_time && date_format_check(s_time, 0) && date_format_check(e_time, 0) && date_format_check(e_time, 1) && is_build == true && is_used == false);

    start_time = s_time;
    end_time = e_time;

    Set_time(s_time, e_time, nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //修改價錢
  function set_price(uint money) public returns (bool){
    require(minter[0] == msg.sender && money >=0 && is_build == true && is_used == false);

    price = money;

    Set_price(money, nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }


  //所有權轉移（要變2個：owner 和 o_addr）
  function transaction(string original_owner, string now_owner, address now_addr) public returns (bool){
    require(minter[0] == msg.sender && string_match(original_owner, owner) && is_build == true && is_used == false);

    owner = now_owner;
    o_addr = now_addr;

    Transaction(interlock_str(original_owner, owner), nowyear*10000 + nowmonth*100 + nowday);

    return true;
  }

  //得到holding和owner（較為隱密，所以用函式取得，而不在變數前加上public） => 0=holding，1=owner
  function get_data(uint num) public returns (string){
    require(minter[0] == msg.sender && num >=0 && num <=1 && is_build == true);

    if(num == 0){return holding;}
    if(num == 1){return owner;}
  }

  //驗證票卷（只有票持有人可以呼叫，如果成功就會要event，就代表這票的確是他的）
  function revoke(string h_username) public {
    if(msg.sender != o_addr || string_match(owner, h_username) == false || is_build == false || is_used == true) throw;

    Revoke(act_id);
  }


  //使用票卷，所以要改變is_used的值
  function use(){
    require(minter[0] == msg.sender && is_used == false && end_time >= (nowyear*10000 + nowmonth*100 + nowday) && is_build == true && start_time <= (nowyear*10000 + nowmonth*100 + nowday));

    is_used = true;
  }

}
