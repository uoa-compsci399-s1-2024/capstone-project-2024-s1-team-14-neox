//import logo from './data/neox.svg';
//import button from './data/button.png';
import './App.css';
import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, Navigate } from 'react-router-dom'
import Login from './data/login'
import Home from './data/home'
import PrivateRoutes from './data/PrivateRoute'
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

  const [showButton, setShowButton] = useState(true);  
  const toggleButton = (value) => {
    setShowButton(value !== undefined ? value : !showButton);
  };
  
  const [jwtToken, setJwtToken] = useState(null); // State to store jwtToken
  const handleJwtToken = (token) => {
    setJwtToken(token);
  };

const handleSignOut = async () => {
  try {
    await Auth.signOut();
    console.log('Sign-out successful.');
    window.location.href = '/sign-in';
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

  return (
    <div className="Background">

      <Router>
        <div className="App">
          <nav className="navbar navbar-expand-lg navbar-light fixed-top">
            <div className="container">
              <Link to={'/Home'} className="navbar-brand">   <img src={logo} alt="NEOX Logo" width="30px" /> NEOX LABS</Link>

                <ul className="nav">
                  {showButton &&<li className="nav-item"><Link className="nav-link" to={'/sign-in'}>Login</Link></li>}
                  {!showButton &&<li className="nav-item"><Link className="nav-link" to={'/display-chart'}>Child Data</Link></li>}
                  {!showButton && ( <li className="nav-item"> <Link className="nav-link" onClick={() => { handleSignOut();}} to={'/sign-in'}>Logout</Link></li>)}
                </ul>

            </div>
          </nav>
          <div className="auth-wrapper">
            <div className="auth-inner">
              <Routes>
                <Route element={<PrivateRoutes/>}>
                  <Route path="/display-chart" component={DisplayChart}/>
                </Route>
                <Route path="/"  element={<Home/>} exact/>
                <Route path="/sign-in" element={<Login toggleButton={toggleButton} handleJwtToken={handleJwtToken} />} />
                <Route path="/home"  element={<Home/>} exact/>
              </Routes>
            </div>
          </div>

        </div>
      </Router>
      
    </div>  
  );
}

export default App;