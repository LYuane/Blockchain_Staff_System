pragma solidity ^0.4.14;

contract payRoll{
    uint salary = 1 ether;
    address frank = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c; //固定地址，硬编码
    uint payDuration = 30 days;
    uint lastPayday = now;
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    function calculatRunway() returns (uint){
        return this.balance / salary ;
    }
    
    function hasEnoughFund() returns(bool){
        return this.balance >= salary ;
        // return this.calculatRunway() > 0 ;
    }
    
    function getPaid(){
        //确保发送人为frank
        if(msg.sender != frank){
            revert();
        } 
        
        //注意局部变量作用域 与js类似  不同于java
        uint nextPayDay = lastPayday + payDuration;
        if(nextPayDay > now){
            revert();//回滚代码  交还剩余gas
        }
        lastPayday = nextPayDay;
        frank.transfer(salary);  // 一定要修改完变量再给钱
    }
    
}