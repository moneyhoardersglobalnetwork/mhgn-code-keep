import React, { Component } from 'react'
import mhgpurp from '../mhgpurp.png'

class Main2 extends Component {

  render() {
    return (
      <div id="content" className="mt-3">
       
 <div>Once you've got some CultureCoin take those MHG tokens and earn even more rewards.</div>
CultureCoin will be the native asset of MHGN's CultureChain node implementation built with Substrate. The future is multi-chain and we embrace the future!
        
          
        
        <table className="table table-borderless text-muted text-center">
          <thead>
            <tr>
              <th scope="col">Hoarding Balance</th>
              <th scope="col">Free Balance MHG</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{window.web3.utils.fromWei(this.props.stakingBalanceMhg, 'Ether')} MHG</td>
              <td>{window.web3.utils.fromWei(this.props.mhgTokenBalance, 'Ether')} MHG</td>
            </tr>
          </tbody>
        </table>
        <div className="card mb-4" >

<div className="card-body">
<div className="input-group-append">
        <div className="input-group-text">
          <div></div>
          <img src={mhgpurp} height='64' alt=""/>
          &nbsp;&nbsp;&nbsp; MHG
        </div>
      </div>
  <form className="mb-3" onSubmit={(event) => {
      event.preventDefault()
      let amount
      amount = this.input.value.toString()
      amount = window.web3.utils.toWei(amount, 'Ether')
      this.props.stakeMhgTokens(amount)
    }}>
    <div>
      <label className="float-left"><b>Stake MHG earn MHG</b></label>
      <span className="float-right text-muted">
        Balance: {window.web3.utils.fromWei(this.props.mhgTokenBalance, 'Ether')}
      </span>
    </div>
    <div className="input-group mb-4">
      <input
        type="text"
        ref={(input) => { this.input = input }}
        className="form-control form-control-lg"
        placeholder="0"
        required />
     
    </div>
    <button type="submit" className="btn btn-primary btn-block btn-lg">STAKE MHG!</button>
  </form>
  <button
    type="submit"
    className="btn btn-link btn-block btn-sm"
    onClick={(event) => {
      event.preventDefault()
      this.props.unstakeMhgTokens()
    }}>
      UN-STAKE MHG...
    </button>
</div>

</div>
        
      </div>
    );
  }
}

export default Main2;
