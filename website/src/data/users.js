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
import axios from 'axios';

Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

const Users = ({ toggleButton, handleJwtToken , jwtToken}) => {
  const [createdUsers, setCreatedUsers] = useState([]);
  const [isSignedUp, setIsSignedUp] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [newUserEmail, setNewUserEmail] = useState('');
  const [isSuccessful, setIsSuccessful] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [idToken, setIdToken] = useState(null); 

  const togglePopup = () => {
    setIsOpen(!isOpen);
  };
  

  useEffect(() => {
    const fetchIdToken = async () => {
      try {
        const session = await Auth.currentSession();
        const token = session.getIdToken();
        setIdToken(token);
      } catch (error) {
        console.error('Error fetching ID token:', error);
      }
    };

    fetchIdToken();
  }, []);

  useEffect(() => {
    const fetchResearchers = async () => {
      try {
        const response = await axios.get(`${awsExports.API_ENDPOINT}/researchers`, {
          headers: { Authorization: `Bearer ${idToken.getJwtToken()}` },
          withCredentials: true,
        });
  
        if (response.data && Array.isArray(response.data.data)) {
          setCreatedUsers(response.data.data);
        } else {
          setCreatedUsers(response.data.data);
        }
      } catch (error) {
        console.error('Error fetching researchers:', error);
      }
    };

    if (idToken) {
      fetchResearchers();
    }
  }, [idToken, newUserEmail]);
  
  const handleSignUp = async (event) => {
    event.preventDefault();
    const formData = new FormData(event.target);
    const email = formData.get('email');
    const firstName = formData.get('given_name');
    const lastName = formData.get('family_name');

    if (!idToken) {
      console.error('Missing JWT token for signup');
      return;
    }

    try {
      const response = await axios.post(
        `${awsExports.API_ENDPOINT}/researchers`,
        {
          given_name: firstName,
          family_name: lastName,
          email,
        },
        {
          headers: {
            Authorization: `Bearer ${idToken.getJwtToken()}`,
          },
          withCredentials: true,
        }
      );

      setNewUserEmail(email);
      setIsSignedUp(true);
      setIsSuccessful(true);
      togglePopup();
    } catch (error) {
      togglePopup();
      setIsSuccessful(false);
      setErrorMessage(error.message);
      console.error('Error signing up:', error);
    }
  };

    if (isSignedUp) {
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
            <label>First name</label>
            <input type="text" className="form-control" placeholder="Enter given name" name="given_name" required />
          </div>
          <div className="mb-3">
            <label>Last name</label>
            <input type="text" className="form-control" placeholder="Enter family name" name="family_name" required />
          </div>
          <div className="d-grid">
            <button type="submit" className="btn btn-primary">Create</button>
          </div>
          {errorMessage && <p className="error-message">{errorMessage}</p>}
          <br/>
          <h2 style={{"text-align": "center"}}>Registered researchers</h2>
          <div className="researchers-list">
          {createdUsers.map((user) => ( 
          <div key={user.id} className="card mb-3"> {/* Access user.id directly */}
            <div className="card-body">
              <p className="card-text" style={{ textAlign: "center" }}>
                {user.id} {/* Display the user's ID */}
              </p>
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
