import React, { Component } from 'react'
import blocksofpassion from '../blocksofpassion.jpg'

class Navbar extends Component {

  render() {
    return (
      <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
        <a
          className="navbar-brand col-sm-3 col-md-2 mr-0"
          href="http://www.moneyhoardersglobal.net"
          target="_blank"
          rel="noopener noreferrer"
        >
          <img src={blocksofpassion} width="30" height="30" className="d-inline-block align-top" alt="" />
          &nbsp; Blocks Of Passion Protocol
        </a>

        <ul className="navbar-nav px-3">
          <li className="nav-item text-nowrap d-none d-sm-none d-sm-block">
            <small className="text-secondary">
              <small id="account">{this.props.account}</small>
            </small>
          </li>
        </ul>
      </nav>
    );
  }
}

export default Navbar;
