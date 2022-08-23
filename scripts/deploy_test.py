from brownie import LegendaryOwls, config, accounts


def main():
    account = accounts.add(config["wallets"]["from_key"])
    contract = LegendaryOwls.deploy([], {"from": account}, publish_source=True)
    contract.setMerkleRoot(
        "0x88e580f25e81219768c8e8a0e1ed3b7362ef9485d456a6c0b4315510693000e3",
        {"from": account},
    )
    contract.setHiddenMetadataUri(
        "ipfs://QmfTG77mvtKmUgUmxXnPWvoZXKYH9AfnK1NnCYLfGiqZyW", {
            "from": account}
    )
