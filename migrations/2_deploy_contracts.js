var ICOFactory = artifacts.require("ICOFactory");
var DicoCoin = artifacts.require("DicoCoin");

module.exports = function(deployer) {
	deployer.deploy(DicoCoin,web3.utils.toWei("100","ether"));
	deployer.deploy(ICOFactory);
}
