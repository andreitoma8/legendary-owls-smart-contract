from brownie import LegendaryOwls, config, accounts


def main():
    account = accounts.add(config["wallets"]["from_key"])
    deploy_tx = LegendaryOwls.deploy({"from": account},  publish_source=True)
