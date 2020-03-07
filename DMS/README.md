# Scripts
My Document Management System is coded in Java. It has a client/server architecture. The server acts as a gate keeper for files to be checked in/out of the server directory. The server keep tracks of who checks out the files, who checks them in and who is the owner. Clients can connect to the server and check files in and out as needed.

The server is always listening in the background for a connection. There can be up to 10 connections at once. Once a client connects via IP address, they have 4 options that they can enter in the terminal:

1) Checkout "file name": You download a files from the server
2) Check in "file name" : You upload a file to the server
3) Refresh : gets a list of files and their checkout status/owners
4) Get latest version : downloads all files related to owner

The project is split into 2 folders. 1st is server (contains all files needed to get server running) and 2nd is client (contains all files needed to connect to server). 