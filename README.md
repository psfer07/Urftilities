# Urftilities

A set of Windows optimizations oriented to improve security and performance, at the same time that it enhances privacy. A shorter link to the repository is available at: [**bit.ly**](https://bit.ly/urftilities).

Index
-----

* [Important](#important)
* [About the program](#about-the-program)
* [Ways to get this program via commands](#ways-to-get-this-program-via-commands)
* [Usage](#usage)
* [Full features](#full-features)
* [Ordinary features](#ordinary-features)
* [Credits](#credits)

# Important

This proyect is modifiable and you can remove or add scripts as you want. For example: by default, Urftilities removes Microsoft Edge. You can browse the script file that does that inside the `.\badWindows` folder.

For compatibility reasons, all the scripts provided by the original package of Urftilities are meant to be run with administrator privileges.

**Remember having your execution policy capable of executing non-signed scripts!!**

# About the program

Operating systems are constantly evolving, and Windows is not an exception. But with the development of new technologies, the ones that we know and the ones that we don't, our systems are getting much more inflated with charasteristics and applications that we actually never use. That bloating is like a double-edged weapon, because it promisses lots of new features as it slowly worsens our computers' performance.

This proyect is oriented to improve the performance of any Windows system at the same time as disabling the 99.9% of telemetry and enhancing privacy.

Note: you don't need to neccessarily remove the scripts that you don't want to apply. You can simply rename their extensions to any other that doesn't contain  `.ps1` on it.

## Ways to get this program via commands

You can get the scripts folder via command line by two ways:

* Optimal way:

  - Press the keys `Win + R` on your computer and paste the following command on the box that appears:
    ```batch
    powershell -c irm bit.ly/urfdeploy | cmd
    ```
* Terminal way:

  - Open a powershell window on your computer and introduce the following command:
    ```powershell
    irm bit.ly/urfdeploy | cmd
    ```

This will pop up in your desktop a command prompt window that will give you some help to launch Urftilities.
Alternatively from using the command line, you can get Urftilities from [releases](https://github.com/psfer07/Urftilities/releases).

# Usage

This program has two modes for execution with multiple parameters to customize its execution on your system.

* The first mode will simply run the scripts located in the script, which will remove all residual files from your system. This mode is meant for periodical optimization because it just maintains the system fresh. **It does not apply any kind of configuration on the device**.
* The second one, which can be called by running the main `Urftweaks.ps1` script with the `-full` parameter, or with its alias: `-f`. This will apply all the optimizations from the package folders, including the set of configurations made by the `OOSU10.exe` executable. After all the processes have finished, the program will ask for a reboot to finish applying everything, if not specified with the `-restart` parameter or with its alias: `-r`, giving way to a new optimized version of your Windows operating system.
* Additionally you can run Urftilities using the `-silent` parameter, or its alias `-s`. With this option, the program will apply all the selected configurations as the common sense indicates, while been able to use you system without any interruption, unless you chose to restart the pc, in that case the program won't ask for a reboot and will only decide whether reboot or not if the user used `-restart`. This parameter can't be used in normal mode

After executing Urftilities, two things can happen, depending on which mode have you run, it will simply close itself after it finished, when running it normally, or it will restart automatically the computer without any user confirmation it runs with the `-full` parameter. In that case, it is not recommended to run any task until the system has rebooted successfuly.

# Full features

This mode aims to solve different problems within Windows, which are divided in four categories: removing unneccessary packages, removing telemetry, removing residual files all over the system and optimize its performance. A more detailed list of the features that Urftilities has are shown below:

* **Remove preinstalled Windows apps**, such as Windows maps, New York Times app, Candy Crush... and prevents all those from reinstalling automatically (the user can install them whenever manually).
* **Remove Microsoft Edge**: as you probably don't use it as you main browser, just for opening PDFs, and its associated telemetry (that is a lot).
* **Remove OneDrive**: as many people don't actually use it actively and prevents from installing automatically (still, the user can install it manually if wanted).
* **Remove Microsoft Teams**: as the majority of users never communicate with others through this, this app is always loading at startup, consuming unneccessary resources and collecting data.
* **Applies Windows UI optimizations**: Disables some anoying features that Windows Explorer has and tweaks some aspects from the mouse.
* **Optimize network**: Optimize how the system sends and receives packages from the internet and optimizes cache management.
* **Optimize services**: Changes the startup mode for all non-essential services in Windows to prevent the system loading them everytime. Instead, the services only load when they need. Also disables some
  expendable services such as the fax service.
* **Apply tweaks on the system**: Optimizes the `svchost.exe` file usage of memory and reduces timings when killing apps. Also ***disables power throttling***, so be aware of that if you are using a laptop!!
* **Optimizes timer resolution**: This is an advanced configuration that let games and high-demanding applications to run with much better performance.
* **Optimize updates**: Creates some rules on the Windows Update policies that prevents it to download anything that aren't actual updates (drivers, 3rd-party software) and delays some days the arrival of updates for security and stability reasons.
* **Repair system**: Seeks in the filesystem for any corrupted system file and repairs it.
* **Disables scheduled tasks**: Disables tasks related to telemetry and data sharing.
* **Optimize privacy**: Disables 99.9% of Windows telemetry and not also from the actual system, but from Microsoft Office and from apps like Google Chrome, Microsoft Edge or Mozilla Firefox (if installed).
* **Disables Microsoft Copilot**: Disables the well-known copilot and its new features like **Copilot+PC**, which is only present on Windows 11 machines.

# Ordinary features

Even if you don't want or you don't trust what this program is doing to your system, there still is a way in which Urftilities can be useful: on cleaning unused files on the system, which can still give your desktop a boost on games or in any other application. This option only execute the scripts located in the junks folder, and it runs, when using or not, the parameter `-full` when running Uftilities. Below, there is a breakdown of what this is doing:

* **Clean temporary files**: Deletes all the system temporary files, the Windows Update cache, the Windows Explorer history with the help of the builtin Microsoft tool `cleanmgr.exe`. Also erases the network cache and reflushes the DNS.

# Credits

This couldn't be possible without some third-party tools or scripts from these people:

- [WinUtil from ChrisTitusTech](https://github.com/ChrisTitusTech/winutil) - for his conversion of Edge Removal script from AveYo and the services list
- [Debloat Windows 10 by W4RH4WK](https://github.com/W4RH4WK/Debloat-Windows-10) - for the `remove-onedrive.ps1` original script
- [Win Debloat Tools by LeDragoX](https://github.com/LeDragoX/Win-Debloat-Tools) - for the `disable-scheduled-tasks.ps1` original file
- [ShutUp 10 ++ by O&amp;O software](https://www.oo-software.com/en/shutup10) - for the program itself
- [UninstallTeams from asheroto](https://github.com/asheroto/UninstallTeams) - for the original file of `remove-teams.ps1`
