from brownie import LegendaryOwls, accounts


def main():
    owner = accounts[0]
    sc = LegendaryOwls.deploy({"from": owner})
    unpause = sc.setPaused(False, {"from": owner})
    price = sc.getPrice({"from": owner})
    mint1 = sc.mint(1, {"from": accounts[1], "amount": price})
    mint2 = sc.mint(2, {"from": accounts[2], "amount": price * 2})
    mint3 = sc.mint(3, {"from": accounts[3], "amount": price * 3})
    mint4 = sc.mint(4, {"from": accounts[4], "amount": price * 4})
    mint5 = sc.mint(5, {"from": accounts[4], "amount": price * 5})
