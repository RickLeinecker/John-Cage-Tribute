/* import React from 'react';
import ReactDOM from 'react-dom';
import Header from './Header';
import '../App.css'

const root = document.getElementById("root");

class MusicLib extends React.Component {
	constructor(p) {
		super(p);
		document.title = "My Music Library - John Cage Tribute";
	}
	
	
	
	render() {
		return (
		<div>
			<Header text="My Music Library" parent="dashboard" />
			<Search />
		</div>
		)
	}
}

function MusicEntry(props) {
	var d = props.details;
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
	)
}


function Search() {
	const item1 = {
		title: "title1",
		duration: "04:33",
		source: "audio.wav"
	};
	var musicList = [item1];
	musicList = musicList.map((item) => <MusicEntry details={item} />)
	return (
	<div style={{textAlign:"center",whiteSpace:"nowrap"}}>
		<input name="search" class="searchBox" />
		<button style={{height:"33px"}}>Search</button>
		<div id="result-container">
			{musicList}
		</div>
	</div>
	);
}

export default MusicLib; */
