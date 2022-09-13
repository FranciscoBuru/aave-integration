from brownie import AaveProvider, accounts, config, network, exceptions
from web3 import Web3
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account


def deploy_contract():
    account = get_account(index=0)
    contract = AaveProvider.deploy(
        config["networks"][network.show_active()]["aave-pool"],
        config["networks"][network.show_active()]["usdt-address"],
        config["networks"][network.show_active()]["a-usdt"],
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    return contract
