import React from 'react';
import ReactDOM from 'react-dom';
import Header from './Header';
import MusicLib from './MusicLibrary';
import '../App.css'

const root = document.getElementById("root");

class Dashboard extends React.Component {
	constructor(p) {
		super(p);
		document.title = "User Dashboard - John Cage Tribute";
	}
	
	render() {
		const dummy = {
			name: "John Doe",
			email: "johndoe@gmail.com",
			phone: "(123)456-7890",
			org: "University of Central Florida"
		};
		return(
		<div>
			<Header text="Dashboard" />
			<div style={{display:"inline-block", width:"70%"}}>
				<table style={{width:"100%"}}>
				<tbody><tr>
					<td style={{width:"25%",minWidth:"200px"}}>
						<div>
							<AccPanel account={dummy} />
						</div>
					</td>
					<td style={{width:"100%", minWidth:"400px"}}> 
						<AptPanel />
						<CompPanel />
					</td>
				</tr></tbody>
				</table>
			</div>
		</div>
		);
	}
	
}

function AccPanel(props) {
	var inline = {display:"inline"};
	var headerStyle = {
		display:"inline",
		fontSize:"16px",
		fontWeight:"bold"
	}
	return (
	<div id="acc-panel" class="panel">
		<div style={{textAlign:"center", border:"2px solid blue",padding:"5px 0px"}}>
			<p style={headerStyle}>Profile</p>
		</div>
		<div class="acc-panel-item">
			<h4 style={inline}>Name: </h4>
			<p style={inline}>{props.account.name}</p>
		</div>
		<div class="acc-panel-item">
			<h4 style={inline}>Phone: </h4>
			<p style={inline}>{props.account.phone}</p>
		</div>
		<div class="acc-panel-item">
			<h4 style={inline}>Email: </h4>
			<p style={inline}>{props.account.email}</p>
		</div>
		<div class="acc-panel-item">
			<h4 style={inline}>Organization: </h4>
			<p style={inline}>{props.account.org}</p>
		</div>
	</div>
	);
}

function AptItem(props) {
	const d = props.details;
	return (
	<div class="apt-panel-item">
		<p>Title: {d.title} | Date: {d.date} | Time: {d.time} | # of members: {d.numMembers}</p>
	</div>
	);
}

function AptPanel(props) {
	const apt1 = {
		title: "title1",
		date: "date1",
		time: "time1",
		numMembers: 1
	}
	const apt2 = {
		title: "title2",
		date: "date2",
		time: "time2",
		numMembers: 2
	}
	var list = [apt1, apt2];
	var aptList = list.map((apt) =>
		<AptItem details={apt} key={apt.title} />
	);
	
	if(aptList.length == 0) {
		aptList = (<p>You have no appointments active</p>);
	}
	return (
	<div style={{display:"inline-block"}} class="panel" id="apt-panel">
		<div style={{border:"2px solid blue"}}>
			<p><strong style={{fontSize:"16px"}}>Appointments</strong></p>
		</div>
		{aptList}
	</div>
	);
}

function CompPanel(props) {
	var list = [];
	for(var i=0; i < 5; i++) {
		list.push({
			title: "title"+i,
			duration: "04:33",
			source: "audio.wav"
		});
	}
	var compList = list.map((comp) =>
		<CompItem details={comp} key={comp.title} />
	);
	if(compList.length == 0) {
		compList = (<p>You have no compositions</p>);
	}
	var more = null;
	var fullList = [];
	if(compList.length > 4) {
		more = (<p style={{fontColor:"blue",textDecoration:"underline"}} onClick={goToMusicLib}>View more...</p>);
		fullList = compList;
		compList = compList.slice(0,4);
	}
	return (
	<div style={{display:"inline-block"}} class="panel" id="apt-panel">
		<div style={{border:"2px solid blue"}}>
			<p><strong style={{fontSize:"16px"}}>Recent Compositions</strong></p>
		</div>
		{compList}
		{more}
	</div>
	);
	
	function goToMusicLib() {
		ReactDOM.render(<MusicLib />, root);
	}
}

function CompItem(props) {
	const d = props.details;
	return (
	<div class="comp-item">
		<p>Title: {d.title}</p>
		<p>Duration: {d.duration}</p>
		<div>
			<audio controls>
				<source src={d.source} type="audio/wav" />
			</audio>
		</div>
	</div>
	);
}

export default Dashboard;