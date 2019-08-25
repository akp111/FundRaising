pragma solidity ^0.4.24;

contract FundRaising{
    
    
    mapping(address=>uint) public Contributors;
    address public admin;
    uint public noOfContributors;
    uint public minContributions;
    uint public deadline;
    uint public goal;
    uint public raisedAmonut=0;
    
    constructor(uint _goal, uint _deadline) public{
        goal=_goal;
        deadline=now +_deadline ;
        admin=msg.sender;
        minContributions=10;
        
    }
    struct Request{
        
        string description;
        address recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    Request [] public requests;
    
    modifier onlyAdmin(){
        require(msg.sender==admin);
        _;
    }
    
    event ContributeEvent(address sender,uint value);
    event CreateRequestEvent(string _description,address _recipient,uint _value);
    event MakePaymentEvent(address recipient,uint value);
    
    
    function contribute() public payable{
        
        require(now<deadline);
        require(msg.value>minContributions);
        if(Contributors[msg.sender]==0)
        {
            noOfContributors++;
        }
        raisedAmonut+=msg.value;
        Contributors[msg.sender]+=msg.value;
        
        emit ContributeEvent(msg.sender,msg.value);
    }
    function getBalance() public view returns(uint){
        return address(this).balance ;
        
    }
    function getRefund() public {
        require(now>deadline);
        require(Contributors[msg.sender]>0);
        require(raisedAmonut<goal);
        address recipient=msg.sender;
        uint amount=Contributors[msg.sender];
        recipient.transfer(amount);
        
        Contributors[msg.sender]=0;
        
    }
    function createRequest( string _description, address _recipient,uint _value)public onlyAdmin{
        Request memory newRequest=Request// must use memory keyword
        ({
            description : _description,
            recipient : _recipient,
            value : _value,
            completed : false,
            noOfVoters : 0
            
            });
            requests.push(newRequest);
            emit CreateRequestEvent(_description,_recipient,_value);
    }
    
    function voteRequest(uint index) public {
        
        Request storage thisRequest = requests[index];
        require(Contributors[msg.sender]>0);
        require(thisRequest.voters[msg.sender]==false);
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
        
    }
    
    function makePayment(uint index) public onlyAdmin{
        Request storage thisRequest= requests[index];
        require(thisRequest.completed== false);
        require(thisRequest.noOfVoters>noOfContributors/2);
        thisRequest.recipient.transfer(thisRequest.value);
        
        thisRequest.completed=true;
        emit MakePaymentEvent(thisRequest.recipient,thisRequest.value);
    }
}
