//import logo from './data/neox.svg';
//import button from './data/button.png';
import './App.css';
import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, Navigate } from 'react-router-dom'
import Login from './data/login'
import Users from './data/users'
import Home from './data/home'
import Create from './data/create'
import PrivateRoutes from './data/privateRoutes'
import DisplayChart from './data/displayChart'
import '../node_modules/bootstrap/dist/css/bootstrap.min.css'
import logo from './data/neox.svg';

//Auth related imports
import { awsExports } from './aws-exports';
import '@aws-amplify/ui-react/styles.css';
import { Auth, Amplify,Hub } from "aws-amplify";

Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

function App() {
  // hides and shows contents
  const [showButton, setShowButton] = useState(true);  
  // hides and shows admin contents
  const [isAdmin, setIsAdmin] = useState(false);
  const toggleButton = (value) => {
    setShowButton(value !== undefined ? value : !showButton);
  };

  const toggleAdminContent = (value) => {
    setIsAdmin(value !== undefined ? value : !isAdmin);
  };
  
  const [jwtToken, setJwtToken] = useState(null); // State to store jwtToken
  const handleJwtToken = (token) => {
    setJwtToken(token);
  };

const handleSignOut = async () => {
  try {
    await Auth.signOut();
    console.log('Sign-out successful.');
    window.location.href = '/';
    toggleButton(true);
  } catch (error) {
    console.error('Error signing out:', error);
  }
};

useEffect(() => {
  // Clear authentication tokens upon component mount
  Amplify.Auth.signOut();
}, []);

const listener = (data) => {
  switch (data?.payload?.event) {
    case 'signIn':
      toggleButton(false);
      fetchJwtToken();
      console.log('user signed in');

      break;
    case 'signUp':
      //toggleButton(false);
      console.log('user signed up');
      break;
    case 'signOut':
      toggleButton(true);
      console.log('user signed out');
      break;
  }
};

Hub.listen('auth', listener);


const fetchJwtToken = async () => {
  try {
    const currentUser = await Auth.currentAuthenticatedUser();
    const session = await Auth.currentSession();
    const token = session.getIdToken().getJwtToken();
    setJwtToken(token);
    handleJwtToken(token); // Pass jwtToken back to App.js
    console.log("user belongs to following groups: " + session.getIdToken().payload["cognito:groups"]);
    const groups = session.getIdToken().payload["cognito:groups"];
    if (groups && groups.includes("admins")) {
      setIsAdmin(true);
    }

  } catch (error) {
    console.log('Error fetching JWT token:', error);
  }
};

  return (
    <div className="Background">

      <Router>
        <div className="App">
          <nav className="navbar navbar-expand-lg navbar-light fixed-top">
            <div className="container">
              <Link to={'/'} className="navbar-brand"><img src={logo} alt="NEOX Logo" width="140px" /></Link>
                <ul className="nav">
                  {showButton &&<li className="nav-item"><Link className="nav-link" to={'/'}>Login</Link></li>}
                  {!showButton && isAdmin && <li className="nav-item"><Link className="nav-link" to={'/users'}>Users</Link></li>}
                  {!showButton && isAdmin && <li className="nav-item"><Link className="nav-link" to={'/create'}>New Study</Link></li>}
                  {!showButton && !isAdmin && <li className="nav-item"><Link className="nav-link" to={'/studyData'}>Study Data</Link></li>}
                  {!showButton && ( <li className="nav-item"> <Link className="nav-link" onClick={() => { handleSignOut();}} to={'/'}>Logout</Link></li>)}
                </ul>

            </div>
          </nav>
          <div className="auth-wrapper">
            <div className="auth-inner">
              <Routes>
                {!showButton && !isAdmin && (
                  <Route path="/studyData" element={<DisplayChart />} />
                )}
                <Route path="/"  element={<Login toggleButton={toggleButton} handleJwtToken={handleJwtToken} />}/>
                {!showButton && isAdmin && (
                  <Route path="/users" element={<Users toggleButton={toggleButton} handleJwtToken={handleJwtToken} />} />
                )}
                {!showButton && isAdmin && (
                  <Route path="/create" element={<Create/>} />
                )}
                {!showButton && (
                  <Route path="/home" element={<Home isAdmin={isAdmin} showButton={showButton} />} />
                )}
              </Routes>
            </div>
          </div>

        </div>
      </Router>
      
    </div>  
  );
}

export default App;