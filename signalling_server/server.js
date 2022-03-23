const app = require('express')();
const {Server} = require('socket.io');

async function server(){
    const http = require('http').createServer(app);
    const io = new Server(http, {transports: ['websocket']});
    const roomId = '0000';

    io.on('connection', (socket) => {
        console.log('connection');
       socket.on('join', (data) =>{
           console.log('joined '+ data.roomId);
         socket.join(data.roomId);
         socket.to(data.roomId).emit('joined');
       });
       socket.on('offer', (data) => {
           console.log('offer ' + data.roomId);
           console.log(data.offer);
           socket.to(data.roomId).emit('offer', data.offer);
        });
        socket.on('answer', (data) => {
            console.log('answer ' + data.roomId);
           console.log(data.answer);
            socket.to(data.roomId).emit('answer', data.answer);
        });
        socket.on('ice', (data) => {
            console.log('ice ' + data.roomId);
           console.log(data.ice);
            socket.to(data.roomId).emit('ice', data.ice);
        });

    });
    http.listen(3000, () => console.log('server open'));
}

server();