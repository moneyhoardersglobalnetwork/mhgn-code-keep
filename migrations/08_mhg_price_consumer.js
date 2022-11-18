const MhgPriceConsumerV3 = artifacts.require("MhgPriceConsumerV3")
const MockV3Aggregator = artifacts.require("MockV3Aggregator")

const { networkConfig, developmentChains } = require("../helper-truffle-config")

module.exports = async function (deployer, network, accounts) {
    let ethUsdPriceFeedAddress

    if (developmentChains.includes(network)) {
        const ethUsdAggregator = await MockV3Aggregator.deployed()
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[network]["ethUsdPriceFeed"]
    }

    await deployer.deploy(MhgPriceConsumerV3, ethUsdPriceFeedAddress)
    const mhgPriceConsumerV3 = await MhgPriceConsumerV3.deployed()
    console.log("MHG Price Consumer Deployed!")
}