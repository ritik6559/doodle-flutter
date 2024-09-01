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

mongodb.connect(DB).then(() =>{
    console.log("connected successfully");
}).catch((e) => {
    console.log(e);
})

io.on('connection',(socket) => {
    console.log("connected");
    socket.on('create-game',async({nickname, name, occupancy, maxRounds}) => {
        try{
            const existingRoom = await Room.findOne({name});
            if(existingRoom){
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
            socket.join(room);
            io.to(name).emit('updateRoom', room);
        } catch (e){
            console.log(e);
        }
    });
});

server.listen(PORT, '0.0.0.0',() => {
    console.log(`server connected at ${PORT}`);
})