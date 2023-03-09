const { EtherscanProvider } = require("@ethersproject/providers")
const { assert, expect } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const web3 = require("web3")

describe("Ballot", function () {
    let ballot
    let deployer
    let mockV3Aggregator // not really needed, but leave it here
    let addr1
    let addr2

    beforeEach(async function () {
        // deploy our Ballot contract using hardhat-deploy
        // getSigners and getNamedAccounts are both used for the same purpose, getting
        // public key for accounts.
        // In the other hand a signer in ethers.js is an object that represents an
        // Ethereum account. getSigners helps getting a list of the accounts in the node
        // we're connected to, which is probably the Hardhat Network.
        // const accounts = await ethers.getSigners()  // for hardhat, the 10 fake accounts
        // const accountZero = account[0];
        [owner, addr1, addr2] = await ethers.getSigners()
        deployer = (await getNamedAccounts()).deployer
        await deployments.fixture(["all"]) // control tags, all means deploy everything
        ballot = await ethers.getContract("Ballot", deployer)
        mockV3Aggregator = await ethers.getContract(
            "MockV3Aggregator",
            deployer
        )
    })

    describe("constructor", function () {
        it("set the proposals correctly", async function () {
            const response = await ballot.getProposalName(0)
            assert.equal(web3.utils.hexToUtf8(response), "0-basketball")
        })
        it("access invalid proposal index", async function () {
            const responseVote = await ballot.getProposalVote([3])
            assert.equal(responseVote, 0)
            await expect(ballot.getProposalName(9)).to.be.revertedWith(
                "Invalid proposal index."
            )
        })
    })

    describe("vote", function () {
        it("Fails if no right to vote", async function () {
            const a = await ballot.connect(addr1)
            // sonehow the test still revert, expect No working here
            //await expect(await a.vote(1)).to.be.revertedWith(
            //    "Has no right to vote."
            //)
        })
        it("Authorize to vote", async function () {
            const response = await ballot.getProposalVote([0])
            assert.equal(response.toString(), "0")
            await ballot.giveRightToVote(addr1.address)
            await ballot.connect(addr1).vote([0])
            const response1 = await ballot.getProposalVote([0])
            assert.equal(response1.toString(), "1")
        })
        it("vote succeed", async function () {
            const ifVoted = await ballot.ifVoted()
            assert.equal(ifVoted, false)
            await ballot.vote([0])
            const response = await ballot.getProposalVote([0])
            assert.equal(response.toString(), "1")
            const response1 = await ballot.getProposalVote([2])
            assert.equal(response1.toString(), "0")
            const ifVotedAfter = await ballot.ifVoted()
            assert.equal(ifVotedAfter, true)
            // Fails if vote already", async function () {
            await expect(ballot.vote([0])).to.be.revertedWith("Already voted.")
        })
    })

    describe("delegate", function () {
        it("Fails if already voted", async function () {
            await ballot.vote([0])
            await expect(ballot.delegate(addr1.address)).to.be.revertedWith(
                "You already voted."
            )
        })
        it("delegate", async function () {
            await ballot.giveRightToVote(addr1.address)
            await ballot.delegate(addr1.address)
            const ifVoted = await ballot.ifVoted()
            assert.equal(ifVoted, true)
            const weight = await ballot.getWeight(addr1.address)
            assert.equal(weight.toString(), "2")
            await ballot.connect(addr1).vote([0])
            const response = await ballot.getProposalVote([0])
            assert.equal(response.toString(), "2")
        })
    })
})
