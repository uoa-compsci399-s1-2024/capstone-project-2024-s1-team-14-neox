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
    const [Ids, setIds] = useState([]);
    const [studies, setStudies] = useState([])

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
        const fetchIds = async () => {
            try {
            const user = await Auth.currentAuthenticatedUser();
            const session = await Auth.currentSession();
            const idToken = session.getIdToken();
            const attributes = user.attributes;
            const email = attributes.email;
            const getId = await fetch(awsExports.API_ENDPOINT + "/researchers/" + email + "/studies", {
                method: 'GET',
                mode: 'cors',
                headers: {
                    'Authorization': 'Bearer ' + idToken.getJwtToken()
                },
		        credentials: 'include',
            })
            const jsonId = await getId.json()
            const ids = jsonId
            if (typeof(ids) != undefined) {
                setIds([ids])
                //const metadata = await fetchMetadata(Ids)
            }

            console.log(Ids)
            } catch (error) {
                console.error('Error fetching study data', error);
                setIds([])
                console.log(typeof(Ids))
            }
            
        }
        fetchIds()
    }, [])

    /*async function fetchMetadata(Id) {
        try {
        const session = await Auth.currentSession();
        const idToken = session.getIdToken();
        const getMetadata = await fetch(awsExports.API_ENDPOINT + "/studies/" + Id + 'info', {
            method: 'GET',
            mode: 'cors',
            headers: {
                'Authorization': 'Bearer ' + idToken.getJwtToken()
            },
            credentials: 'include',
        })
        const jsonMetadata = await getMetadata.json()
        const metadata = jsonMetadata.data
        console.log(metadata)
        } catch (error) {
            console.error('Error fetching study data', error);
        }
        
    }*/
    
    async function removeStudy(id) {
        const session = await Auth.currentSession();
        const idToken = session.getIdToken()
        try{
        const result = await fetch(awsExports.API_ENDPOINT + "/studies/" + id, { 
            method: "DELETE",
            mode: 'cors',
            headers: {
                'Authorization': 'Bearer ' + idToken.getJwtToken()
                },
		    credentials: 'include',
        })
        console.log(result.json())
        } catch (error) {
            console.log("Delete failed", error)
        }
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
                <hr/>
                <div class="studies">
                    <h3>Current Studies</h3>
                    {typeof(Ids) != undefined ? (
                    <div>
                    {Ids.map(study =>              
                    <div class="study-card" key={study.id}>
                    <Card variation="elevated">
                    <button type="button" class="btn btn-link" onClick={() => removeStudy(study.id)} style={{"float": "left", "clear": "none"}}>Delete</button>
                    <h5 style={{"text-align": "center", "font-style": "italic", "width": "90%"}}>ID {study.id}</h5>
                        <hr/>
                        <h3 style={{"text-align": "center"}}>{study.id}</h3>
                        <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{study.id} </h5>
                        <h5><span class="card-titles">Period:</span> {study.id} - {study.id} </h5>
                        <h5><span class="card-titles bottom">Researchers:</span></h5> 
                        <div class="d-table-row gap-4 d-md-flex justify-content-md-end">
                            <button type="button" class="btn btn-outline-primary">Download CSV</button>
                    
                            <Link to="/users" type="button" class="btn btn-outline-primary"
                            >Manage Researchers</Link>
                            
                        </div>
                    </Card>
                    </div>
                    )}
                </div>
                    ):(null) }     
                </div>
                </div>
            
            ):(
            <div>
            <hr/>
            <div class="studies">
                <h3>Current Studies</h3> 
                
                {Ids.map(study =>              
                <div class="study-card" key={study.id}>
                <Card variation="elevated">
                <button type="button" class="btn btn-link" onClick={() => removeStudy(study.id)} style={{"float": "left", "clear": "none"}}>Delete</button>
                <h5 style={{"text-align": "center", "font-style": "italic", "width": "90%"}}>ID {study.id}</h5>
                    <hr/>
                    <h3 style={{"text-align": "center"}}>{study.id}</h3>
                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{study.id} </h5>
                    <h5><span class="card-titles">Period:</span> {study.id} - {study.id} </h5>
                    <h5><span class="card-titles bottom">Researchers:</span></h5> 
                    <div class="d-table-row gap-4 d-md-flex justify-content-md-end">
                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                    </div>
                </Card>
                </div>)}
            </div>
            <div class="non-admin">
                <p>Don't see a study?</p>
                <p>Request access from the admins</p>
                </div>
        </div>
            )}
        </div>
        )}

export default Home;
