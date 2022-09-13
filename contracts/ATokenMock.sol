// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ATokenMock is ERC20, Ownable {
    constructor() ERC20("ATokenMock", "ATM") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}
