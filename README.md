## PHP Installer MSI
###### A MSI package for installing non-thread-safe build of PHP

Fork of https://sourceforge.net/projects/phpinstallermsi/

### Pre-requisites:

- .NET Framework 1.1 SP1 Runtime installed
- PHP Windows zip binary distribution
- The pre-compiled PECL extensions for Windows from http://pecl4win.php.net/branch.php
- Copy of PHP Manual in CHM format.
- Local Checked out copy of this directory

### Building

1) Unzip the PHP Windows zip binary distribution into the "Files/x86" or "Files/x64" directory.
2) Unzip the PECL extensions zip file for the branch into the "Files/[Platform]/pecl" directory.
3) Copy PHP Manual CHM File into the "Files/[Platform]" directory.
4) Run the "build.bat" script with the first arguement as the platform you are building for.

### Example:
```build.bat "x64"``` when building for PHP 64 bit, default: x86

The script will produce the installer as php-VERSION-Win32-REDIST-PLATFORM.msi where VERSION is the version of PHP scaned from Files folder, REDIST is the Visual C++ redistributable package required for run PHP and PLATFORM is the platform to create the installer passed to the build.bat script.

### License

Please see the [license file](/LICENSE.txt) for more information.