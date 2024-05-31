import React, { useState } from 'react';
//date range picker
import { DateRangePicker } from 'rsuite';
import 'rsuite/dist/rsuite.min.css';
import subDays from 'date-fns/subDays';
import addDays from 'date-fns/addDays';
import startOfMonth from 'date-fns/startOfMonth';
import endOfMonth from 'date-fns/endOfMonth';
import addMonths from 'date-fns/addMonths';

//images
import logo from './neox.svg';
import button from './button.png';

//chart
import { Bar } from 'react-chartjs-2';
import 'chart.js/auto';
import exposureData from './collectedData.json';

//for fetching and posting data for api
import axios from 'axios';


//get sample data and download it in csv format
function downloadCSV(data, filename) {
  const csv = convertToCSV(data);
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.setAttribute('href', url);
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}
function convertToCSV(data) {
  const header = Object.keys(data[0]).join(',') + '\n';
  const rows = data.map(row => Object.values(row).join(',')).join('\n');
  return header + rows;
}
function fetchDataAndDownload() {
  axios.get(`${process.env.REACT_APP_API_URL}/samples`)
 //axios.get(`https://xql8m9zukd.execute-api.ap-southeast-2.amazonaws.com/samples`)
    .then(response => {
      const data = response.data.map(entry => ({
        tstamp: entry.timestamp,
        child_id: entry.child_id,
        uv_index: entry.uv,
        lux: entry.light
      }));
      downloadCSV(data, 'sample.csv');
    })
    .catch(error => console.error('Error fetching data:', error));
}

//predefined ranges for calender 
const predefinedBottomRanges = [
  {
    label: 'Today',
    value: [new Date(), new Date()]
  },
  {
    label: 'Yesterday',
    value: [addDays(new Date(), -1), addDays(new Date(), -1)]
  },
  {
    label: 'Last 7 days',
    value: [subDays(new Date(), 6), new Date()]
  },
  {
    label: 'Last 30 days',
    value: [subDays(new Date(), 29), new Date()]
  },
  {
    label: 'Last month',
    value: [startOfMonth(addMonths(new Date(), -1)), endOfMonth(addMonths(new Date(), -1))]
  },
  {
    label: 'Last year',
    value: [new Date(new Date().getFullYear() - 1, 0, 1), new Date(new Date().getFullYear(), 0, 0)]
  }
];


const DisplayChart = () => {
  //set startdate and enddate
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

  //for hiding and showing elements
  const [showButton, setShowButton] = useState(true);

  return (
    <div className="App">
      <div className="spacer"></div>

      <div className="dataCard clientCard">
        <pre>
          <b>Jamie Smith</b>
          <br></br>
          Age: 13
          <br></br>
          Gender: Male
          <br></br>
          Last visit: 01/05/2024
        </pre>
      </div>

      <div className="dataCard downloadCard">
        <div className="downloadCardLeft">
          <DateRangePicker
            ranges={predefinedBottomRanges}
            placeholder="Set Date Range To Download"
            format="dd/MM/yyyy"
            size="lg"
            onChange={handleDateChange}
          />
        </div>

        <div className="downloadCardRight">
          <button onClick={fetchDataAndDownload}>
            <img src={button} alt="download button" height="100px" role="button" />
          </button>
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
                order: 1,
                yAxisID: 'y1'
              },
              {
                label: "Myopia Dioptre",
                data: exposureData.map((data) => data.dioptre),
                backgroundColor: "#FF3030",
                borderColor: "#FF3030",
                type: 'line',
                order: 0,
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
                title: {
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

export default DisplayChart;
