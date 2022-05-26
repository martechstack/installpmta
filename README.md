<h1>Installing pmta on a server</h1>

<h3>How to run</h3>
<p>U need to connect to your new server and run next:
<code>curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/install.sh | bash</code>
</p>

step 2: 
Copy content from:
https://raw.githubusercontent.com/martechstack/installpmta/master/src/add_rule.sh
and replace new server IP

<ul>
Regenerate config:
<li>create: config.json</li>
<li>run: curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/regenerate_config.sh | bash</li>
</ul>