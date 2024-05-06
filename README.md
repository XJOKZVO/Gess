# Gess
Ruby script here for scanning for subdomain takeover vulnerabilities. This script takes a list of domains as input and checks each one for vulnerabilities that could lead to subdomain takeover.

1.Command-line Options Parsing: The script uses the OptionParser class to parse command-line options. It expects a -l or --list option followed by the name of a file containing a list of domains.

2.Reading Domain List: If the file containing the domain list exists, it reads each line, processes the domain names, and stores them in an array called sub_list.

3.Checking for Subdomain Takeover: It defines vulnerable content patterns and then checks each domain in sub_list for these patterns concurrently using threads. If a domain contains any of the vulnerable content patterns, it's considered vulnerable.

4.Output: The script prints out the results, including vulnerable domains, non-vulnerable domains, and any errors encountered during the process.

5.Summary: Finally, it prints a summary of the total number of domains checked, vulnerable domains, non-vulnerable domains, and error domains.

6.File Handling: It writes the valid URLs to a file named "validUrls.txt" and writes vulnerable domains to a file named "Takeover.txt".
