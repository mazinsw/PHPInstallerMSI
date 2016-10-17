<?php
require_once "common.php";

$nts = trim($argv[1]) != '';
$version = $argv[2];
$platform = $argv[3];

$cmds = array();

$values = array('ts' => '', 'nts' => '');
if($nts)
	$values['nts'] = 'nts';
else
	$values['ts'] = 'ts';
$cmds[] = array('callback' => false, 'search' => '/\[ts\/\]/', 'replace' => $values['ts']);
$cmds[] = array('callback' => false, 'search' => '/\[nts\/\]/', 'replace' => $values['nts']);

$values = array('ts' => '', 'nts' => '');
if($nts)
	$values['nts'] = '$1';
else
	$values['ts'] = '$1';
$cmds[] = array('callback' => false, 'search' => '/\[ts\]\n?(.*?)\[\/ts\]\n?/s', 'replace' => $values['ts']);
$cmds[] = array('callback' => false, 'search' => '/\[nts\]\n?(.*?)\[\/nts\]\n?/s', 'replace' => $values['nts']);
$vercmp_regex = '/\[(lt|le|gt|ge|eq|ne)\(([0-9\.]+)\)\]\n?((?:[^\[]|\[(?!\/?(:?lt|le|gt|ge|eq|ne|end)(:?\([0-9\.]+\))?])|(?R))+)\[\/end\]\n?/s';
function vercmp_cb($matches) {
	global $version;
	global $vercmp_regex;

	$cmp = $matches[1];
	$inpver = $matches[2];
	$content = $matches[3];
	$input = '';
	if(version_compare($version, $inpver, $cmp))
		$input = $content;
    return preg_replace_callback($vercmp_regex, 'vercmp_cb', $input);
}
$cmds[] = array('callback' => true, 'search' => $vercmp_regex, 'replace' => 'vercmp_cb');

$files = array(
	'ExtensionsFeaturesBuild.wxs',
	'ExtensionsComponentsBuild.wxs',
	'PHPInstallerCommonBuild.wxs',
	'PHPInstallerBuild.wxs',
	'WebServerConfigBuild.wxs',
	'WixUI_en-us_Build.wxl',
);
foreach ($files as $name) {
	$content = file_get_contents($name);
	foreach ($cmds as $prop) {
		if($prop['callback'])
	    	$content = preg_replace_callback($prop['search'], $prop['replace'], $content);
	    else
			$content = preg_replace($prop['search'], $prop['replace'], $content);
	}
	file_put_contents($name, $content);
}
