# Sequential Runoff Ballot project
This project is built on Hardhat platform. It comes with a ballot contract, tests for the contract, and a script that deploys that contract.

# Project Idea Description
1. Key concepts
    1.1 deployer: the MetaMask account deployed the contract either on a. test networt OR b. local hardhat node
    1.2 signers: the accounts available in the contract
    1.3 msg.sender: the sender of the request to the block chain provider
2. ballot behavior
    2.1 the contract deployer is the chair person of a ballot campaign, only he/she could accounts right to vode, or debug voter account details
    2.2 all accounts have right to vote have voter.weight > 0, i.e. if voter.weight === 0 or null, the account could not vote
    2.3 an account with right to vote could also delegate the vote to some other account if not voted yet. (ideally the delegated account should also have right to vote, but the current contract is not very clear and need to be clarified.)  In the condition of a valid delegation, the from-account's weight will be added to the to-account, and the from-account becomes voted. When the to-account votes, all the weight will be added to the voted proposal

# Project set up tutorial
1. install VS code   https://code.visualstudio.com/download
2. create a folder for the ballot smart contract portion (i.e. you will need a peer folder for HTML frontend portion)
3. open a new vs code window and open the folder
4. clone github repository https://github.com/feileg/BallotSmartConstract.git
5. install yarn on computer
5. yarn init
6. install hardhat:  yarn add --dev hardhat
7. set up project by follow the prompts:  yarn hardhat
8. install prettier plugin:  yarn add --dev prettier prettier-plugin-solidity
9. install prettier extension using vscode
10. install "live server" extension and "solidity" (yellow logo) extension using vscode
11. install etherscan plugin:  yarn add --dev @nomiclabs/hardhat-etherscan
12. other useful plugins: 
    - yarn add hardhat-gas-reporter --dev
    - yarn add solidity-coverage --dev
    - yarn add --dev @chainlink/contracts
    - yarn add --dev hardhat-deploy   (deploy plugin)
    - yarn add --dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers
13. compile the contract:   yarn hardhat compile
14. try to deploy:  yarn hardhat deploy
15. run tests(optional):  yarn hardhat test
16. start localhost hardhat node(which will run forever until ctrl^C):  yarn hardhat node
