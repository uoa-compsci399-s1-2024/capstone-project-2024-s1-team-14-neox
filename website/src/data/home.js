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


const Home = ({ isAdmin, showButton }) => {
    const [familyName, setFamilyName] = useState(null);
    const [studies, setStudies] = useState([]);
    const [idToken, setIdToken] = useState(null); 

    const fetchIdToken = async() => {
        const session = await Auth.currentSession();
        const token = session.getIdToken();
        setIdToken(token);
    }
    fetchIdToken();

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
        const fetchStudies = async () => {
            try {
            const user = await Auth.currentAuthenticatedUser();
            const session = await Auth.currentSession();
            const idToken = session.getIdToken();
            const attributes = user.attributes;
            const email = attributes.email;
            const data = await fetch(awsExports.API_ENDPOINT + "/researchers/" + email + "/studies", {
                method: 'GET',
                mode: 'no-cors',
                headers: {
                    'Authorization': 'Bearer ' + idToken
                },
            })
            /*const result = await fetch('https://jsonplaceholder.typicode.com/posts')
            const jsonResult = await result.json()*/
            setStudies(data)
            console.log(idToken)
            console.log(data)
            } catch (error) {
                console.error('Error fetching study data', error);
            }
            
        }
        fetchStudies()
    }, [])

    async function removeStudy(id) {
        /*const result = await fetch(awsExports.API_ENDPOINT + "/studies/" + id, { 
            method: "DELETE",
            header: {
                'Authorization': 'Bearer' + jwtToken
            }
        })*/
        console.log("works")
    }
    

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
                {studies.map(study =>              
                <div class="study-card" key={study.id}>
                <Card variation="elevated">
                <button type="button" class="btn btn-link" onClick={() => removeStudy(study.id)} style={{"float": "left", "clear": "none"}}>Delete</button>
                <h5 style={{"text-align": "center", "font-style": "italic", "width": "90%"}}>ID {study.id}</h5>
                    <hr/>
                    <h3 style={{"text-align": "center"}}>{study.title}</h3>
                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{study.completed} </h5>
                    <h5><span class="card-titles">Period:</span> {study.userId} - {study.userId} </h5>
                    <h5><span class="card-titles bottom">Researchers:</span></h5> 
                    <div class="d-table-row gap-4 d-md-flex justify-content-md-end">
                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                        {isAdmin ? (
                                <Link to="/users" type="button" class="btn btn-outline-primary"
                                >Manage Researchers</Link>
                        ) : (null)}
                    </div>
                </Card>
                </div>)}
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
