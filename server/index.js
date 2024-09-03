const express = require('express');
const mongodb = require('mongoose');
const http = require('http');
const PORT = process.env.PORT || 3000;
const app = express();
const server = http.createServer(app);
var io = require('socket.io')(server);
const Room = require('./models/room');
const getWord = require('./api/getWord');

//middleware
app.use(express.json());


const DB = "mongodb+srv://ritikjoshi741:9456597017ritik@cluster0.vvntg.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongodb.connect(DB).then(() => {
    console.log("connected successfully");
}).catch((e) => {
    console.log(e);
})

io.on('connection', (socket) => {
    console.log("connected");
    socket.on('create-game', async ({ nickname, name, occupancy, maxRounds }) => {
        try {
            const existingRoom = await Room.findOne({ name });
            if (existingRoom) {
                socket.emit('notCorrectGame', 'Room with that name already exists!');
            }
            let room = new Room();
            const word = getWord();
            room.word = word;
            room.name = name;
            room.occupancy = occupancy;
            room.maxRounds = maxRounds;

            let player = {
                socketID: socket.id,
                nickname,
                isPartyLeader: true,
            }

            room.players.push(player);
            room = await room.save();
            socket.join(name);
            io.to(name).emit('updateRoom', room);
        } catch (e) {
            console.log(e);
        }
    });


    socket.on('join-game', async ({ nickname, name }) => {
        try {

            let room = await Room.findOne({ name });
            if (!room) {
                socket.emit(`notCorrectGame`, `Please enter a valid room name`);
            }

            if (room.isJoin) {
                let player = {
                    socketID: socket.id,
                    nickname,
                }
                room.players.push(player);
                socket.join(name);
                if (room.players.length === room.occupancy) {
                    room.isJoin = false;
                }

                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(name).emit('updateRoom', room);
            } else {
                socket.emit(`notCorrectGame`, `Game is in progress, please try later.`);
            }

        } catch (e) {
            console.log(e);
        }
    });

    socket.on('paint', ({details, roomName}) => {
        io.to(roomName).emit('points', {details: details});
    });

    socket.on('color-change',({color, roomName}) => {
        io.to(roomName).emit('color-change', color);
    });

    socket.on('stroke-change',({stroke, roomName}) => {
        io.to(roomName).emit('stroke-change', stroke);
    });

    socket.on('clear-screen', (roomName)=> {
        io.to(roomName).emit('clear-screen');
    })
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`server connected at ${PORT}`);
})