import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

public class Server 
{
	private ServerSocket server;
	private int port;
	private Socket client;
	private String directory;
	private ArrayList<ServerFile> files;
	private ArrayList<ConnectionHandler> connections;
	private final int maxConnections = 10;
	
	// Constructor to create a new server
	public Server(int port)
	{
		this.port = port;
		server = null;
		client = null;
		directory = "C:/ServerFiles";
		
		File fileDir = new File(directory);
		if (!fileDir.exists()) 
		{
		    System.out.println("Please create a directory under C:/ServerFiles");
		}
		
		files = new ArrayList<ServerFile>();
		connections = new ArrayList<ConnectionHandler>();
		
		files.add(new ServerFile(directory, "Document1.txt", -1));
		files.add(new ServerFile(directory, "Document2.txt", -1));
		files.add(new ServerFile(directory, "Document3.txt", -1));
		files.add(new ServerFile(directory, "Document4.txt", -1));
	}
	
	// Starts the server
	public void start() throws IOException
	{
		server = new ServerSocket(port);
	}
	
	// Accepts a new client connection
	public void acceptConnection() throws IOException
	{
		client = server.accept();
		ConnectionHandler handler = new ConnectionHandler(client, files, connections.size(), directory);
		
		if(getNumActiveConnections() < maxConnections)
		{
			connections.add(handler);
			handler.start();
		}
	}
	
	// Closes the server
	public void terminate() throws IOException
	{
		server.close();
	}
	
	public int getNumActiveConnections()
	{
		int active = 0;
		
		for(int i = 0; i < connections.size(); i++)
		{
			if(connections.get(i).isAlive())
				active++;
		}
		
		return active;
		
	}
	
	public static void main(String[] args) throws IOException
	{
		int port = 10010;
		Server server = new Server(port);
		
		try
		{
			server.start();
			
			// Accept client connections forever
			while(true)
				server.acceptConnection();
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			server.terminate();
		}
	}
}