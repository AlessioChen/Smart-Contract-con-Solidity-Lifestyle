// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./LoanLibrary.sol";

contract LoanManager {

    enum LoanState{
        Requested,
        Active,
        Paid,
        Late,
        Cancelled
    }



    struct Loan {
        address payable borrower;
        address payable lender;
        uint amountRequested;
        uint256 interestRate;
        uint duration;
        uint256 startDate;
        uint256 endDate;
        uint256 amountGiven;
        uint256 remainingAmountToPay;
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


    /**
    *
    * @dev Allows a borrower to borrow a certain amount of funds for a specified duration with a given interest rate
    * @param _amount The amount of funds the borrower wants to borrow
    * @param _interestRate The interest rate of the loan
    * @param _duration The duration of the loan in days
    */
    function borrow(uint _amount, uint _interestRate, uint _duration) external payable {
        require(_amount > 0, "Amount should be greater than 0");
        require(_interestRate > 0, "Interest rate should be greater than 0");
        require(_duration > 0, "Duration should be greater than 0");
        require(msg.value == _amount, "Insufficient funds");

        uint interest = LoanLibrary.calculateInterest(_amount, _interestRate, _duration);
        uint totalAmount = _amount + interest;

        Loan memory newLoan = Loan({
            borrower: payable(msg.sender),
            lender: payable(address(0)),
            amountRequested: msg.value,
            amountGiven: _amount,
            duration: _duration,
            remainingAmountToPay: totalAmount,
            interestRate: _interestRate,
            startDate: block.timestamp,
            endDate: block.timestamp + (_duration * 1 days),
            state: LoanState.Requested
        });

        loans.push(newLoan);
    }

    /**
    * @dev Allows a lender to lend funds to a borrower for a requested loan.
    * @param _loanId The ID of the loan being lent out.
    */
    function lend(uint _loanId) external payable onlyExistLoan(_loanId) {
        Loan storage loan = loans[_loanId];
        require(loan.lender == address(0), "Loan has already been lent out");
        require(msg.value == loan.amountRequested, "Insufficient funds");

        loans[_loanId].state = LoanState.Active;

        loan.lender = payable(msg.sender);
        loan.borrower.transfer(loan.amountRequested);

    }

    /**
    * @dev Allows a borrower to cancel a requested loan.
    * The function updates the state of the loan to 'Cancelled'.
    * @param _loanId The ID of the loan being cancelled.
    */
    function cancelLoan(uint _loanId) public onlyExistLoan(_loanId) onlyValidState(_loanId, LoanState.Requested)  onlyBorrower(_loanId) {
        loans[_loanId].state = LoanState.Cancelled;
    }


    /**
    * @dev Allows a borrower to repay a loan.
    * The function updates the remaining amount to pay, and if the loan is fully repaid, updates the state to 'Paid' and transfers the repayment amount to the lender.
    * @param _loanId The ID of the loan being repaid.
    */
    function repayLoan(uint _loanId) public payable onlyValidState(_loanId, LoanState.Active) onlyExistLoan(_loanId)  onlyBorrower(_loanId){

        Loan storage loan = loans[_loanId];
        uint penalty = LoanLibrary.calculatePenalty(loan.amountRequested, loan.remainingAmountToPay ,loan.endDate, loan.startDate);
        uint interest = LoanLibrary.calculateInterest(loan.amountRequested, loan.interestRate, loan.duration);
        require(msg.value > 0 && msg.value <= loan.remainingAmountToPay + interest + penalty, "Invalid repayment amount");

        uint amountToRepay = msg.value + penalty + interest;
        loan.remainingAmountToPay -= msg.value;

        if(loan.remainingAmountToPay <= 0){
            loan.state = LoanState.Paid;
        }

        loan.lender.transfer(amountToRepay);

    }



    /**
    * @dev Returns the details of a loan with the given ID
    * @param _loanId The ID of the loan being repaid.
    */
    function getLoan(uint256 _loanId) public view onlyExistLoan(_loanId) returns(
        address borrower,
        address lender,
        uint amountRequested,
        uint256 interestRate,
        uint duration,
        uint256 startDate,
        uint256 endDate,
        uint256 amountGiven,
        uint256 remainingAmountToPay,
        LoanState state

    ){

        Loan storage loan = loans[_loanId];
        borrower = loan.borrower;
        lender = loan.lender;
        amountRequested = loan.amountRequested;
        duration = loan.duration;
        interestRate = loan.interestRate;
        startDate = loan.startDate;
        endDate = loan.endDate;
        amountGiven = loan.amountGiven;
        remainingAmountToPay = loan.remainingAmountToPay;
        state = loan.state;
    }



}