const MhgToken = artifacts.require('MhgToken')
const DaiToken = artifacts.require('DaiToken')
const TokenRewardVault = artifacts.require('TokenRewardVault')
const TokenRewardVault2 = artifacts.require('TokenRewardVault2')


module.exports = async function(deployer, network, accounts) {
  // Deploy Mock DAI Token
  await deployer.deploy(DaiToken)
  const daiToken = await DaiToken.deployed()

  // Deploy MHG Token
  await deployer.deploy(MhgToken)
  const mhgToken = await MhgToken.deployed()

  

  // Deploy TokenRewardVault
  await deployer.deploy(TokenRewardVault, mhgToken.address, daiToken.address)
  const tokenRewardVault = await TokenRewardVault.deployed()

    // Deploy TokenRewardVault
    await deployer.deploy(TokenRewardVault2, mhgToken.address)
    const tokenRewardVault2 = await TokenRewardVault2.deployed()
  
    // Transfer 1 million tokens to TokenRewardVault (1 million)
  await mhgToken.transfer(tokenRewardVault.address, '1000000000000000000000000')

  // Transfer 1 million tokens to TokenRewardVault (1 million)
  await mhgToken.transfer(tokenRewardVault2.address, '1000000000000000000000000')


  // Transfer 100 Mock DAI tokens to investor
  await daiToken.transfer(accounts[1], '100000000000000000000')


}
