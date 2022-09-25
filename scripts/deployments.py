from brownie import Factory, accounts, config, network, exceptions
from web3 import Web3
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account


def main():
    deploy_factory()


def deploy_factory():
    account = get_account(number=0)
    contract = Factory.deploy({"from": account})
    return contract
