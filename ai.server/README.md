<h2>Overview</h2>
<p>This add-on allows you to run <strong>Code Project AI</strong> locally on your <strong>Home Assistant OS</strong> installation. It provides an <strong>AI-powered</strong> processing engine for <strong>image recognition, object detection, and more</strong> using CPU (with optional Google Coral support).</p>

<h2>Features</h2>
<ul>
    <li>Runs <strong>Code Project AI</strong> on your Home Assistant device</li>
    <li>Supports <strong>persistent storage</strong> for AI models and settings</li>
    <li><strong>Google Coral</strong> acceleration supported (optional)</li>
    <li>Exposes a <strong>local API</strong> for easy integration with Home Assistant</li>
    <li><strong>Fully configurable via add-on settings</strong></li>
</ul>

<h2>Installation</h2>
<ol>
    <li>Navigate to <strong>Settings → Add-ons</strong> in Home Assistant.</li>
    <li>Click on <strong>"Add-on Store"</strong> and select <strong>Repositories</strong>.</li>
    <li>Add this GitHub repository: <code>https://github.com/BertilJ/ha-addons/</code></li>
    <li>Install the <strong>Code Project AI</strong> add-on.</li>
    <li>Start the add-on and check the logs for any issues.</li>
</ol>

<h2>Configuration</h2>
<p>This add-on does not require complex setup. It runs <strong>locally</strong> on your Home Assistant OS. Persistent storage ensures your settings and models remain intact between reboots.</p>

<h2>API Usage</h2>
<p>The add-on exposes the AI API at <code>http://homeassistant.local:32168</code>.</p>

<h2>Persistent Storage</h2>
<ul>
    <li>AI models are stored in: <code>/data/models/</code></li>
    <li>Configuration files are stored in: <code>/data/config/</code></li>
    <li>Logs and temp files are stored in: <code>/data/logs/</code></li>
</ul>

<h2>Version Control</h2>
<p>This add-on is built using a <strong>fixed version of Code Project AI</strong>, controlled via the <code>Dockerfile</code>. If you need to update the version, modify the <code>AI_VERSION</code> variable in the <code>Dockerfile</code>.</p>

<h2>Changelog</h2>
<p>See <strong>changelog.txt</strong> for detailed updates.</p>

<h2>License</h2>
<p>See <strong>LICENSE</strong> for details on usage and distribution.</p>

<h2>Support & Contributions</h2>
<p>For issues or feature requests, please open an <strong>issue on GitHub</strong>.</p>

<hr>