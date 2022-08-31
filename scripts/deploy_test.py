from brownie import LegendaryOwls, config, accounts


def main():
    account = accounts.add(config["wallets"]["from_key"])
    contract = LegendaryOwls.deploy([], {"from": account}, publish_source=True)
    contract.setMerkleRoot(
        "0x2212e2b53ea18aa556726b2ed300f31762028779da50c160cf4a7537a1b2d486",
        {"from": account},
    )
