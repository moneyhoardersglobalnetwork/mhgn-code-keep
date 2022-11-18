const DaiToken = artifacts.require('DaiToken')
const MhgToken = artifacts.require('MhgToken')
const TokenRewardVault = artifacts.require('TokenRewardVault')

require('chai')
  .use(require('chai-as-promised'))
  .should()

function tokens(n) {
  return web3.utils.toWei(n, 'ether');
}

contract('TokenRewardVault', ([owner, investor]) => {
  let daiToken, mhgToken, tokenRewardVault

  before(async () => {
    // Load Contracts
    daiToken = await DaiToken.new()
    mhgToken = await MhgToken.new()
    tokenRewardVault = await TokenRewardVault.new(mhgToken.address, daiToken.address)

    // Transfer all MHG tokens to farm (1 million)
    await mhgToken.transfer(tokenRewardVault.address, tokens('1000000'))

    // Send tokens to investor
    await daiToken.transfer(investor, tokens('100'), { from: owner })
  })

  describe('Mock DAI deployment', async () => {
    it('has a name', async () => {
      const name = await daiToken.name()
      assert.equal(name, 'Mock DAI Token')
    })
  })

  describe('MHG Token deployment', async () => {
    it('has a name', async () => {
      const name = await mhgToken.name()
      assert.equal(name, 'MHG Token')
    })
  })

  describe('Token Reward Vault deployment', async () => {
    it('has a name', async () => {
      const name = await tokenRewardVault.name()
      assert.equal(name, 'Token Reward Vault')
    })

    it('contract has tokens', async () => {
      let balance = await mhgToken.balanceOf(tokenRewardVault.address)
      assert.equal(balance.toString(), tokens('1000000'))
    })
  })

  describe('Farming tokens', async () => {

    it('rewards investors for staking mDai tokens', async () => {
      let result

      // Check investor balance before staking
      result = await daiToken.balanceOf(investor)
      assert.equal(result.toString(), tokens('100'), 'investor Mock DAI wallet balance correct before staking')

      // Stake Mock DAI Tokens
      await daiToken.approve(tokenFarm.address, tokens('100'), { from: investor })
      await tokenFarm.stakeTokens(tokens('100'), { from: investor })

      // Check staking result
      result = await daiToken.balanceOf(investor)
      assert.equal(result.toString(), tokens('0'), 'investor Mock DAI wallet balance correct after staking')

      result = await daiToken.balanceOf(tokenFarm.address)
      assert.equal(result.toString(), tokens('100'), 'Token Farm Mock DAI balance correct after staking')

      result = await tokenFarm.stakingBalance(investor)
      assert.equal(result.toString(), tokens('100'), 'investor staking balance correct after staking')

      result = await tokenFarm.isStaking(investor)
      assert.equal(result.toString(), 'true', 'investor staking status correct after staking')

      // Issue Tokens
      await tokenFarm.issueTokens({ from: owner })

      // Check balances after issuance
      result = await dappToken.balanceOf(investor)
      assert.equal(result.toString(), tokens('100'), 'investor DApp Token wallet balance correct affter issuance')

      // Ensure that only onwer can issue tokens
      await tokenFarm.issueTokens({ from: investor }).should.be.rejected;

      // Unstake tokens
      await tokenFarm.unstakeTokens({ from: investor })

      // Check results after unstaking
      result = await daiToken.balanceOf(investor)
      assert.equal(result.toString(), tokens('100'), 'investor Mock DAI wallet balance correct after staking')

      result = await daiToken.balanceOf(tokenFarm.address)
      assert.equal(result.toString(), tokens('0'), 'Token Farm Mock DAI balance correct after staking')

      result = await tokenFarm.stakingBalance(investor)
      assert.equal(result.toString(), tokens('0'), 'investor staking balance correct after staking')

      result = await tokenFarm.isStaking(investor)
      assert.equal(result.toString(), 'false', 'investor staking status correct after staking')
    })
  })

})
