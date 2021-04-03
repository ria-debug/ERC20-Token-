
pragma solidity ^0.5.16;


/// @title ERC20 Token
/// @author Riya Rana
/// @notice You can use this contract for only the most basic simulation

import "./MyToken.sol";
import "./SafeMath.sol"; 


contract Contributions is MyToken{

using SafeMath for uint256;

// The token being sold
MyToken public token;

uint256 public startTime;
uint256 public endTime;
// address where funds are collected
address public wallet;
// how many token units a buyer gets per wei
uint256 public rate;
// amount of raised money in wei
uint256 public weiRaised;



/** @notice stores ethereum donated by each doner
 */
mapping(address => uint256) public EthContributed;

/**
* event for token purchase logging
* @param purchaser who paid for the tokens
* @param beneficiary who got the tokens
* @param value weis paid for purchase
* @param amount amount of tokens purchased
*/

event TokenPurchase(address indexed purchaser, address indexed beneficiary, 
uint256 value, uint256 amount);


function Contributions(uint256 _startTime, uint256 _endTime, uint256 _rate, 
address _wallet, MyToken _token) public {
require(_startTime >= now);
require(_endTime >= _startTime);
require(_rate > 0);
require(_wallet != address(0));
require(_token != address(0));

startTime = _startTime;
endTime = _endTime;
rate = _rate;
wallet = _wallet;
token = _token;
}

 // fallback function can be used to buy tokens
 function () external payable {
 buyTokens(msg.sender);

 }


 function buyTokens(address beneficiary) public payable {
 require(beneficiary != address(0));
 require(validPurchase());

 uint256 weiAmount = msg.value;

// calculate token amount to be created
uint256 tokens = getTokenAmount(weiAmount);

// update state
weiRaised = weiRaised.add(weiAmount);

token.generateTokens(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

forwardFunds();
EthContributed[beneficiary] = weiAmount;
}

// @return true if crowdsale event has ended
function hasEnded() public view returns (bool) {
return now > endTime;
}


function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
return weiAmount.mul(rate);
}

// send ether to the fund collection wallet
// override to create custom fund forwarding mechanisms
function forwardFunds() internal {
wallet.transfer(msg.value);
}

// @return true if the transaction can buy tokens
function validPurchase() internal view returns (bool) {
bool withinPeriod = now >= startTime && now <= endTime;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase;
}

function CheckContribution(address doner) public view returns(uint256){
 return(EthContributed[doner]);
}

}