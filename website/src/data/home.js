import React, { useEffect, useState } from "react";
import { Link, Navigate, useLocation } from 'react-router-dom';
import { Auth, Logger } from 'aws-amplify';
import { Card } from '@aws-amplify/ui-react';


const Home = ({ isAdmin, showButton }) => {
    const [familyName, setFamilyName] = useState(null);
    var data = null;
    var title = null;
    var id = null;
    var description = null;
    var startDate = null;
    var endDate = null;
    var set = false;
    if (typeof(localStorage['cards-demos']) != "undefined") {
        set = true;
        data = localStorage['cards-demos'];
        title = data[0] + data[1] + data[2] + data[3] + data[4] + data[5];
        id = data[7] + data[8] + data[9] + data[10] + data[11] + data[12];
        description = data[14] + data[15] + data[16] + data[17] + data[18] + data[19] + data[20] + data[21] + data[22] + data[23] + data[24];
        startDate = "21/05/24";
        endDate = "21/06/24";
    }
    
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

    function StudyCard() {
        return (
            <div class="study-card">
                <Card variation="elevated">
                    <h5 style={{"text-align": "center", "font-style": "italic"}}>ID 210524</h5>
                    <hr/>
                    <h3 style={{"text-align": "center"}}>Miopia in Children</h3>
                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>Exploring the relationship between outdoor time and Miopia progression in children </h5>
                    <h5><span class="card-titles">Period:</span> 21/05/24 - 21/06/24 </h5>
                    <h5><span class="card-titles bottom">Researchers:</span></h5>                  
                    <div class="d-table-row gap-2 d-md-flex justify-content-md-end">
                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                        {isAdmin ? (
                            <button type="button" class="btn btn-outline-primary" //onClick={() => alert("Works!")}
                            >Manage Researchers</button>
                        ) : (null)}
                    </div>
                </Card>
            </div>
        )
    }
    
    function studyCard() {
        return (
            <div class="study-card">
                <Card variation="elevated">
                    <h5 style={{"text-align": "center", "font-style": "italic"}}>ID {id} </h5>
                    <hr/>
                    <h3 style={{"text-align": "center"}}>{title}</h3>
                    <h5 style={{"text-align": "center", "padding-bottom": "2%"}}>{description}</h5>
                    <h5><span class="card-titles">Period:</span> {startDate} - {endDate} </h5>
                    <h5><span class="card-titles bottom">Researchers:</span></h5>                  
                    <div class="d-table-row gap-2 d-md-flex justify-content-md-end">
                        <button type="button" class="btn btn-outline-primary">Download CSV</button>
                        {isAdmin ? (
                            <button type="button" class="btn btn-outline-primary" //onClick={() => alert("Works!")}
                            >Manage Researchers</button>
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
                {StudyCard()}  
                {set ? (
                    studyCard()
                    
                ): (null)}              
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
