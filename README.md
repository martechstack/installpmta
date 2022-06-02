<h1>Installing pmta on a server</h1>

<h3>How to install</h3>
<ul>
U need to connect to your new server and run next:
<li>create: config.json</li>
<li>
    <code>curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/src/1-Start.sh | bash
curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/make_config.sh | bash
    </code>
</li>
<li>nano config.json and insert configs there</li>
<li>
    <code>curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/install.sh | bash</code>    
</li>
</ul>


<ul>
<h3>Regenerate config:</h3>
<li>create: config.json</li>
<li>run: curl -s https://raw.githubusercontent.com/martechstack/installpmta/master/regenerate_configs.sh | bash</li>
</ul>