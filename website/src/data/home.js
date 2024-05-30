import React, { useEffect, useState } from "react";
import { Link } from 'react-router-dom';
import { Auth, Amplify } from 'aws-amplify';
import { Card } from '@aws-amplify/ui-react';
import { awsExports } from "../aws-exports";

Amplify.configure({
    Auth: {
      region: awsExports.REGION,
      userPoolId: awsExports.USER_POOL_ID,
      userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
    }
  });

const baseURI = "https://xu31tcdj0e.execute-api.ap-southeast-2.amazonaws.com/dev"

const Home = ({ isAdmin, showButton }) => {
    const [familyName, setFamilyName] = useState(null);
    const [studies, setStudies] = useState([])
    const [jwtToken, setJwtToken] = useState(null); 

    const fetchJwtToken = async() => {
        const session = await Auth.currentSession();
        const token = session.getIdToken().getJwtToken();
        setJwtToken(token);
    }
    fetchJwtToken();

    useEffect(() => {
        async function fetchFamilyName() {
            try {
                const user = await Auth.currentAuthenticatedUser();
                const attributes = user.attributes;
                setFamilyName(attributes.family_name);
            } catch (error) {
                console.error('Error fetching family name:', error);
            }
        }

        fetchFamilyName();
    }, []);

    useEffect(() => {
        async function fetchStudies() {
            try {
            const user = await Auth.currentAuthenticatedUser()
            const attributes = user.attributes;
            const email = attributes.email;
            const data = await fetch("https://xu31tcdj0e.execute-api.ap-southeast-2.amazonaws.com/dev/researchers/gabriel.lisaca+admin@gmail.com/studies", {
                method: 'GET',
                mode: 'no-cors',
                headers: {
                    'Authorization': 'Bearer ' + jwtToken
                },
            })
            console.log(data.json())
            } catch (error) {
                console.error('Error fetching study data', error);
            }
        }
        fetchStudies()
    }, [])
    
    

    return (
        <div class="home-body">
            <h1>Welcome {familyName}!</h1>
            {isAdmin ? (
                <div>
                    <h4>Admin</h4>
                    <div className="d-grid">
                        <Link to="/create" className="btn btn-primary">Start a new study</Link>
                    </div>
                </div>
            ):(null)}
            <hr/>
            <div class="studies">
                <h3>Current Studies</h3>               
                <div class="study-card">
                
                {studies.map(study =>
                <Card variation="elevated" key={study.id}>
            
                    <h5 style={{"text-align": "center", "font-style": "italic"}}>ID {study.id}</h5>
                    <hr/>
                    <h3 style={{"text-align": "center"}}>{study.title}</h3>
                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{study.description} </h5>
                    <h5><span class="card-titles">Period:</span> {studies.startDate} - {study.endDate} </h5>
                    <h5><span class="card-titles bottom">Researchers:</span></h5>                  
                    <div class="d-table-row gap-2 d-md-flex justify-content-md-end">
                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                        {isAdmin ? (
                            <button type="button" class="btn btn-outline-primary" //onClick={() => alert("Works!")}
                            >Manage Researchers</button>
                        ) : (null)}
                    </div>
                </Card>
                )}
            </div>
                
            </div>
            {isAdmin ? (
                null
            ): (<div class="non-admin">
                <p>Don't see a study?</p>
                <p>Request access from the admins</p>
                </div>)}
            </div>
    );
};

export default Home;
