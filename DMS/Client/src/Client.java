import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Scanner;

import javax.swing.JOptionPane;

public class Client 
{
	private static String directory = "C:/ClientFiles";
	private int portNumber;
	private String IPAddress;
	private Socket client;
	private InputStream serverInput;
	private DataInputStream dis;
	private OutputStream serverOutput;
	private OutputStreamWriter writer;
	private Scanner reader;
	private HashMap<String, Integer> fileInfo;
	
	public Client(int port, String IP) throws IOException
	{
		this.portNumber = port;
		this.IPAddress = IP;
		client = null;
		
		File fileDir = new File(directory);
		if (!fileDir.exists()) 
		{
		    try
		    {
		    	fileDir.mkdir();
		    } 
		    catch(SecurityException e)
		    {
		    	
		    }        
		}
		
		fileInfo = new HashMap<String, Integer>();
	}
	
	public void start() throws UnknownHostException, IOException
	{
		client = new Socket(IPAddress, portNumber);
		serverInput = client.getInputStream();
		dis = new DataInputStream(serverInput);
		serverOutput = client.getOutputStream();
		writer = new OutputStreamWriter(serverOutput);


		reader = new Scanner(serverInput);
	}
	
	public void startSourceControl() throws IOException
	{		
		Scanner clientReader = new Scanner(System.in);
		
		String fileName = "";
		while(!fileName.contains("Welcome"))
		{
			fileName = reader.nextLine();
			if(!fileName.contains("Welcome"))
			{
				int fileSize = Integer.parseInt(reader.nextLine());
				fileInfo.put(fileName, fileSize);
				System.out.println(fileName + " " + fileSize);
			}
		}
		
		String message = fileName;
		System.out.println(message);
		message = reader.nextLine();
		System.out.println(message);
		
		String command = "";
		
		while(!command.toLowerCase().equals("exit"))
		{
			command = clientReader.nextLine();
			
			if(command.contains("checkout"))
			{
				String[] input = command.split(" ");
				
				if(input.length == 1 || input[1].equals(""))
				{
					System.out.println("Incorrect syntax (ex. checkout filename.txt)");
				}
				else
				{
					writer.write(command + "\r\n");
					writer.flush();
					
					System.out.println("Checking out file...");
					
					String name = input[1];
					
					byte [] mybytearray  = new byte [10000];
				    FileOutputStream fos = new FileOutputStream(directory + "/" + name);
				    BufferedOutputStream bos = new BufferedOutputStream(fos);
				    
				    int bytesRead = serverInput.read(mybytearray, 0, mybytearray.length);
				    int current = bytesRead;
				
				    bos.write(mybytearray, 0 , current);
				    bos.flush();
				  
				    // Notify user if the file is empty
				    System.out.println("File downloaded (" + current + " bytes read)");
				  	
				  	fos.close();
				    bos.close();
				}
			}
			else if(command.contains("checkin"))
			{
				String[] input = command.split(" ");
				
				if(input.length == 1 || input[1].equals(""))
				{
					System.out.println("Incorrect syntax (ex. checkout filename.txt)");
				}
				else
				{
					writer.write(command + "\r\n");
					writer.flush();
				}
				
				writer.write(command + "\r\n");
				writer.flush();
				
				ServerFile file = new ServerFile(directory, input[1]);
				
				byte [] mybytearray  = new byte [(int)file.length()];
				FileInputStream fis = new FileInputStream(file);
				BufferedInputStream bis = new BufferedInputStream(fis);
		        bis.read(mybytearray, 0, mybytearray.length);
		        serverOutput.write(mybytearray, 0, mybytearray.length);
		        serverOutput.flush();
		        fis.close();
		        bis.close();
				
			}
			else if(command.equalsIgnoreCase("refresh"))
			{
				writer.write(command + "\r\n");
				writer.flush();
			}
			else if(command.equalsIgnoreCase("get latest version"))
			{
				writer.write(command + "\r\n");
				writer.flush();
				
				int count = fileInfo.size();
				
				while(count > 0)
				{
					String name = dis.readLine();
					System.out.println(name);
					byte [] mybytearray  = new byte [10000];
				    FileOutputStream fos = new FileOutputStream(directory + "/" + name);
				    BufferedOutputStream bos = new BufferedOutputStream(fos);
				    //int bytesRead = serverInput.read(mybytearray, 0, fileInfo.get(name));
				    int bytesRead = dis.read(mybytearray, 0, fileInfo.get(name));
				    bos.write(mybytearray, 0 , bytesRead);
				    bos.flush();
				  
				    // Notify user if the file is empty
				    System.out.println("File downloaded (" + bytesRead + " bytes read)");
			  	
				  	fos.close();
				    bos.close();
				    count--;
				}
			}
			else if(command.equalsIgnoreCase("exit"))
			{
				writer.write(command + "\r\n");
				writer.flush();
			}
		}
		
		client.close();
		serverInput.close();
		serverOutput.close();
		writer.close();
		reader.close();
		clientReader.close();
	}
	
	public void terminate() throws IOException
	{
		client.close();
	}
	
	public static void main(String[] args) throws UnknownHostException, IOException
	{
		String IPAddress = "";
		int port = 10010;
		
		IPAddress = JOptionPane.showInputDialog("Enter an IP Address");
		
		Client client = new Client(port, IPAddress);
		client.start();
		client.startSourceControl();
		
		client.terminate();
		
		
		
	}
}
