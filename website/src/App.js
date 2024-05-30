//import logo from './data/neox.svg';
//import button from './data/button.png';
import './App.css';
import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Link, Navigate } from 'react-router-dom';
import Login from './data/login';
import Users from './data/users';
import Popup from './popup';
import AccessDenied from './data/accessDenied';
import Home from './data/home';
import Create from './data/create';
import PrivateRoutes from './data/privateRoutes';
import DisplayChart from './data/displayChart';
import '../node_modules/bootstrap/dist/css/bootstrap.min.css';
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

  //trigger for popup box
  const [isOpen, setIsOpen] = useState(false);
  const togglePopup = () => {
    setIsOpen(!isOpen);
  }
  // State to store jwtToken
  const [jwtToken, setJwtToken] = useState(null); 
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
    fetchJwtToken();
  }, []);

  const listener = (data) => {
    switch (data?.payload?.event) {
      case 'signIn':
        toggleButton(false);
        fetchJwtToken();
        console.log('user signed in');
        break;
      case 'signUp':
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
      handleJwtToken(token);
      console.log("user belongs to following groups: " + session.getIdToken().payload["cognito:groups"]);
      const groups = session.getIdToken().payload["cognito:groups"];
      if (groups && groups.includes("admins")) {
        setIsAdmin(true);
      }else if (groups && groups.includes("researchers")){
        
      }else{
        handleSignOut();
        alert("The email does not exist");
      }
      //console.log('token is ', token);
      toggleButton(false);
    } catch (error) {
      console.log('Error fetching JWT token:', error);
      toggleButton(true);
      setIsAdmin(false);
    }
  };

  return (
    <div className="Background">

      <Router>
        <div className="App">
          <nav className="navbar navbar-expand-lg navbar-light fixed-top" style={{"border-bottom": "solid", "background-color": "white"}}>            
            <div className="container">
            {showButton && <Link to={'/'} className="navbar-brand"><img src={logo} alt="NEOX Logo" width="140px" /></Link>}
            {!showButton && <Link to={'/home'} className="navbar-brand"><img src={logo} alt="NEOX Logo" width="140px" /></Link>}
                <ul className="nav">
                  {!showButton && ( <li className="nav-item"> <Link className="nav-link" to={'/home'}>Home</Link></li>)}
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
                  <Route path="/create" element={<Create handleJwtToken={handleJwtToken}/>} />
                )}
                {!showButton && (
                  <Route path="/home" element={<Home isAdmin={isAdmin} showButton={showButton} handleJwtToken={handleJwtToken} />} />
                )}
                <Route path="/accessDenied" element={<AccessDenied/>} />
              </Routes>
            </div>
          </div>

        </div>
      </Router>
    </div>  
  );
}

export default App;