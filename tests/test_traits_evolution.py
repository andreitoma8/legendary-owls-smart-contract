from brownie import LegendaryOwls, accounts, chain
import time

# Test made with 3 and 7 minutes for uncage timers

URI_SUFIX = "1.json"
SECONDS_TO_PASS_FIRST = 259300
SECONDS_TO_PASS_SECOND = 604900
CAGED_URI = "Owl behind bars"
URI_PREFIX = "Free Owl"
HIDDEN_URI = "Hidden Owl"
CAGED_AND_PRISON_BACKGROUND_URI = "Owl in prison"


def test_main():
    # Deploy
    owner = accounts[0]
    one = LegendaryOwls.deploy({"from": owner})
    one.setPaused(False, {"from": owner})
    # Mint
    price = one.getPrice({"from": owner})
    one.mint(1, {"from": accounts[1], "amount": price})
    one.setCagedUri(CAGED_URI, {"from": owner})
    one.setUriPrefix(URI_PREFIX, {"from": owner})
    one.setHiddenMetadataUri(HIDDEN_URI, {"from": owner})
    one.setCagedBackgroundMetadataUri(CAGED_AND_PRISON_BACKGROUND_URI, {"from": owner})
    assert one.tokenURI(1, {"from": owner}) == HIDDEN_URI
    one.setRevealed(True, {"from": owner})
    assert (
        one.tokenURI(1, {"from": owner}) == CAGED_AND_PRISON_BACKGROUND_URI + URI_SUFIX
    )
    chain.mine(blocks=100, timedelta=SECONDS_TO_PASS_FIRST)
    one.uncage(1, {"from": owner})
    assert one.tokenURI(1, {"from": owner}) == CAGED_URI + URI_SUFIX
    chain.mine(blocks=100, timedelta=SECONDS_TO_PASS_SECOND)
    one.uncage(1, {"from": owner})
    assert one.tokenURI(1, {"from": owner}) == URI_PREFIX + URI_SUFIX
