/*
const express = require('express');
const app = require('express')();
const mongoose = require('mongoose');
const http = require('http').createServer(app);
const io = require('socket.io')(http);
const multer = require('multer');
const path = require('path');
const Role = {
  LISTENER: 0,
  PERFORMER: 1
};
availableRooms = {}; // Currently active rooms
memberAttendance = {}; // Maps socketId to roomId
io.on('connection', function (socket) {
  console.log(`Received connection from socket: ${socket.id}.`);
  const rooms = availableRooms;
  socket.emit('updaterooms', rooms);
  socket.on('createroom', function (data) {
    console.log(`Received createroom from socket: ${socket.id}.`);
    const room = data.room;
    const roomId = room['id'];
    const member = data.member;
    availableRooms[roomId] = room;
    availableRooms[roomId]['members'] = {};
    availableRooms[roomId]['members'][socket.id] = member;
    availableRooms[roomId]['members'][socket.id]['socket'] = socket.id;
    memberAttendance[socket.id] = roomId;
    socket.join(roomId);
    io.to(roomId).emit('updatemembers', availableRooms[roomId]['members']);
  });
  socket.on('leaveroom', function (roomId) {
    const existingRoom = availableRooms[roomId];
    if (!existingRoom) {
      io.to(roomId).emit('roomerror', 'Room data does not exist. Please exit.');
      return;
    }
    const memberList = existingRoom['members'];
    if (!memberList) {
      io.to(roomId).emit(
        'roomerror',
        "This room's member data is missing. Please exit."
      );
      return;
    }
    const user = memberList[socket.id];
    if (!user) {
      return;
    }
    // If the host is leaving, clear the room
    if (user['isHost']) {
      console.log('Host is leaving.');
      io.of('/')
        .in(roomId)
        .clients((error, socketIds) => {
          if (error) throw error;
          socketIds.forEach((socketId) => {
            io.sockets.sockets[socketId].emit(
              'roomerror',
              `The host has disconnected. Please exit the room.`
            );

            delete memberAttendance[socketId];
            io.sockets.sockets[socketId].leave(roomId);
          });
        });
      delete availableRooms[roomId];
    }
    // If non-host is leaving, handle them exclusively
    else {
      console.log('Non-host is leaving.');
      delete memberAttendance[socket.id];
      socket.leave(roomId);
      const member = availableRooms[roomId]['members'][socket.id];
      if (!member) {
        console.log(
          `(leaveroom) Leaving member\'s data does not exist in room: ${roomId}.`
        );
        return;
      }
      const memberRole = member['role'];
      delete availableRooms[roomId]['members'][socket.id];
      if (memberRole == Role.LISTENER) {
        console.log('A listener member is leaving.');
        availableRooms[roomId]['currentListeners']--;
      } else {
        console.log('A performer member is leaving.');
        availableRooms[roomId]['currentPerformers']--;
      }
      io.to(roomId).emit('updatemembers', availableRooms[roomId]['members']);
      const existingRoom = availableRooms[roomId];
      if (existingRoom) {
        delete availableRooms[roomId]['members'][socket.id];
        if (member['role'] == Role.LISTENER) {
          availableRooms[roomId]['currentListeners']--;
        } else {
          availableRooms[roomId]['currentPerformers']--;
        }
        io.to(roomId).emit('updatemembers', availableRooms[roomId]['members']);
      }
    }
  });
  socket.on('verifypin', function (data) {
    console.log(`Received verifypin from socket: ${socket.id}`);
    const roomId = data.roomId;
    const enteredPin = data.enteredPin;
    const room = availableRooms[roomId];
    if (!room) {
      console.log('Attempting to join nonexistent room.');
      socket.emit('verifypin', 'This room is no longer available.');
      return;
    } else {
      if (enteredPin == room['pin']) {
        socket.emit('verifypin', room['pin']);
        return;
      }
      socket.emit('verifypin', 'The entered PIN is incorrect.');
    }
  });
  // Non-host actions
  socket.on('joinroom', function (data) {
    console.log(`Received joinroom from socket: ${socket.id}.`);
    const roomId = data.roomId;
    const member = data.member;
    // roomerror? Idk man...
    const room = availableRooms[roomId];
    if (!room) {
      console.log(`(joinroom) Room does not exist.`);
      socket.emit('roomerror', 'This room does not exist.');
      return;
    }
    const roomMembers = room['members'];
    if (!roomMembers) {
      console.log("(joinroom) This room's member data seems to be missing.");
      socket.emit(
        'joinerror',
        "This room's member data seems to be missing. Please exit."
      );
      return;
    } else {
      if (member['role'] == Role.LISTENER) {
        if (
          availableRooms[roomId]['currentListeners'] ==
          availableRooms[roomId]['maxListeners']
        ) {
          socket.emit(
            'roomerror',
            "This room's max listener capacity was reached. Please exit."
          );
          return;
        }
        availableRooms[roomId]['currentListeners']++;
      } else {
        if (
          availableRooms[roomId]['currentPerformers'] ==
          availableRooms[roomId]['maxPerformers']
        ) {
          console.log('Max performers reached...');
          socket.emit(
            'roomerror',
            "This room's max performer capacity was reached. Please exit."
          );
          return;
        }
        availableRooms[roomId]['currentPerformers']++;
      }
      availableRooms[roomId]['members'][socket.id] = member;
      memberAttendance[socket.id] = roomId;
      socket.join(roomId);
      io.to(roomId).emit('updatemembers', availableRooms[roomId]['members']);
    }
  });
  socket.on('startsession', function (roomId) {
    console.log(`Received startsession from socket: ${socket.id}.`);
    const existingRoom = availableRooms[roomId];
    if (!existingRoom) {
      io.to(roomId).emit(
        'roomerror',
        'Non-host is attempting to start session. Functionality is unavailable.'
      );
      return;
    }
    const memberList = existingRoom['members'];
    if (!memberList) {
      io.to(roomId).emit('roomerror', "This room's member data is missing.");
      return;
    }
    const user = memberList[socket.id];
    if (!user) {
      return;
    }
    // If the host is leaving, clear the room
    if (user['isHost']) {
      console.log(`Yep! You're the host! Time to partyyyy!`);
      io.to(roomId).emit('audiostart', null);
    }
  });
  // Iterate through members of roomId whose roles are LISTENER
  // Then, pass them the audio data
  socket.on('sendaudio', function (data) {
    const roomId = memberAttendance[socket.id];
    if (!roomId) {
      socket.emit('roomerror', 'Error associating user with the room.');
    }
    console.log('Received sendaudio message.');
    console.log(`Audio data in server: ${data.length}`);
    for (var member in availableRooms[roomId]['members']) {
      details = availableRooms[roomId]['members'][member];
      if (details['role'] == Role.LISTENER) {
        console.log(`${details['username']} is a listener!`);
        io.to(details['socket']).emit('playaudio', data);
      }
    }
  });
  socket.on('endsession', function (roomId) {
    const existingRoom = availableRooms[roomId];
    if (!existingRoom) {
      io.to(roomId).emit(
        'roomerror',
        'Cannot end session of nonexistent room. Please exit.'
      );
      return;
    }
    io.to(roomId).emit('audiostop', null);
  });
  socket.on('disconnect', function () {
    console.log(`Received disconnect from socket: ${socket.id}.`);
    const roomId = memberAttendance[socket.id];
    if (roomId != null) {
      // Disconnected user was a host
      if (socket.id == roomId) {
        const existingRoom = availableRooms[socket.id];
        if (!existingRoom) {
          io.to(roomId).emit(
            'roomerror',
            'Room data does not exist. Please exit.'
          );
        } else {
          io.of('/')
            .in(roomId)
            .clients((error, socketIds) => {
              if (error) throw error;
              socketIds.forEach((socketId) => {
                io.sockets.sockets[socketId].emit(
                  'roomerror',
                  `The host has disconnected. Please exit the room.`
                );
                io.sockets.sockets[socketId].leave(roomId);
              });
            });
          delete availableRooms[roomId];
        }
      }
      // Disconnected user was a non-host
      else {
        const existingRoom = availableRooms[roomId];
        if (existingRoom) {
          const member = existingRoom['members'][socket.id];
          if (!member) {
            console.log('Member data missing.');
            return;
          }
          if (member['role'] == Role.LISTENER) {
            availableRooms[roomId]['currentListeners']--;
          } else {
            availableRooms[roomId]['currentPerformers']--;
          }
          delete availableRooms[roomId]['members'][socket.id];
          io.to(roomId).emit(
            'updatemembers',
            availableRooms[roomId]['members']
          );
        }
      }
    }
  });
  socket.on('updaterooms', function () {
    console.log(`Received updaterooms from socket: ${socket.id}.`);
    const existingRooms = availableRooms;
    socket.emit('updaterooms', existingRooms);
  });
});
*/
