import React, { Fragment, useEffect } from 'react';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import api from '../../utils/api';
import CompList from '../CompList';
// import DashboardActions from './DashboardActions';
// import Experience from './Experience';
// import Education from './Education';
import { getCurrentProfile, deleteAccount } from '../../actions/profile';

const Dashboard = ({
  getCurrentProfile,
  deleteAccount,
  auth: { user },
  profile: { profile }
}) => {
  useEffect(() => {
    getCurrentProfile();
  }, [getCurrentProfile]);
  
  
  var res = api.get("/compositions/user/"+user._id)
  return (
    <Fragment>
      <h1 className="large text-primary">Dashboard</h1>
      <div style={{marginBottom:"35px"}}>
		  <p className="lead">Welcome, {user && user.name}</p>
		  <p>Email: {user && user.email}</p>
	  </div>
      {profile !== null ? (
        <div style={{minWidth:"700px"}}>
          <div style={{width:"100%",borderBottom:"2px solid #17a2b8"}}>
			<p style={{fontSize:"2em"}}>My Compositions</p>
		  </div>
		  <div style={{textAlign:"center",padding:"10px"}}>
			<CompList list={res}/>
          </div>
		  <div className="my-2">
            <button className="btn btn-danger" onClick={() => deleteAccount()}>
              Delete My Account
            </button>
          </div>
        </div>
      ) : (
        <Fragment>
          Loading recordings...
        </Fragment>
      )}
    </Fragment>
  );
};


Dashboard.propTypes = {
  getCurrentProfile: PropTypes.func.isRequired,
  deleteAccount: PropTypes.func.isRequired,
  auth: PropTypes.object.isRequired,
  profile: PropTypes.object.isRequired
};

const mapStateToProps = (state) => ({
  auth: state.auth,
  profile: state.profile
});

export default connect(mapStateToProps, { getCurrentProfile, deleteAccount })(
  Dashboard
);
