/* eslint-disable jsx-a11y/anchor-is-valid */
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
//Auth related imports
import { awsExports } from '../aws-exports';
import { Authenticator } from '@aws-amplify/ui-react';
import '../App.css';
import '@aws-amplify/ui-react/styles.css';
import { Auth, Amplify, Logger, Hub  } from 'aws-amplify';

//date range picker
import { DateRangePicker } from 'rsuite';
import 'rsuite/dist/rsuite.min.css';

Amplify.configure({
  Auth: {
    region: awsExports.REGION,
    userPoolId: awsExports.USER_POOL_ID,
    userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
  }
});

const Create = ({ toggleButton, handleJwtToken }) => {

    //set startdate and enddate
    const [startDate, setStartDate] = useState(null);
    const [endDate, setEndDate] = useState(null);
    const handleDateChange = (date) => {
        if (date === null) {
        setStartDate(null);
        setEndDate(null);
        } else {
        setStartDate(date[0]);
        setEndDate(date[1]);
        }
    };
    

    const [jwtToken, setJwtToken] = useState('');
    const logger = new Logger('Logger', 'INFO');
    const [isSignedUp, setIsSignedUp] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');


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

        const handleSubmit = async (event) => {
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
              setIsSignedUp(true);
            } catch (error) {
              console.log('Error signing up:', error);
              setErrorMessage(error.message);
            }
          };
        
          if (isSignedUp) {
            //return <Redirect to="/Home" />;
          }
        
          return (
            <div>
            <form onSubmit={handleSubmit}>
              <h2>Begin a new study</h2>
              <br></br>
              <div className="mb-3">
                <label>Name</label>
                <input type="text" className="form-control" placeholder="" name="name" required />
              </div>
              <div className="mb-3">
                <label>Institute</label>
                <input type="text" className="form-control" placeholder="" name="institute" required />
              </div>
              <div className="mb-3">
                <label>Reference Number</label>
                <input type="text" className="form-control" placeholder="" name="referenceNumber" required/>
              </div>
              <div className="mb-3">
              <DateRangePicker
                placeholder="Set Start and End Dates"
                format="dd/MM/yyyy"
                size="lg"
                onChange={handleDateChange}
              />
              </div>
              <div className="d-grid">
                <button type="submit" className="btn btn-primary">Create</button>
              </div>
              <br></br>
              <div className="d-grid">
                <Link to="/" className="btn btn-primary">Back to Home</Link>
              </div>
              {errorMessage && <p className="error-message">{errorMessage}</p>}
            </form>

            </div>
  );
};

export default Create;
