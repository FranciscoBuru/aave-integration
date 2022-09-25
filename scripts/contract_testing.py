from brownie import (
    Factory,
    Child,
    USDTMock,
    PoolMock,
    network,
    accounts,
    config,
    network,
    exceptions,
    interface,
)
from web3 import Web3
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account


def main():
    approve()


def create_community():
    community = Factory[-1].generateChild(1, {"from": get_account(number=0)})
    print(community)


def get_community():
    community = Child[-2]
    #tx = community.addUnit(
    #    1,
    #    "hola",
    #    "0x7f98B625eA17fA2F841ff6D92bb1f6c0ae07EBe5",
    #    {"from": get_account(number=0)},
    #)
    tx = community.deployNFTs({"from": get_account(number=0)})
    #tx.wait(1)
    #usdt = USDTMock[0]
    #pool = PoolMock[0]

    #amount = Web3.toWei(100, "ether")
    #network.gas_limit(1000000)
    #tx = usdt.approve(community, amount, {"from": get_account(number=0)})
    #tx.wait(1)
    #tx = community.depositt(
        Web3.toWei(0.01, "ether"),
        1,
        1,
        1,
        {"from": get_account(number=0), "allow_revert": True},
    )
    tx.wait(1)
    # tx = community.generateNFT(1, 1, 1)
    # tx.wait(1)


def deploy_child():
    account = get_account(number=0)
    Child.deploy(
        1,
        "0xE70d62cB33A77E4045E8d6D4896Efdd346E5d5F4",
        {"from": account, "allow_revert": True},
    )


def approve():
    usdt = USDTMock[0]
    community = Child[-1]
    amount = Web3.toWei(2000, "ether")
    tx = usdt.approve(
        "0x41Dc5c8de461b7dcaD5a0044C0F1F69Af4d90Ab1",
        amount,
        {"from": get_account(number=0)},
    )
    tx.wait(1)
