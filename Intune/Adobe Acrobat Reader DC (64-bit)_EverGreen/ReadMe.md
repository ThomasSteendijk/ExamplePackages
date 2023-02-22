# Status
|status|name|
|--|--|
:white_check_mark:|Company portal view 
:white_check_mark:|Install
:white_check_mark:|Uninstall
:white_check_mark:|Auto-update

:white_check_mark: = Finished and tested
:black_square_button: = Finished 


# Description:
This is a package made for Adobe Acrobat Reader DC (64-bit) in intune.  
![Banner](./package/AppDeployToolkit/AppDeployToolkitBanner.png)

# Including: 
- Install (using winget)
- Uninstall
- configuration
- Uploadscript for Intune

# How to use:
Download the folder to your local system and run the powershell script `"Upload to intune.ps1"`. 
It will install all the required modules and prompt you for the tanent ID (CompanyName.OnMicrosoft.com) and later a account with permission to administrate intune. 

The script will create two deployments in intune
- Adobe Acrobat Reader DC (64-bit)
- Adobe Acrobat Reader DC (64-bit) (upgrader)

The first deployment "Adobe Acrobat Reader DC (64-bit)" is the deployment to assign to the users or devices that need to have Adobe Acrobat Reader DC (64-bit) installed.
The second deployment "Adobe Acrobat Reader DC (64-bit) (Updater)" makes sure that the application is always up to date. Assign this to the computers or users who need to be kept up-to-date as required.

# Configuration
This package includes two configurations:  
- EULA has been accepted and (both system and user key have been placed). this so the user does not get a popup and that the build in autoupdater works as expected.  
- PDF is set to open with Adobe Acrobat Reader using SetUserFTA.exe.  

## A Example deployment
Lets say: You want to make Adobe Acrobat Reader DC (64-bit) available to all members of IT and Marketing and keep them up to date but if someone else has already installed Teams also make sure that they are also updated.

AAD group: AppGroup_AdobeAcrobatReaderDC(64-bit)
Members: All_MarketingUsers, All_ITUsers

Adobe Acrobat Reader DC (64-bit)
Deployment: 
- Available: AppGroup_AdobeAcrobatReaderDC(64-bit)
- Required : None

Adobe Acrobat Reader DC (64-bit) (Upgrader)
Deployment: 
- Available : None
- Required : All Users

With this setup the users of Marketing and IT can go to the company portal and install teams like they are used to and intune checks all users if teams is installed, and if it is installed but out of date updates teams for them.


# How does this look (admin side):
The Admin gets two new packaging in the portal.  
![AdminPortal](./Configuration/Images/AdminPortal_Preview.png)

These packages can be assigned to users or devices. 
The "Adobe Acrobat Reader DC (64-bit)" package should be assigned to the users that want to install the software (as available or required)
The "Adobe Acrobat Reader DC (64-bit) (Updater)" Should be assigned to the users or devices that need to be kept up to date as required.

The packages already have all needed information and configuration.

# How does this look (client side):
The user can install the software from the company portal.  
![Companyportal](./Configuration/Images/CompanyPortal_Preview.png)

If the user has teams installed but it is out-of-date it will be updated. if the user is not using teams at that moment the update will happen without interupting the user.
If the user has teams active they will be prompted to close the application or defer the installation.  

![UserMsg1](./Configuration/Images/UserMsg_Preview1.png)

And while the installation is going on they will get a progress message  

![UserMsg2](./Configuration/Images/UserMsg_Preview2.png)

Then when the update is finished teams will automaticaly be restarted and the user can continue.