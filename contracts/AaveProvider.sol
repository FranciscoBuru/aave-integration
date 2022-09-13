// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@aave/contracts/interfaces/IPool.sol";
import "@aave/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/contracts/interfaces/IAToken.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; No hace falta pq IAToken ya lo jala
import "@openzeppelin/contracts/access/Ownable.sol";

contract AaveProvider is Ownable {
    //The address of the stablecoin to use
    address public stableAddress;

    //The aToken produced when you deposit the stablecoin
    IAToken public aTokenContract;

    //aave pool interface
    IPool public aavePool;

    //Balance of stable token in contract
    uint256 public contractBalance;

    //Maps address to stable amount deposited to contract
    mapping(address => uint256) public depositedAmount;

    /**
        @dev Contract constructor.
     */
    constructor(
        address _poolAddress,
        address _stableToken,
        address _aToken
    ) {
        aavePool = IPool(_poolAddress);
        aTokenContract = IAToken(_aToken);
        stableAddress = _stableToken;
    }

    /**
        @dev Lets people deposit the ERC20 to contract.

        Requirements:
            - '_tokenAddress' has to be the same of the stable address accepted in contract.
     */
    function depositToContract(uint256 _amount, address _tokenAddress) public {
        require(_tokenAddress == stableAddress, "Invalid ERC20");
        IERC20(stableAddress).transferFrom(msg.sender, address(this), _amount);
        depositedAmount[msg.sender] = _amount;
        contractBalance += _amount;
    }

    /**
        @dev Lets contract owner deposit _amount to aave pool

        Requirements:
            - '_amount" has to be smaller or equal to tha amount of ERC20
            the contract has
     */

    function supplyToPool(uint256 _amount) public onlyOwner {
        require(_amount <= contractBalance, "Insufficient funds in contract");
        IERC20(stableAddress).approve(address(aavePool), _amount);
        aavePool.supply(stableAddress, _amount, address(this), 0);
        contractBalance -= _amount;
    }

    /**
        @dev Lets contract owner withdraw '_amount' from pool

        Requirements:
            - '_amount' has to be lees or equal to the amount previously 
            deposited. 
     */
    function withdrawFromPool(uint256 _amount) public onlyOwner {
        require(
            _amount <= aTokenContract.balanceOf(address(this)),
            "Insufficient aTokens"
        );
        //Quita lo siguiente
        //aTokenContract.approve(address(aavePool), _amount);
        aavePool.withdraw(stableAddress, _amount, address(this));
        contractBalance += _amount;
    }
}

// TODO Call the pool first by reading the address since it can change because it is
// a proxy.  IDK READ INTO THIS.

// TODO Investigar esto https://docs.aave.com/developers/deployed-contracts/v3-mainnet/polygon#core-and-periphery-contracts
