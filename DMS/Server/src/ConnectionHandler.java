import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Scanner;

public class ConnectionHandler extends Thread
{
	private Socket client;
	private InputStream clientInput;
	private OutputStream clientOutput;
	private OutputStreamWriter writer;
	private Scanner reader;
	private int userId;
	private ArrayList<ServerFile> files;
	private String directory;
	
	public ConnectionHandler(Socket client, ArrayList<ServerFile> files, int id, String directory) throws IOException
	{
		this.client = client;
		clientInput = client.getInputStream();
		clientOutput = client.getOutputStream();
		writer = new OutputStreamWriter(clientOutput);
		reader = new Scanner(clientInput);
		this.files = files;
		this.userId = id;
		this.directory = directory;
	}
	
	public void closeConnection() throws IOException
	{
		client.close();
		clientInput.close();
		clientOutput.close();
		writer.close();
		reader.close();
	}
	
	public void setId(int id)
	{
		userId = id;
	}
	
	// Check out a file - user sends the name of the file they want to check out
	public void checkOut(String fileName) throws IOException
	{
		ServerFile requestedFile = null;
		
		// Check to see if the file exists in the server's directory
		for(int i = 0; i < files.size(); i++)
		{
			if(files.get(i).getName().equals(fileName))
			{
				requestedFile = files.get(i);
			}
		}
		
		// If the file does not exist, alert the user
		if(requestedFile == null)
		{
			System.out.println("File not found");
			return;
		}
		
		// If the file is already checked out, alert the user
		if(requestedFile.isCheckedOut())
		{
			System.out.println("File is already being accessed by another user");
			return;
		}
		
		// All tests have passed, now update the file info and send the file to the user
		requestedFile.setOwnerId(userId);
		requestedFile.setCheckedOut(true);
		
		// Send the file to the user
		sendFile(requestedFile);
	}
	
	public void checkIn(String fileName) throws IOException
	{
		ServerFile requestedFile = null;
		
		for(int i = 0; i < files.size(); i++)
		{
			if(files.get(i).getName().equals(fileName))
			{
				requestedFile = files.get(i);
			}
		}
		
		if(requestedFile == null)
		{
			System.out.println("File not found");
			return;
		}
		
		if(requestedFile.getOwnerId() != userId)
		{
			System.out.println("You are not the owner of the file");
			return;
		}
		
		// Receive the file from the user
		
		receiveFile(fileName);
		
		requestedFile.setCheckedOut(false);
		requestedFile.setOwnerId(-1);
	}
	
	public void refresh()
	{
		for(int i = 0; i < files.size(); i++)
		{
			System.out.println("File name: " + files.get(i).getName());
			if(files.get(i).isCheckedOut())
				System.out.println("Status: Checked out");
			else
				System.out.println("Status: Available");
			System.out.println("File Owner: " + files.get(i).getOwnerId());
		}
	}
	
	public void getLatestVersion() throws IOException
	{		
		// Send the files
		for(int i = 0; i < files.size(); i++)
		{
			writer.write(files.get(i).getName() + "\r\n");
			writer.flush();
			sendFile(files.get(i));
		}
	}
	
	public void sendFileInfo() throws IOException
	{
		for(int i = 0; i < files.size(); i++)
		{
			writer.write(files.get(i).getName() + "\n");
			writer.write(files.get(i).length() + "\r\n");
			writer.flush();
		}
	}
	
	public void sendFile(ServerFile requestedFile) throws IOException
	{
		byte [] mybytearray  = new byte [(int)requestedFile.length()];
		FileInputStream fis = new FileInputStream(requestedFile);
		BufferedInputStream bis = new BufferedInputStream(fis);
        bis.read(mybytearray, 0, mybytearray.length);
        clientOutput.write(mybytearray, 0, mybytearray.length);
        clientOutput.flush();
        fis.close();
        bis.close();
	}
	
	public void receiveFile(String fileName) throws IOException
	{
		byte [] mybytearray  = new byte [10000];
	    FileOutputStream fos = new FileOutputStream(directory + "/" + fileName);
	    BufferedOutputStream bos = new BufferedOutputStream(fos);
	    
	    int bytesRead = clientInput.read(mybytearray, 0, mybytearray.length);
	    int current = bytesRead;
	
	    bos.write(mybytearray, 0 , current);
	    bos.flush();
	  
	    System.out.println("File downloaded (" + current + " bytes read)");
	  	
	  	fos.close();
	    bos.close();
	}
	
	public void terminate() throws IOException
	{
		client.close();
		clientInput.close();
		clientOutput.close();
		writer.close();
		reader.close();
	}
	
	@Override
	public void run()
	{
		try 
		{			
			sendFileInfo();
			
			writer.write("Welcome to the Document Management Server\n");
			writer.write("Type one of the following commands: checkout, checkin, refresh, get latest version\r\n");
			writer.flush();
			
			String command = "";
			while(!command.equalsIgnoreCase("exit"))
			{
				command = reader.nextLine();
				
				// Check for one of the commands from the user
				if(command.contains("checkout"))
				{
					String[] input = command.split(" ");
					String name = input[1];
					
					checkOut(name);
				}
				else if(command.contains("checkin"))
				{
					String[] input = command.split(" ");
					String name = input[1];
					
					checkIn(name);
				}
				else if(command.equalsIgnoreCase("refresh"))
				{
					refresh();
				}
				else if(command.equalsIgnoreCase("get latest version"))
				{
					getLatestVersion();
				}
				else if(command.equalsIgnoreCase("exit"))
				{
					terminate();
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
}
