from brownie import LegendaryOwls, config, accounts

owners = []


def main():
    account = accounts.add(config["wallets"]["from_key"])
    contract = LegendaryOwls.deploy(
        owners, {"from": account},  publish_source=True)
