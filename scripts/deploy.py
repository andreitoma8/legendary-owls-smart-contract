from brownie import LegendaryOwls, config, accounts


def main():
    account = accounts.add(config["wallet"]["from_key"])
    deploy_tx = LegendaryOwls.deploy({"from": account})
