const TokenRewardVault = artifacts.require('TokenRewardVault')
const TokenRewardVault2 = artifacts.require('TokenRewardVault2')

module.exports = async function(callback) {
  let tokenRewardVault = await TokenRewardVault.deployed()
  await tokenRewardVault.issueTokens()
  let tokenRewardVault2 = await TokenRewardVault2.deployed()
  await tokenRewardVault2.issueTokens()
  // Code goes here...
  console.log("MhgTokens issued for Hoarding mDai!", "MhgTokens issued for Hoarding MHG")
  callback()
}
