import React, { useEffect, useState } from "react";
import { Link } from 'react-router-dom';
import { Auth, Amplify } from 'aws-amplify';
import { Card } from '@aws-amplify/ui-react';
import { awsExports } from "../aws-exports";
import pLimit from "p-limit";

Amplify.configure({
    Auth: {
      region: awsExports.REGION,
      userPoolId: awsExports.USER_POOL_ID,
      userPoolWebClientId: awsExports.USER_POOL_APP_CLIENT_ID
    }
  });

function AdminHeader({isAdmin}) {
    if (isAdmin) {
        return (
            <>
                <h4>Admin</h4>
                <div className="d-grid">
                    <Link to="/create" className="btn btn-primary">Start a new study</Link>
                </div>
            </>
        );
    } else {
        return <></>;
    }
}

function NonAdminTrailer({isAdmin}) {
    if (isAdmin) {
        return <></>;
    } else {
        return (
            <div className="non-admin">
                <p>Don't see a study?</p>
                <p>Request access from the admins</p>
            </div>
        );
    }
}

const MAX_CONNECTIONS = 5;  // arbitrary
const _LIMIT = pLimit(MAX_CONNECTIONS);

async function fetchInfo (id, token) {
    const info = await fetch(`${awsExports.API_ENDPOINT}/studies/${id}/info`, {
        method: 'GET',
        mode: 'cors',
        headers: {
            'Authorization': 'Bearer ' + token.getJwtToken()
        },
        credentials: 'include',
    });
    const jsoninfo = await info.json();
    return jsoninfo.data;
}
async function fetchParticipants(id, token) {
    const resp = await fetch(`${awsExports.API_ENDPOINT}/studies/${id}/participants`, {
        method: 'GET',
        mode: 'cors',
        headers: {
            'Authorization': 'Bearer ' + token.getJwtToken()
        },
        credentials: 'include',
    });
    const json = await resp.json();
    return json.data;
}

function AdminExtraStudyFields({id, token, isAdmin}) {
    const [participants, setParticipants] = useState(null);
    useEffect(() => {
        async function fetchWithToken() {
            if (isAdmin && token != null) {
                setParticipants(await _LIMIT(fetchParticipants, id, token));
            }
        }
        fetchWithToken();
    }, [id]);
    if (isAdmin) {
        return (
            <h5><span className="card-titles bottom">Researchers: </span>{participants ? participants.researchers.length : "(Loading...)"}</h5>
        );
    } else {
        return <></>;
    }
}

function StudyCard({id, token, isAdmin}) {
    const [details, setDetails] = useState(null);
    // const [participants, setParticipants] = useState(null);
    useEffect(() => {
        async function fetchWithToken() {
            if (token != null) {
                setDetails(await _LIMIT(fetchInfo, id, token));
            }
        }
        fetchWithToken();
    }, [id]);

    return (
        <div className="study-card" key={id}>
            <Card variation="elevated">
                <h5 style={{"textAlign": "center", "fontStyle": "italic"}}>ID {id}</h5>
                <hr/>
                <h3 style={{"textAlign": "center"}}>{details ? details.name : "(Loading...)"}</h3>
                <h5 style={{"textAlign": "center", "paddingBottom": "2%"}}>{details ? details.description : "(Loading...)"} </h5>
                <h5><span className="card-titles">Period:</span> {details ? `${details.start_date} - ${details.end_date}` : "(Loading...)"} </h5>
                <AdminExtraStudyFields id={id} token={token} isAdmin={isAdmin} />
                <div className="d-table-row gap-4 d-md-flex justify-content-md-end">
                    <button type="button" className="btn btn-outline-primary">Download CSV</button>
                </div>
            </Card>
        </div>
    );
}

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
        fetchIdToken();
    }, []);

    const [studies, setStudies] = useState([]);

    useEffect(() => {
        const fetchStudies = async () => {
          try {
            const user = await Auth.currentAuthenticatedUser();
            const email = user.attributes.email;
            if (!idToken) {
                throw new Error('No ID token');
            }

            let url;
            if (isAdmin) {
                url = `${awsExports.API_ENDPOINT}/studies`;
            } else {
                url = `${awsExports.API_ENDPOINT}/researchers/${email}/studies`;
            }
            const response = await fetch(url, {
                method: 'GET',
                mode: 'cors',
                headers: {
                    'Authorization': 'Bearer ' + idToken.getJwtToken()
                },
                credentials: 'include',
            });
            const jsonData = await response.json();
            if (!(jsonData && Array.isArray(jsonData.data))) {
                console.error('Error fetching study data:', jsonData);
            }
            const studyIDs = jsonData.data.map(s => s.id);
            setStudies(studyIDs);
          } catch (error) {
            console.error('Error fetching study data', error);
          }
        };
        fetchStudies();
      }, [idToken])

    return (
        <div className="home-body">
            <h1>Welcome {familyName}!</h1>
            <div>
                <AdminHeader isAdmin={isAdmin} />
                <hr/>
                <div className="studies">
                    <h3>Current Studies</h3>
                    <div>
                        {studies.map((id) => <StudyCard key={id} id={id} token={idToken} isAdmin={isAdmin} />)}
                    </div>
                    <NonAdminTrailer isAdmin={isAdmin} />
                </div>
            </div>
        </div>
    );
}

export default Home;
