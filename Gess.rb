require 'net/http'
require 'optparse'
require 'colorize'
require 'artii'
require 'resolv'

# Define color constants
RED = "\033[1;31m"
GREEN = "\033[1;32;0m"
OKBLUE = "\033[94m"
WHITE = "\033[0;37m"

# Define options hash
options = {}

# Set up command-line option parser
parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby Gess.rb [options]"

  opts.on("-l LIST", "--list=LIST", "File containing a list of domains") do |list|
    options[:list] = list
  end
end

# Parse command-line options
parser.parse!

# Get domain list from options
domain_list = options[:list]

# Define Artii object
a = Artii::Base.new
puts a.asciify("Gess")

# Signal trap for Ctrl+C
trap('INT') do
  puts "\n\n#{RED}Scan interrupted by user. Exiting gracefully.\033[0m"
  exit
end

# Check if domain list file exists
if domain_list && File.file?(domain_list)
  read_words = File.open(domain_list, 'r')
else
  exit("#{RED}File Not Found Unable To Load Targets")
end

# Initialize arrays and files
sub_list = []
vuln = []
valid = []
valid_urls = File.open('ValidUrls.txt', 'a')
takeover = File.open('Takeover.txt', 'a')

# Process each domain in the list
read_words.each_line do |words|
  words = words.strip
  words = words.gsub("https://", "")
  words = words.gsub("http://", "")
  words = words.gsub("https://www.", "")
  words = words.gsub("http://www.", "")
  words = words.gsub("/", "")
  words = "http://#{words}"
  sub_list << words
  valid_urls.write("#{words}\n")
end

# Close files
valid_urls.close
read_words.close

