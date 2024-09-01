const express = require('express');
const mongodb = require('mongoose');

const PORT = 3000;
const app = express();
const DB = "mongodb+srv://ritikjoshi741:9456597017ritik@cluster0.vvntg.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongodb.connect(DB).then(() =>{
    console.log("connected successfully");
})

app.listen(PORT, '0.0.0.0',() => {
    console.log(`server connected at ${PORT}`);
})