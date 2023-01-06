const { network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
require("dotenv").config()

// preferred this option, with a lot of syntax sugar
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const {
        networkConfig,
        developmentChains,
    } = require("../helper-hardhat-config")
    // above line is the syntax sugar for the follow two lines
    // const helperConfig = require("../helper-hardhat-config")
    // const networkzConfig = helperConfig.networkConfig

    const proposals = [
        "0-basketball",
        "1-soccer",
        "2-volleyball",
        "3-baseball",
        "4-softball",
        "5-other",
    ]

    // when going for localhost or hardhat network, we want to use a mock
    const args = [proposals]
    const fundMe = await deploy("Ballot", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    log("----------------------------------------------------")
    log("Deploying Ballot and waiting for confirmations...")
}
module.exports.tags = ["all"]
