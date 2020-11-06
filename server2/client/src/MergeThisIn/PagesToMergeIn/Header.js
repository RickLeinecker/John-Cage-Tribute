/*import React from 'react';
import ReactDOM from 'react-dom';
import Dashboard from './Dashboard'

const root = document.getElementById("root");

function Header(props) {
	return (
		<header>
			<table>
			<tr>
				<td style={{borderRight:"2px solid black",paddingRight:"15px"}}>
					<button class="backButton" onClick={goBack}>&lt;-</button></td>
				<td style={{paddingLeft:"15px"}}>
					{props.text}</td>
			</tr>
			</table>
		</header>
	);
	
	function goBack() {
		switch(props.parent) {
			case "dashboard":
				ReactDOM.render(<Dashboard />, root)
				break;
			default: console.log("No parent page specified");
		}
	}
}

export default Header; */
