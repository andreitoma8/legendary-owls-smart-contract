from brownie import LegendaryOwls, config, accounts


def main():
    account = accounts.add(config["wallets"]["from_key"])
    contract = LegendaryOwls.deploy(["0x4122e8c96D0D4CE34c08af237f801cd36247517F", "0x0d81958917E757993F86A6Fe1802d5f98084Df4A",
                                    "0x656E5621b961e33951De416C7a7CC1f2e69a5c94", "0xc1b69B555Ed6d4426Ac9ABAc6647ac27eA135788"], {"from": account}, publish_source=True)
    contract.setMerkleRoot(
        "0x88e580f25e81219768c8e8a0e1ed3b7362ef9485d456a6c0b4315510693000e3",
        {"from": account},
    )
    contract.setHiddenMetadataUri(
        "ipfs://QmfTG77mvtKmUgUmxXnPWvoZXKYH9AfnK1NnCYLfGiqZyW", {
            "from": account}
    )
