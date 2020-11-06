import React, { Fragment, useEffect } from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import api from '../../utils/api';
import CompList from '../compositions/CompList';
import { deleteAccount } from '../../actions/profile';

const Dashboard = ({
  deleteAccount,
  auth: { user }
}) => {
  return (
    <Fragment>
		<h1 className="large text-primary">Dashboard</h1>
		<div style={{marginBottom:"35px"}}>
			<p className="lead">Welcome, {user && user.name}</p>
			<p>Email: {user && user.email}</p>
		</div>
		<div style={{minWidth:"700px"}}>
			<div style={{width:"100%",borderBottom:"2px solid #17a2b8"}}>
				<p style={{fontSize:"2em"}}>My Compositions</p>
			</div>
			<div style={{textAlign:"center",padding:"10px"}}>
				<CompList list={api.get("/compositions/usercompositions")}/>
			</div>
			<div className="my-2">
				<button className="btn btn-danger" onClick={() => deleteAccount()}>
					Delete My Account
				</button>
			</div>
		</div>
    </Fragment>
  );
};


Dashboard.propTypes = {
  deleteAccount: PropTypes.func.isRequired,
  auth: PropTypes.object.isRequired,
};

const mapStateToProps = (state) => ({
  auth: state.auth
});

export default connect(mapStateToProps, { deleteAccount })(
  Dashboard
);
