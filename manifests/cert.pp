# = Define: docker::cert
#
# Install client certificates for docker to be able to connect to a private registry.
#
# === Parameters
#
# [*title*]
#   The full URL of the registry _including the port number_!
#
# [*ca_cert_target*]
#   The file path to the ca cert (will be symlinked to)
#   'ca_cert_content'  and 'ca_cert_target' are mutually exclusive.
#
# [*ca_cert_content*]
#   The file content to the ca cert (real file is created)
#   If set, 'ca_cert_content' cancels 'ca_cert_target' and the symlink is not created.
#
# [*client_cert_target*]
#   The file path to the client cert (will be symlinked to)
#   'client_cert_content'  and 'client_cert_target' are mutually exclusive.
#
# [*client_cert_content*]
#   The file content to the client cert (real file is created)
#   If set, 'client_cert_content' cancels 'client_cert_target' and the symlink is not created.
#
# [*client_key_target*]
#   The file path to the client key (will be symlinked to)
#   'client_key_content'  and 'client_key_target' are mutually exclusive.
#
# [*client_key_content*]
#   The file content to the client key (real file is created)
#   If set, 'client_key_content' cancels 'client_key_target' and the symlink is not created.

#
# === Examples
#
#  docker::cert { 'quay.io':
#    ca_cert_target     => '/etc/tls/quay.io/ca.crt',
#    client_cert_target => '/etc/tls/quay.io/client.cert',
#    client_key_target  => '/etc/tls/quay.io/client.key',
#  }
#
#
#  docker::cert { 'quay.io':
#    ca_cert_content     => '--- BEGIN CERTIFICATE --- ...',
#    client_cert_content => '--- BEGIN CERTIFICATE --- ...',
#    client_key_content  => '--- BEGIN PRIVATE KEY --- ...',
#  }
#
define docker::cert(
  $ca_cert_target      = undef,
  $ca_cert_content     = undef,
  $client_cert_target  = undef,
  $client_cert_content = undef,
  $client_key_target   = undef,
  $client_key_content  = undef
) {
  validate_string($title, $ca_cert_target, $client_cert_target, $client_key_target, $ca_cert_content, $client_key_content, $client_key_content )

  include ::docker

  $registry_cert_path   = "/etc/docker/certs.d/${title}"
  $registry_ca_cert     = "${registry_cert_path}/ca.crt"
  $registry_client_cert = "${registry_cert_path}/client.cert"
  $registry_client_key  = "${registry_cert_path}/client.key"

  file { $registry_cert_path :
    ensure => directory,
    path   => $registry_cert_path,
    mode   => '0400',
    owner  => root,
    group  => root,
  }

  if $ca_cert_content {
    file { $registry_ca_cert :
      ensure  => file,
      content => $ca_cert_content,
      mode    => '0400',
      owner   => root,
      group   => root,
      require => File[$registry_cert_path],
      notify  => Service['docker'],
    }
  } else {
    file { $registry_ca_cert :
      ensure => link,
      target => $ca_cert_target,
      mode   => '0400',
      owner  => root,
      group  => root,
      require => File[$registry_cert_path],
      notify  => Service['docker'],
    }
  }

  if $client_cert_content {
    file { $registry_client_cert :
      ensure  => file,
      content => $client_cert_content,
      mode    => '0400',
      owner   => root,
      group   => root,
      require => File[$registry_cert_path],
      notify  => Service['docker'],
    }
  } else {
    file { $registry_client_cert :
      ensure => link,
      target => $client_cert_target,
      mode   => '0400',
      owner  => root,
      group  => root,
      require => File[$registry_cert_path],
      notify  => Service['docker'],
    }
  }

  if $client_key_content {
    file { $registry_client_key :
      ensure  => file,
      content => $client_key_content,
      mode    => '0400',
      owner   => root,
      group   => root,
      require => File[$registry_cert_path],
      notify  => Service['docker'],
    }
  } else {
    file { $registry_client_key :
      ensure => link,
      target => $client_key_target,
      mode   => '0400',
      owner  => root,
      group  => root,
      require => File[$registry_cert_path],
      notify  => Service['docker'],
    }
  }

}
