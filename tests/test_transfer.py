from brownie import LegendaryOwls, accounts


def test_main():
    # Deploy
    owner = accounts[0]
    one = LegendaryOwls.deploy({"from": owner})
    print("Contract deployed!")
    # Unpause
    unpause = one.setPaused(False, {"from": owner})
    print("Contract unpaused")
    # Mint
    price = one.getPrice({"from": owner})
    mint1 = one.mint(1, {"from": owner, "amount": price})
    enable_token_transfer = one.setCanTransfer(True, {"from": owner})
    owner_address = owner.address
    recipient_address = accounts[1].address
    tx = one.safeTransferFrom(owner_address, recipient_address, 1, {"from": owner})
    new_owner = one.ownerOf(1, {"from": owner})
    assert new_owner == recipient_address
