pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract ICOSale {

	//For Debugging
	event Debug(string notes,uint opt1,uint opt2);
	
	using SafeMath for uint;
	
	address public governor;
	uint public priceInWei;
	uint8 public decimal;
	uint public closeTime;
	uint public startTime;
	uint public minBuy;
	uint public maxBuy;
	address public erc20;
	mapping(address => uint) public boughtAmount;

	constructor(address _governor,uint _initialPriceInWei,address _erc20TokenAddress, uint8 _decimal,uint _closeTime,uint _startTime,uint _minBuy,uint _maxBuy) public {
		governor = _governor;
		priceInWei = _initialPriceInWei;
		erc20 = _erc20TokenAddress;
		decimal = _decimal;
		closeTime = _closeTime;
		startTime = _startTime;
		minBuy = _minBuy;
		maxBuy = _maxBuy;
	}
	
	function BuyWithWei(uint _amount) external payable {
		require(_amount > minBuy,"Please Buy Atleast Minimum Amount!");
		require(boughtAmount[msg.sender] < maxBuy,"Max Buy Per Address Is Reached!");
		require(_amount == msg.value,"Please Match Correctly The Amount And Value!");
		require(closeTime > now,"Sale Is Now Closed!");
		require(startTime < now,"Sale Is Yet To Start!");
		uint _amounttosell = _amount.mul(uint(10).pow(uint(decimal))).div(priceInWei);
		IERC20(erc20).transfer(msg.sender,_amounttosell);
		boughtAmount[msg.sender] = boughtAmount[msg.sender].add(_amounttosell);
	}

	function AddReserves(uint _amount) external {
		require(msg.sender == governor,"Only Governor Can Add Reserves!");
		require(_amount > 0,"You Have To Add More Then 0 Tokens!");
		uint _allowance = IERC20(erc20).allowance(msg.sender,address(this));
		require(_allowance >= _amount,"Please Approve The Contract Address With Amount To Be Reserved!");
		IERC20(erc20).transferFrom(msg.sender,address(this),_amount);
	}

	function RemoveReserves(uint _amount) external {
		require(msg.sender == governor,"Only Governor Can Remove Reserves!");
		require(GetReserves() <= _amount,"Not Enough Token To Remove!");
		IERC20(erc20).transfer(msg.sender,_amount);
	}

	function GetReserves() public view  returns (uint) {
		return IERC20(erc20).balanceOf(address(this));
	}

	function GetWeiBalance() public view returns (uint) {
		return address(this).balance;
	}
	
	function WithdrawWei(uint _amount) external view {
		require(msg.sender == governor,"Only Governor Can Withdraw The Wei!");
		require(address(this).balance <= _amount,"Not Enough Wei Collected To Withdraw!");
		msg.sender.call.value(_amount);
	}

	function ChangePrice(uint _amount) external {
		require(msg.sender == governor,"Only Governor Can Change Price!");
		require(_amount > 0,"Price Cannot Be Zero!");
		priceInWei = _amount;
	}

	function GetBoughtAmount(address _address) public view returns (uint) {
		return boughtAmount[_address];
	}

	function changeCloseTime(uint _time) external {
		require(msg.sender == governor,"Only Governor Can Change The Closing Time!");
		closeTime = _time;
	}

	function changeStartTime(uint _time) external {
		require(msg.sender == governor,"Only Governor Can Change The Starting Time!");
		startTime = _time;
	}

	function changeMinBuy(uint _minBuy) external {
		require(msg.sender == governor,"Only Governor Can Change Minimum Purchase!");
		minBuy = _minBuy;
	}

	function changeMaxBuy(uint _maxBuy) external {
		require(msg.sender == governor,"Only Governor Can Change Max Tokens Per Address!");
		maxBuy = _maxBuy;
	}

	function changeGovernor(address _newGovernor) external {
		require(msg.sender == governor,"Only Governor Can Change The Governor!");
		governor = _newGovernor;
	}
	
}

contract ICOFactory {

	event NewICO(address _tokenAddress,address _c,address sender);
	function NewICOSale(uint _initialPriceInWei,address _tokenAddress,uint8 _decimal,uint _closeTime,uint _startTime,uint _minBuy,uint _maxBuy) public returns(address) {
		ICOSale c = new ICOSale(msg.sender,_initialPriceInWei,_tokenAddress,_decimal,_closeTime,_startTime,_minBuy,_maxBuy);
		emit NewICO(_tokenAddress,address(c),msg.sender);
		return address(c);
	}
	
}
