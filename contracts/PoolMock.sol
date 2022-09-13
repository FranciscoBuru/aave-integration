// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ATokenMock.sol";

contract PoolMock {
    address public stableAddress;
    ATokenMock public aTokenContract;
    uint256 public contractBalance;

    constructor(address _stableToken, address _aToken) {
        aTokenContract = ATokenMock(_aToken);
        stableAddress = _stableToken;
    }

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) public {
        require(asset == stableAddress, "Invalid ERC20");
        IERC20(stableAddress).transferFrom(msg.sender, address(this), amount);
        contractBalance += amount;
        aTokenContract.mint(onBehalfOf, amount);
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) public {
        require(asset == stableAddress, "Invalid ERC20");
        require(
            amount <= aTokenContract.balanceOf(msg.sender),
            "Insufficient funds in contract"
        );
        aTokenContract.burn(msg.sender, amount);
        IERC20(stableAddress).transfer(msg.sender, amount);
        contractBalance -= amount;
    }
}
