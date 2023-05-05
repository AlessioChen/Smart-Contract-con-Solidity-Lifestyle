pragma solidity ^0.8.0;

contract LoanManager {

    enum LoanState{
        Requested,
        Active,
        Paid,
        Expired,
        Cancelled
    }

    struct Loan {
        address borrower;
        address lender;
        uint256 interestRate;
        uint256 startDate;
        uint256 dueDate;
        uint256 amount;
        uint256 amountPaid;
        LoanState state;
    }

    mapping (uint256 => Loan) public loans;
    uint256 public loanCounter;

    modifier onlyExistLoan(uint256 loanId) {
        require(loanId > 0 && loanId <= loanCounter, "Loan does not exist");
        _;
    }

    modifier onlyValidState(uint256 loanId, LoanState state) {
        require(loans[loanId].state == state, "Invalid loan state");
        _;
    }

    modifier onlyBorrower(uint256 loanId) {
        require(msg.sender == loans[loanId].borrower, "Only borrower can call this function");
        _;
    }

    modifier onlyLender(uint256 loanId) {
        require(msg.sender == loans[loanId].lender, "Only lender can call this function");
        _;
    }


    function requestLoan(address _lender, uint256 _amount, uint256 _interestRate, uint256 _duration) public{
        require(_amount > 0, "Loan amount must be grater than zero.");
        require(_interestRate > 0, "Interest rate must be grater than zero.");

        uint256 endTime = block.timestamp + _duration;
        loans[loanCounter] = Loan(
            msg.sender,
            _lender,
            _interestRate,
            block.timestamp,
            endTime,
            0,
            0,
            LoanState.Requested
        );

        loanCounter++;

    }

    function cancelLoan(uint _loanId) public onlyExistLoan(_loanId) onlyValidState(_loanId, LoanState.Requested)  onlyBorrower(_loanId) {
        loans[_loanId].state = LoanState.Cancelled;
    }

    function approveLoan(uint256 _loanId) public payable onlyExistLoan(_loanId) onlyValidState(_loanId, LoanState.Requested) onlyLender(_loanId){
        require(msg.value == loans[_loanId].amount, "Amount sent must match loan amount.");
        loans[_loanId].state = LoanState.Active;
    }

    function getLoan(uint256 _loanId) public view onlyExistLoan(_loanId) returns(
        address borrower,
        address lender,
        uint256 interestRate,
        uint256 startDate,
        uint256 dueDate,
        uint256 amount,
        uint256 amountPaid,
        LoanState state

    ){

        Loan storage loan = loans[_loanId];
        borrower = loan.borrower;
        lender = loan.lender;
        amount = loan.amount;
        interestRate = loan.interestRate;
        startDate = loan.startDate;
        dueDate = loan.dueDate;
        amount = loan.amount;
        amountPaid = loan.amountPaid;
        state = loan.state;

    }



}