from brownie import LegendaryOwls, accounts


def main():
    owner = accounts[0]
    sc = LegendaryOwls.deploy({"from": owner})
    unpause = sc.setPaused(False, {"from": owner})
    sc.setPrice(0, {"from": owner})
    for i in range(1, 10):
        sc.mint(i, {"from": accounts[i-1]})
