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
    contract = deploy_contract()
    assert (
        contract.stableAddress()
        == config["networks"][network.show_active()]["usdt-address"]
    )
    assert (
        contract.aTokenContract() == config["networks"][network.show_active()]["a-usdt"]
    )
    assert contract.aavePool() == config["networks"][network.show_active()]["aave-pool"]


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
    tx = usdt.approve(pool, 10**18, {"from": account})
    tx.wait(1)
    tx = pool.supply(usdt, 10**18, account.address, 0, {"from": account})
    tx.wait(1)
    assert pool.contractBalance() == 10**18
    assert atoken.balanceOf(account.address) == 10**18
    assert usdt.balanceOf(account.address) == 99 * 10**18
    return usdt, atoken, pool


def test_mocks_burn_on_withdrawal():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    account = get_account()
    usdt, atoken, pool = test_mocks_mint_on_deposit()
    ##The next line should not be done in real life but given that we are
    # mocking we have to. Yolo
    tx = atoken.approve(pool, 10**18, {"from": account})
    tx.wait(1)
    # Now the real deal
    tx = pool.withdraw(usdt, (10**18) / 2, account.address)
    assert pool.contractBalance() == (10**18) / 2
    assert atoken.balanceOf(account.address) == (10**18) / 2
    assert usdt.balanceOf(account.address) == 99 * 10**18 + (10**18) / 2
    assert usdt.balanceOf(pool) == (10**18) / 2
