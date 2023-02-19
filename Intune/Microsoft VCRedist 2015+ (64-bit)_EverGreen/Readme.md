# Description:
This is a package made for Microsoft Visual C++ 2015-2022 Redistributable (x64)in intune.
This package is been made available because its a pre-requiside for using winget under the system context. 

# Including: 
- Install (downloading the latest version and then using winget)
- Uninstall
- Configuration
- Uploadscript for Intune


# How to use:
Download the folder to your local system and run the powershell script "Upload to intune.ps1". 
It will install all the required modules and prompt you for the tanent ID (CompanyName.OnMicrosoft.com) and later a account with permission to administrate intune. 

The script will create two deployments in intune
- Microsoft VCredist 2015+ (64-bit)
- Microsoft VCredist 2015+ (64-bit) (upgrader)

The first deployment "Microsoft VCredist 2015+ (64-bit)" is the deployment to assign to the users or devices that need to have Microsoft VCredist 2015+ (64-bit) installed.
The second deployment "Microsoft VCredist 2015+ (64-bit) (Updater)" makes sure that the application is always up to date. Assign this to the computers or users who need to be kept up-to-date as required.

## A Example deployment

Lets say: You want to make Microsoft VCredist 2015+ (64-bit) available to all members of IT and Marketing and keep them up to date but if someone else has already installed Microsoft VCredist 2015+ (64-bit) also make sure that they are also updated.

AAD group: AppGroup_MicrosoftVCredist2015+(64-bit)
Members: All_MarketingUsers, All_ITUsers

Microsoft VCredist 2015+ (64-bit)
Deployment: 
- Available: AppGroup_MicrosoftTeams
- Required : None

Microsoft VCredist 2015+ (64-bit) (Upgrader)
Deployment: 
- Available : None
- Required : All Users

With this setup the users of Marketing and IT can go to the company portal and install teams like they are used to and intune checks all users if teams is installed, and if it is installed but out of date updates teams for them.


# How does this look (admin side):
The Admin gets two new packaging in the portal.
![](./Configuration/Images/Admin_Preview1.png.png)

These packages can be assigned to users or devices. 
The "Microsoft VCredist 2015+ (64-bit)" package should be assigned to the users that want to install the software (as available or required)
The "Microsoft VCredist 2015+ (64-bit) (Updater)" Should be assigned to the users or devices that need to be kept up to date as required.

The packages already have all needed information and configuration.

# How does this look (client side):
The user can install the software from the company portal. 
![](./Configuration/Images/User_Preview1.png.png)

If the user has teams installed but it is out-of-date it will be updated. 

