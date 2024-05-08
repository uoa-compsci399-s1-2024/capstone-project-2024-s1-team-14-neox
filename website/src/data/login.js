/* eslint-disable jsx-a11y/anchor-is-valid */
import React, { useState, useEffect } from 'react';
import { Navigate } from 'react-router-dom';
import logo from './neox.svg';
import axios from 'axios';
//Auth related imports
import { awsExports } from '../aws-exports';
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import { Auth, Amplify, Logger, Hub  } from 'aws-amplify';

Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

const Login = ({ toggleButton, handleJwtToken }) => {
    const [jwtToken, setJwtToken] = useState('');
    const logger = new Logger('Logger', 'INFO');


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
    

    const handleStateChange = (state) => {
      if (state === 'signUp') {
      // Trigger toggleButton when changing from signIn to signUp
      toggleButton(false);
        console.log('Transitioned from signIn to signUp');
      }
    };
    
    return (
        <Authenticator initialState='signIn' onStateChange={handleStateChange}
        components={{
            SignUp: {
            FormFields() {

                return (
                <>
                    <Authenticator.SignUp.FormFields />

                    <div><label>Email</label></div>
                    <input
                    type="text"
                    name="email"
                    //placeholder="Please enter your Email"
                    />
                    <div><label>First name</label></div>
                    <input
                    type="text"
                    name="given_name"
                    //placeholder="Please enter your first name"
                    />
                    <div><label>Last name</label></div>
                    <input
                    type="text"
                    name="family_name"
                    //placeholder="Please enter your last name"
                    />
                    <div><label>Middle name</label></div>
                    <input
                    type="text"
                    name="middle_name"
                    //placeholder="Please enter your middle name"
                    />
                    <div><label>Nickname</label></div>
                    <input
                    type="text"
                    name="nickname"
                    //placeholder="Please enter your Nickname"
                    />
                </>
                );
            },
            },
        }}
        services={{
            async validateCustomSignUp(formData) {
            if (!formData.given_name) {
                return {
                given_name: 'First Name is required',
                };
            }
            if (!formData.family_name) {
                return {
                family_name: 'Last Name is required',
                };
            }
            if (!formData.email) {
                return {
                email: 'Email is required',
                };
            }
            },
        }}
        >
        {({ signOut, user}) => (
            <Navigate to="/display-chart" />
        )}
        </Authenticator>
  );
};

export default Login;
