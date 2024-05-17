import React, { useEffect, useState } from "react";
import { Link } from 'react-router-dom';
import { Auth } from 'aws-amplify';


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

    return (
        isAdmin ? (
            <div>
                <h1>Hello {familyName}!</h1>
                <h2>You are an admin of Neox Labs</h2>
                <div className="d-grid">
                    <Link to="/create" className="btn btn-primary">Start a new study</Link>
                </div>
            </div>
        ) : (
            <div>
                <h1>Hello {familyName}!</h1>
                <h2>Here are your studies:</h2>
    
                <h2>Don't see a study?</h2>
                <h2>Request access to the admins.</h2>
            </div>
        )
    );
};

export default class Home extends Component {
    render() {
        return (
            <div className="home-body">
                <div id="home-titles">
                    <h1>Welcome Phil! </h1>
                    <Button isFullWidth={false} variation="primary" size="Large" onClick={() => alert("something")}> Create Study</Button>
                </div>
                <div id="studies-title">
                    <h3>Studies</h3>
                </div>
                <StudyCard/>
                <StudyCard/>
                <StudyCard/>                   
            </div>
        )
    }
}
