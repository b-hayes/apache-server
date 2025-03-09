<?php

echo "<h1>Welcome</h1>";
echo exec('whoami');
echo "<pre>";

// Execute Docker command to list containers
$output = shell_exec('echo "can yous ee this?" 2>&1');
echo "<pre>$output</pre>"; // works

// Execute Docker command to list containers
$output = shell_exec('docker ps --format "{{.ID}}: {{.Names}}" 2>&1');

echo "<pre>$output</pre>"; // show permission error