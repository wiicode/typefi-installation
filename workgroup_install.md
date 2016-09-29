#Typefi Workgroup Server Installation Example
This is an informal set of procedures which can be adapted for a specific installation environment.



##PREP

Download all required files (see list below).
Make internet access available to the server.  I noted where internet access is required.
Create a local administrator, with logon as service rights, to be used as the Service Account for Typefi and InDesign. See http://social.technet.microsoft.com/wiki/contents/articles/13436.windows-server-2012-how-to-add-an-account-to-a-local-administrator-group.aspx and https://technet.microsoft.com/en-us/library/cc739424(v=ws.10).aspx. This can be a domain account.
Install .NET 3.5 and 4.6. Both are typically available within Windows Features and Roles.  Be sure both are fully installed.
Disable UAC on the system (recommended).
Restart the system.
DOWNLOADS

Typefi Workgroup Server, latest available version from ftp.typefi.com.
Typefi Engine Plugins, latest available version from ftp.typefi.com.
Adobe InDesign Server & Latest Update, latest available version from ftp.typefi.com or from http://www.adobe.com/devnet/indesign/indesign-server-trial-downloads.html.
Adobe Provisioning Toolkit (APTEE), also available on Adobe's website and ftp.typefi.com
Deliverables (scripts, fonts, and other materials used for projects).
Client Software: Typefi Designer, Typefi Writer, Typefi Typefitter.
INSTALL - ABBREVIATED PROCEDURES

These procedures are designed to help system administrators quickly deploy a Typefi 8 Workgroup Server.  Please see Typefi's official documentation and guides for complete information about this process.

Adobe Server and Updates:  Extract the installation ZIP file to a location you can use in the future. Start setup.exe.

The Adobe Setup Wizard will ask you to select the installation type and also require an Adobe Sign-In.  You can create an account from the installer. This requires an internet connection. Adobe InDesign Server Trial installations will function for 60 days.

You may change the installation path, although that is not necessary. Although, accepting all defaults is sufficient, Typefi's suggested practices call for installing all components into a dedicated volume or folder.  This step depends on your internal policies.

Restart the instance after Adobe InDesign Server is installed.

Extract and run the latest Adobe InDesign Server Update.

Register the InDesign Server Management Console.  Launch Command Line as administrator. Using the command line, change directories all the way through the "Adobe InDesign CC Server 2015" folder that was installed.  Run this command:  "regsvr32 InDesignServerMMC64.dll" and verify it to be successful.  Leave the CMD window open, you will come back to it shortly.

From the same command line window, you can type "MMC" and launch the Windows Management Console.  Flick on File, Add/Remove Snap-In, and locate the InDesign Snap In.

Be sure the copyright is visible, as that tells you the previous step was successful. If Copyright is blank, something is wrong with the registration and you will likely require further support. If that happens, make a note but proceed with these steps anyways.

Once you open the InDesign Management Console create a service instance by left-clicking on the InDesignServer tree, then right-clicking in the blank window and choosing "New Service".  The service will immediately appear. Edit the properties to assign port 8470 to the service; this is the default port for the Typefi Engine Plugins.

This step is not entirely intuitive, but it is critical as it sets up the registry.

Go to the Windows Services Console, locate InDesignServerService and edit properties.  Change the startup from "Manual" to "Automatic".   Then, from the "Logon" tab, change the setting from "Local System" to the account you provisioned earlier.

Do not start the service.

Going back to the open Command Line window, type "InDesignServer.com" and press enter. This step requires internet connectivity. This will result in one of two behaviors:
It will start InDesign Server, this will be pretty obvious, as it will load plugins.  If this happens.  CTRL+C and start it again. Confirm it starts twice before moving on. Once again, CTRL+C to end it.  Skip Step 12.
It will throw an error and a Return Code, probably 14.  This means that the serialization for Trial you initiated failed to proceed as normal, and you will need to follow Step 10.

See above step to determine whether this is required.
Execute the Adobe Provisioning Toolkit installer, which is a self-extracting ZIP with only one executable within it.

Find the extracted folder, and consider moving the adobe_prtk.exe file from the long directory name right into the root of "C:\APTEE".

