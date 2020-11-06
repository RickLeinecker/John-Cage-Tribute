import React, { Fragment, useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import api from '../../utils/api';
import Spinner from '../layout/Spinner';
import CompList from "./CompList";

class Search extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			searchParam: "",
			searchQuery: ""
		};
		this.performSearch = this.performSearch.bind(this);
	}
	
	render() {
		const s = "search-params-button";
		const chosenStyle = {
			backgroundColor: "#adf"
		}
		var res, tagsStyle=null, titleStyle=null, composerStyle=null, performerStyle=null; 
		switch(this.state.searchParam) {
			case "tags":
				res = api.get("compositions/tags", {query: this.state.searchQuery});
				tagsStyle = chosenStyle;
				break;
			case "composer":
				res = api.get("compositions/composer", {query: this.state.searchQuery});
				composerStyle = chosenStyle;
				break;
			case "performer":
				res = api.get("compositions/performer", {query: this.state.searchQuery});
				performerStyle = chosenStyle;
				break;
			case "title":
				res = api.get("compositions/title", {query: this.state.searchQuery});
				titleStyle = chosenStyle;
				break;
			default:
				res = api.get("/compositions");
				break;
		}
		return (
		<Fragment>
			<div style={{textAlign:"center"}}>
				<input type="text" id="search-bar" placeholder="Search"/>
				<button style={{padding:"4px 7px",fontWeight:"bold"}} onClick={this.performSearch}>&gt;</button>
			</div>
			<div style={{textAlign:"center",borderBottom:"1px solid gray",padding:"10px 0px"}}>
				<div className={s} id="title" style={titleStyle}
					onClick={() => this.changeSearchParam("title")}>Title</div>
				<div className={s} id="tags" style={tagsStyle}
					onClick={() => this.changeSearchParam("tags")}>Tags</div>
				<div className={s} id="composer" style={composerStyle}
					onClick={() => this.changeSearchParam("composer")}>Composer</div>
				<div className={s} id="performer" style={performerStyle}
					onClick={() => this.changeSearchParam("performer")}>Performer</div>
			</div>
			<CompList list={res} />
		</Fragment>
		);
	}
	
	performSearch() {
		this.setState({
			searchQuery: document.getElementById("search-bar").value
		})
		this.forceUpdate();
	}
	
	changeSearchParam(str) {
		this.setState({
			searchParam: str
		})
	}
}

export default Search;