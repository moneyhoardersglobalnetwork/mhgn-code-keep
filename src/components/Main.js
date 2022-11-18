import React, { Component } from 'react'
import dai from '../dai.png'
import mhgpurp from '../mhgpurp.png'

class Main extends Component {

  render() {
    return (
      <div id="content" className="mt-3">
        <img src={mhgpurp} height='500' alt=""/>
 <div>Welcome all! MHGN Core Devs are working hard during ChainLink's Fall Hackathon to implement new Defi features for Blocks Of Passion Protocol's "BOP" token and "MHG" token.</div>
CultureCoin will be the native asset of MHGN's CultureChain node implementation built with Substrate.
        <table className="table table-borderless text-muted text-center">
          <thead>
            <tr>
              <th scope="col">mDai Hoarding Balance</th>
              <th scope="col">MHG Balance</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{window.web3.utils.fromWei(this.props.stakingBalance, 'Ether')} mDAI</td>
              <td>{window.web3.utils.fromWei(this.props.mhgTokenBalance, 'Ether')} MHG</td>
            </tr>
          </tbody>
        </table>

        <div className="card mb-4" >

          <div className="card-body">

            <form className="mb-3" onSubmit={(event) => {
                event.preventDefault()
                let amount
                amount = this.input.value.toString()
                amount = window.web3.utils.toWei(amount, 'Ether')
                this.props.stakeTokens(amount)
              }}>
              <div>
                <label className="float-left"><b>Stake mDai earn MHG</b></label>
                <span className="float-right text-muted">
                  Balance: {window.web3.utils.fromWei(this.props.daiTokenBalance, 'Ether')}
                </span>
              </div>
              <div className="input-group mb-4">
                <input
                  type="text"
                  ref={(input) => { this.input = input }}
                  className="form-control form-control-lg"
                  placeholder="0"
                  required />
                <div className="input-group-append">
                  <div className="input-group-text">
                    <img src={dai} height='32' alt=""/>
                    &nbsp;&nbsp;&nbsp; mDAI
                  </div>
                </div>
              </div>
              <button type="submit" className="btn btn-primary btn-block btn-lg">STAKE!</button>
            </form>
            <button
              type="submit"
              className="btn btn-link btn-block btn-sm"
              onClick={(event) => {
                event.preventDefault()
                this.props.unstakeTokens()
              }}>
                UN-STAKE...
              </button>
          </div>
          
        </div>
        


        
      </div>
    );
  }
}

export default Main;