Using the CMD window (as administrator) CD over to C:\APTEE (or the correct path), and run this serialization command (this step requires internet connectivity). This step will vary for InDesignServer CS6, CC2014, and CC2015. The steps below assume CC2015:
adobe_prtk --tool=StartTrial --leid=V7{}InDesignServer-11-Win-GM
alternatively, if there are any issues, a slightly different variation is  adobe_prtk --tool=StartTrial --leid=InDesignServer-11-Win-GM
 In both cases, please be aware that there are two "-" before each parameter.  Formal serialization can be done at this stage or later.

Go back to Step 9.  Your result should be two consecutive starts.  If that does not happen, try the alternative serialization command. If you continue to experience issues, it's feasible internet access is preventing connections to Adobe's serialization systems and will require further intervention.

Run the Typefi Engine Plugins installer accepting all defaults; there is no need to change the installation path. This is a simple defaults only installation and is very quick.  Upon completion, please open the ".\Adobe InDesign CC2015 Server\Plug-Ins" folder and verify that a folder named "Typefi" was created.

Run the Typefi Workgroup Server installer. Although you may select all defaults, our suggested practice is to install to a dedicated volume or a designated app folder.  The contents of this package include Apache Tomcat and Typefi Server Console files.

Open the Windows Services Console, and stop the Typefi Workgroup Server service.  Change the "Logon As" settings to use the account you previously provisioned and used for InDesignServerService.

Reboot the server.

Once back up, verify the following two processes are running: InDesignServer.exe and InDesignServerService.exe.

Open firewall ports for port 8080 or any other ports you intend to use.

At this point, you have InDesign installed and patched, as well as Typefi Workgroup Server installed. Now it's time to provision key features:

Open your web browser and visit http://localhost:8080.  This should load a Typefi login page.  The password is "admin/admin".

Click on the Actions Tab and use the "Add Plugins" button to install the additional WAR files provided in your Deliverables.   You will have a few of them.

Each time you add a file, the process may take a moment, and will populate the new action on that screen with an auto-refresh. Do not cancel or manually refresh the page.

If you do not see the files uploading, this means a local security setting is affecting the system.  As a temporary work around you may locate the Typefi installation folder, click on .\Typefi\Server\webapps and paste all the WAR files into that folder. You will see them self-extract within a few moments. If this happens, make a note of the issue so it can be resolved.

Click on the Admin Tab and review the FileStore.  At this point, I would not make any changes, but note that the FileStore is C:\ProgramData\Typefi\FileStore.  You can change the location or leave it as is.  If a change is made, be sure the directory exists and has FULL RIGHTS by the service account.

This can be easily moved later by simply stopping the Typefi services, moving the directory, resetting security, and updating the path.

Click on the LDAP tab.  If you choose to use your directory services, this is the opportunity to configure it.  There are many ways to configure LDAP and some basic LDAP search query syntax knowledge is required.  I am providing a very common example here:

Server URL: ldap://yourservername.YourDomain.YourSuffix

Username:  userwithdelegatedrightstodirectory

Password:  password

Search Base: OU=Users,DC=YourDomain,DC=YourSuffix.

Search Filter can be left as-is, or changed.  In this example we use the "OR" logic to allow users from two groups:

(|(memberOf=CN=Typefi-Users-Group1,OU=Typefi Groups,DC=YourDomain,DC=YourSuffix)(memberOf=CN=Typefi-Users-Group2,OU=Typefi Groups,DC=YourDomain,DC=YourSuffix))

username attribute:  userPrincipalName.  You will find "samAccountName" being most often the typical field, while sometimes "mail" is preferred.

Display Name: cn

Idle Session Time Out: leave blank unless you require advanced security.

Save

One important note about this feature.  Typefi inherently blocks passwords with "<" or ">" or "&" due to internal security features. If your users have those characters inside their passwords, they will not be able to login.

Click on the InDesign tab.  Configure the engine.  Sample configuration is:
Name: CC2015
Host: 127.0.0.1 or localhost
Port 8470
Save and then click the refresh. You should see PDF Presets load.

Super User: change the password if required.

License.  The account technical contact will have your Installation Code.  Once you enter it in, you must click on "Request License" and await a second email. The second email will contain the license key.

Restart the server once more, or at least restart the services.
