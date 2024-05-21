/* eslint-disable jsx-a11y/anchor-is-valid */
import React, { useState, useEffect } from 'react';
import { Navigate } from 'react-router-dom';
//Auth related imports
import { awsExports } from '../aws-exports';
import { Authenticator } from '@aws-amplify/ui-react';
import '../App.css';
import '@aws-amplify/ui-react/styles.css';
import { Auth, Amplify, Logger, Hub  } from 'aws-amplify';
import Popup from '../popup';

Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

const Users = ({ toggleButton, handleJwtToken }) => {
  const [jwtToken, setJwtToken] = useState('');
  const logger = new Logger('Logger', 'INFO');
  const [isSignedUp, setIsSignedUp] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const [newUserEmail, setNewUserEmail] = useState('');
  const [isSuccessful, setIsSuccessful] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const togglePopup = () => {
    setIsOpen(!isOpen);
  }


  useEffect(() => {
      fetchJwtToken();
  }, []);
  
  const fetchJwtToken = async () => {
      try {
          const currentUser = await Auth.currentAuthenticatedUser();
          const session = await Auth.currentSession();
          const token = session.getIdToken().getJwtToken();
          setJwtToken(token);
          handleJwtToken(token); // Pass jwtToken back to App.js

      } catch (error) {
          console.log('Error fetching JWT token:', error);
      }
      };

    const handleSignUp = async (event) => {
        event.preventDefault();
        const formData = new FormData(event.target);
        const email = formData.get('email');
        const password = formData.get('password');
        const firstName = formData.get('given_name');
        const middleName = formData.get('middle_name');
        const lastName = formData.get('family_name');
        const nickname = formData.get('nickname');
    
        try {
          const { user } = await Auth.signUp({
            username: email,
            password,
            attributes: {
              email,
              given_name: firstName,
              middle_name: middleName,
              family_name: lastName,
              nickname
            }
          });
          console.log('user:', user);
          setNewUserEmail(email);
          setIsSignedUp(true);
          setIsSuccessful(true);
          togglePopup();
        } catch (error) {
          togglePopup();
          setIsSuccessful(false);
          setNewUserEmail(email);
          setErrorMessage(error.message);
          console.log('Error signing up:', error);
        }
      };
    
      if (isSignedUp) {
        //return <Redirect to="/Home" />;
      }
    
      return (
        <div>
        <form onSubmit={handleSignUp} class="create-form">
          <h1 style={{"text-align": "center"}}>Manage researchers</h1>
          <br></br>
          <h2>Create an account</h2>
          <br></br>
          <div className="mb-3">
            <label>Email</label>
            <input type="email" className="form-control" placeholder="Enter email" name="email" required />
          </div>
          <div className="mb-3">
            <label>Password</label>
            <input type="password" className="form-control" placeholder="Enter password" name="password" required />
          </div>
          <div className="mb-3">
            <label>First name</label>
            <input type="text" className="form-control" placeholder="" name="given_name" required />
          </div>
          <div className="mb-3">
            <label>Middle name</label>
            <input type="text" className="form-control" placeholder="" name="middle_name" required/>
          </div>
          <div className="mb-3">
            <label>Last name</label>
            <input type="text" className="form-control" placeholder="" name="family_name" required />
          </div>
          <div className="mb-3">
            <label>Nickname</label>
            <input type="text" className="form-control" placeholder="" name="nickname" required/>
          </div>
          <div className="d-grid">
            <button type="submit" className="btn btn-primary">Create</button>
          </div>
          {errorMessage && <p className="error-message">{errorMessage}</p>}
        </form>
        <br/>
        <h2 style={{"text-align": "center"}}>Registered researchers</h2>
        <li style={{"text-align": "center", "font-size": "2em"}}>N. Jones</li>

        {isOpen && isSuccessful && <Popup
          content={<>
            <b>Account {newUserEmail} is successfully created!</b>
          </>}
          handleClose={togglePopup}
        />}

        {isOpen && !isSuccessful &&<Popup
          content={<>
            <b>Failed to create account {newUserEmail}.</b>
            <p>Error: {errorMessage}</p>
          </>}
          handleClose={togglePopup}
        />}
        </div>
  );
};

export default Users;
