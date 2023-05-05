pragma solidity ^0.8.0;

contract LoanManager {

    enum LoanState{
        Active,
        Paid,
        Late,
        Defaulted,
        Cancelled
    }


    struct Loan {
        address borrower;
        address payable lender;
        uint amount;
        uint256 interestRate;
        uint duration;
        uint256 startDate;
        uint256 endDate;
        uint256 totalAmount;
        uint256 remainingAmount;
        LoanState state;
    }

    Loan[] public loans;


    modifier onlyExistLoan(uint _loanId) {
        require(_loanId < loans.length, "Invalid loan ID");
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



    function createLoan(address _borrower, uint _interestRate, uint _duration) public payable{
        require(_borrower != address(0), "Invalid borrower address");
        require(msg.value > 0, "Loan amount must be greater than zero");
        require(_interestRate > 0, "Interest rate must be greater than zero");
        require(_duration > 0, "Loan duration must be greater than zero");

        uint totalAmount = msg.value + ((msg.value * _interestRate) / 100);
        uint startTime = block.timestamp;
        uint endTime = startTime + (_duration * 1 days);

        loans.push(Loan({
            borrower: _borrower,
            lender: payable(msg.sender),
            amount: msg.value,
            interestRate: _interestRate,
            duration: _duration,
            startDate: startTime,
            endDate: endTime,
            totalAmount: totalAmount,
            remainingAmount: totalAmount,
            state: LoanState.Active
        }));

    }

    function cancelLoan(uint _loanId) public onlyExistLoan(_loanId) onlyValidState(_loanId, LoanState.Active)  onlyBorrower(_loanId) {
        loans[_loanId].state = LoanState.Cancelled;
    }

    function repayLoan(uint _loanId) public payable onlyValidState(_loanId, LoanState.Active) onlyExistLoan(_loanId)  onlyBorrower(_loanId){

        require(msg.value > 0 && msg.value <= loans[_loanId].remainingAmount, "Invalid repayment amount");

        uint penalty = 0;
        if (block.timestamp > loans[_loanId].endDate) {
            penalty = ((loans[_loanId].totalAmount * 10) / 100); // penalty of 10% of the total amount
            loans[_loanId].state = LoanState.Defaulted;
        } else if (block.timestamp > (loans[_loanId].endDate - 1 days)) {
            penalty = ((loans[_loanId].totalAmount * 5) / 100); // penalty of 5% of the total amount
            loans[_loanId].state = LoanState.Late;
        }

        uint amountToRepay = msg.value;
        if(penalty> 0){
            amountToRepay += penalty;
        }

        loans[_loanId].remainingAmount -= msg.value;

        if(loans[_loanId].remainingAmount <= 0){
            loans[_loanId].state = LoanState.Paid;
        }

        loans[_loanId].lender.transfer(amountToRepay);

    }


    function getLoan(uint256 _loanId) public view onlyExistLoan(_loanId) returns(
        address borrower,
        address lender,
        uint amount,
        uint256 interestRate,
        uint duration,
        uint256 startDate,
        uint256 endDate,
        uint256 totalAmount,
        uint256 remainingAmount,
        LoanState state

    ){

        Loan storage loan = loans[_loanId];
        borrower = loan.borrower;
        lender = loan.lender;
        amount = loan.amount;
        duration = loan.duration;
        interestRate = loan.interestRate;
        startDate = loan.startDate;
        endDate = loan.endDate;
        totalAmount = loan.totalAmount;
        remainingAmount = loan.remainingAmount;
        state = loan.state;

    }



}