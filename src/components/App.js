import React, { Component } from 'react'
import Web3 from 'web3'
import DaiToken from '../abis/DaiToken.json'
import MhgToken from '../abis/MhgToken.json'
import TokenRewardVault from '../abis/TokenRewardVault.json'
import TokenRewardVault2 from '../abis/TokenRewardVault2.json'
import Navbar from './Navbar'
import Main from './Main'
import Main2 from './Main2'
import './App.css'

class App extends Component {

  async componentWillMount() {
    await this.loadWeb3()
    await this.loadBlockchainData()
  }

  async loadBlockchainData() {
    const web3 = window.web3

    const accounts = await web3.eth.getAccounts()
    this.setState({ account: accounts[0] })

    const networkId = await web3.eth.net.getId()

    // Load DaiToken
    const daiTokenData = DaiToken.networks[networkId]
    if(daiTokenData) {
      const daiToken = new web3.eth.Contract(DaiToken.abi, daiTokenData.address)
      this.setState({ daiToken })
      let daiTokenBalance = await daiToken.methods.balanceOf(this.state.account).call()
      this.setState({ daiTokenBalance: daiTokenBalance.toString() })
    } else {
      window.alert('DaiToken contract not deployed to detected network.')
    }

    // Load MhgToken
    const mhgTokenData = MhgToken.networks[networkId]
    if(mhgTokenData) {
      const mhgToken = new web3.eth.Contract(MhgToken.abi, mhgTokenData.address)
      this.setState({ mhgToken })
      let mhgTokenBalance = await mhgToken.methods.balanceOf(this.state.account).call()
      this.setState({ mhgTokenBalance: mhgTokenBalance.toString() })
    } else {
      window.alert('MhgToken contract not deployed to detected network.')
    }

    // Load TokenRewardVault
    const tokenRewardVaultData = TokenRewardVault.networks[networkId]
    if(tokenRewardVaultData) {
      const tokenRewardVault = new web3.eth.Contract(TokenRewardVault.abi, tokenRewardVaultData.address)
      this.setState({ tokenRewardVault })
      let stakingBalance = await tokenRewardVault.methods.stakingBalance(this.state.account).call()
      this.setState({ stakingBalance: stakingBalance.toString() })
    } else {
      window.alert('TokenRewardVault contract not deployed to detected network.')
    }

      // Load TokenRewardVault2
      const tokenRewardVault2Data = TokenRewardVault2.networks[networkId]
      if(tokenRewardVault2Data) {
        const tokenRewardVault2 = new web3.eth.Contract(TokenRewardVault2.abi, tokenRewardVault2Data.address)
        this.setState({ tokenRewardVault2 })
        let stakingBalanceMhg = await tokenRewardVault2.methods.stakingBalanceMhg(this.state.account).call()
        this.setState({ stakingBalanceMhg: stakingBalanceMhg.toString() })
      } else {
        window.alert('TokenRewardVault2 contract not deployed to detected network.')
      }

    this.setState({ loading: false })
  }

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum)
      await window.ethereum.enable()
    }
    else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider)
    }
    else {
      window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  }

  stakeTokens = (amount) => {
    this.setState({ loading: true })
    this.state.daiToken.methods.approve(this.state.tokenRewardVault._address, amount).send({ from: this.state.account }).on('transactionHash', (hash) => {
      this.state.tokenRewardVault.methods.stakeTokens(amount).send({ from: this.state.account }).on('transactionHash', (hash) => {
        this.setState({ loading: false })
      })
    })
  }

  unstakeTokens = (amount,) => {
    this.setState({ loading: true })
    this.state.tokenRewardVault.methods.unstakeTokens().send({ from: this.state.account }).on('transactionHash', (hash) => {
      this.setState({ loading: false })
    })
  }

  stakeMhgTokens = (amount) => {
    this.setState({ loading: true })
    this.state.mhgToken.methods.approve(this.state.tokenRewardVault2._address, amount).send({ from: this.state.account }).on('transactionHash', (hash) => {
      this.state.tokenRewardVault2.methods.stakeMhgTokens(amount).send({ from: this.state.account }).on('transactionHash', (hash) => {
        this.setState({ loading: false })
      })
    })
  }

  unstakeMhgTokens = (amount,) => {
    this.setState({ loading: true })
    this.state.tokenRewardVault2.methods.unstakeMhgTokens().send({ from: this.state.account }).on('transactionHash', (hash) => {
      this.setState({ loading: false })
    })
  }

  constructor(props) {
    super(props)
    this.state = {
      account: '0x0',
      daiToken: {},
      mhgToken: {},
      tokenFarm: {},
      daiTokenBalance: '0',
      mhgTokenBalance: '0',
      stakingBalance: '0',
      stakingBalanceMhg: '0',
      loading: true
    }
  }

  render() {
    let content, content2
    if(this.state.loading) {
      content = <p id="loader" className="text-center">Loading...</p>
    } else {
      content = <Main
        daiTokenBalance={this.state.daiTokenBalance}
        mhgTokenBalance={this.state.mhgTokenBalance}
        stakingBalance={this.state.stakingBalance}
        stakingBalanceMhg={this.state.stakingBalanceMhg}
        stakeTokens={this.stakeTokens}
        unstakeTokens={this.unstakeTokens}
        stakeMhgTokens={this.stakeMhgTokens}
        unstakeMhgTokens={this.unstakeMhgTokens}
      />
    
      content2 = <Main2
      daiTokenBalance={this.state.daiTokenBalance}
      mhgTokenBalance={this.state.mhgTokenBalance}
      stakingBalance={this.state.stakingBalance}
      stakingBalanceMhg={this.state.stakingBalanceMhg}
      stakeMhgTokens={this.stakeMhgTokens}
      unstakeMhgTokens={this.unstakeMhgTokens}
    />
    }
    

    return (
      <div>
        <Navbar account={this.state.account} />
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: '600px' }}>
              <div className="content mr-auto ml-auto">
                <a
                  href="http://www.moneyhoardersglobal.net"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                </a>

                {content}
                

              </div>
              {content2}
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
