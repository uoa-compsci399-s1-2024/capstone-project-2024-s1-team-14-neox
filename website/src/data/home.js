import React, { useEffect, useState } from "react";
import { Link } from 'react-router-dom';
import { Auth } from 'aws-amplify';
import { Button, Card } from '@aws-amplify/ui-react';
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
                    <div class="study-title">
                        <h3>Study title</h3>
                    </div>
                    <h5>Description: </h5>
                    <h5>Approval Date: </h5>
                    <h5>Number of Participants: </h5>
                    <h5>Researchers: </h5>
                    <button class="button" size="large" isFullWidth={false} colorTheme='info' loadingText="" onClick={() => alert('something')}>Download CSV</button>
                    {!isAdmin ? (
                        <Button class="button" size="large" isFullWidth={false} colorTheme='info' loadingText="" onClick={() => alert('something')}>Manage Researchers</Button>
                    ) : (null)}
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
            <div class="studies">
                <h3>Active Studies</h3>
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
