# Riposte

If you're running a server and have fail2ban enabled (which you should), your `/var/log/auth.log` file will sooner or later fill up with messages about someone trying to compromise your SSH port. Riposte analyzes these messages, ranks the countries most of these attackers originate from, and offers the ability to scan incoming connections for open HTTP ports using nmap. Why? More on that later.

## Dependencies
geoiplookup, nmap, grep - the usual.

## Usage
	Usage: riposte.sh [OPTION]
	Show unique IPs in /var/log/auth.log - or scan attacking IPs for an open HTTP port

	Options:
	  --show         List unique IPs, sorted by frequency and country of origin
	  --analyze      Executes a specified NMAP search pattern and writes a report from the results.
	  --help         Show this help

`--show ` reads your auth.log and creates a simple ranking of where most attacks on your server originate:

	Top countries of blocked connections:
	8 × Singapore
	28 × China
	13 × United States
	7 × Korea
	7 × Hong Kong
	7 × Germany
	5 × United Kingdom
	5 × Indonesia


`--analyze` filters the IPs and scans all IP addresses for open HTTP ports using nmap. Why? Because many of the attacking IPs belong to servers that have themselves been victims of attackers. An open HTTP port usually means a website – and that often offers the possibility of contacting the server administrator and informing them about what their machine is doing.
Nmap scanning isn't a crime, but since I don't have all the local laws of every country memorized, the code offers the option to blacklist countries using `EXCLUDE_COUNTRIES=()`. The HTTP scanner will take this into account and won't scan IP addresses that, according to `geoiplookup`, originate from such countries.
Once everything is done, all IP-Adresses with open HTTP-ports will be saved to a file called `http_found.txt`

## todo
- Speeding up the scanning process - currently looking into `parallel` and `masscan`
- Webcrawler which attempts to find and evaluate contact email addresses hosted on the websites in order to potentially automate the admin notification

## Disclaimer
Don't do anything illegal wis this, obviously
My native language is German - if any German variables still appear in the code, I apologize; I tried to translate everything.
