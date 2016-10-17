<?php
require_once "common.php";

$basefile = $argv[1];
$version = $argv[2];
$vcver = $argv[3];
$distver = $argv[4];

$PHPInstallerBaseWXS = new DOMDocument;
$PHPInstallerBaseWXS->preserveWhiteSpace = false;
$PHPInstallerBaseWXS->load($basefile);
$PHPInstallerBaseWXS->formatOutput = true;

// Update the Package info to be specific for this build
$PHPInstallerBaseWXS->getElementsByTagName('Product')->item(0)->setAttribute("Name", "PHP $version");
$PHPInstallerBaseWXS->getElementsByTagName('Product')->item(0)->setAttribute("Version", "$version");
$PHPInstallerBaseWXS->getElementsByTagName('Product')->item(0)->setAttribute("Id", genGUID());
$PHPInstallerBaseWXS->getElementsByTagName('Package')->item(0)->setAttribute("Description", "PHP $version Installer");
$instver = 300;
if($vcver == '11')
	$instver = 405;
$PHPInstallerBaseWXS->getElementsByTagName('Package')->item(0)->setAttribute('InstallerVersion', "$instver");
$tags = $PHPInstallerBaseWXS->getElementsByTagName('Registry');
$i = 0;
while ( $i < $tags->length ) {
	if ( $tags->item($i)->getAttribute('Id') == 'PHPRegistryVersion' ) {
		$tags->item($i)->setAttribute("Value","$version");
		break;
	}
	$i++;
}

// Add in the VCX MSM if we are building that installer
if ( !empty($vcver) ) {
	$TargetDir = $PHPInstallerBaseWXS->getElementsByTagName('Directory')->item(0);
	$Merge = $PHPInstallerBaseWXS->createElement('Merge');
	$Merge = $TargetDir->appendChild($Merge);
	$Merge->setAttribute('Id','VCRedist');
	$Merge->setAttribute('SourceFile',"Modules/Microsoft_VC{$vcver}0_CRT_{$distver}.msm");
	$Merge->setAttribute('DiskId','1');
	$Merge->setAttribute('Language','0');
	
	$MainFeature = $PHPInstallerBaseWXS->getElementsByTagName('Feature')->item(0);
	$MergeRef = $PHPInstallerBaseWXS->createElement('MergeRef');
	$MergeRef = $MainFeature->appendChild($MergeRef);
	$MergeRef->setAttribute('Id','VCRedist');
}

// remove extension info from php.ini-production
if ( is_file("Files/{$distver}/php.ini-production") )
	$infile = fopen("Files/{$distver}/php.ini-production",'r');
else
	$infile = fopen("Files/{$distver}/php.ini-recommended",'r');
$outfile = fopen("Files/{$distver}/php.ini",'w');
if (!$outfile || !$infile) {
	echo "Cannot open php.ini or php.ini-production\n";
	exit(1);
}
while (!feof($infile)) {
	$buffer = fgets($infile);
	if ( stristr($buffer,';extension') === FALSE ) {
		fwrite($outfile,$buffer);
	}
}
fclose($infile);
fclose($outfile);

// check for presence of certain file; if not there then remove the feature from the installer
$files = array(
	'readme-redist-bins.txt' => 'readmedistbinsTXT',
);

foreach ( $files as $filename => $component ) {
	if ( !file_exists("Files/{$distver}/$filename") ) {
		$Components = $PHPInstallerBaseWXS->getElementsByTagName('Component');
		foreach ( $Components as $Component ) {
			if ( $Component->getAttribute('Id') == $component ) {
				$Component->parentNode->removeChild($Component);
				break;
			}
		}
		$ComponentRefs = $PHPInstallerBaseWXS->getElementsByTagName('ComponentRef');
		foreach ( $ComponentRefs as $ComponentRef ) {
			if ( $ComponentRef->getAttribute('Id') == $component ) {
				$ComponentRef->parentNode->removeChild($ComponentRef);
				break;
			}
		}
	}
}

$PHPInstallerBaseWXS->save($basefile);

exit;