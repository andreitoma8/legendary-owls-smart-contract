from brownie import LegendaryOwls, accounts, chain


URI_SUFIX = ".json"
SECONDS_TO_PASS_FIRST = 172810
SECONDS_TO_PASS_SECOND = 172810
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
    one.setPrice(0, {"from": owner})
    one.mint(2, {"from": accounts[1]})
    one.setCagedUri(CAGED_URI, {"from": owner})
    one.setUriPrefix(URI_PREFIX, {"from": owner})
    one.setHiddenMetadataUri(HIDDEN_URI, {"from": owner})
    one.setCagedBackgroundMetadataUri(
        CAGED_AND_PRISON_BACKGROUND_URI, {"from": owner})
    assert one.tokenURI(1, {"from": owner}) == HIDDEN_URI
    one.setRevealed(True, {"from": owner})
    assert (
        one.tokenURI(1, {"from": owner}
                     ) == CAGED_AND_PRISON_BACKGROUND_URI + "1" + URI_SUFIX
    )
    assert (
        one.tokenURI(2, {"from": owner}
                     ) == CAGED_AND_PRISON_BACKGROUND_URI + "2" + URI_SUFIX
    )
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_FIRST)
    assert one.tokenURI(1, {"from": owner}) == CAGED_URI + "1" + URI_SUFIX
    assert one.tokenURI(2, {"from": owner}) == CAGED_URI + "2" + URI_SUFIX
    chain.mine(blocks=1, timedelta=SECONDS_TO_PASS_SECOND)
    assert one.tokenURI(1, {"from": owner}) == URI_PREFIX + "1" + URI_SUFIX
    assert one.tokenURI(2, {"from": owner}) == URI_PREFIX + "2" + URI_SUFIX
