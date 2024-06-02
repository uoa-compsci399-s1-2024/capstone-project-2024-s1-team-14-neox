/* eslint-disable jsx-a11y/anchor-is-valid */
import React from 'react';
import { Navigate } from 'react-router-dom';
import LoginLogo from './loginLogo.svg';
//Auth related imports
import { awsExports } from '../aws-exports';
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import { Amplify  } from 'aws-amplify';



Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

const Login = ({ toggleButton, handleJwtToken }) => {
    
    return (
      <div>
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          <div style={{ textAlign: 'center' }}>
          <img src={LoginLogo} alt="NEOX Logo" width="300px" style={{ paddingBottom: "30px" }} />
              <br></br>
              <h1 style={{ margin: '0', padding: '0' }}>Welcome to Neox Labs</h1>
              <br></br>
              <h2 style={{ margin: '0', padding: '0' }}>Log in to continue</h2>
              <br></br>
          </div>
        </div>
        <Authenticator initialState='signIn' loginMechanisms={['email']} hideSignUp={true}
          components={{
          }}
          services={{
          }}
          >
          {({ signOut, user}) => (
              <Navigate to="/home" />
          )}
        </Authenticator>
      </div>
  );
};

export default Login;
