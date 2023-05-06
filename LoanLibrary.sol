// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library LoanLibrary {


    /**
     *
     * @dev Calculates the interest to be paid on a loan based on the interest rate and the loan duration.
    * @param _amount The amount of the loan.
    * @param _interestRate The interest rate of the loan, expressed an an annual percentage rate.
    * @param  _duration The duration of the loan, in seconds.
    * @return The interest to be paid on the loan
    */

    function calculateInterest(uint _amount, uint _interestRate, uint _duration) internal pure returns (uint){

        uint interest = (_amount * _interestRate * _duration) / (100 * 365);


        return interest;
    }

    /**
    * @dev Calculates the penalty to be applied to a late loan repayment.
    * @param _amount The amount of the loan.
    * @param _endTime The due date of the loan repayment.
    * @param _paymentTime The date on which the loan repayment is made.
    * @return The penalty to be applied to the loan repayment.
    */

    function calculatePenalty(uint _amount, uint _totalAmountTobePaid,  uint _endTime, uint _paymentTime) internal pure returns(uint){

        uint penalty = 0;

        if(_paymentTime > _endTime ){
            uint timeDiff = _paymentTime - _endTime;
            uint daysLate = timeDiff / 86400;
            penalty = (_amount * daysLate * 2) /100 ;
        }

        if(_amount != _totalAmountTobePaid){
            penalty += (penalty *5)  / 100;
        }
        return penalty;


    }
}