pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DicoCoin is ERC20 {
    constructor(uint256 initialSupply) ERC20("DicoCoin","DICO") public {
        _mint(msg.sender, initialSupply);
    }
}
