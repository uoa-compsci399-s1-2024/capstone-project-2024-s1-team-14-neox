import React, { useEffect, useState } from "react";
import { Link } from 'react-router-dom';
import { Auth, Amplify } from 'aws-amplify';
import { Card } from '@aws-amplify/ui-react';
import { awsExports } from "../aws-exports";
import Popup from '../popup';

Amplify.configure({
    Auth: {
      region: awsExports.REGION,
      userPoolId: awsExports.USER_POOL_ID,
      userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
    }
  });


const Home = ({ isAdmin, showButton }) => {
    const [familyName, setFamilyName] = useState(null);

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

    const [idToken, setIdToken] = useState(null);

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
        if (!isAdmin) {
            fetchIdToken();
        }
    }, []);

    const [studies, setStudies] = useState([]);
    const [idTokenAdmin, setIdTokenAdmin] = useState(null); 
    //const [tick, setTick] = useState([]);
    
    useEffect(() => {
        const fetchIdTokenAdmin = async () => {
          try {
            const session = await Auth.currentSession();
            const token = session.getIdToken();
            setIdTokenAdmin(token);
            //console.log(idTokenAdmin)
          } catch (error) {
            console.error('Error fetching ID token:', error);
          }
        };
        if (isAdmin) {
            fetchIdTokenAdmin();
        }
    }, []);
    
    useEffect(() => {
        const fetchStudies = async () => {
          try {
            const user = await Auth.currentAuthenticatedUser();
            const email = user.attributes.email;
            var studyData = [];
            var token = null;
            if (!idToken && !idTokenAdmin) {
                throw new Error('No ID token');
            }
            else if (idTokenAdmin) {
                const response = await fetch(`${awsExports.API_ENDPOINT}/studies`, {
                method: 'GET',
                mode: 'cors',
                headers: {
                    'Authorization': 'Bearer ' + idTokenAdmin.getJwtToken()
                },
                credentials: 'include',
                });
                const jsonData = await response.json();
                if (jsonData && Array.isArray(jsonData.data)) { 
                studyData = jsonData.data;
                } else {
                console.error('Error fetching study data:', jsonData); 
                }
                token = idTokenAdmin;
            }
            else if (idToken){
                const response = await fetch(`${awsExports.API_ENDPOINT}/researchers/${email}/studies`, {
                method: 'GET',
                mode: 'cors',
                headers: {
                    'Authorization': 'Bearer ' + idToken.getJwtToken()
                },
                credentials: 'include',
                });
                const jsonData = await response.json();
                if (jsonData && Array.isArray(jsonData.data)) { 
                studyData = jsonData.data;
                } else {
                    console.error('Error fetching study data:', jsonData); 
                }
                token = idToken;
            }
            for (let i in studyData) {
                const info = await fetch(`${awsExports.API_ENDPOINT}/studies/${studyData[i].id}/info`, {
                    method: 'GET',
                    mode: 'cors',
                    headers: {
                        'Authorization': 'Bearer ' + token.getJwtToken()
                    },
                    credentials: 'include',
                });
                const jsoninfo = await info.json();
                const data = jsoninfo.data;
                studyData[i]["start_date"] = data.start_date;
                studyData[i]["end_date"] = data.end_date;
                studyData[i]["name"] = data.name;
                studyData[i]["description"] = data.description;
            }
            setStudies(studyData);
          } catch (error) {
            console.error('Error fetching study data', error);
          }
        };
        fetchStudies();
    }, [idTokenAdmin])

    
    // new code starts from here
    const [researcherId, setResearcherId] = useState("");
    const [selectedStudyId, setSelectedStudyId] = useState("");
    const [editError, setEditError] = useState(null); 
    const [isOpen, setIsOpen] = useState(false);
    const [isSuccessful, setIsSuccessful] = useState(false);

    const addResearcher = async () => {
        try {
            const token = idTokenAdmin; 
            const response = await fetch(`${awsExports.API_ENDPOINT}/researchers/${researcherId}/studies/${selectedStudyId}`, {
            method: 'PUT',
            mode: 'cors',
            headers: {
                'Authorization': 'Bearer ' + token.getJwtToken(),
                'Content-Type': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify({ researcherId })
            });

            if (response.ok) {
                setEditError(null); 
                console.log(response)
                } else {
                setEditError(null);
                setEditError('Error adding researcher'); 
            }
            } catch (error) {
                setEditError(null);
                setEditError('Error adding researcher'); 
                console.log(error)
            }
    };

    const removeResearcher = async () => {
        try {
            const token = idTokenAdmin; 
            const response = await fetch(`${awsExports.API_ENDPOINT}/researchers/${researcherId}/studies/${selectedStudyId}`, {
            method: 'DELETE',
            mode: 'cors',
            headers: {
                'Authorization': 'Bearer ' + token.getJwtToken(),
                'Content-Type': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify({ researcherId })
            });

            if (response.ok) {
                setEditError(null);
                console.log(response)
                } else {
                setEditError(null);
                setEditError('Error deleting researcher'); 
            }
            } catch (error) {
                setEditError(null);
                setEditError('Error deleting researcher');
                console.log(error)
                togglePopup();
            }
    };

    const togglePopup = () => {
        setIsOpen(!isOpen);
    };

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
                        <div class="study-card"> 
                            <Card variation="elevated">
                                <h3>Manage Researchers</h3> 
                                {editError && <p style={{ color: 'red' }}>{editError}</p>}  
                                <p>Study ID <input 
                                    type="text" 
                                    value={selectedStudyId} 
                                    onChange={e => setSelectedStudyId(e.target.value)}
                                    placeholder="Study ID"
                                /></p>
                                <p>Researcher ID <input 
                                    type="text" 
                                    value={researcherId} 
                                    onChange={e => setResearcherId(e.target.value)}
                                    placeholder="Researcher ID"
                                /></p>

                                
                                <div class="d-table-row gap-4 d-md-flex justify-content-md-end">
                                    <button type="button" class="btn btn-outline-primary" onClick={addResearcher}>
                                        Add Researcher
                                    </button>
                                    <button type="button" class="btn btn-outline-danger" onClick={removeResearcher}>
                                        Remove Researcher
                                    </button>
                                </div>
                            </Card>
                        </div>
                        <div>
                            {studies.map((study) => (              
                            <div class="study-card" key={study.id}>
                                <Card variation="elevated">
                                    <h5 style={{"text-align": "center", "font-style": "italic"}}>ID {study.id}</h5>
                                    <hr/>
                                    <h3 style={{"text-align": "center"}}>{study.name}</h3>
                                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{study.description} </h5>
                                    <h5><span class="card-titles">Period:</span> {study.start_date} - {study.end_date} </h5>
                                    <h5><span class="card-titles bottom">Researchers: </span>{study.id}</h5> 
                                    <div class="d-table-row gap-4 d-md-flex justify-content-md-end">
                                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                                        <Link to="/users" type="button" class="btn btn-outline-primary"
                                        >Manage Researchers</Link>
                                    
                                    </div>
                                </Card>
                            </div>
                            ))}
                        </div>
                    </div>
                </div>
            
            ):(
            <div>
            <hr/>
            <div class="studies">
                        <h3>Current Studies</h3>
                        <div>
                            {studies.map((study) => (              
                            <div class="study-card" key={study.id}>
                                <Card variation="elevated">
                                    <h5 style={{"text-align": "center", "font-style": "italic"}}>ID {study.id}</h5>
                                    <hr/>
                                    <h3 style={{"text-align": "center"}}>{study.name}</h3>
                                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{study.description} </h5>
                                    <h5><span class="card-titles">Period:</span> {study.start_date} - {study.end_date} </h5>
                                    <h5><span class="card-titles bottom">Researchers: </span>{study.id}</h5> 
                                    <div class="d-table-row gap-4 d-md-flex justify-content-md-end">
                                        <button type="button" class="btn btn-outline-primary">Download CSV</button>

                                    </div>
                                </Card>
                            </div>
                            ))}
                            <div class="non-admin">
                                <p>Don't see a study?</p>
                                <p>Request access from the admins</p>
                            </div>
                        </div>
                    </div>
                </div> 
                )}
                {isOpen && isSuccessful && <Popup
                content={<>

                </>}
                handleClose={togglePopup}
                />}

                {isOpen && !isSuccessful &&<Popup
                content={<>

                </>}
                handleClose={togglePopup}
                />}
            </div>
        )}

export default Home;
