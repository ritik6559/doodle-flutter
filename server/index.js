const express = require('express');
const mongodb = require('mongoose');
const http = require('http');
const PORT = process.env.PORT || 3000;
const app = express();
const server = http.createServer(app);
var io = require('socket.io')(server);

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

        } catch (e){
            console.log(e);
        }
    });
});

server.listen(PORT, '0.0.0.0',() => {
    console.log(`server connected at ${PORT}`);
})