# Display total targets loaded
if sub_list.length > 0
  puts "#{WHITE}\n[!] Total #{sub_list.length} Targets Loaded [!]\033[94m"
  puts "#{WHITE}[!] Checking For Subdomain Takeover..... [!]\n\033[94m"

  # Define vulnerable contents
  vuln_contents = [
    "<strong>Trying to access your account",
    "Use a personal domain name",
    "The request could not be satisfied",
    "Sorry, We Couldn't Find That Page",
    "Fastly error: unknown domain",
    "The feed has not been found",
    "You can claim it now at",
    "Publishing platform",
    "There isn't a GitHub Pages site here",
    "No settings were found for this company",
    "Heroku | No such app",
    "<title>No such app</title>",
    "You've Discovered A Missing Link. Our Apologies!",
    "Sorry, couldn&rsquo;t find the status page",
    "NoSuchBucket",
    "Sorry, this shop is currently unavailable",
    "<title>Hosted Status Pages for Your Company</title>",
    "data-html-name=\"Header Logo Link\"",
    "<title>Oops - We didn't find your site.</title>",
    "class=\"MarketplaceHeader__tictailLogo\"",
    "Whatever you were looking for doesn't currently exist at this address",
    "The requested URL was not found on this server",
    "The page you have requested does not exist",
    "This UserVoice subdomain is currently available!",
    "but is not configured for an account on our platform",
    "<title>Help Center Closed | Zendesk</title>",
    "Sorry, We Couldn't Find That Page Please try again",
    "This domain is not registered with WordPress.com",
    "The site you were looking for couldn't be found",
    "We could not find the page you're looking for",
    "The specified bucket does not exist",
    "Domain not found",
    "Your CNAME record is not set up correctly",
    "There's nothing here, yet",
    "The site you requested is not active",
    "This domain is no longer parked",
    "This page is parked free, courtesy of",
    "The site you were looking for couldn't be found",
    "The requested URL could not be found",
    "This UserVoice subdomain is available",
    "This domain expired",
    "The site you're looking for is not yet available",
    "The requested URL was not found on this server",
    "404 Not Found",
    "404: This page could not be found",
    "404 - Not Found",
    "404 error unknown site!",
    "404. That's an error.",
    "The URL may be misspelled or the page you are looking for is no longer available",
    "Please update your billing information to reactivate your site",
    "Domain not configured",
    "Domain available",
    "No website is configured at this address",
    "There's nothing here, yet.",
    "This domain is available for sale!",
    "The requested URL does not exist",
    "The site you were looking for couldn't be found, and we're sorry about that.",
    "This domain is for sale!",
    "This domain has expired",
    "Sorry, we couldn't find any results for",
    "The specified bucket does not exist",
    "There's nothing here yet, but Bitbucket is our favorite",
    "The requested URL was not found on this server",
    "The resource could not be found",
    "The URL you visited was not found",
    "No such app was found at this domain",
    "This domain is parked for FREE",
    "This domain has expired and is pending renewal or deletion",
    "The site you were looking for couldn't be found",
    "No such app",
    "This domain is parked for FREE by",
    "The site you are looking for could not be found",
    "This domain has just been registered",
    "This domain is available to register!",
    "The page you are looking for cannot be found",
    "This domain is registered at Namecheap",
    "This site is currently parked with Netfleet",
    "This domain is parked free of charge with NameSilo.com",
    "This domain is parked free",
    "This domain is for sale",
    "This domain may be for sale",
    "This domain is available for purchase",
    "This domain is available to buy",
    "This domain is available to register",
    "This domain is available for registration",
    "This domain is no longer active",
    "This domain is not configured",
    "This domain is suspended",
    "This domain is pending renewal",
    "This domain is pending deletion",
    "This domain is pending verification",
    "This domain is no longer in use",
    "This domain is not renewed",
    "This domain is not configured for a website",
    "This domain is not associated with a website",
    "This domain is not active",
    "This domain has been registered but is not yet active",
    "This domain has been suspended",
    "This domain has been deleted",
    "This domain has been expired",
    "This domain has been transferred",
    "This domain has been canceled",
    "This domain has been disabled",
    "This domain has been removed",
    "This domain has been retired",
    "This domain has been decommissioned",
    "This domain has been abandoned",
    "This domain has been taken down",
    "This domain has been seized",
    "This domain has been blacklisted",
    "This domain has been blocked",
    "This domain has been flagged",
    "This domain has been marked as spam",
    "This domain has been flagged for abuse",
    "This domain has been reported as malicious",
    "This domain has been reported for phishing",
    "This domain has been reported for fraud",
    "This domain has been reported for scam",
    "This domain has been reported for illegal activities",
    "This domain has been reported for copyright infringement",
    "This domain has been reported for trademark violation",
    "This domain has been reported for intellectual property theft",
    "This domain has been reported for data breach",
    "This domain has been reported for hacking",
    "This domain has been reported for malware",
    "This domain has been reported for data breach",
    "This domain is expired",
    "CNAME entry not found",
    "Your connection isn't private",
  ]

  # Initialize arrays for vulnerable, non-vulnerable, and suspended domains
  vulnerable_domains = []
  non_vulnerable_domains = []
  suspended_domains = []

  # Define function for checking vulnerability
  def check_vulnerability(domain, vuln_contents, vuln, valid, takeover, vulnerable_domains, non_vulnerable_domains, suspended_domains)
    begin
      ip_address = Resolv.getaddress(URI(domain).host)
      response = Net::HTTP.get_response(URI(domain))
      sub_domain = response.body

      is_vulnerable = vuln_contents.any? { |vuln_content| sub_domain.include?(vuln_content) }

      if is_vulnerable
        puts "#{GREEN}    [✔️] Vulnerable #{domain} (IP: #{ip_address})\033[94m \n"
        vuln << domain
        valid << domain
        takeover.write("#{domain} (IP: #{ip_address})\n")
        vulnerable_domains << domain
      else
        puts "#{OKBLUE}  -- Not Vulnerable #{domain} (IP: #{ip_address})\033[94m \n"
        valid << domain
        non_vulnerable_domains << domain
      end
    rescue StandardError
      puts "#{RED}!! Error => #{domain}\033[94m \n"
      suspended_domains << domain
    end
  end

  # Concurrently check vulnerability for each domain
  threads = sub_list.map do |domain|
    Thread.new { check_vulnerability(domain, vuln_contents, vuln, valid, takeover, vulnerable_domains, non_vulnerable_domains, suspended_domains) }
  end

  threads.each(&:join) # Wait for all threads to finish

  # Display vulnerable, non-vulnerable, and error domains
  puts "\nVulnerable Domains:"
  puts vulnerable_domains.join("\n").colorize(:green) if vulnerable_domains.any?
  puts "\nNon-Vulnerable Domains:"
  puts non_vulnerable_domains.join("\n").colorize(:blue) if non_vulnerable_domains.any?
  puts "\nError Domains:"
  puts suspended_domains.join("\n").colorize(:red) if suspended_domains.any?

  # Display summary
  total_domains_checked = sub_list.length
  total_vulnerable_domains = vulnerable_domains.length
  total_non_vulnerable_domains = non_vulnerable_domains.length
  total_suspended_domains = suspended_domains.length

  puts "\nSummary:"
  puts "Total Domains Checked: #{total_domains_checked}"
  puts "Vulnerable Domains: #{total_vulnerable_domains}"
  puts "Non-Vulnerable Domains: #{total_non_vulnerable_domains}"
  puts "Error Domains: #{total_suspended_domains}"

  # Close files
  takeover.close
else
  puts "\nSubdomain Takeover Scanner \n\n\t--help, -h: Show Help\n\t--list, -l: File containing a list of domains\n"
end
