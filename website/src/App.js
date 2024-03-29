import logo from './data/neox.svg';
import date from './data/date.png';
import button from './data/button.png';
import testfile from './data/test.csv';
import './App.css';
import React from "react";
import { Bar} from "react-chartjs-2";
import { Chart } from 'chart.js/auto';
import exposureData from "./data/collectedData.json";





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

          <Bar
            data={{
              labels: exposureData.map((data) => data.label),
              datasets: [
                {
                  label: "Monthly Average Sunlight Exposure (in minutes)",
                  data: exposureData.map((data) => data.exposure),
                  backgroundColor: "#064FF0",
                  borderColor: "#064FF0",
                  order:1,
                  yAxisID: 'y1'
                },
                {
                  label: "Myopia Dioptre",
                  data: exposureData.map((data) => data.dioptre),
                  backgroundColor: "#FF3030",
                  borderColor: "#FF3030",
                  type: 'line',
                  order:0,
                  yAxisID: 'y'
                },
              ],
            }}
            options={{
              responsive: true,
              maintainAspectRatio: false,
              plugins: {
                legend: {
                  position: 'top',
                },
                title: {
                  display: true,
                  text: 'Monthly Average Sunlight Exposure',
                  font: {
                    size: 25,
                    weight: 'bold'
                  }
        
                },
              },

              scales: {

                x: { 
                  grid: {
                    display: false, // Hide the grid lines of the x-axis
                  },
                },

                y: {
                  
                  type: 'linear',
                  display: true,
                  position: 'left',
                  reverse: true,
                  min: Math.min(...exposureData.map(data => data.dioptre)) - 1, // Calculate the minimum value for y-axis ticks
                  title:{
                    display: true,
                    text: 'Myopia Dioptre',
                    font: {
                      size: 18,
                    }

                  },

                  
                  ticks: {
                    stepSize: 1,
                  }
                  
                },
                y1: {
                  
                  type: 'linear',
                  display: true,
                  position: 'right',
                  max: Math.ceil(Math.max(...exposureData.map(data => data.exposure)) / 30) * 30, // Calculate the maximum value for y1-axis ticks

                  ticks: {
                    callback: function (value) {
                        const hours = Math.floor(value / 60); 
                        const minutes = value % 60; 
                        return `${hours}h ${minutes}m`; 
                    },
                    stepSize: 30
                  },

                  grid: {
                    drawOnChartArea: false, // Hide the grid lines of y1-axis
                  },
                },
              }
            }}
            
          />
      
        
      </div>

    </div>
  );
}

export default App;