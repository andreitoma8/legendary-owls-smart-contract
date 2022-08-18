from brownie import LegendaryOwls, accounts, chain


URI_SUFIX = "1.json"
SECONDS_TO_PASS_FIRST = 172810
SECONDS_TO_PASS_SECOND = 172810
CAGED_URI = "Owl behind bars"
URI_PREFIX = "Free Owl"
HIDDEN_URI = "Hidden Owl"
CAGED_AND_PRISON_BACKGROUND_URI = "Owl in prison"


def test_main():
    # Deploy
    owner = accounts[0]
    user = accounts[1]
    one = LegendaryOwls.deploy({"from": owner})
    one.setPaused(False, {"from": owner})
    # Mint
    one.setPrice(0, {"from": owner})
    one.mint(1, {"from": user})
    one.setCagedUri(CAGED_URI, {"from": owner})
    one.setUriPrefix(URI_PREFIX, {"from": owner})
    one.setHiddenMetadataUri(HIDDEN_URI, {"from": owner})
    one.setCagedBackgroundMetadataUri(
        CAGED_AND_PRISON_BACKGROUND_URI, {"from": owner})
    assert one.tokenURI(1, {"from": owner}) == HIDDEN_URI
    one.setRevealed(True, {"from": owner})
    assert (
        one.tokenURI(1, {"from": owner}
                     ) == CAGED_AND_PRISON_BACKGROUND_URI + URI_SUFIX
    )
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST/2)
    one.transferFrom(user.address, owner.address, 1, {"from": user})
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST/2 + 100)
    assert (
        one.tokenURI(1, {"from": owner}
                     ) == CAGED_AND_PRISON_BACKGROUND_URI + URI_SUFIX
    )
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST/2 + 100)
    assert one.tokenURI(1, {"from": owner}) == CAGED_URI + URI_SUFIX
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST/2 + 100)
    one.transferFrom(owner.address, user.address, 1, {"from": owner})
    assert one.tokenURI(1, {"from": owner}) == CAGED_URI + URI_SUFIX
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST/2 + 100)
    assert one.tokenURI(1, {"from": owner}) == CAGED_URI + URI_SUFIX
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST/2 + 100)
    assert one.tokenURI(1, {"from": owner}) == URI_PREFIX + URI_SUFIX
    one.transferFrom(user.address, owner.address, 1, {"from": user})
    assert one.tokenURI(1, {"from": owner}) == URI_PREFIX + URI_SUFIX
