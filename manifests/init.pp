# == Class: dellomsa
#
# This module will install Dell OMSA and configure it with
# SSL certificates and a sane and secure configuration.
#
# === Parameters
#
# [*keystore_password*]
#   Just a random generated password - you will never need to type it
#
# [*ssl_certificate*]
#   path to a ssl certificate
#
# [*ssl_chain*]
#   path to a ssl chain
#
# [*ssl_private_key*]
#   path to a ssl private key
#
# === Examples
#
#  class { dellomsa:
#    keystore_password => '<RANDOM PASSWORD>',
#    ssl_certificate => '/etc/ssl/private/omsa.host.tld.crt',
#    ssl_chain => '/etc/ssl/private/omsa.host.tld.inter',
#    ssl_private_key => '/etc/ssl/private/omsa.host.tld.key',
#  }
#
# === Authors
#
# Author Name <ak@cego.dk>
#
# === Copyright
#
# Copyright 2016 Anders Kvist <ak@cego.dk>
#
class dellomsa (
  $keystore_password,
  $ssl_certificate,
  $ssl_chain,
  $ssl_private_key,

  $development = false,
  
) inherits dellomsa::params {

  apt::source { 'omsa':
    location => 'http://linux.dell.com/repo/community/ubuntu',
    repos => 'openmanage',
    key => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
    key_server => 'pool.sks-keyservers.net',
  }
  ->
  apt::pin { 'srvadmin':
    packages => 'srvadmin-*',
    priority => '1001',
    version => '7.4.*',
  }
  ->
  package { 'srvadmin-all':
    ensure => 'installed',
    require => Class['apt::update'],
  }
  ->
  class { 'dellomsa::development': }
  ->
  service { ['dataeng','dsm_om_connsvc']:
    ensure => 'running',
    enable => 'true',
  }

  file { "${serverxml_path}":
    content => template('dellomsa/server.xml.erb'),
    notify => Service['dsm_om_connsvc'],
    require => Package['srvadmin-all'],
  }
  ->
  exec { 'Remove OMSA keystore if we cannot login':
    command => "/bin/rm -f ${keystore_path}",
    unless => "/usr/bin/keytool -list -keystore ${keystore_path} -storepass ${keystore_password}",
  }
  ->
  java_ks { 'dell':
    ensure      => "present",
    certificate => $ssl_certificate,
    chain       => $ssl_chain,
    private_key => $ssl_private_key,
    password    => $keystore_password,
    target      => $keystore_path,
    notify      => Service['dsm_om_connsvc'],
  }
}
