from brownie import LegendaryOwls, accounts


def main():
    account = accounts[0]
    deploy_tx = LegendaryOwls.deploy({"from": account})
