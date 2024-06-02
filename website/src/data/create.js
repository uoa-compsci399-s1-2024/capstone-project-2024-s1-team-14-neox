/* eslint-disable jsx-a11y/anchor-is-valid */
import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';

//Auth related imports
import { awsExports } from '../aws-exports';
import '../App.css';
import '@aws-amplify/ui-react/styles.css';
import { Auth, Amplify, Logger  } from 'aws-amplify';

//date range picker
import { DateRangePicker } from 'rsuite';
import 'rsuite/dist/rsuite.min.css';
import { format } from 'date-fns';

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
    
    const navigate = useNavigate();
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
          try{
            const session = await Auth.currentSession();
            const idToken = session.getIdToken();
            const jwtToken = idToken.getJwtToken()
            event.preventDefault();
            const formData = new FormData(event.target);
            const title = formData.get('title');
            const id = formData.get('id');
            const description = formData.get('description');
            const study = await fetch(awsExports.API_ENDPOINT + "/studies/" + id, {
              method: "put",
              mode: "cors",
              headers: {
                "Authorization": "Bearer " + jwtToken
              },
              credentials: 'include',
              body: JSON.stringify({
                "name": title,
                "description": description,
                "start_date": format(startDate, "yyyy-MM-dd"),
                "end_date": format(endDate, "yyyy-MM-dd")
              })
            })
            navigate("/home"); 
          } catch (error) {
            console.log("Error creating study", error)
          }

          };

        
          return (
            <div>
              <h2 style={{"text-align": "center"}}>Begin a new study</h2>
              <br></br>
            <form class="create-form" onSubmit={handleSubmit}>
              
              <div className="mb-3">
                <label>Study Name</label>
                <input type="text" className="form-control" placeholder="" name="title" required />
              </div>
              <div className="mb-3">
                <label>Study ID</label>
                <input type="text" className="form-control" placeholder="" name="id" required/>
              </div>
              <div className="mb-3" style={{"height": "30%"}}>
                <label>Description</label>
                <input type="text" className="form-control" placeholder="" name="description" required />
              </div>
              <div className="mb-3" style={{"text-align": "center"}}>
              <DateRangePicker
                placeholder="Set Start and End Dates"
                format="dd/MM/yyyy"
                size="lg"
                onChange={handleDateChange}
              />
              </div>
              <div className="d-grid" style={{"width": "100%"}}>
                <button type="submit" className="btn btn-primary" onClick={() => handleSubmit}>Create</button>
              </div>
              <br></br>
              <div className="d-grid" style={{"width": "100%"}}>
                <Link to="/" className="btn btn-primary">Back to Home</Link>
              </div>
              {errorMessage && <p className="error-message">{errorMessage}</p>}
            </form>

            </div>
  );
};

export default Create;
