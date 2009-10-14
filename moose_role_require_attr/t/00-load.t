#!perl

use strict;
use warnings;
use Test::More;

use_ok('MyModuleOk');
use_ok('MyModuleAlsoOk');
TODO: {
  local $TODO = 'with() can satisfy requires() from attr() in previous roles';
  use_ok('MyModuleFail');
}

done_testing();
