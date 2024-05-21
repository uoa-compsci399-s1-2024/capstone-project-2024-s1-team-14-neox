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
  const [createdUsers, setCreatedUsers] = useState([]);
  const logger = new Logger('Logger', 'INFO');
  const [isSignedUp, setIsSignedUp] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const [newUserEmail, setNewUserEmail] = useState('');
  const [isSuccessful, setIsSuccessful] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const togglePopup = () => {
    setIsOpen(!isOpen);
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
        setCreatedUsers((prevUsers) => [...prevUsers, { email, firstName, lastName, nickname }]);
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
        <h1 style={{"text-align": "center"}}>Manage researchers</h1>
        <h2 style={{"text-align": "center"}}>Create an account</h2>
        <form onSubmit={handleSignUp} class="user-form">

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
          <br/>
          <h2 style={{"text-align": "center"}}>Registered researchers</h2>
          <div className="researchers-list">
            {createdUsers.map((user, index) => (
                <div key={index} className="card mb-3">
                  <div className="card-body">
                    <p className="card-text" style={{"text-align": "center"}}>{user.lastName} | {user.email}</p>
                  </div>
                </div>
              ))}
          </div>
        </form>

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
