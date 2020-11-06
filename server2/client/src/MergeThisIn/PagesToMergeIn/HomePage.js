/*import React from 'react';
import ReactDOM from 'react-dom';
import '../App.css';

const root = document.getElementById("root");

class HomePage extends React.Component {
	constructor(props) {
		super(props);
		document.title = "Homepage - John Cage Tribute";
	}
	
	render() {
		var headerStyle = {
			textAlign: "center",
			display:"inline-block",
			backgroundColor:"#0675ff",
			color:"white",
			borderRadius:"10px",
			fontSize:"2.5em"
		};
		return (
		<div>
			<div style={{marginBottom:"40px", backgroundColor:"#0675ff"}}>
				<h1 style ={headerStyle}>John Cage Tribute(WIP)</h1>
			</div>
			<div style={{width:"800px",display:"inline-block"}}>
				<div id="pic-acc">
					<img src="johncage.jpg" style={{borderRadius:"10px"}}/>
					<LoginOrSignup />
				</div>
				<br /><hr /><br />
				<div>
					<h2>Mission Statement</h2>
					<p>
						Our goal is to contribute to the legacy of John Cage. We want to achieve this by designing a system that takes sounds and mixes them together in the style of John Cage. 
					</p>
					<h2>How It Works</h2>
					<p>
						Sound clips are recorded from multiple phones using our mobile app. The clips are sent to back to our server to be mixed with our algorithm based on John Cage's style(currently in development). The resulting composition is then stored in our database where it can be retrieved for listening with the use of either the app or here on the website. 
					</p>
				</div>
			</div>
		</div>
		);
	}
	
}

class LoginOrSignup extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			mode: "login"
		}
		
		this.changeState = this.changeState.bind(this);
	}
	
	render() {
		var notchosenTab = {
			width: "50%",
			display: "inline-block",
			border: "1px solid blue",
			borderRadius: "10px",
			fontWeight: "bold",
			padding: "10px",
			fontSize: "1.2em"
		};
		var chosenTab = {
			width: "50%",
			display: "inline-block",
			border: "1px solid blue",
			borderRadius: "10px",
			fontWeight: "bold",
			padding: "10px",
			fontSize: "1.2em",
			backgroundColor: "#2486e7"
		}
		var accStyle = {
			borderRadius: "10px",
			borderTop: "none",
			width: "400px",
			backgroundColor:"#30a0ef"
		};
		var inputStyle ={
			display: "inline",
			width: "96%",
			textAlign: "center",
			border: "none"
		}
		var form = null;
		var loginTabStyle = null;
		var signinTabStyle = null;
		if(this.state.mode == "login") {
			form = (
			<div style={{textAlign:"center",padding:"10px"}}>
				<label for="acc-name">Email</label>
				<div style={{marginBottom:"10px", textAlign:"center"}}>
					<input name="acc-name" id="acc-name" style={inputStyle} />
				</div>
				<label for="acc-pass">Password</label>
				<div>
					<input name="acc-pass" id="acc-pass" style={inputStyle} />
				</div>
				<input type="submit" style={{display:"inline",marginTop:"20px"}}/>
			</div>
			);
			loginTabStyle = chosenTab;
			signinTabStyle = notchosenTab;
		}
		else if(this.state.mode == "signup") {
			form = (
			<div style={{textAlign:"center",padding:"10px"}}>
				<label for="acc-name">Username</label>
				<div style={{marginBottom:"10px", textAlign:"center"}}>
					<input name="acc-name" id="acc-name" style={inputStyle} />
				</div>
				<label for="acc-email">Email</label>
				<div style={{marginBottom:"10px", textAlign:"center"}}>
					<input name="acc-email" id="acc-email" style={inputStyle} />
				</div>
				<label for="acc-pass">Password</label>
				<div>
					<input name="acc-pass" id="acc-pass" style={inputStyle} />
				</div>
				<input type="submit" style={{display:"inline",marginTop:"20px"}} />
			</div>
			);
			loginTabStyle = notchosenTab;
			signinTabStyle = chosenTab;
		}
		
		return (
		<div style={accStyle}>
			<div style={{display:"flex"}}>
				<div style={loginTabStyle} class="acc-tab" onClick={() => this.changeState("login")}>Log in</div>
				<div style={signinTabStyle} class="acc-tab" onClick={() => this.changeState("signup")}>Sign up</div>
			</div>
			{form}
		</div>
		)
	}
	
	changeState(str) {
		console.log("changing state")
		this.setState(state => ({
			mode: str
		}));
	}
}

export default HomePage; */
