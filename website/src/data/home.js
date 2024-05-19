import React, { useEffect, useState } from "react";
import { Link } from 'react-router-dom';
import { Auth } from 'aws-amplify';
import { Card } from '@aws-amplify/ui-react';
import { Navigate } from 'react-router-dom';


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

    function studyCard() {
        return (
            <div class="study-card">
                <Card variation="elevated">
                    <h5 style={{"text-align": "center", "font-style": "italic"}}>ID 123456</h5>
                    <hr/>
                    <h3 style={{"text-align": "center"}}>This is what the study title looks like</h3>
                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>The description of the study looks like this The description of the study looks like this The description of the study looks like this The description of the study looks like this The description of the study looks like this</h5>
                    <h5><span class="card-titles">Period:</span> xx/xx/xx - xx/xx/xx </h5>
                    <h5><span class="card-titles">Number of Participants:</span> x </h5>
                    <h5><span class="card-titles bottom">Researchers:</span> Name Name, Name Name </h5>                  
                    <div class="d-table-row gap-2 d-md-flex justify-content-md-end">
                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                        {isAdmin ? (
                            <button type="button" class="btn btn-outline-primary" onClick={() => alert("Works!")}>Manage Researchers</button>
                        ) : (null)}
                    </div>
                </Card>
            </div>
        )
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
                
                {studyCard()}
                {studyCard()}
                {studyCard()}
                
            </div>
            {!isAdmin ? (
                <div class="non-admin">
                    <p>Don't see a study?</p>
                    <p>Request access from the admins</p>
                </div>
            ): (null)}
        </div>
    );
};

export default Home;
