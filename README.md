# azure-tm-monitor
To use azure-tm-monitor you must first add your client, subscription, resource group, and traffic manager profile information to the azure-tm-config.json config file. You also need to change some of the parameters at the bottom of the script to allow you to monitor a certain endpoint and set a priority endpoint.

If you want to recieve email alerts, you will need to add the SMTP server and mail addresses that you would like to send to. Alerts are handled by the New-TrafficMonitorStatusReport cmdlet.
