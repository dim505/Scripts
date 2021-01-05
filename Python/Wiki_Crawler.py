import sys
import requests
import time
from bs4 import BeautifulSoup

#if something is wrong with the input, it will generate an error and  it will exit.
try:
	# the url you are starting at
	st_URL = sys.argv[1]
except:
	#prints error
	print("Looks Like something is wrong there...Please make sure your URL is correct and try again!")
	#exits script
	sys.exit()

#if something is wrong with the input, it will generate an error and  it will exit.
try:
	# the URL you want to reach 
	end_url = sys.argv[2]
	
except:
	#prints out error
	print("Looks Like something is wrong there...Please make sure your URL is correct and try again!")
	#exits script
	sys.exit()

	

print("\nIT BOT Starting Now........\n")
	

#list holding at the URLs visited 
Pages_visited = [st_URL] 


#some commands printing to the terminal

def continue_crawl(Pages_visited, end_url):

    #if last URL visited URL in Crawl is equal to target URL then it reached its destination
    if Pages_visited[-1] == end_url:													
        print("\n\nWe've reached your specified target url - " + end_url + "\n")
        print("IT Bot going to sleep Beep Bop Boop......")
        return False
	#compares if number is visited links has exceeded the max visited links threshold of 50
    elif len(Pages_visited) > 50:
        print("\nOur search history has the maximum article threshold.\n")
        print("IT Bot going to sleep Beep Bop Boop......")
        return False
    #compares number of sites visited  with set number of sites visited, if there is a duplicate in list, you made a loop
	# thus exiting the search 
    elif len(Pages_visited) != len(set(Pages_visited)):
        print("\nZoinks o_O!!! We've hit a repeat!!\n")
        print("Article " + Pages_visited[-1][30:] + " is already on the list.\n")
        print("IT Bot going to sleep Beep Bop Boop......")
        return False
    else:
        return True
		

def Find_link(url):
	#downloads the html file
	response = requests.get(url)
	#saves it as a string
	html = response.text
	#creates a BeautifulSoup object used for extracting data from the html 
	SoupObj = BeautifulSoup(html, 'html.parser')
	#finds element with ID mw-content-text, inside that element find sub element with classname mw-parser-output
	content_div = SoupObj.find(id="mw-content-text").find(class_="mw-parser-output")

	article_name = None
	#finds all P elements in element with class mw-parser-output, only sticks to direct children of selected element
	for element in content_div.find_all("p", recursive=False):
		#if it finds a element inside of P, that will become the next visited link
		if element.find("a", recursive=False):
			#gets Href value from first A link in mw-parser-output class element
			article_name = element.find("a", recursive=False).get('href')
			break
	#if it does not find anything then it was a dead end, returns nothing
	if not article_name:
		return 
	#creates the link
	first_link = 'https://en.wikipedia.org' + article_name
	#returns wiki link
	return first_link

	
#checks to see if it should contine checking for links

while continue_crawl(Pages_visited, end_url):

	print(Pages_visited[-1] + "\n\n", end='')
		
		#gets the next linked page from the URL
	first_link = Find_link(Pages_visited[-1])
		#if no links are found then program exits
	if not first_link:
		print("\nThe article has no links.\n")
		print("IT Bot going to sleep Beep Bop Boop......")
		break
		#adds to total list of sites visitedd
	Pages_visited.append(first_link) 

	#slows down crawl rate so it wont be blocked by wikipedia
	time.sleep(2) 