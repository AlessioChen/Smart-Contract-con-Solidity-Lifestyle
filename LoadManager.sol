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
        bool isPaid;
        bool isCancelled;
        LoanState state;
    }

    mapping (uint256 => Loan) public loans;
    uint256 public loanCounter;


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
            false,
            false,
            LoanState.Requested
        );

        loanCounter++;

    }

    function cancelLoan(uint _loanId) public{
        require(loans[_loanId].state == LoanState.Requested, "Loan is not in requested state.");
        require(loans[_loanId].borrower == msg.sender, "Only borrower can cancel the loan.");

        loans[_loanId].state = LoanState.Cancelled;
    }

    function approveLoan(uint256 _loanId) public payable{
        require(loans[_loanId].state == LoanState.Requested, "Loan is not in requested state.");
        require(loans[_loanId].lender == msg.sender, "Only lender can approve the loan.");
        require(msg.value == loans[_loanId].amount, "Amount sent must match loan amount.");

        loans[_loanId].state = LoanState.Active;
    }


}