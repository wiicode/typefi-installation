System requirements are published at https://www.typefi.com/support/typefi-administration/system-requirements/

Typefi Desktop consists of three installers which you can access via our FTP; folder is called "Typefi_Desktop".  Keep in mind version 8.2.0 will be placed in that folder shortly.
Typefi Desktop Server, which contains the Tomcat server and our application.
Typefi Writer, which contains the Microsoft Word add-on for Typefi and Typefi Print Manager.
Typefi Designer, which is the set of Plugins for Adobe InDesign. Please note that your system will need Adobe InDesign installed prior to installing our components unless you will not be using InDesign as part of your workflows (unlikely).
Typefi Desktop installation process is split into three major sections: installation, configuration, and deployment of plugins. This is also the most complex part of theinstallation.
INSTALLATION of Typefi Desktop Server, requires admin access.
Run the latest Typefi Desktop Server package. Unless necessary, I would encourage you to take all the defaults during the installation. Your IT will want to know what is being installed, so here is a short version:
We create some basic software folders and files in C:\Program Files (x86)\Typefi, including Java Runtime.
We then add a Typefi folder to C:\ProgramData which will store configuration and also majority of the Tomcat files. The default FileStore is also placed there.
After installation, Typefi Desktop Server (the executable) should launch automatically. Because this is a desktop application, this is not a Windows Service. Furthermore, it must run as an application because of the InDesign interactions.
Once the executable is started, you can visit http://localhost:8080 via browser, or from the icon on the desktop, and load the Typefi Desktop Server Console. It does not prompt for any authentication as it is the server.
INSTALLATION of Typefi Designer
be sure Adobe InDesign is already installed and functioning. Close the application.
Run the Typefi Designer package. Accept all defaults. Majority of the install simply places our InDesign components into the Plugins folder of Adobe InDesign.
INSTALLATION of Typefi Writer
The sure Microsoft Word 2013 or 2016 is installed, and that all Microsoft Updates are current. We specifically depend on Windows Common Controls (mscomctl.ocx) which has changed in recent updates.
Run the Typefi Writer installer.
Due to the nature of the install, I expect that one important file will be misplaced. We place a TypefiWriter.dotm file inside %APPDATA%\Roaming\Microsoft\Word\STARTUP, but I suspect that it will be missing. Actually, it will not be missing, rather placed inside the same folder but within the Administrator’s profile. It may require that your IT copy it to the user that will actually be using the software.
CONFIGURATION
Launch InDesign prior
Visit http://localhost:8080 from a web browser.
Click on the Admin tab
Although you may change a number of the settings here, the only one that is required is on the InDesign tab. You will need to add an entry for the local instance. Click add engine. The indesign server address is “localhost” if necessary.
ADVANCED CONFIGURATION
In addition to the downloads I’ve described above, you will also get several Typefi Server Plugins in the form of *.WAR files. They are installed via the Typefi Desktop Server UI.  You can use the same plugin WAR files you already have.
Access http://localhost:8080
Click on Actions
Click Add/Install Plugin, and browse to a WAR file we supplied. Wait a moment for it to install.
Repeat with remains WAR files.
Then, it’s also time to license the installation. I will email you a license which will be entered on the ADMIN > License tab. Our license process is split into two parts. You will obtain an installation ID from us, and then request a license key from the License tab. This second step will force a license key to be emailed to you. Licenses are issued for each system and are hardware specific.
