from brownie import LegendaryOwls, accounts


def main():
    owner = accounts[0]
    sc = LegendaryOwls.deploy([], {"from": owner})
    unpause = sc.setPaused(False, {"from": owner})
    for i in range(1, 10):
        sc.mint(i, {"from": accounts[i-1], "amount": 88000000000000000 * i})
