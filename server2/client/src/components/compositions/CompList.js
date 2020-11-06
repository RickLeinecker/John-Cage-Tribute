import React, {Fragment} from 'react';
import Spinner from '../layout/Spinner';

class CompList extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			list: props.list
		}
		this.renderList = this.renderList.bind(this);
	}
	
	// This component takes a Promise that should contain the list of composition info when it resolves. Upon resolving, it will call the renderList() function to render the list with the proper information it received from the database.
	componentDidMount() {
			this.state.list.then(r => {
				this.renderList(r.data)
			}, () => {
				this.renderList([])
			})
	}
	
	renderList(lst) {
		this.setState({
			list: lst
		})
	}
	
	render() {
		console.log(this.state.list)
		
		var list = !Array.isArray(this.state.list) ?
			(<Spinner />) : this.state.list.length != 0 ?
			this.state.list.map((item) => <CompListItem info={item} key={item._id}/>) :
			(<p>No Compositions</p>)
		return (
		<div style={{textAlign:"center"}}>
			<div id="comp-list-header">
				<div style={{width:"30%"}}>Title</div>
				<div style={{width:"30%"}}>Tags</div>
				<div style={{width:"20%"}}>Date</div>
				<div style={{width:"20%"}}>Duration</div>
			</div>
			{list}
		</div>
		);
	}
}

class CompListItem extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			info: props.info,
			chosen: false,
			sidebarClass: ""
		}
		this.chosenState = this.chosenState.bind(this)
		this.parseDate = this.parseDate.bind(this)
	}
	
	render() {
		var info = this.state.info;
		var tags = info.tags.join(", ");
		var date = this.parseDate(info.date);
		
		var sidebar = null;
		if(this.state.chosen) {
			var c = "info-field-title";
			sidebar = (
			<div className="dark-overlay" style={{zIndex:"2", position:"fixed"}}>
				<div id="sidebar" className={this.state.sidebarClass}>
					<button onClick={this.chosenState} style={{padding:"5px"}}>Close</button>
					<div style={{padding:"10px"}}>
						<h2 className="text-primary" id="info-title">Composition Information</h2>
						<br />
						<p><span className={c}>Title: </span>{info.title}</p>
						<p><span className={c}>Tags: </span>{tags}</p>
						<p><span className={c}>Date: </span>{date}</p>
						<p><span className={c}>Duration: </span>{info.runtime}</p>
						<p><span className={c}>Composer: </span>{info.composer}</p>
						<p><span className={c}>Performers: </span>{info.performers.join(", ")}</p>
						<p><span className={c}>Description: </span>{info.description}</p>
						<audio controls className="audio-elem">
							<source src={"https://johncagetribute.org/api/compositions/view/" + info._id} type={info.filetype}/>
						</audio>
					</div>
				</div>
			</div>
			)
		}
		
		return (
		<Fragment>	
			{sidebar}
			<div className="comp-list-item" onClick={this.chosenState}>
				<div style={{width:"30%"}}>{info.title}</div>
				<div style={{width:"30%"}}>{tags}</div>
				<div style={{width:"20%"}}>{date}</div>
				<div style={{width:"20%"}}>{info.runtime}</div>
			</div>
		</Fragment>
		);
	}
	
	parseDate(str) {
		var res = "";
		for(var i=0; i < str.length; i++) {
			if(str[i] == "T" || str[i] == "Z")
				res += " ";
			else res += str[i];
		}
		return res
	}
	
	chosenState() {
		var s;
		if(!this.state.chosen)
			s = "open-sidebar";
		else
			s = "";
		this.setState((state) => ({
			chosen: !state.chosen,
			sidebarClass: s
		}))
	}
}

export default CompList;