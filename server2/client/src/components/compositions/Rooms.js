import React from "react";
import io from 'socket.io-client';

//room requirements
//=================
//-guest or user can join rooms to listen
//-requires pin

class Rooms extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			socket: io("https://johncagetribute.org/")
		};
		this.updateRooms = this.updateRooms.bind(this);
	}
	
	componentDidMount() {
		const socket = this.state.socket;
		socket.on("updaterooms", rooms => {
			console.log("Rooms: ")
			console.log(rooms)
		})
	}
	
	componentWillUnmount() {
		const socket = this.state.socket;
		console.log(socket);
		socket.emit("disconnect");
		socket.close();
	}
	render() {
		return (
		<div>
			<h1 className="large text-primary">Rooms</h1>
			<button onClick={this.updateRooms}>Refresh</button>
		</div>
		)
	}
	
	updateRooms() {
		const socket = this.state.socket
		socket.emit("updaterooms");
	}
}

export default Rooms;