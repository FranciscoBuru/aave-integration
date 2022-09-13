from brownie import network, config, accounts
from web3 import Web3
import math
import time

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganace-local", "mainnet-fork"]
TESTNETS = ["rinkeby", "goerli"]

"""Retrives an account. 
   Args:    
        index (int): index returns a local ganache account
        id (int): return one of the accounts saved for rinkeby use. Keys must be in .env file
        
    Returns:
        account xor none if something went wrong. 
"""


def get_account(index=None, id=None, number=None):
    # accounts[0]
    # accounts.add("env")
    # account.load("id")
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)  # id="freecodecamp-account"
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    if network.show_active() in config["networks"]:
        if number:
            if number == 0:
                return accounts.add(config["wallets"][f"from_key"])
            else:
                return accounts.add(config["wallets"][f"from_key{number}"])
        else:
            return accounts.add(config["wallets"]["from_key"])
    else:
        return None
