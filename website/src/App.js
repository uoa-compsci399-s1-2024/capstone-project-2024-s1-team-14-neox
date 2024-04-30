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
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import { Auth, Amplify } from "aws-amplify";

Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

async function handleSignOut(toggleButton) {
  try {
    await Auth.signOut();
    console.log('Sign-out successful.');
    window.location.href = '/sign-in';
    toggleButton(true);
  } catch (error) {
    console.error('Error signing out:', error);
  }
}

function App() {

  const [showButton, setShowButton] = useState(true);  
  const toggleButton = (value) => {
    setShowButton(value !== undefined ? value : !showButton);
  };
  
  const [jwtToken, setJwtToken] = useState(null); // State to store jwtToken
  const handleJwtToken = (token) => {
    setJwtToken(token);
  };

  return (
    <div className="Background">

      <Router>
        <div className="App">
          <nav className="navbar navbar-expand-lg navbar-light fixed-top">
            <div className="container">
              <Link className="navbar-brand" to={'/Home'}>NEOX</Link>

                <ul className="nav">
                  {showButton &&<li className="nav-item"><Link className="nav-link" to={'/sign-in'}>Login</Link></li>}
                  {!showButton &&<li className="nav-item"><Link className="nav-link" to={'/display-chart'}>Child Data</Link></li>}
                  {!showButton && ( <li className="nav-item"> <Link className="nav-link" onClick={() => { handleSignOut(toggleButton(true));}} to={'/sign-in'}>Logout</Link></li>)}
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