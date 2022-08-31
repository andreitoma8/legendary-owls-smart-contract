from brownie import LegendaryOwls, accounts


def main():
    owner = accounts[0]
    sc = LegendaryOwls.deploy([], {"from": owner})
    # sc.mintForAddresses([7, 1, 1, 4, 7], [accounts[1].address, accounts[2].address,
    #                     accounts[3].address, accounts[4].address, accounts[5].address], {"from": owner})
    sc.mintForAddresses([109], [owner.address], {"from": owner})
    sc.mintForAddresses([100], [owner.address], {"from": owner})
    sc.mintForAddresses([100], [owner.address], {"from": owner})
