const app = require('express')();
const {Server} = require('socket.io');

async function server(){
    const http = require('http').createServer(app);
    const io = new Server(http, {transports: ['websocket']});
    const roomId = '0000';

    io.on('connection', (socket) => {
        console.log('connection');
       socket.on('join', () =>{
           console.log('joined');
         socket.join(roomId);
         socket.to(roomId).emit('joined');
       });
       socket.on('offer', (offer) => {
           console.log('offer');
           socket.to(roomId).emit('offer', offer);
        });
        socket.on('answer', (answer) => {
            socket.to(roomId).emit('answer', answer);
        });
        socket.on('ice', (ice) => {
            socket.to(roomId).emit('ice', ice);
        });

    });
    http.listen(3000, () => console.log('server open'));
}

server();