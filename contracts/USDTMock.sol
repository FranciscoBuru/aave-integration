// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTMock is ERC20 {
    constructor(uint256 initialSupply) ERC20("USDTMock", "USDTM") {
        _mint(msg.sender, initialSupply);
    }
}
