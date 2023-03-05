# Status
|status|name|status| 
|--|--|--|
:white_check_mark:|Company portal view 
:white_check_mark:|Install
:black_square_button:|Uninstall
:black_square_button:|Auto-update | Zoom does not properly report version so winget incorrectly detects it

:white_check_mark: = Finished and tested
:black_square_button: = Finished 

# Description:
This is a package made for Zoom in intune.  
![Banner](./package/AppDeployToolkit/AppDeployToolkitBanner.png)

# Including: 
- Install (using winget)
- Uninstall
- Uploadscript for Intune


# How to use:
1.) Download the folder to your local system
1.) run the powershell script `"Upload to intune.ps1"`. 
It will install all the required modules and prompt you for the Tanent ID
1.) Input tanent ID (CompanyName.OnMicrosoft.com) and later a account with permission to administrate intune. 
1.) Input link to the desktop.

The script will create two deployments in intune
- Zoom
- Zoom (upgrader) <== Currently disabeld in upload script because of issues with winget. 

The first deployment "Zoom" is the deployment to assign to the users or devices that need to have Zoom installed.
The second deployment "Zoom (Updater)" makes sure that the application is always up to date. Assign this to the computers or users who need to be kept up-to-date as required.

## A Example deployment

Lets say: You want to make Zoom available to all members of IT and Marketing and keep them up to date but if someone else has already installed Zoom also make sure that they are also updated.

AAD group: AppGroup_ZoomZoom
Members: All_MarketingUsers, All_ITUsers

Zoom
Deployment: 
- Available: AppGroup_ZoomZoom
- Required : None

Zoom (Upgrader)
Deployment: 
- Available : None
- Required : All Users

With this setup the users of Marketing and IT can go to the company portal and install Zoom like they are used to and intune checks all users if Zoom is installed, and if it is installed but out of date updates Zoom for them.


# How does this look (admin side):
The Admin gets two new packaging in the portal.
![](./Configuration/Images/PreviewAdminView1.png)

These packages can be assigned to users or devices. 
The "Zoom" package should be assigned to the users that want to install the software (as available or required)
The "Zoom (Updater)" Should be assigned to the users or devices that need to be kept up to date as required.

The packages already have all needed information and configuration.

# How does this look (client side):
The user can install the software from the company portal. 
![](./Configuration/Images/PreviewIfUserHasCompanyPortal.png)

If the user has Zoom installed but it is out-of-date it will be updated. if the user is not using Zoom at that moment the update will happen without interupting the user.
If the user has Zoom active they will be prompted to close the application or defer the installation.  

![UserMsg1](./Configuration/Images/PreviewUserMsg1.png)

And while the installation is going on they will get a progress message  

![UserMsg1](./Configuration/Images/PreviewUserMsg2.png)

Then when the update is finished Zoom will automaticaly be restarted and the user can continue.
