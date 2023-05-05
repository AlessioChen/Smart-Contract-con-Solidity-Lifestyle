pragma solidity ^0.8.0;

contract LoanManager {

    enum LoanState{
        Requested,
        Active,
        Paid,
        Late,
        differentAmount,
        Cancelled
    }



    struct Loan {
        address payable borrower;
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

    function borrow(uint _amount, uint _interestRate, uint _duration) external payable {
        require(_amount > 0, "Amount should be greater than 0");
        require(_interestRate > 0, "Interest rate should be greater than 0");
        require(_duration > 0, "Duration should be greater than 0");
        require(msg.value == _amount, "Insufficient funds");

        Loan memory newLoan = Loan({
            borrower: payable(msg.sender),
            lender: payable(address(0)),
            amount: msg.value,
            totalAmount: _amount,
            duration: _duration,
            remainingAmount: _amount,
            interestRate: _interestRate,
            startDate: block.timestamp,
            endDate: block.timestamp + (_duration * 1 days),
            state: LoanState.Requested
        });

        loans.push(newLoan);
    }


    function lend(uint _loanId) external payable onlyExistLoan(_loanId) {
        Loan storage loan = loans[_loanId];
        require(loan.lender == address(0), "Loan has already been lent out");
        require(msg.value == loan.totalAmount, "Insufficient funds");

        loans[_loanId].state = LoanState.Active;

        loan.lender = payable(msg.sender);
        loan.borrower.transfer(loan.totalAmount);

    }

    function cancelLoan(uint _loanId) public onlyExistLoan(_loanId) onlyValidState(_loanId, LoanState.Requested)  onlyBorrower(_loanId) {
        loans[_loanId].state = LoanState.Cancelled;
    }

    function repayLoan(uint _loanId) public payable onlyValidState(_loanId, LoanState.Active) onlyExistLoan(_loanId)  onlyBorrower(_loanId){

        require(msg.value > 0 && msg.value <= loans[_loanId].remainingAmount, "Invalid repayment amount");

        uint penalty = 0;

        if (block.timestamp > loans[_loanId].endDate) {
            penalty = ((loans[_loanId].totalAmount * 10) / 100); // penalty of 10% of the total amount
            loans[_loanId].state = LoanState.Late;
        } else if (msg.value != loans[_loanId].totalAmount) {
            penalty = ((loans[_loanId].totalAmount * 5) / 100); // penalty of 5% of the total amount
            loans[_loanId].state = LoanState.differentAmount;
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