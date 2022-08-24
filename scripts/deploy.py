from brownie import LegendaryOwls, config, accounts

owners = ["0x4a8430604a863Ffe3B15612E10f8868E4d464931", "0x7Bd4364286084E3cA7a16cbA445d3CACCCd4b588",
          "0x0CaA6be1509Fb5fcf47F42d724d576b90BF2c7CF", "0x2961C65Ad87595e9F5e8C227Ae92c730C33DC923"]


def main():
    account = accounts.add(config["wallets"]["from_key"])
    contract = LegendaryOwls.deploy(
        owners, {"from": account},  publish_source=True)
