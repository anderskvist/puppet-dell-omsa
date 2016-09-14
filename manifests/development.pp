class dellomsa::development (
) {
  if ($dellomsa::development) {
    file_line { 'Let us start Dell dataeng even tough it\' not a Dell system':
      path => '/opt/dell/srvadmin/sbin/CheckSystemType',
      line => 'NON_DELL=0',
      match   => "^NON_DELL=.*$",
    }
  }
}
