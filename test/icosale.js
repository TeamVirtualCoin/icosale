const DicoCoin = artifacts.require("DicoCoin");
const ICOFactory = artifacts.require("ICOFactory");

contract("test for ICOSale", async accounts => {
	it("should mint 100 coins in owners balance", async () => {
		let instance = await DicoCoin.deployed();
		let balance = await instance.balanceOf.call(accounts[0]);
		assert.equal(balance.valueOf(),web3.utils.toWei("100","ether"));
	});
	it("should have 0 coins in second account", async () => {
		let instance = await DicoCoin.deployed();
		let balance2 = await instance.balanceOf.call(accounts[1]);
		assert.equal(balance2.valueOf(),web3.utils.toWei("0","ether"));
	});
	it("should approve 10 coins to second account",async () => {
		let instance = await DicoCoin.deployed();
		await instance.approve(accounts[1],web3.utils.toWei("10","ether"),{from : accounts[0]});
		let allowance = await instance.allowance.call(accounts[0],accounts[1]);
		assert.equal(allowance.valueOf(),web3.utils.toWei("10","ether"));
	});
	it("should send 10 coins from from first account to third account via second account", async () => {
		let instance = await DicoCoin.deployed();
		await instance.transferFrom(accounts[0],accounts[2],web3.utils.toWei("10","ether"),{from : accounts[1]});
		let balance = await instance.balanceOf.call(accounts[2]);
		assert.equal(balance,web3.utils.toWei("10","ether"));
	});
	it("should create a icosale with 3rd account",async () => {
		let instance = await ICOFactory.deployed();
		let dico = await DicoCoin.deployed();
		let time = (Date.now() / 1000).toFixed()
		let ico = await instance.NewICOSale(web3.utils.toWei("1","ether"),dico.address,18,parseInt(time) + 600,parseInt(time),web3.utils.toBN(1e18),web3.utils.toBN(1e20),{from : accounts[4]});
		let ICOSale = artifacts.require("ICOSale");
		let icosale = await ICOSale.at(ico.logs[0].args._c);
		await dico.transfer(accounts[4],web3.utils.toWei("10","ether"),{from : accounts[0]});
		await dico.approve(icosale.address,web3.utils.toWei("10","ether"),{from : accounts[4]});
		await icosale.AddReserves(web3.utils.toBN(1e19),{from : accounts[4]});
		let bal = await dico.balanceOf.call(accounts[4]);
		await icosale.BuyWithWei(web3.utils.toWei("1.7828383","ether"),{from : accounts[4],value : web3.utils.toWei("1.7828383","ether")});
		let balance = await dico.balanceOf.call(accounts[4]);
		assert.equal(parseInt(balance.toString()),web3.utils.toWei("1.7828383","ether"));
		await icosale.WithdrawWei(web3.utils.toWei("1.7828383","ether"),{from : accounts[4]});
	});
});
