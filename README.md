
# Solidity Smart Contract - Lifestyle

This code implements a basic lending system on the Ethereum blockchain, where borrowers can request loans and lenders can lend out the requested amounts. The borrowers can repay the loans, and the lenders can receive the repayments. The LoanManager contract keeps track of all the loans and their states.

## LoanManager.Sol
The LoanManager contract manages a collection of loans. It defines a Loan struct that represents the details of a loan, including the borrower, lender, amount requested, interest rate, duration, start and end dates, amount given, remaining amount to pay, and the current state of the loan.

The LoanState enum is used to represent the possible states of a loan: requested, active, paid, late, and cancelled.

It has several functions for interacting with the loans.
- The borrow function allows a borrower to request a loan by providing the amount, interest rate, and duration.
- The lend function allows a lender to lend out the requested loan amount.
- The repay loan function allows a borrower to repay a loan
- The cancel loan function allows a borrower to cancel a requested loan.

## LoanLibrary.sol

The LoanLibrary contract is a library that contains two functions for calculating the interest and penalty on a loan. These functions are used in the LoanManager contract to calculate the interest and penalty on loans.