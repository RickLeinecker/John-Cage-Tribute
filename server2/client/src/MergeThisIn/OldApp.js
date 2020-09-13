/*import React from 'react';
import ReactDOM from 'react-dom';
import logo from './logo.svg';
import './App.css';
import HomePage from './pages/HomePage';
import Dashboard from './pages/Dashboard';
import MusicLib from './pages/MusicLibrary';
import Header from './pages/Header';

const root = document.getElementById('root');
const apt = 'apt';
const mylib = 'mylib';
const dash = 'dash';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      page: 'home'
    };
  }

  render() {
    var page = this.state.page;
    if (page == 'apt') return <ApptCreate />;
    else if (page == 'mylib') return <MusicLib />;
    else if (page == 'dash') return <Dashboard />;
    else if (page == 'home') return <HomePage />;
    else return <p>no page given</p>;
  }
}

//********* APPOINTMENT CREATION **********

class ApptCreate extends React.Component {
  constructor(p) {
    super(p);
    document.title = 'Appointment Creation - John Cage Tribute';
  }

  render() {
    return (
      <div>
        <Header text='Create an Appointment' />
        <form style={{ textAlign: 'left' }}>
          <label for='apt-members'>Date: </label>
          <input name='apt-date' id='apt-date' type='date' />
          <br />
          <label for='time'>Time: </label>
          <input name='apt-time' id='apt-time' type='time' />
          <br />
          <label for='apt-members'>Number of Members(2-8): </label>
          <input
            name='apt-members'
            id='apt-members'
            type='number'
            min='2'
            max='8'
          />
          <br />
          <label for='apt-duration'>Duration(in seconds): </label>
          <input name='apt-duration' id='apt-duration' value='273' />
          <br />
          <input type='reset' class='formbutton' />
          <input type='submit' class='formbutton' />
        </form>
      </div>
    );
  }
}

export default App;*/
