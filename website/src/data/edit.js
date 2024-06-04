import { format } from "date-fns";
import { DateRangePicker } from 'rsuite';
import 'rsuite/dist/rsuite.min.css';
import '@aws-amplify/ui-react/styles.css';
import { Auth } from 'aws-amplify';
import { awsExports } from '../aws-exports';
import '../App.css';
import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const Edit = ({showButton, isAdmin}) => {
    const params = new URLSearchParams(window.location.search)
    const id = params.get("id")
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

    const navigate = useNavigate()
    const handleSubmit = async (event) => {
        try{
            event.preventDefault();
            const session = await Auth.currentSession();
            const idToken = session.getIdToken();
            const jwtToken = idToken.getJwtToken();
            const formData = new FormData(event.target);
            const title = formData.get('title');
            const description = formData.get('description');
            const study = await fetch(`${awsExports.API_ENDPOINT}/studies/${id}/info`, {
                method: "PATCH",
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
            }).then(response => {navigate("/home")})
            } catch (error) {
            console.log("Error editing study", error)
            }
    };
    
    if (isAdmin) {

        return (
            <div style={{"max-height": "100vh"}}>
              <h2 style={{"text-align": "center"}}>Edit study {id} </h2>
              <br></br>
            <form class="create-form" style={{"max-height": "100vh", "min-height": "50vh"}} onSubmit={handleSubmit}>
              <div className="mb-3">
                <label>Study Name</label>
                <input type="text" className="form-control" placeholder="" name="title" required />
              </div>
              <div className="mb-3" style={{"height": "20vh"}}>
                <label>Description</label>
                <textarea type="text" style={{"height": "90%"}} className="form-control" placeholder="" name="description" required />
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
                <button type="submit" className="btn btn-primary" onClick={() => handleSubmit}>Submit</button>
            </div>
            <br></br>
            <div className="d-grid" style={{"width": "100%"}}>
                <Link to="/home" className="btn btn-primary">Back to Home</Link>
            </div>
            </form>

            </div>
        );
    }
    else {
        return <></>
    }
}

export default Edit;