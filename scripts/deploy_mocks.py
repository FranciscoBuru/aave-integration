from brownie import (
    ATokenMock,
    PoolMock,
    USDTMock,
    accounts,
    config,
    network,
    exceptions,
)
from web3 import Web3
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account

SUPPLY = Web3.toWei(10000, "ether")


def main():
    deploy_mocks()


def deploy_mocks():
    account = get_account(number=0)
    usdt = USDTMock.deploy(SUPPLY, {"from": account})
    atoken = ATokenMock.deploy({"from": account})
    pool = PoolMock.deploy(usdt, atoken, {"from": account})
    tx = atoken.transferOwnership(pool, {"from": account})
    tx.wait(1)
    return usdt, atoken, pool
