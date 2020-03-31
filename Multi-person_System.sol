pragma solidity ^0.4.23;

contract Payroll{
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
    }
    
    
   uint constant payDuration = 10 seconds;//方便测试
   
   address owner;
   Employee[] employees;
    function Payroll(){
    
    owner = msg.sender;
        
    }
    function _partialPaid(Employee employee) private{
            uint payment = employee.salary * (now - employee.lastPayday) /payDuration;//整除，不存在浮点数
            employee.id.transfer(payment);
    }
    
    function _findEmloyee(address employeeId) private returns (Employee,uint){
        for (uint i=0;i<employees.length;i++)
        {
            if (employees[i].id == employeeId){
                return (employees[i],i);
            } 
        }
    
    }
    function addEmployee(address employeeId,uint salary){
        require(msg.sender == owner);

        var (employee,index ) = _findEmloyee(employeeId); //var 任意类型
        assert(employee.id != 0x0);   //如果不存在 地址即为0x0
        
        employees.push(Employee(employeeId,salary,now));
    }
    
    function removeEmployee(address employeeId){
         require(msg.sender == owner);
         var (employee,index) = _findEmloyee(employeeId); 
         assert(employee.id != 0x0);
        _partialPaid(employees[index]);
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
}
    
    function updateEmployee(address employeeId,uint salary) {
        require(msg.sender == owner);
        //等效 
        // if (msg.sender != owner){//avoid employee cheating
        //     revert();
        // }
        
         var (employee,index) = _findEmloyee(employeeId); 
         assert(employee.id != 0x0);
        _partialPaid(employee);
        employees[index].salary = salary;
        employees[index].lastPayday = now;     
         

    }
    
    function addFund() payable returns(uint){
        return this.balance;
    }
    
    
    function calculateRunway()returns(uint)
    { 
        uint totalSalary = 0;
        for (uint i=0;i<employees.length;i++)
         {
             totalSalary += employees[i].salary; 
         } 

        return this.balance / totalSalary; 
    }
    function hasEnoughFund() returns(bool){
        // return this.balance >=salary;
        //return this.calculateRunway() > 0; //this方法 使用的gas 较多，不推荐
        //因为this会将其看为外部函数进行引用
        return calculateRunway() > 0; //vm jump 操作,使用gas较少,推荐
    }
    function getPaid (){
         var (employee,index) = _findEmloyee(msg.sender); 
         assert(employee.id != 0x0);
        uint nextPayday = employee.lastPayday + payDuration;
         //每一次运算都是真金白银~
         //原则：不重复运算！——省gas
        assert(nextPayday < now);
        // if( nextPayday > now){
        //     revert();
              //throw or revert
            //throw: 所有的gas 均会被消耗殆尽
            //revert：回滚，return没有消耗的gas
           
        // }
        
            employees[index].lastPayday = nextPayday;//原则：先修改内部变量，再给钱——》之后会讲，安全问题
            employee.id.transfer(employee.salary);

    }
}