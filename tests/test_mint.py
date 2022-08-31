from brownie import LegendaryOwls, accounts
import brownie

# Test made with a 60s wait time to uncage the owl


def test_main():
    # Deploy
    owner = accounts[0]
    one = LegendaryOwls.deploy([], {"from": owner})
    print("Contract deployed!")
    # Unpause
    unpause = one.setPaused(False, {"from": owner})
    print("Contract unpaused")
    # Mint
    price = 88000000000000000
    mint1 = one.mint(1, {"from": accounts[1], "amount": price})
    mint2 = one.mint(2, {"from": accounts[2], "amount": price * 2})
    mint3 = one.mint(3, {"from": accounts[3], "amount": price * 3})
    mint4 = one.mint(4, {"from": accounts[4], "amount": price * 4})
    # Exceed mint limit = Passed
    # mint5 = one.mint(10, {"from": accounts[5], "amount": price * 10})
    # Pay less = Passed
    # mint6 = one.mint(3, {"from": accounts[6], "amount": price})
    total_supply = one.totalSupply({"from": owner})
    assert total_supply == 10
    # Reveal
    reveal = one.setRevealed(True, {"from": owner})
    reveal.wait(1)
    one.setUriPrefix("Hidden", {"from": owner})
    token_uri = one.tokenURI(1, {"from": owner})
    assert token_uri != "Hidden"
    # Withdraw
    balance1 = owner.balance()
    withdraw = one.withdraw({"from": owner})
    withdraw.wait(1)
    assert owner.balance() > balance1 + (price * 10) - 10000000000000000
