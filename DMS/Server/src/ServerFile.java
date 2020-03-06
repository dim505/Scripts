import java.io.File;

public class ServerFile extends File
{
	private String name;
	private int ownerId;
	private boolean checkedOut;
	
	public ServerFile(String directory, String name, int ownerId)
	{
		super(directory + "/" + name);
		this.name = name;
		this.ownerId = ownerId;
		checkedOut = false;
	}
	
	public String getName()
	{
		return name;
	}
	
	public void setName(String name)
	{
		this.name = name;
	}
	
	public int getOwnerId()
	{
		return ownerId;
	}
	
	public void setOwnerId(int ownerId)
	{
		this.ownerId = ownerId;
	}
	
	public boolean isCheckedOut()
	{
		return checkedOut;
	}
	
	public void setCheckedOut(boolean checkedOut)
	{
		this.checkedOut = checkedOut;
	}
}
