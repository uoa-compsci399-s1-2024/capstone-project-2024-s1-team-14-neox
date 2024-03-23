import logo from './data/neox.svg';
import chart from './data/chart.png';
import date from './data/date.png';
import button from './data/button.png';
import testfile from './data/test.csv';
import './App.css';
import React from "react";




function App() {
  return (
    
    <div className="App">

      <div className="logoCard">
      <img src={logo} className="App-logo" alt="logo" />
      </div>



      <div className="dataCard clientCard">
      <pre>
        <b>Jamie SMITH</b>
        <br></br>
        DOB: 04/12/2010
        <br></br>
        Age: 13 years 11 months
        <br></br>
        Address: 34 Princes Street, Auckland CBD
        <br></br>
        Last visit: 18/03/2024
      </pre>
        
      </div>



      <div className="dataCard downloadCard">

        <div className="downloadCardLeft">
        <img src={date} alt='date' width ='95%' height='90%'/>
        </div>

        <div className="downloadCardRight">
          <a href={testfile} download="test"> 
            <img src={button} alt="download button" height="100px" role="button"  /> 
          </a>
        </div>

      </div>
      


      <div className="dataCard chartCard">

      <img src={chart} alt='chart' width ='95%' height='100%'/>
        
      </div>

    </div>
  );
}

export default App;