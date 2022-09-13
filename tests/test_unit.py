from brownie import AaveProvider, accounts, config, network, exceptions
from web3 import Web3
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
from scripts.deploy_contract import deploy_contract
from scripts.deploy_mocks import deploy_mocks
import pytest


ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"
SUPPLY = 100 * (10**18)

"""
Tests for the Aave implementation of the contract. 
"""


def test_deploy():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    usdt, atoken, pool = deploy_mocks()
    contract = deploy_contract(pool, usdt, atoken)
    assert contract.stableAddress() == usdt
    assert contract.aTokenContract() == atoken
    assert contract.aavePool() == pool


def test_deploy_mocks():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    usdt, atoken, pool = deploy_mocks()
    account = get_account()
    assert SUPPLY == usdt.balanceOf(account.address)
    assert atoken.owner() == pool
    return usdt, atoken, pool


def test_mocks_mint_on_deposit():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    usdt, atoken, pool = test_deploy_mocks()
    tx = usdt.approve(pool, Web3.toWei(1, "ether"), {"from": account})
    tx.wait(1)
    tx = pool.supply(
        usdt, Web3.toWei(1, "ether"), account.address, 0, {"from": account}
    )
    tx.wait(1)
    assert pool.contractBalance() == Web3.toWei(1, "ether")
    assert atoken.balanceOf(account.address) == Web3.toWei(1, "ether")
    assert usdt.balanceOf(account.address) == Web3.toWei(99, "ether")
    return usdt, atoken, pool


def test_mocks_burn_on_withdrawal():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    usdt, atoken, pool = test_mocks_mint_on_deposit()
    ##The next line should not be done in real life but given that we are
    # mocking we have to. Yolo
    tx = atoken.approve(pool, Web3.toWei(1, "ether"), {"from": account})
    tx.wait(1)
    # Now the real deal
    tx = pool.withdraw(usdt, Web3.toWei(0.5, "ether"), account.address)
    assert pool.contractBalance() == Web3.toWei(0.5, "ether")
    assert atoken.balanceOf(account.address) == Web3.toWei(0.5, "ether")
    assert usdt.balanceOf(account.address) == Web3.toWei(99.5, "ether")
    assert usdt.balanceOf(pool) == Web3.toWei(0.5, "ether")


def test_deposit_to_contract():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    account2 = get_account(index=2)
    usdt, atoken, pool = deploy_mocks()
    contract = deploy_contract(pool, usdt, atoken)
    tx = usdt.transfer(account2, Web3.toWei(10, "ether"), {"from": account})
    tx.wait(1)
    tx = usdt.approve(contract, Web3.toWei(5, "ether"), {"from": account2})
    tx.wait(1)
    tx = contract.depositToContract(Web3.toWei(5, "ether"), usdt, {"from": account2})
    tx.wait(1)
    assert contract.contractBalance() == Web3.toWei(5, "ether")
    assert contract.depositedAmount(account2) == Web3.toWei(5, "ether")
    assert usdt.balanceOf(account2.address) == Web3.toWei(5, "ether")
    return usdt, atoken, pool, contract


def test_supply_to_pool_owner():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    usdt, atoken, pool, contract = test_deposit_to_contract()
    tx = contract.supplyToPool(Web3.toWei(1, "ether"), {"from": account})
    tx.wait(1)
    assert atoken.balanceOf(contract) == Web3.toWei(1, "ether")
    assert usdt.allowance(account, contract) == 0
    assert pool.contractBalance() == Web3.toWei(1, "ether")
    assert usdt.balanceOf(pool) == Web3.toWei(1, "ether")
    return usdt, atoken, pool, contract


def test_withdraw_part_from_pool_owner():
    account = get_account()
    usdt, atoken, pool, contract = test_supply_to_pool_owner()
    tx = contract.withdrawFromPool(Web3.toWei(0.5, "ether"), {"from": account})
    tx.wait(1)
    assert atoken.balanceOf(contract) == Web3.toWei(0.5, "ether")
    assert usdt.allowance(account, contract) == 0
    assert pool.contractBalance() == Web3.toWei(0.5, "ether")
    assert usdt.balanceOf(pool) == Web3.toWei(0.5, "ether")
    assert usdt.balanceOf(contract) == Web3.toWei(4.5, "ether")
    assert usdt.balanceOf(account.address) == Web3.toWei(90, "ether")


def test_withdraw_full_from_pool_owner():
    account = get_account()
    usdt, atoken, pool, contract = test_supply_to_pool_owner()
    tx = contract.withdrawFromPool(Web3.toWei(1, "ether"), {"from": account})
    tx.wait(1)
    assert atoken.balanceOf(contract) == Web3.toWei(0.0, "ether")
    assert usdt.allowance(account, contract) == 0
    assert pool.contractBalance() == Web3.toWei(0.0, "ether")
    assert usdt.balanceOf(pool) == Web3.toWei(0.0, "ether")
    assert usdt.balanceOf(contract) == Web3.toWei(5, "ether")
    assert usdt.balanceOf(account.address) == Web3.toWei(90, "ether")
    assert contract.contractBalance() == Web3.toWei(5, "ether")
